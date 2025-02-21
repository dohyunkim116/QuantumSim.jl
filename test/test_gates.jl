@testset "Test x! function for n = 2" begin
    n = 2;
    initket = falses(n);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    wks = [wk0];
    s = State(n, wks);
    x!(1, s);
    @test s.kets[3] == [1, 0]
    x!(1, s);
    @test s.kets[1] == [0, 0]
    s = State(n, wks);
    x!(2, s);
    @test s.kets[2] == [0, 1]
    x!(2, s);
    @test s.kets[1] == [0, 0]
end

@testset "Test t! function for n = 1" begin
    n = 1;
    initket = falses(n);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    wks = [wk0];
    s = State(n, wks);
    t!(1, s);
    @test s.amps[1] == 1.0 + 0.0im
    t!(1, s);
    @test s.amps[1] ≈ 1.0 + 0.0im
    initket = trues(n);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    s = State(n, [wk0]);
    t!(1, s);
    @test s.amps[2] ≈ exp(1.0im * π / 4)
    t!(1, s);
    @test s.amps[2] ≈ exp(1.0im * π / 2)
end

@testset "Test tdg! function for n = 1" begin
    n = 1;
    initket = falses(n);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    wks = [wk0];
    s = State(n, wks);
    tdg!(1, s);
    @test s.amps[1] == 1.0 + 0.0im
    tdg!(1, s);
    @test s.amps[1] ≈ 1.0 + 0.0im
    initket = trues(n);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    s = State(n, [wk0]);
    tdg!(1, s);
    @test s.amps[2] ≈ exp(-1.0im * π / 4)
    t!(1, s);
    @test s.amps[2] ≈ 1.0 + 0.0im
end

@testset "Test cx! function for n = 2" begin
    n = 2;
    initket = BitArray([0, 0]);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    wks = [wk0];
    s = State(n, wks);
    cx!(1, 2, s);
    @test s.kets[1] == [0, 0]
    cx!(1, 2, s);
    @test s.kets[1] == [0, 0]
    s = State(n, wks);
    cx!(2, 1, s);
    @test s.kets[1] == [0, 0]
    cx!(2, 1, s);
    @test s.kets[1] == [0, 0]
    initket = BitArray([1, 0])
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    s = State(n, [wk0]);
    cx!(1, 2, s);
    @test s.kets[4] == [1, 1]
    cx!(1, 2, s);
    @test s.kets[3] == [1, 0]
    s = State(n, [wk0]);
    cx!(2, 1, s);
    @test s.kets[3] == [1, 0]
end

@testset "Test h! function for n = 2" begin
    n = 2;
    initket = BitArray([0, 0]);
    wk0 = WeightedKet(n, 1.0 + 0.0im, initket);
    wks = [wk0];
    s = State(n, wks);
    h!(2, s);
    @test s.amps[1] == 1/sqrt(2)
    @test s.amps[2] == 1/sqrt(2)
    h!(2, s);
    @test s.amps[1] ≈ 1
    s = State(n, wks);
    h!(1, s);
    @test s.amps[1] == 1/sqrt(2)
    @test s.amps[3] == 1/sqrt(2)
    h!(1, s);
    @test s.amps[1] ≈ 1
end
