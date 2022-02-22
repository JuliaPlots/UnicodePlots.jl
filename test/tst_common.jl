@testset "plotting_range" begin
    @testset "types" begin
        @test UnicodePlots.plotting_range(0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range(0.0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range(0, 1.0f0) === (0.0, 1.0f0)
        @test UnicodePlots.plotting_range(0x0, 0x1) === (0.0, 1.0)
    end

    @test UnicodePlots.plotting_range(0.0001, 0.002) === (0.0, 0.01)
    @test UnicodePlots.plotting_range(0.001, 0.02) === (0.0, 0.1)
    @test UnicodePlots.plotting_range(0.01, 0.2) === (0.0, 1.0)
    @test UnicodePlots.plotting_range(0.1, 2.0) === (0.0, 10.0)
    @test UnicodePlots.plotting_range(0, 2) === (0.0, 10.0)
    @test UnicodePlots.plotting_range(0, 5) === (0.0, 10.0)
end

@testset "plotting_range_narrow" begin
    @testset "types" begin
        @test UnicodePlots.plotting_range_narrow(0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0.0, 1) === (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0, 1.0f0) === (0.0, 1.0f0)
        @test UnicodePlots.plotting_range_narrow(0x0, 0x1) === (0.0, 1.0)
    end

    @test UnicodePlots.plotting_range_narrow(0.0001, 0.002) === (0.0, 0.002)
    @test UnicodePlots.plotting_range_narrow(0.001, 0.02) === (0.0, 0.02)
    @test UnicodePlots.plotting_range_narrow(0.01, 0.2) === (0.0, 0.2)
    @test UnicodePlots.plotting_range_narrow(0.1, 2.0) === (0.0, 2.0)
    @test UnicodePlots.plotting_range_narrow(0, 2) === (0.0, 2.0)
    @test UnicodePlots.plotting_range_narrow(0, 5) === (0.0, 5.0)
end

@testset "extend_limits" begin
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0.1, 2]) === (0.1, 2.0)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0, 1.1]) === (0.0, 1.1)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [2, 3]) === (2.0, 3.0)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0, 0]) === (1.0, 4.0)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [1, 1]) === (0.0, 2.0)
end

@testset "bordermap" begin
    bmap_keys = keys(UnicodePlots.BORDERMAP)
    @test length(bmap_keys) == 9
    @test haskey(UnicodePlots.BORDERMAP, :none)
    @test haskey(UnicodePlots.BORDERMAP, :bnone)
    @test haskey(UnicodePlots.BORDERMAP, :solid)
    @test haskey(UnicodePlots.BORDERMAP, :corners)
    @test haskey(UnicodePlots.BORDERMAP, :barplot)
    @test haskey(UnicodePlots.BORDERMAP, :bold)
    @test haskey(UnicodePlots.BORDERMAP, :dotted)
    @test haskey(UnicodePlots.BORDERMAP, :dashed)
    @test haskey(UnicodePlots.BORDERMAP, :ascii)
    for (k, v) in zip(bmap_keys, UnicodePlots.BORDERMAP)
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

@testset "colors" begin
    @test UnicodePlots.julia_color(100) == 100
    @test UnicodePlots.julia_color(:red) == :red
    @test UnicodePlots.julia_color(nothing) == :normal
    @test UnicodePlots.julia_color((0, 135, 95)) == 29

    @test UnicodePlots.colormap_callback(UnicodePlots.COLOR_MAP_DATA |> keys |> first) isa
          Function
    @test UnicodePlots.colormap_callback(() -> nothing) isa Function
    @test UnicodePlots.colormap_callback([1, 2, 3]) isa Function
    @test UnicodePlots.colormap_callback(nothing) === nothing

    # clamp in range
    values = collect(1:10)
    callback = UnicodePlots.colormap_callback(:viridis)
    colors = [callback(v, values[2], values[end - 1]) for v in values]

    # en.wikipedia.org/wiki/ANSI_escape_code#8-bit
    @test UnicodePlots.rgb2ansi((0, 0, 0)) == 016  # black
    @test UnicodePlots.rgb2ansi((1, 0, 0)) == 196  # red
    @test UnicodePlots.rgb2ansi((0, 1, 0)) == 046  # green
    @test UnicodePlots.rgb2ansi((0, 0, 1)) == 021  # blue
    @test UnicodePlots.rgb2ansi((1, 1, 1)) == 231  # white
end

struct Scale{T}
    r::T
end
(f::Scale)(x) = f.r * x

@testset "miscellaneous" begin
    @test UnicodePlots.char_marker('a') === 'a'
    @test UnicodePlots.char_marker("a") === 'a'
    @test UnicodePlots.char_marker(:+) === '+'

    @test UnicodePlots.iterable([1, 2]) == [1, 2]
    @test collect(Iterators.take(UnicodePlots.iterable(:abc), 2)) == [:abc, :abc]

    @test UnicodePlots.scale_callback(:identity)(1) === 1
    @test UnicodePlots.scale_callback(:log10)(10) ≈ 1
    @test UnicodePlots.scale_callback(:log2)(2) ≈ 1
    @test UnicodePlots.scale_callback(:ln)(ℯ) ≈ 1
    @test UnicodePlots.scale_callback(x -> x)(1) === 1
    @test UnicodePlots.scale_callback(Scale(π))(1) ≈ π

    @test UnicodePlots.out_stream_width(nothing) == 40
    @test UnicodePlots.out_stream_height(nothing) == 15

    @test UnicodePlots.superscript("-10") == "⁻¹⁰"
    @test UnicodePlots.superscript("+2") == "⁺²"

    @test_throws AssertionError UnicodePlots.default_size!(width = 8, height = 8)
    UnicodePlots.default_size!(width = 64)
    @test UnicodePlots.DEFAULT_WIDTH[] == 64
    @test UnicodePlots.DEFAULT_HEIGHT[] == 24
    UnicodePlots.default_size!(height = 15)
    @test UnicodePlots.DEFAULT_WIDTH[] == 40
    @test UnicodePlots.DEFAULT_HEIGHT[] == 15
end

@testset "docs" begin
    # coverage
    @test UnicodePlots.arguments() isa String
    @test UnicodePlots.keywords() isa String
    @test UnicodePlots.default_with_type(:foo_bar) isa String
end

@testset "units" begin
    x = [1.0, 2.0, 3.0]
    @test UnicodePlots.number_unit(x) == (x, nothing)
    @test UnicodePlots.number_unit(1) == (1, nothing)
    @test UnicodePlots.number_unit(x * u"°C") == (x, "°C")
    @test UnicodePlots.number_unit(1u"°C") == (1, "°C")

    @test UnicodePlots.unit_label("  fancy label  ", "Hz") == "  fancy label (Hz)"
    @test UnicodePlots.unit_label("  ", "dB") == "dB"
    @test UnicodePlots.unit_label("  no units  ", nothing) == "  no units"
end
