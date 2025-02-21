"""
    struct Operation

Represents a QASM operation with `operation` name and `args` arguments.
"""
struct Operation
    operation::String
    args::Vector{Int}
end

"""
    normalize_line(line::String) -> String

Normalize spaces and remove extra spaces around brackets in the given `line`.
"""
function normalize_line(line::String)
    # Normalize spaces around commas
    line = replace(line, r"\s*,\s*" => ",")
    # Normalize spaces around semicolons
    line = replace(line, r"\s*;\s*" => ";")
    # Remove any extra spaces around brackets
    line = replace(line, r"\s*\[\s*" => "[")
    line = replace(line, r"\s*\]\s*" => "]")
    # Remove leading/trailing spaces
    return strip(line)
end

"""
    tokenize(file_path::String) -> Vector{String}

Read the QASM file at `file_path` and return a vector of tokens.
"""
function tokenize(file_path::String)
    lines = readlines(file_path)
    tokens = String[]
    for line in lines
        # Remove comments and whitespace
        line = normalize_line(line)
        line = replace(line, r"//.*" => "") |> strip
        if !isempty(line)
            # Split into tokens by space and semicolon
            append!(tokens, split(line, r"[\s;]+", keepempty=false))
        end
    end
    return tokens
end

"""
    _parse_qasm(tokens::Vector{String}) -> Vector{Operation}

Parse the QASM tokens into a vector of `Operation` objects.
"""
function _parse_qasm(tokens::Vector{String})
    instructions = Operation[]
    i = 1
    while i <= length(tokens)
        token = tokens[i]

        if token == "OPENQASM"
            @assert tokens[i + 1] == "2.0" "Unsupported QASM version"
            i += 2  # Skip "OPENQASM" and "2.0"

        elseif token == "include"
            @assert tokens[i + 1] == "\"qelib1.inc\"" "Unsupported include"
            i += 2  # Skip "include" and the library

        elseif token == "qreg" || token == "creg"
            size = match(r"([a-zA-Z_]+)\[(\d+)\]", tokens[i + 1]).captures[2] |> x -> parse.(Int, x)
            push!(instructions, Operation(token, [size]))
            i += 2

        elseif token in ["h", "x", "t", "tdg"]
            qubit = match(r"q\[(\d+)\]", tokens[i + 1]).captures[1] |> x -> parse.(Int, x) .+ 1
            push!(instructions, Operation(token, [qubit]))
            i += 2

        elseif token == "cx"
            control, target = match(r"q\[(\d+)\],q\[(\d+)\]", tokens[i + 1]).captures |> x -> parse.(Int, x) .+ 1
            push!(instructions, Operation(token, [control, target]))
            i += 2
        elseif token == "measure"
            println(i)
            qubit, classical = match(r"q\[(\d+)\]->c\[(\d+)\]", tokens[i + 1] * tokens[i + 2] * tokens[i + 3]).captures
            qubit = parse(Int, qubit) + 1
            classical = parse(Int, classical) + 1
            push!(instructions, Operation(token, [qubit, classical]))
            i += 4
        else
            error("Unexpected token: $token")
        end
    end
    return instructions
end

"""
    parse_qasm(qasm_path::String) -> Vector{Operation}

Parse the QASM file at `qasm_path` and return a vector of `Operation` objects.
"""
function parse_qasm(qasm_path::String)
    tokens = tokenize(qasm_path)
    return _parse_qasm(tokens)
end