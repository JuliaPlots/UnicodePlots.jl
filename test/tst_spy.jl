@testset "sizing" begin
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 0, 0, .1))
    test_ref("references/spy/default_0x0.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 10, 10, .15))
    @test p isa Plot
    test_ref("references/spy/default_10x10.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 10, 15, .15))
    test_ref("references/spy/default_10x15.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 15, 10, .15))
    test_ref("references/spy/default_15x10.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 2000, 200, .0001))
    test_ref("references/spy/default_2000x200.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 200, 2000, .0001))
    test_ref("references/spy/default_200x2000.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 2000, 2000, .1))
    test_ref("references/spy/default_overdrawn.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 200, 200, .001))
    test_ref("references/spy/default_200x200_normal.txt", @show_col(p, :displaysize=>T_SZ))
    test_ref("references/spy/default_200x200_normal_nocolor.txt", @show_nocol(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(Matrix(_stable_sprand(RNG, 200, 200, .001)))
    test_ref("references/spy/default_200x200_normal.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 200, 200, .001), width=10)
    test_ref("references/spy/default_200x200_normal_small.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 200, 200, .001), height=5)
    test_ref("references/spy/default_200x200_normal_small.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 200, 200, .001), height=5, width=20)
    test_ref("references/spy/default_200x200_normal_misshaped.txt", @show_col(p, :displaysize=>T_SZ))
end

@testset "parameters" begin
    seed!(RNG, 1337)
    p = @inferred spy(_stable_sprand(RNG, 200, 200, .001), color=:green)
    test_ref("references/spy/parameters_200x200_green.txt", @show_col(p, :displaysize=>T_SZ))
    test_ref("references/spy/parameters_200x200_green_nocolor.txt", @show_nocol(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = spy(_stable_sprand(RNG, 200, 200, .001), title="Custom Title", canvas=DotCanvas, border=:ascii)
    test_ref("references/spy/parameters_200x200_dotcanvas.txt", @show_col(p, :displaysize=>T_SZ))
    seed!(RNG, 1337)
    p = spy(_stable_sprand(RNG, 200, 200, .99), show_zeros=true)
    test_ref("references/spy/parameters_200x200_zeros.txt", @show_col(p, :displaysize=>T_SZ))
end
