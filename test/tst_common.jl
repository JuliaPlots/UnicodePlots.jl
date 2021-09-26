@testset "plotting_range" begin
    @testset "types" begin
        @test UnicodePlots.plotting_range(0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range(0.0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range(0, 1f0) === (0.0, 1.0)
        @test UnicodePlots.plotting_range(0x0, 0x1) === (0.0, 1.0)
    end

    @test UnicodePlots.plotting_range(0.0001, 0.002) === (0.0, 0.01)
    @test UnicodePlots.plotting_range(0.001,  0.02)  === (0.0, 0.1)
    @test UnicodePlots.plotting_range(0.01,   0.2)   === (0.0, 1.0)
    @test UnicodePlots.plotting_range(0.1,    2.)    === (0.0, 10.0)
    @test UnicodePlots.plotting_range(0, 2) === (0.0, 10.0)
    @test UnicodePlots.plotting_range(0, 5) === (0.0, 10.0)
end

@testset "plotting_range_narrow" begin
    @testset "types" begin
        @test UnicodePlots.plotting_range_narrow(0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0.0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0, 1f0) === (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0x0, 0x1) === (0.0, 1.0)
    end

    @test UnicodePlots.plotting_range_narrow(0.0001, 0.002) === (0.0, 0.002)
    @test UnicodePlots.plotting_range_narrow(0.001,  0.02)  === (0.0, 0.02)
    @test UnicodePlots.plotting_range_narrow(0.01,   0.2)   === (0.0, 0.2)
    @test UnicodePlots.plotting_range_narrow(0.1,    2.)    === (0.0, 2.0)
    @test UnicodePlots.plotting_range_narrow(0, 2) === (0.0, 2.0)
    @test UnicodePlots.plotting_range_narrow(0, 5) === (0.0, 5.0)
end

@testset "extend_limits" begin
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0.1, 2]) === (0.1, 2.)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0, 1.1]) === (0., 1.1)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [2, 3]) === (2., 3.)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0, 0]) === (1., 4.)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [1, 1]) === (0., 2.)
end

@testset "bordermap" begin
    bmap_keys = keys(UnicodePlots.bordermap)
    @test length(bmap_keys) == 9
    @test haskey(UnicodePlots.bordermap, :none)
    @test haskey(UnicodePlots.bordermap, :bnone)
    @test haskey(UnicodePlots.bordermap, :solid)
    @test haskey(UnicodePlots.bordermap, :corners)
    @test haskey(UnicodePlots.bordermap, :barplot)
    @test haskey(UnicodePlots.bordermap, :bold)
    @test haskey(UnicodePlots.bordermap, :dotted)
    @test haskey(UnicodePlots.bordermap, :dashed)
    @test haskey(UnicodePlots.bordermap, :ascii)
    for (k, v) in zip(bmap_keys, UnicodePlots.bordermap)
        @test length(keys(v)) == 8
        @test haskey(v, :tl)
        @test haskey(v, :tr)
        @test haskey(v, :bl)
        @test haskey(v, :br)
        @test haskey(v, :r)
        @test haskey(v, :l)
        @test haskey(v, :t)
        @test haskey(v, :b)
    end
end

@testset "miscellaneous" begin
    @test UnicodePlots.char_marker('a') === 'a'
    @test UnicodePlots.char_marker("a") === 'a'
    @test UnicodePlots.char_marker(:+) === '+'

    @test UnicodePlots.iterable([1, 2]) == [1, 2]
    @test collect(Iterators.take(UnicodePlots.iterable(:abc), 2)) == [:abc, :abc]

    @test UnicodePlots.fscale(1, :identity) === 1
    @test UnicodePlots.iscale(1, :identity) === 1

    @test UnicodePlots.fscale(10, :log10) ≈ 1
    @test UnicodePlots.iscale(1, :log10) ≈ 10

    @test UnicodePlots.fscale(2, :log2) ≈ 1
    @test UnicodePlots.iscale(1, :log2) ≈ 2

    @test UnicodePlots.fscale(ℯ, :ln) ≈ 1
    @test UnicodePlots.iscale(1, :ln) ≈ ℯ
end

