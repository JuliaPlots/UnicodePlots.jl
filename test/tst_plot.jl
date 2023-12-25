@testset "empty" begin
    canvas =
        BrailleCanvas(10, 40, origin_y = 0.0, origin_x = 0.0, height = 1.0, width = 1.0)
    p = @inferred Plot(canvas)
    @test_throws ArgumentError Plot(canvas, margin = -1)
    test_ref("plot/empty.txt", @show_col(p))
    p = @inferred Plot(
        BrailleCanvas(5, 30; origin_y = 0.0, origin_x = 0.0, height = 1.0, width = 1.0),
    )
    test_ref("plot/empty_small.txt", @show_col(p))

    # empty plot ctor
    p = Plot()
    @test p isa Plot
    p = Plot([], [])
    @test p isa Plot
    p = Plot([], [], [])
    @test p isa Plot

    p = Plot([], []; xlim = (-3, 5), ylim = (-10, 2))
    test_ref("plot/empty_xylim.txt", @show_col(p))
end

@testset "invisible" begin
    p = Plot([0], [0], width = 0)
    @test !p.graphics.visible
end

@testset "width - height, :auto" begin
    p = Plot([0], [0], height = :auto, width = :auto)
    @test p isa Plot
end

@testset "x/y ticks" begin
    p = Plot([0, 1], [0, 1], xticks = false)
    test_ref("plot/noxticks.txt", @show_col(p))

    p = Plot([0, 1], [0, 1], yticks = false)
    test_ref("plot/noyticks.txt", @show_col(p))
end

function _test_canvas(; kw...)
    canvas = BrailleCanvas(
        10,
        40;
        origin_y = 0.0,
        origin_x = 0.0,
        height = 1.0,
        width = 1.0,
        kw...,
    )
    lines!(canvas, 0.0, 0.0, 1.0, 1.0; color = :blue)
    lines!(canvas, 0.2, 0.7, 1.0, 0.0; color = :red)
    lines!(canvas, 0.0, 2.0, 0.5, 0.0; color = :green)
    points!(canvas, 0.5, 0.8)
    canvas
end

@testset "canvas / xylabel" begin
    p = @inferred Plot(_test_canvas())
    test_ref("plot/canvas_only.txt", @print_col(p))
    test_ref("plot/canvas_only.txt", @show_col(p))

    for border ∈ (:solid, :corners, :barplot, :bold, :ascii, :none, :dashed, :dotted)
        local p = @inferred Plot(_test_canvas(); border)
        test_ref("plot/border_$(string(border)).txt", @show_col(p))
    end

    p = @inferred Plot(_test_canvas(), xlabel = "x", ylabel = "y")
    test_ref("plot/xylabel.txt", @show_col(p))

    p = @inferred Plot(_test_canvas(), xlabel = "x", ylabel = "y", compact = true)
    test_ref("plot/xylabel_compact.txt", @show_col(p))
end

@testset "xyflip" begin
    p = Plot(_test_canvas(; xflip = true))
    test_ref("plot/xflip.txt", @show_col(p))
    p = Plot(_test_canvas(; yflip = true))
    test_ref("plot/yflip.txt", @show_col(p))
    p = Plot(_test_canvas(; xflip = true, yflip = true))
    test_ref("plot/xyflip.txt", @show_col(p))
end

@testset "padding" begin
    p = @inferred Plot(
        _test_canvas(),
        title = "testtitle",
        xlabel = "x",
        ylabel = "y",
        margin = 4,
        padding = 5,
    )
    @test @inferred(label!(p, :l, ":l auto 1")) ≡ p
    @test @inferred(label!(p, :r, ":r auto 1", :red)) ≡ p
    test_ref("plot/padding.txt", @show_col(p))

    p = @inferred Plot(
        _test_canvas(),
        title = "testtitle",
        xlabel = "x",
        ylabel = "y",
        margin = 4,
        padding = 5,
        labels = false,
    )
    @test @inferred(label!(p, :l, ":l auto 1")) ≡ p
    @test @inferred(label!(p, :r, ":r auto 1", :red)) ≡ p
    test_ref("plot/padding_nolabels.txt", @show_col(p))
end

@testset "title / labels / full deco" begin
    p = @inferred Plot(_test_canvas(), title = "testtitle")
    test_ref("plot/title.txt", @show_col(p))
    @test @inferred(label!(p, :l, ":l auto 1")) ≡ p
    @test @inferred(label!(p, :r, ":r auto 1", :red)) ≡ p
    @test @inferred(label!(p, :l, ":l auto 2", :green)) ≡ p
    @test @inferred(label!(p, :r, ":r auto 2", :blue)) ≡ p
    test_ref("plot/title_auto.txt", @show_col(p))

    for i ∈ 1:10
        @test @inferred(label!(p, :l, i, "$i", color = :green)) ≡ p
        @test @inferred(label!(p, :r, i, "$i", :yellow)) ≡ p
    end
    @test_throws ArgumentError label!(p, :bl, 5, ":l  5", :red)
    @test_throws ArgumentError label!(p, :d, ":l auto", :red)
    @test @inferred(label!(p, :l, 5, ":l  5", :red)) ≡ p
    @test @inferred(label!(p, :r, 5, "5  :r", color = :blue)) ≡ p
    @test @inferred(label!(p, :t, ":t", color = :yellow)) ≡ p
    @test @inferred(label!(p, :tl, ":tl", :cyan)) ≡ p
    @test @inferred(label!(p, :tr, ":tr")) ≡ p
    label!(p, :bl, ":bl", :blue)
    label!(p, :b, ":b", :green)
    label!(p, :br, ":br", :white)

    @test @inferred(lines!(p, 0.0, 1.0, 1.0, 0.0, color = (0, 0, 255))) ≡ p
    @test @inferred(pixel!(p, 10, 1, color = (255, 255, 0))) ≡ p
    @test @inferred(points!(p, 0.05, 0.75, color = (0, 255, 0))) ≡ p

    ttl = "title!(plot, text)"
    @test @inferred(title!(p, ttl)) ≡ p
    @test @inferred(title(p)) == ttl
    xlab = "xlabel!(plot, text)"
    @test @inferred(xlabel!(p, xlab)) ≡ p
    @test @inferred(xlabel(p)) == xlab
    ylab = "ylabel!(plot, text)"
    @test @inferred(ylabel!(p, ylab)) ≡ p
    @test @inferred(ylabel(p)) == ylab
    zlab = "zlabel!(plot, text)"
    @test @inferred(zlabel!(p, zlab)) ≡ p
    @test @inferred(zlabel(p)) == zlab

    test_ref("plot/full_deco.txt", @show_col(p))
    tmp = tempname()
    savefig(p, tmp; color = true)
    test_ref("plot/full_deco.txt", read(tmp, String))

    test_ref("plot/full_deco_nocolor.txt", @show_nocol(p))
    tmp = tempname()
    savefig(p, tmp; color = false)
    test_ref("plot/full_deco_nocolor.txt", read(tmp, String))
end

@testset "annotations" begin
    p = @inferred Plot(_test_canvas())
    @test @inferred(annotate!(p, 0.5, 0.5, "Origin")) ≡ p
    @test @inferred(annotate!(p, 0.5, 1.0, "North")) ≡ p
    @test @inferred(annotate!(p, 1.0, 1.0, "North East"; halign = :right)) ≡ p
    @test @inferred(annotate!(p, 1.0, 0.5, "East"; halign = :right)) ≡ p
    @test @inferred(annotate!(p, 1.0, 0.0, "South East"; halign = :right)) ≡ p
    @test @inferred(annotate!(p, 0.5, 0.0, "South")) ≡ p
    @test @inferred(annotate!(p, 0.0, 0.0, "South West"; halign = :left)) ≡ p
    @test @inferred(annotate!(p, 0.0, 0.5, "West"; halign = :left)) ≡ p
    @test @inferred(annotate!(p, 0.0, 1.0, "North West"; halign = :left)) ≡ p
    @test @inferred(annotate!(p, 0.0, 0.25, '🗹')) ≡ p  # Char
    test_ref("plot/annotations_BrailleCanvas.txt", @show_col(p))

    for sym ∈ (:AsciiCanvas, :DotCanvas, :BlockCanvas)
        p = lineplot([-1, 1], [-1, 1], canvas = getproperty(UnicodePlots, sym))
        annotate!(p, +0, +0, "Origin")
        annotate!(p, +0, +1, "North")
        annotate!(p, +1, +1, "North East"; halign = :right)
        annotate!(p, +1, +0, "East"; halign = :right)
        annotate!(p, +1, -1, "South East"; halign = :right)
        annotate!(p, +0, -1, "South")
        annotate!(p, -1, -1, "South West"; halign = :left)
        annotate!(p, -1, +0, "West"; halign = :left)
        annotate!(p, -1, +1, "North West"; halign = :left)
        test_ref("plot/annotations_$sym.txt", @show_col(p))
    end

    p = lineplot([-1, 1], [-1, 1])
    for h ∈ (:right, :left, :center, :hcenter), v ∈ (:top, :bottom, :center, :vcenter)
        annotate!(p, 0, 0, "Origin"; halign = h, valign = v)
    end
end

@testset "mutability" begin
    pl = lineplot(1:2)
    pl.margin[] = pl.padding[] = 0
    pl.title[] = "foo"
    pl.xlabel[] = "x"
    pl.ylabel[] = "y"
    pl.zlabel[] = "z"
    @test show(devnull, pl) == (20, 45)
end

@testset "formatter" begin
    p = lineplot(1:4, 1:4; xscale = :log10, yscale = :ln, unicode_exponent = false)
    test_ref("plot/no_unicode_exponent.txt", @show_col(p))

    xlim = ylim = (1_000, 1_000_000)

    p = lineplot(1:1; xlim, ylim, thousands_separator = '\0')
    test_ref("plot/no_thousands_separator.txt", @show_col(p))

    p = lineplot(1:1; xlim, ylim, thousands_separator = '_')
    test_ref("plot/underscore_thousands_separator.txt", @show_col(p))
end
