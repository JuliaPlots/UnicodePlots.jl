@testset "empty" begin
    canvas =
        BrailleCanvas(40, 10, origin_x = 0.0, origin_y = 0.0, width = 1.0, height = 1.0)
    p = @inferred Plot(canvas)
    @test_throws ArgumentError Plot(canvas, margin = -1)
    test_ref("plot/empty.txt", @show_col(p))
    canvas = BrailleCanvas(30, 5, origin_x = 0.0, origin_y = 0.0, width = 1.0, height = 1.0)
    p = @inferred Plot(canvas)
    test_ref("plot/empty_small.txt", @show_col(p))
end

canvas = BrailleCanvas(40, 10, origin_x = 0.0, origin_y = 0.0, width = 1.0, height = 1.0)
lines!(canvas, 0.0, 0.0, 1.0, 1.0, :blue)
lines!(canvas, 0.2, 0.7, 1.0, 0.0, :red)
lines!(canvas, 0.0, 2.0, 0.5, 0.0, :green)
points!(canvas, 0.5, 0.9)

@testset "canvas / xylabel" begin
    p = @inferred Plot(canvas)
    test_ref("plot/canvas_only.txt", @print_col(p))
    test_ref("plot/canvas_only.txt", @show_col(p))

    for border in (:solid, :corners, :barplot, :bold, :ascii, :none, :dashed, :dotted)
        local p = @inferred Plot(canvas, border = border)
        test_ref("plot/border_$(string(border)).txt", @show_col(p))
    end

    p = @inferred Plot(canvas, xlabel = "x", ylabel = "y")
    test_ref("plot/xylabel.txt", @show_col(p))

    p = @inferred Plot(canvas, xlabel = "x", ylabel = "y", compact = true)
    test_ref("plot/xylabel_compact.txt", @show_col(p))
end

@testset "padding" begin
    p = @inferred Plot(
        canvas,
        title = "testtitle",
        xlabel = "x",
        ylabel = "y",
        margin = 4,
        padding = 5,
    )
    @test @inferred(label!(p, :l, ":l auto 1")) === p
    @test @inferred(label!(p, :r, ":r auto 1", :red)) === p
    test_ref("plot/padding.txt", @show_col(p))

    p = @inferred Plot(
        canvas,
        title = "testtitle",
        xlabel = "x",
        ylabel = "y",
        margin = 4,
        padding = 5,
        labels = false,
    )
    @test @inferred(label!(p, :l, ":l auto 1")) === p
    @test @inferred(label!(p, :r, ":r auto 1", :red)) === p
    test_ref("plot/padding_nolabels.txt", @show_col(p))
end

@testset "title / labels / full deco" begin
    p = @inferred Plot(canvas, title = "testtitle")
    test_ref("plot/title.txt", @show_col(p))
    @test @inferred(label!(p, :l, ":l auto 1")) === p
    @test @inferred(label!(p, :r, ":r auto 1", :red)) === p
    @test @inferred(label!(p, :l, ":l auto 2", :green)) === p
    @test @inferred(label!(p, :r, ":r auto 2", :blue)) === p
    test_ref("plot/title_auto.txt", @show_col(p))

    for i in 1:10
        @test @inferred(label!(p, :l, i, "$i", color = :green)) === p
        @test @inferred(label!(p, :r, i, "$i", :yellow)) === p
    end
    @test_throws ArgumentError label!(p, :bl, 5, ":l  5", :red)
    @test_throws ArgumentError label!(p, :d, ":l auto", :red)
    @test @inferred(label!(p, :l, 5, ":l  5", :red)) === p
    @test @inferred(label!(p, :r, 5, "5  :r", color = :blue)) === p
    @test @inferred(label!(p, :t, ":t", color = :yellow)) === p
    @test @inferred(label!(p, :tl, ":tl", :cyan)) === p
    @test @inferred(label!(p, :tr, ":tr")) === p
    label!(p, :bl, ":bl", :blue)
    label!(p, :b, ":b", :green)
    label!(p, :br, ":br", :white)

    @test @inferred(lines!(p, 0.0, 1.0, 1.0, 0.0, color = (0, 0, 255))) === p
    @test @inferred(pixel!(p, 10, 1, color = (255, 255, 0))) === p
    @test @inferred(points!(p, 0.05, 0.75, color = (0, 255, 0))) === p

    ttl = "title!(plot, text)"
    @test @inferred(title!(p, ttl)) === p
    @test @inferred(title(p)) == ttl
    xlab = "xlabel!(plot, text)"
    @test @inferred(xlabel!(p, xlab)) === p
    @test @inferred(xlabel(p)) == xlab
    ylab = "ylabel!(plot, text)"
    @test @inferred(ylabel!(p, ylab)) === p
    @test @inferred(ylabel(p)) == ylab
    zlab = "zlabel!(plot, text)"
    @test @inferred(zlabel!(p, zlab)) === p
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
    p = @inferred Plot(canvas)
    @test @inferred(annotate!(p, 0.5, 0.5, "Origin")) === p
    @test @inferred(annotate!(p, 0.5, 1.0, "North")) === p
    @test @inferred(annotate!(p, 1.0, 1.0, "North East"; halign = :right)) === p
    @test @inferred(annotate!(p, 1.0, 0.5, "East"; halign = :right)) === p
    @test @inferred(annotate!(p, 1.0, 0.0, "South East"; halign = :right)) === p
    @test @inferred(annotate!(p, 0.5, 0.0, "South")) === p
    @test @inferred(annotate!(p, 0.0, 0.0, "South West"; halign = :left)) === p
    @test @inferred(annotate!(p, 0.0, 0.5, "West"; halign = :left)) === p
    @test @inferred(annotate!(p, 0.0, 1.0, "North West"; halign = :left)) === p
    test_ref("plot/annotations_BrailleCanvas.txt", @show_col(p))

    @test @inferred(annotate!(p, 0.0, 0.0, 'c')) === p  # Char

    for sym in (:AsciiCanvas, :DotCanvas, :BlockCanvas)
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
    for h in (:right, :left, :center, :hcenter), v in (:top, :bottom, :center, :vcenter)
        annotate!(p, 0, 0, "Origin"; halign = h, valign = v)
    end
end

@testset "invisible" begin
    p = Plot([0], [0], width = 0)
    @test !p.graphics.visible
end

@testset "x/y ticks" begin
    p = Plot([0, 1], [0, 1], xticks = false)
    test_ref("plot/no_xticks.txt", @show_col(p))

    p = Plot([0, 1], [0, 1], yticks = false)
    test_ref("plot/no_yticks.txt", @show_col(p))
end
