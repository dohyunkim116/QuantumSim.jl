OPENQASM 2.0;
include "qelib1.inc";
qreg q[2];    // Quantum register with 2 qubits
creg c[2];    // Classical register with 2 bits
h q[0];       // Apply Hadamard gate to qubit 0
cx q[0],q[1]; // Apply CNOT gate with qubit 0 as control and qubit 1 as target
