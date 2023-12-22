@testset "aspect ratio" begin
    @test spy(rand(2, 2)).graphics.grid |> size == (2, 5)
    @test spy(rand(4, 4)).graphics.grid |> size == (2, 5)
    @test spy(rand(8, 4)).graphics.grid |> size == (2, 5)
    @test spy(rand(12, 4)).graphics.grid |> size == (3, 5)
    @test spy(rand(8, 8)).graphics.grid |> size == (2, 5)
    @test spy(rand(8, 12)).graphics.grid |> size == (2, 6)
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 80, 80, 0.15), fix_ar = true)
    test_ref("spy/fix_aspect_ratio_80x80_.txt", @show_col(p, :displaysize => T_SZ))
end

@testset "sizing" begin
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 0, 0, 0.1))
    test_ref("spy/default_0x0.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 10, 10, 0.15))
    @test p isa Plot
    test_ref("spy/default_10x10.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 10, 15, 0.15))
    test_ref("spy/default_10x15.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 15, 10, 0.15))
    test_ref("spy/default_15x10.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 2_000, 200, 0.0001))
    test_ref("spy/default_2000x200.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 200, 2_000, 0.0001))
    test_ref("spy/default_200x2000.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 200, 200, 0.001))
    test_ref("spy/default_200x200_normal.txt", @show_col(p, :displaysize => T_SZ))
    test_ref("spy/default_200x200_normal_nocolor.txt", @show_nocol(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(Matrix(_stable_sprand(RNG, 200, 200, 0.001)))
    test_ref("spy/default_200x200_normal.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 200, 200, 0.001), width = 10)
    test_ref("spy/default_200x200_normal_small.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 200, 200, 0.001), height = 5)
    test_ref("spy/default_200x200_normal_small.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 200, 200, 0.001), height = 5, width = 20)
    test_ref("spy/default_200x200_normal_misshaped.txt", @show_col(p, :displaysize => T_SZ))
end

@testset "parameters" begin
    seed!(RNG, 1_337)
    p = @binf spy(_stable_sprand(RNG, 200, 200, 0.001), color = :green)
    test_ref("spy/parameters_200x200_green.txt", @show_col(p, :displaysize => T_SZ))
    test_ref(
        "spy/parameters_200x200_green_nocolor.txt",
        @show_nocol(p, :displaysize => T_SZ)
    )
    seed!(RNG, 1_337)
    p = spy(
        _stable_sprand(RNG, 200, 200, 0.001),
        title = "Custom Title",
        canvas = DotCanvas,
        border = :ascii,
    )
    test_ref("spy/parameters_200x200_dotcanvas.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1_337)
    p = spy(_stable_sprand(RNG, 200, 200, 0.99), show_zeros = true, compact = true)
    test_ref("spy/parameters_200x200_zeros.txt", @show_col(p, :displaysize => T_SZ))
end
