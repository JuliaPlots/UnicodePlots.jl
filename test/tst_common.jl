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

    @test UnicodePlots.fscale(1, x->x) === 1
    @test UnicodePlots.iscale(1, x->x) === 1

    @test UnicodePlots.out_stream_width(nothing) == 40
    @test UnicodePlots.out_stream_height(nothing) == 15

    @test UnicodePlots.ansi_8bit_color(0x80) == UnicodePlots.THRESHOLD + 0x80  # ansi 128
    @test UnicodePlots.ansi_8bit_color(128) == UnicodePlots.THRESHOLD + 0x80  # ansi 128
    @test UnicodePlots.ansi_8bit_color(:red) == UnicodePlots.THRESHOLD + 0x01
    @test UnicodePlots.ansi_8bit_color(:green) == UnicodePlots.THRESHOLD + 0x02
    @test UnicodePlots.ansi_8bit_color(:blue) == UnicodePlots.THRESHOLD + 0x04
    # enable when github.com/KristofferC/Crayons.jl/pull/59 is merged
    # @test UnicodePlots.ansi_8bit_color((0, 0, 0)) == UnicodePlots.THRESHOLD + 0x0
    # @test UnicodePlots.ansi_8bit_color((255, 255, 255)) == UnicodePlots.THRESHOLD + 0xe7  # ansi 231

    @test UnicodePlots.ansi_24bit_color(0x80) == 0x00af00d7  # ansi 128
    @test UnicodePlots.ansi_24bit_color(128) == 0x00af00d7  # ansi 128
    @test UnicodePlots.ansi_24bit_color(:red) == UnicodePlots.THRESHOLD + 0x01
    @test UnicodePlots.ansi_24bit_color(:green) == UnicodePlots.THRESHOLD + 0x02
    @test UnicodePlots.ansi_24bit_color(:blue) == UnicodePlots.THRESHOLD + 0x04
    @test UnicodePlots.ansi_24bit_color((0, 0, 0)) == 0x0
    @test UnicodePlots.ansi_24bit_color((255, 255, 255)) == 0xffffff

    @test UnicodePlots.superscript("-10") == "⁻¹⁰"
end

