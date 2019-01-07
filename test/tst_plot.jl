canvas = BrailleCanvas(40, 10, origin_x = 0., origin_y = 0., width = 1., height = 1.)
p = @inferred Plot(canvas)
@test_throws ArgumentError Plot(canvas, margin=-1)
@test_reference(
    "references/plot/empty.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
canvas = BrailleCanvas(30, 5, origin_x = 0., origin_y = 0., width = 1., height = 1.)
p = @inferred Plot(canvas)
@test_reference(
    "references/plot/empty_small.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

canvas = BrailleCanvas(40, 10, origin_x = 0., origin_y = 0., width = 1., height = 1.)
lines!(canvas, 0., 0., 1., 1., :blue)
lines!(canvas, .2, .7, 1., 0., :red)
lines!(canvas, 0., 2., .5, 0., :green)
points!(canvas, .5, .9)

p = @inferred Plot(canvas)
@test_reference(
    "references/plot/canvas_only.txt",
    @io2str(print(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
@test_reference(
    "references/plot/canvas_only.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

for border in (:solid, :corners, :barplot, :bold, :ascii, :none, :dashed, :dotted)
    p = @inferred Plot(canvas, border = border)
    @test_reference(
        "references/plot/border_$(string(border)).txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

p = @inferred Plot(canvas, xlabel = "x", ylabel= "y")
@test_reference(
    "references/plot/xylabel.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

p = @inferred Plot(canvas, title = "testtitle", xlabel = "x", ylabel= "y", margin = 4, padding = 5)
@test @inferred(annotate!(p, :l, ":l auto 1")) === p
@test @inferred(annotate!(p, :r, ":r auto 1", :red)) === p
@test_reference(
    "references/plot/padding.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

p = @inferred Plot(canvas, title = "testtitle", xlabel = "x", ylabel= "y", margin = 4, padding = 5, labels = false)
@test @inferred(annotate!(p, :l, ":l auto 1")) === p
@test @inferred(annotate!(p, :r, ":r auto 1", :red)) === p
@test_reference(
    "references/plot/padding_nolabels.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

p = @inferred Plot(canvas, title = "testtitle")
@test_reference(
    "references/plot/title.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
@test @inferred(annotate!(p, :l, ":l auto 1")) === p
@test @inferred(annotate!(p, :r, ":r auto 1", :red)) === p
@test @inferred(annotate!(p, :l, ":l auto 2", :green)) === p
@test @inferred(annotate!(p, :r, ":r auto 2", :blue)) === p
@test_reference(
    "references/plot/title_auto.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

for i in 1:10
    @test @inferred(annotate!(p, :l, i, "$i", color=:green)) === p
    @test @inferred(annotate!(p, :r, i, "$i", :yellow)) === p
end
@test_throws ArgumentError annotate!(p, :bl, 5, ":l  5", :red)
@test_throws ArgumentError annotate!(p, :d, ":l auto", :red)
@test @inferred(annotate!(p, :l, 5, ":l  5", :red)) === p
@test @inferred(annotate!(p, :r, 5, "5  :r", color=:blue)) === p
@test @inferred(annotate!(p, :t, ":t", color=:yellow)) === p
@test @inferred(annotate!(p, :tl, ":tl", :cyan)) === p
@test @inferred(annotate!(p, :tr, ":tr")) === p
annotate!(p, :bl, ":bl", :blue)
annotate!(p, :b, ":b", :green)
annotate!(p, :br, ":br", :white)

@test @inferred(lines!(p, 0., 1., 1., 0., color=:blue)) === p
@test @inferred(pixel!(p, 10, 1, color = :yellow)) === p
@test @inferred(points!(p, 0.05, .75, color = :green)) === p

ttl = "title!(plot, text)"
@test @inferred(title!(p, ttl)) === p
@test @inferred(title(p)) == ttl
xlab = "xlabel!(plot, text)"
@test @inferred(xlabel!(p, xlab)) === p
@test @inferred(xlabel(p)) == xlab
ylab = "ylabel!(plot, text)"
@test @inferred(ylabel!(p, ylab)) === p
@test @inferred(ylabel(p)) == ylab

@test_reference(
    "references/plot/full_deco.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
@test_reference(
    "references/plot/full_deco_nocolor.txt",
    @io2str(show(::IO, p)),
    render = BeforeAfterFull()
)
