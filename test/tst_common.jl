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
    # coverage
    _cycle = UnicodePlots.COLOR_CYCLE[]
    UnicodePlots.brightcolors!()
    UnicodePlots.faintcolors!()
    UnicodePlots.COLOR_CYCLE[] = _cycle

    @test UnicodePlots.c256(0.0) == 0
    @test UnicodePlots.c256(1.0) == 255
    @test UnicodePlots.c256(0) == 0
    @test UnicodePlots.c256(255) == 255

    @test_throws ErrorException UnicodePlots.colormode!(123456789)

    _color_mode = UnicodePlots.colormode()
    UnicodePlots.COLORMODE[] = Crayons.COLORS_16  # we only suport 8bit or 24bit, not 4bit
    @test_throws ErrorException UnicodePlots.colormode()

    UnicodePlots.colors256!()
    @test UnicodePlots.ansi_color(0x80) == UnicodePlots.THRESHOLD + 0x80  # ansi 128
    @test UnicodePlots.ansi_color(128) == UnicodePlots.THRESHOLD + 0x80  # ansi 128
    @test UnicodePlots.ansi_color((0, 0, 0)) == UnicodePlots.THRESHOLD + 0x0
    @test UnicodePlots.ansi_color((255, 255, 255)) == UnicodePlots.THRESHOLD + 0xe7  # ansi 231
    @test UnicodePlots.ansi_color(:red) == UnicodePlots.THRESHOLD + 0x01
    @test UnicodePlots.ansi_color(:green) == UnicodePlots.THRESHOLD + 0x02
    @test UnicodePlots.ansi_color(:blue) == UnicodePlots.THRESHOLD + 0x04
    @test UnicodePlots.ansi_color(:light_red) == UnicodePlots.THRESHOLD + 0x09  # bright := normal + 8
    @test UnicodePlots.ansi_color(:light_green) == UnicodePlots.THRESHOLD + 0x0a
    @test UnicodePlots.ansi_color(:light_blue) == UnicodePlots.THRESHOLD + 0x0c

    UnicodePlots.truecolors!()
    _lut = UnicodePlots.USE_LUT[]
    UnicodePlots.USE_LUT[] = true
    @test UnicodePlots.ansi_color(0x80) == 0xaf00d7
    @test UnicodePlots.ansi_color(128) == 0xaf00d7
    @test UnicodePlots.ansi_color((0, 0, 0)) == 0x0
    @test UnicodePlots.ansi_color((255, 255, 255)) == 0xffffff
    @test UnicodePlots.ansi_color(:red) == 0x800000
    @test UnicodePlots.ansi_color(:green) == 0x008000
    @test UnicodePlots.ansi_color(:blue) == 0x000080
    @test UnicodePlots.ansi_color(:light_red) == 0xff0000
    @test UnicodePlots.ansi_color(:light_green) == 0x00ff00
    @test UnicodePlots.ansi_color(:light_blue) == 0x0000ff
    UnicodePlots.USE_LUT[] = false
    @test UnicodePlots.ansi_color(0x80) == UnicodePlots.THRESHOLD + 0x80
    @test UnicodePlots.ansi_color(128) == UnicodePlots.THRESHOLD + 0x80
    @test UnicodePlots.ansi_color((0, 0, 0)) == 0x0
    @test UnicodePlots.ansi_color((255, 255, 255)) == 0xffffff
    @test UnicodePlots.ansi_color(:red) == UnicodePlots.THRESHOLD + 0x1
    @test UnicodePlots.ansi_color(:green) == UnicodePlots.THRESHOLD + 0x2
    @test UnicodePlots.ansi_color(:blue) == UnicodePlots.THRESHOLD + 0x4
    @test UnicodePlots.ansi_color(:light_red) == UnicodePlots.THRESHOLD + 0x09
    @test UnicodePlots.ansi_color(:light_green) == UnicodePlots.THRESHOLD + 0x0a
    @test UnicodePlots.ansi_color(:light_blue) == UnicodePlots.THRESHOLD + 0x0c
    UnicodePlots.USE_LUT[] = _lut

    UnicodePlots.colormode!(_color_mode)

    if true  # physical average
        @test UnicodePlots.blend_colors(UInt32(0), UInt32(255)) == UInt32(180)
        @test UnicodePlots.blend_colors(0xff0000, 0x00ff00) == 0xb4b400  # red & green -> yellow
        @test UnicodePlots.blend_colors(0x00ff00, 0x0000ff) == 0x00b4b4  # green & blue -> cyan
        @test UnicodePlots.blend_colors(0xff0000, 0x0000ff) == 0xb400b4  # red & blue -> magenta
    else  # binary or
        @test UnicodePlots.blend_colors(UInt32(0), UInt32(255)) == UInt32(255)
        @test UnicodePlots.blend_colors(0xff0000, 0x00ff00) == 0xffff00
        @test UnicodePlots.blend_colors(0x00ff00, 0x0000ff) == 0x00ffff
        @test UnicodePlots.blend_colors(0xff0000, 0x0000ff) == 0xff00ff
    end

    @test UnicodePlots.complement(UnicodePlots.INVALID_COLOR) == UnicodePlots.INVALID_COLOR
    @test UnicodePlots.complement(0x003ae1c3) == 0x00c51e3c

    io = PipeBuffer()
    _cfast = UnicodePlots.CRAYONS_FAST[]
    for fast in (false, true)
        UnicodePlots.CRAYONS_FAST[] = fast
        UnicodePlots.print_crayons(io, Crayon(foreground = :red), 123)
        UnicodePlots.print_crayons(io, Crayon(), 123)
    end
    UnicodePlots.CRAYONS_FAST[] = _cfast

    @test UnicodePlots.colormap_callback(UnicodePlots.COLOR_MAP_DATA |> keys |> first) isa
          Function
    @test UnicodePlots.colormap_callback(() -> nothing) isa Function
    @test UnicodePlots.colormap_callback([1, 2, 3]) isa Function
    @test UnicodePlots.colormap_callback(nothing) === nothing

    # clamp in range
    values = collect(1:10)
    callback = UnicodePlots.colormap_callback(:viridis)
    colors = [callback(v, values[2], values[end - 1]) for v in values]
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

    h, w = displaysize()
    @test UnicodePlots.out_stream_height() == h
    @test UnicodePlots.out_stream_width() == w

    @test UnicodePlots.superscript("-10") == "⁻¹⁰"
    @test UnicodePlots.superscript("+2") == "⁺²"

    @test_throws AssertionError default_size!(width = 8, height = 8)

    @test default_size!(height = 30) == (30, 80)
    @test default_size!(width = 64) == (24, 64)
    @test default_size!() == (15, 40)
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
