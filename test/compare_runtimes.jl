using PyCall
using BenchmarkTools
using DataFrames
using PrettyTables
using QuantumSim

# Import Cirq functions
py"""
from cirq.contrib.qasm_import import circuit_from_qasm
from cirq import Simulator
"""

# Simulate with Cirq
function cirq_simulate(qasm_path::String)
    qasm_string = read(qasm_path, String)
    circuit = py"circuit_from_qasm"(qasm_string)
    simulator = py"Simulator"()
    result = simulator.simulate(circuit)
    return [Complex(x) for x in result.final_state_vector]
end

# Simulate with QuantumSim.jl
function julia_simulate(qasm_path::String)
    sim = QSim(qasm_path)
    execute!(sim)
    return sim.s.amps
end

# Benchmark simulation with BenchmarkTools.jl
function benchmark_simulation(simulate::Function, qasm_path::String; reps=10)
    b = @benchmark $simulate(qasm_path) setup=(qasm_path=$qasm_path) samples=reps
    return median(b).time / 1e9  # Convert nanoseconds to seconds
end

# Compare runtimes and results
function compare_simulations_with_timing(qasm_path::String; reps=10)
    println("Benchmarking QASM file: $qasm_path")

    # Benchmark Cirq
    cirq_time = benchmark_simulation(cirq_simulate, qasm_path; reps=reps)

    # Benchmark QuantumSim.jl
    julia_time = benchmark_simulation(julia_simulate, qasm_path; reps=reps)

    # Validate results
    julia_state_vector = julia_simulate(qasm_path)
    cirq_state_vector = cirq_simulate(qasm_path)
    @assert length(julia_state_vector) == length(cirq_state_vector)
    n = log2(length(julia_state_vector))
    is_approx = isapprox(julia_state_vector, cirq_state_vector; atol=1e-8, rtol=1e-5)
    println(" Amplitude  comparison: ", is_approx ? "PASS" : "FAIL")

    return (qasm_path, n, julia_time, cirq_time, is_approx)
end

# Test all QASM files in a directory and create a table
function benchmark_all_qasm(qasm_dir::String; reps=10)
    qasm_files = filter(f -> endswith(f, ".qasm"), readdir(qasm_dir))
    results = DataFrame(
        File = String[],
        Num_Qubits = Int[],
        quantumSim_Time = Float64[],
        Cirq_Time = Float64[],
        Amplitude_Equality = Bool[]
    )

    for f in qasm_files
        fpath = joinpath(qasm_dir, f)
        file, n, quantumsim_time, cirq_time, comparison = compare_simulations_with_timing(fpath; reps=reps)
        push!(results, (file, n, quantumsim_time, cirq_time, comparison))
    end

    return results
end

# Run benchmarks and display results
qasm_dir = "test/qasm"
results = benchmark_all_qasm(qasm_dir; reps=1)
sort!(results, :Num_Qubits)
println("\nRuntime Comparison Table:")
pretty_table(
    results,
    formatters=ft_printf("%.6f", [3, 4]),
    alignment=:l
)

using Plots
plot(results.Num_Qubits, results.quantimSim_Time, label="QuantumSim")
plot!(results.Num_Qubits, results.Cirq_Time, label="Cirq")
xlabel!("Number of Qubits")
ylabel!("Run Time (seconds)")
title!("Run Time vs Number of Qubits")
