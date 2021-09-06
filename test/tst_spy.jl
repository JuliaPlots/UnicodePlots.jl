@testset "sizing" begin
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 10, 10, 0.15))
    @test p isa Plot
    test_ref("references/spy/default_10x10.txt", @show_col(p, :displaysize => TERM_SIZE))
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 10, 15, 0.15))
    test_ref("references/spy/default_10x15.txt", @show_col(p, :displaysize => TERM_SIZE))
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 15, 10, 0.15))
    test_ref("references/spy/default_15x10.txt", @show_col(p, :displaysize => TERM_SIZE))
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 2000, 200, 0.0001))
    test_ref("references/spy/default_2000x200.txt", @show_col(p, :displaysize => TERM_SIZE))
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 200, 2000, 0.0001))
    test_ref("references/spy/default_200x2000.txt", @show_col(p, :displaysize => TERM_SIZE))
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 2000, 2000, 0.1))
    test_ref(
        "references/spy/default_overdrawn.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 200, 200, 0.001))
    test_ref(
        "references/spy/default_200x200_normal.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
    test_ref(
        "references/spy/default_200x200_normal_nocolor.txt",
        @show_nocol(p, :displaysize => TERM_SIZE)
    )
    seed!(RNG, 1337)
    p = @inferred spy(Matrix(stable_sprand(RNG, 200, 200, 0.001)))
    test_ref(
        "references/spy/default_200x200_normal.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 200, 200, 0.001), width=10)
    test_ref(
        "references/spy/default_200x200_normal_small.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 200, 200, 0.001), height=5)
    test_ref(
        "references/spy/default_200x200_normal_small.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 200, 200, 0.001), height=5, width=20)
    test_ref(
        "references/spy/default_200x200_normal_misshaped.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
end

@testset "parameters" begin
    seed!(RNG, 1337)
    p = @inferred spy(stable_sprand(RNG, 200, 200, 0.001), color=:green)
    test_ref(
        "references/spy/parameters_200x200_green.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
    test_ref(
        "references/spy/parameters_200x200_green_nocolor.txt",
        @show_nocol(p, :displaysize => TERM_SIZE)
    )
    seed!(RNG, 1337)
    p = spy(
        stable_sprand(RNG, 200, 200, 0.001),
        title="Custom Title",
        canvas=DotCanvas,
        border=:ascii,
    )
    test_ref(
        "references/spy/parameters_200x200_dotcanvas.txt",
        @show_col(p, :displaysize => TERM_SIZE)
    )
end
