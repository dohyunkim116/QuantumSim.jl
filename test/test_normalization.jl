qasm_dir = "qasm"
qasm_files = filter(f -> endswith(f, ".qasm"), readdir(qasm_dir))

@testset "Test normalization for QASM files" begin
    for f in qasm_files
        fpath = joinpath(qasm_dir, f)
        sim = QSim(fpath)
        execute!(sim)
        mask = findall(sim.s.amps .!= zero(eltype(sim.s.amps)))
        summ = sum(abs2.(sim.s.amps[mask]))
        @test isapprox(summ, 1.0, atol=1e-10)
    end
end