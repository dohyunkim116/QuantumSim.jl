# quantumSim

[![Build Status](https://github.com/dohyunkim116/quantumSim.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/dohyunkim116/quantumSim.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Overview

`quantumSim` is a Julia package for simulating quantum circuits for a subset of QASM (Quantum Assembly Language) programs. The package supports various quantum gates and allows for comparison with Cirq simulations for programs in the `test/qasm` directory. The supported gates include: H, X, T, T†, and CX.

## Prerequisites

Ensure you have Julia version 1.9 installed on your system. You can download it from [Julia's official website](https://julialang.org/downloads/).

## Installation

To install the package, clone the repository and add it to your Julia environment:

```sh
git clone https://github.com/dohyunkim116/quantumSim.jl
cd quantumSim.jl
julia -e 'using Pkg; Pkg.add(PackageSpec(path=pwd()))'
```

## Usage

### Providing Input

The input to the simulator is a QASM file. QASM files describe quantum circuits using a specific syntax. There are 14 QASM files in the `test/qasm` directory for testing the simulator.

### Running the Program and understanding the Output

Here is an example of how to run a quantum circuit using one of the QASM files in the `test/qasm` directory, and how to access the final state of the quantum circuit:

```julia
using quantumSim

qasm_dir = "test/qasm" # assuming your current working directory is the root of the package
qasm_files = readdir(qasm_dir)
fpath = joinpath(qasm_dir, qasm_files[1])
sim = QSim(fpath)
execute!(sim)
state = sim.s # the final state of the qubits
kets = sim.s.kets # a vector of computational basis
amps = sim.s.amps # amplitudes of corresponding computational basis
```

The `amps` variable will be used to check the approximate equality with the outputs from Cirq. To compare the simulation results with Cirq, run `test_compare_to_cirq.jl` script in the `test` directory. The following is the relevant code snippet in the script:

```julia
qasm_dir = "qasm"
@testset "QASM comparison test against Cirq" begin
    test_all_qasm(qasm_dir)
end
```

This will print whether each QASM file passes or fails the approximate equality test against the outputs of Cirq. Alternatively, if you have navigated to the `quantumSim.jl` folder, you can activate the package environment in the Julia REPL by typing `] activate .` and run all of the tests defined in `runtests.jl` by typing `test`. The `runtests.jl` file includes tests for comparing the simulation results with Cirq.

## Documentation

The package includes documentation for each function. Refer to the source code for more information.

## License

This project is licensed under the MIT License.