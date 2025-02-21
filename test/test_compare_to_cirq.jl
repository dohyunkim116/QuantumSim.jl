try
    pyimport("cirq")
catch e
    @warn "Cirq module not found. Please install Cirq to run these tests."
    exit(1)
end

py"""
from cirq.contrib.qasm_import import circuit_from_qasm
from cirq import Simulator
"""

function cirq_simulate(qasm_path::String)
    # Read the QASM file
    qasm_string = read(qasm_path, String)
    
    # Convert QASM string to Cirq circuit
    circuit = py"circuit_from_qasm"(qasm_string)
    
    # Simulate using Cirq's Simulator
    simulator = py"Simulator"()
    result = simulator.simulate(circuit)
    
    # Return final state vector as a Julia array
    return [Complex(x) for x in result.final_state_vector]
end

function compare_simulations(qasm_path::String)
    # Simulate using Julia implementation
    sim = QSim(qasm_path)
    execute!(sim)
    julia_state_vector = sim.s.amps

    # Simulate using Cirq
    cirq_state_vector = cirq_simulate(qasm_path)

    # Compare the two state vectors
    is_approx = isapprox(julia_state_vector, cirq_state_vector; atol=1e-8, rtol=1e-5)
    println("$qasm_path: ", is_approx ? "PASS" : "FAIL")
    return is_approx
end

# Test all QASM files in a directory
function test_all_qasm(qasm_dir::String)
    qasm_files = filter(f -> endswith(f, ".qasm"), readdir(qasm_dir))
    all_passed = true
    
    for f in qasm_files
        fpath = joinpath(qasm_dir, f)
        passed = compare_simulations(fpath)
        @test all_passed && passed 
    end
    println("All tests passed: ", all_passed)
end

qasm_dir = "qasm";
@testset "QASM comparison test against Cirq" begin
    test_all_qasm(qasm_dir)
end
