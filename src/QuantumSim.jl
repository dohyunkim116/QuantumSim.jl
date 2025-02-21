module QuantumSim

using LinearAlgebra
export QSim, WeightedKet, State, x!, t!, tdg!, cx!, h!, execute!, tokenize, parse_qasm, _parse_qasm

include("parser.jl")
include("utils.jl")

"""
    struct WeightedKet{T <: Complex}

Represents a weighted quantum state (ket) with amplitude `amp` and bit array `ket`.
"""
struct WeightedKet{T <: Complex}
	amp::Vector{T} # amplitude
	ket::BitArray # |x>
end

"""
    WeightedKet(n::Int, amp::Complex = 1.0 + 0.0im, ket::BitArray = falses(n)) -> WeightedKet

Create a new `WeightedKet` with `n` qubits, optional amplitude `amp`, and optional bit array `ket`.
"""
function WeightedKet(
	n::Int,
	amp::Complex = 1.0 + 0.0im,
	ket::BitArray = falses(n),
)
	@assert length(ket) == n
	return WeightedKet([amp], ket)
end

"""
    struct State{T <: Complex, TT <: BitArray}

Represents the quantum state with `n` qubits, amplitudes `amps`, and kets `kets`.
"""
struct State{T <: Complex, TT <: BitArray}
	n::Int
	amps::Vector{T}
	kets::Vector{TT}
end

"""
    State(n::Int, wks::Vector{WeightedKet{T}}=WeightedKet{ComplexF64}[]) -> State

Create a new `State` with `n` qubits and optional weighted kets `wks`.
"""
function State(n::Int, wks::Vector{WeightedKet{T}}=WeightedKet{ComplexF64}[]) where T <: Complex
    if isempty(wks)
        return State(n, zeros(T, 2^n), Vector{BitArray}(undef, 2^n))
    end
	@assert all(length(wk.ket) == n for wk in wks)
	"All WeightedKet objects must have the same n number of qubits."
	amps = zeros(T, 2^n)
	kets = Vector{BitArray}(undef, 2^n)
	for wk in wks
		idx = bitarray_to_index(wk.ket)
		amps[idx] = wk.amp[1]
		kets[idx] = wk.ket
	end
	return State(n, amps, kets)
end

"""
    struct QSim{T <: Complex}

Represents a quantum simulator with `n` qubits, `m` classical bits, QASM operations `ops`, and quantum state `s`.
"""
struct QSim{T <: Complex}
	n::Int # number of qubits
	m::Int # number of classical bits
	ops::Vector{Operation} # QASM operations
    s::State{T} # quantum state
end

"""
    QSim(qasm_path::String) -> QSim

Create a new `QSim` instance by parsing the QASM file at `qasm_path`.
"""
function QSim(qasm_path::String)
    ops = parse_qasm(qasm_path)
    n = ops[1].args[1]
    m = ops[2].args[1]
    nprime = maximum(reduce(vcat, [op.args for op in ops[3:end]]))
    mprime = n = min(n, nprime)
    m = min(m, mprime)
    s = State(n)
    s.amps[1] = 1.0 + 0.0im
    s.kets[1] = falses(n)
	return QSim(n, m, ops[3:end], s)
end

"""
    execute!(qsim::QSim)

Execute the QASM operations on the quantum simulator `qsim`.
"""
function execute!(qsim::QSim)
    for op in qsim.ops
        if op.operation == "h"
            h!(op.args[1], qsim.s)
        elseif op.operation == "x"
            x!(op.args[1], qsim.s)
        elseif op.operation == "t"
            t!(op.args[1], qsim.s)
        elseif op.operation == "tdg"
            tdg!(op.args[1], qsim.s)
        elseif op.operation == "cx"
            cx!(op.args[1], op.args[2], qsim.s)
        else
            error("Unsupported operation: $(op.operation)")
        end
    end
end



include("gates.jl")


end
