@testset "plotting_range_narrow" begin
    @testset "types" begin
        @test UnicodePlots.plotting_range_narrow(0, 1) ≡ (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0.0, 1) ≡ (0.0, 1.0)
        @test UnicodePlots.plotting_range_narrow(0, 1.0f0) ≡ (0.0, 1.0f0)
        @test UnicodePlots.plotting_range_narrow(0x0, 0x1) ≡ (0.0, 1.0)
    end

    @test_logs (:warn, "Invalid plotting range") UnicodePlots.plotting_range_narrow(
        nextfloat(-Inf),
        prevfloat(+Inf),
    )
    @test UnicodePlots.plotting_range_narrow(nextfloat(-Inf32), prevfloat(Inf32)) ≡
          (-Inf32, Inf32)
    @test UnicodePlots.plotting_range_narrow(nextfloat(-Inf16), prevfloat(Inf16)) ≡
          (-Inf16, Inf16)
    @test UnicodePlots.plotting_range_narrow(0.0001, 0.002) ≡ (0.0, 0.002)
    @test UnicodePlots.plotting_range_narrow(0.001, 0.02) ≡ (0.0, 0.02)
    @test UnicodePlots.plotting_range_narrow(0.01, 0.2) ≡ (0.0, 0.2)
    @test UnicodePlots.plotting_range_narrow(0.1, 2.0) ≡ (0.0, 2.0)
    @test UnicodePlots.plotting_range_narrow(0, 2) ≡ (0.0, 2.0)
    @test UnicodePlots.plotting_range_narrow(0, 5) ≡ (0.0, 5.0)

    @test UnicodePlots.floor_base(15.0, 10.0) ≈ 10
    @test UnicodePlots.ceil_base(15.0, 10.0) ≈ 10^2
    @test UnicodePlots.floor_base(4.2, 2.0) ≈ 2^2
    @test UnicodePlots.ceil_base(4.2, 2.0) ≈ 2^3
    @test UnicodePlots.floor_base(1.5 * ℯ, ℯ) ≈ ℯ
    @test UnicodePlots.ceil_base(1.5 * ℯ, ℯ) ≈ ℯ^2
end

@testset "limits" begin
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0.1, 2]) ≡ (0.1, 2.0)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0, 1.1]) ≡ (0.0, 1.1)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [2, 3]) ≡ (2.0, 3.0)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [0, 0]) ≡ (1.0, 4.0)
    @test UnicodePlots.extend_limits([1, 2, 3, 4], [1, 1]) ≡ (0.0, 2.0)

    @test UnicodePlots.extend_limits([], (-1, 2)) ≡ (-1.0, 2.0)

    @test UnicodePlots.is_auto((0, 0))
    @test UnicodePlots.is_auto([0, 0])
    @test !UnicodePlots.is_auto((-1, 1))
    @test !UnicodePlots.is_auto([-1, 1])

    # `SVector` inferrability
    @test UnicodePlots.autolims([-3, 2]) == [-3, 2]
    @test UnicodePlots.autolims([-3, 2], 1:10) == [-3, 2]
    @test UnicodePlots.autolims([0, 0], 1:10) == [1, 10]
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
    for (k, v) ∈ zip(bmap_keys, UnicodePlots.BORDERMAP)
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
    @test first(UnicodePlots.COLOR_CYCLE_BRIGHT) ≡ :light_green
    @test first(UnicodePlots.COLOR_CYCLE_FAINT) ≡ :green

    _cycle = UnicodePlots.COLOR_CYCLE[]
    @test UnicodePlots.brightcolors!() == UnicodePlots.COLOR_CYCLE_BRIGHT
    @test UnicodePlots.faintcolors!() == UnicodePlots.COLOR_CYCLE_FAINT
    UnicodePlots.COLOR_CYCLE[] = _cycle

    @test UnicodePlots.c256(0.0) == 0
    @test UnicodePlots.c256(1.0) == 255
    @test UnicodePlots.c256(0) == 0
    @test UnicodePlots.c256(255) == 255

    @test_throws ArgumentError UnicodePlots.colormode!(123456789)

    _color_mode = UnicodePlots.colormode()
    UnicodePlots.COLORMODE[] = Crayons.COLORS_16  # we only suport 8bit or 24bit, not 4bit (terminal dependent)
    @test_throws ArgumentError UnicodePlots.colormode()

    UnicodePlots.colors256!()
    @test UnicodePlots.ansi_color(0x80) == UnicodePlots.THRESHOLD + 0x80  # ansi 128
    @test UnicodePlots.ansi_color(128) == UnicodePlots.THRESHOLD + 0x80  # ansi 128
    @test UnicodePlots.ansi_color((0.0, 0.0, 0.0)) == UnicodePlots.THRESHOLD + 0x0  # float 0 - 1 range
    @test UnicodePlots.ansi_color((1.0, 1.0, 1.0)) == UnicodePlots.THRESHOLD + 0xe7  # float 0 - 1 range
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
    @test UnicodePlots.ansi_color((0.0, 0.0, 0.0)) == 0x0
    @test UnicodePlots.ansi_color((1.0, 1.0, 1.0)) == 0xffffff
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
    for fast ∈ (false, true)
        UnicodePlots.CRAYONS_FAST[] = fast
        UnicodePlots.print_crayons(io, Crayon(foreground = :red), 123)
        UnicodePlots.print_crayons(io, Crayon(), 123)
    end
    UnicodePlots.CRAYONS_FAST[] = _cfast

    @test UnicodePlots.ignored_color(nothing)
    @test UnicodePlots.crayon_color(missing) isa Crayons.ANSIColor
    @test UnicodePlots.crayon_color(nothing) isa Crayons.ANSIColor
end

@testset "colormaps" begin
    @test UnicodePlots.colormap_callback(:inferno) isa Function
    @test UnicodePlots.colormap_callback(() -> nothing) isa Function
    @test UnicodePlots.colormap_callback([1, 2, 3]) isa Function
    @test UnicodePlots.colormap_callback(nothing) isa Function
end

@testset "ColorSchemes: custom registered cmap" begin
    ColorSchemes.loadcolorscheme(
        :test_unicodeplots,
        map(i -> RGB{Float64}(i, i, i), 0.0:0.1:1.0),
        "general",
        "test colorscheme (grays)",
    )
    callback = UnicodePlots.colormap_callback(:test_unicodeplots)
    lft = callback(0.5, 0.0, 2.0)
    rgt = callback(1.5, 0.0, 2.0)
    if UnicodePlots.colormode() == 8
        @test lft == UnicodePlots.THRESHOLD + 0x3b
        @test rgt == UnicodePlots.THRESHOLD + 0x91
    elseif UnicodePlots.colormode() == 24
        @test UnicodePlots.red(lft) ==
              UnicodePlots.grn(lft) ==
              UnicodePlots.blu(lft) ==
              UnicodePlots.c256(0.25)
        @test UnicodePlots.red(rgt) ==
              UnicodePlots.grn(rgt) ==
              UnicodePlots.blu(rgt) ==
              UnicodePlots.c256(0.75)
    else
        @test false
    end
end

@testset "clamp colors values within smaller range" begin
    values = collect(-10:0.5:10)
    left, right = 15, length(values) - 10
    mini, maxi = values[left], values[right]

    callback = UnicodePlots.colormap_callback(collect(1:10))
    colors = map(v -> callback(v, mini, maxi), values)

    # smaller interval, must hit colormap extrema
    @test all(x -> x == first(colors), colors[1:left])
    @test all(x -> x == last(colors), colors[right:end])
end

@testset "miscellaneous" begin
    @test UnicodePlots.split_plot_kw(pairs((width = 1, height = 2))) |> last |> isempty  # only plot keywords
    @test UnicodePlots.split_plot_kw(pairs((foo = 1, bar = 2))) |> first |> isempty  # only other keywords

    @test_logs (:warn, r".*will be lost") UnicodePlots.warn_on_lost_kw(pairs((; a = 1)))
    @test UnicodePlots.warn_on_lost_kw(pairs((;))) ≡ nothing

    @test UnicodePlots.char_marker('a') ≡ 'a'
    @test UnicodePlots.char_marker("a") ≡ 'a'
    @test UnicodePlots.char_marker(:+) ≡ '+'

    @test UnicodePlots.iterable([1, 2]) == [1, 2]
    @test collect(Iterators.take(UnicodePlots.iterable(:abc), 2)) == [:abc, :abc]

    @test UnicodePlots.scale_callback(:identity)(1) ≡ 1
    @test UnicodePlots.scale_callback(:log10)(10) ≈ 1
    @test UnicodePlots.scale_callback(:log2)(2) ≈ 1
    @test UnicodePlots.scale_callback(:ln)(ℯ) ≈ 1
    @test UnicodePlots.scale_callback(x -> x)(1) ≡ 1
    @test UnicodePlots.scale_callback(x -> sin(x))(0) ≈ 0

    h, w = ds = displaysize()
    @test UnicodePlots.out_stream_height() == h
    @test UnicodePlots.out_stream_width() == w
    @test UnicodePlots.out_stream_size(nothing) == ds
    @test UnicodePlots.out_stream_size(stdout) == displaysize(stdout)

    @test UnicodePlots.superscript("-10") == "⁻¹⁰"
    @test UnicodePlots.superscript("+2") == "⁺²"

    @test_throws AssertionError default_size!(width = 8, height = 8)

    @test default_size!(height = 30) == (30, 80)
    @test default_size!(width = 64) == (24, 64)
    @test default_size!() == (15, 40)

    @test UnicodePlots.nice_repr(2.1e-9, true, ' ') == "2.1e⁻⁹"
    @test UnicodePlots.nice_repr(1e20, false, ' ') == "1e20"
    @test UnicodePlots.nice_repr(1e20, true, ' ') == "1e²⁰"
    @test UnicodePlots.nice_repr(1.0, true, ' ') == "1"
    @test UnicodePlots.nice_repr(10, true, ' ') == "10"
    @test UnicodePlots.nice_repr(1 + 0.1eps(), true, ' ') == "1"

    s = UnicodePlots.KEYWORDS.thousands_separator
    @test UnicodePlots.nice_repr(-1_000_000_000, nothing) == "-1$(s)000$(s)000$(s)000"
    @test UnicodePlots.nice_repr(-100_000_000, nothing) == "-100$(s)000$(s)000"
    @test UnicodePlots.nice_repr(-10_000_000, nothing) == "-10$(s)000$(s)000"
    @test UnicodePlots.nice_repr(-1_000_000, nothing) == "-1$(s)000$(s)000"
    @test UnicodePlots.nice_repr(-100_000, nothing) == "-100$(s)000"
    @test UnicodePlots.nice_repr(-10_000, nothing) == "-10$(s)000"
    @test UnicodePlots.nice_repr(-1_000, nothing) == "-1$(s)000"
    @test UnicodePlots.nice_repr(-100, nothing) == "-100"
    @test UnicodePlots.nice_repr(-10, nothing) == "-10"
    @test UnicodePlots.nice_repr(-1, nothing) == "-1"
    @test UnicodePlots.nice_repr(0, nothing) == "0"
    @test UnicodePlots.nice_repr(+1, nothing) == "1"
    @test UnicodePlots.nice_repr(+10, nothing) == "10"
    @test UnicodePlots.nice_repr(+100, nothing) == "100"
    @test UnicodePlots.nice_repr(+1_000, nothing) == "1$(s)000"
    @test UnicodePlots.nice_repr(+10_000, nothing) == "10$(s)000"
    @test UnicodePlots.nice_repr(+100_000, nothing) == "100$(s)000"
    @test UnicodePlots.nice_repr(+1_000_000, nothing) == "1$(s)000$(s)000"
    @test UnicodePlots.nice_repr(+10_000_000, nothing) == "10$(s)000$(s)000"
    @test UnicodePlots.nice_repr(+100_000_000, nothing) == "100$(s)000$(s)000"
    @test UnicodePlots.nice_repr(+1_000_000_000, nothing) == "1$(s)000$(s)000$(s)000"
end

@testset "docs coverage" begin
    @test UnicodePlots.default_with_type(:foo_bar) isa String
    @test UnicodePlots.arguments() isa String
    @test UnicodePlots.keywords() isa String
end

const UE = if isdefined(Base, :get_extension)
    Base.get_extension(UnicodePlots, :UnitfulExt)
else
    UnicodePlots.UnitfulExt
end

@testset "units" begin
    x = [1.0, 2.0, 3.0]
    @test UE.number_unit(x) == (x, nothing)
    @test UE.number_unit(1) == (1, nothing)
    @test UE.number_unit(x * u"°C") == (x, "°C")
    @test UE.number_unit(1u"°C") == (1, "°C")

    @test UE.unit_label("  fancy label  ", "Hz") == "  fancy label (Hz)"
    @test UE.unit_label("  ", "dB") == "dB"
    @test UE.unit_label("  no units  ", nothing) == "  no units"
end
