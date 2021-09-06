canvas = BrailleCanvas(40, 10, origin_x=0.0, origin_y=0.0, width=1.0, height=1.0)
p = @inferred Plot(canvas)
@test_throws ArgumentError Plot(canvas, margin=-1)
test_ref("references/plot/empty.txt", @show_col(p))
canvas = BrailleCanvas(30, 5, origin_x=0.0, origin_y=0.0, width=1.0, height=1.0)
p = @inferred Plot(canvas)
test_ref("references/plot/empty_small.txt", @show_col(p))

canvas = BrailleCanvas(40, 10, origin_x=0.0, origin_y=0.0, width=1.0, height=1.0)
lines!(canvas, 0.0, 0.0, 1.0, 1.0, :blue)
lines!(canvas, 0.2, 0.7, 1.0, 0.0, :red)
lines!(canvas, 0.0, 2.0, 0.5, 0.0, :green)
points!(canvas, 0.5, 0.9)

p = @inferred Plot(canvas)
test_ref("references/plot/canvas_only.txt", @print_col(p))
test_ref("references/plot/canvas_only.txt", @show_col(p))

for border in (:solid, :corners, :barplot, :bold, :ascii, :none, :dashed, :dotted)
    local p = @inferred Plot(canvas, border=border)
    test_ref("references/plot/border_$(string(border)).txt", @show_col(p))
end

p = @inferred Plot(canvas, xlabel="x", ylabel="y")
test_ref("references/plot/xylabel.txt", @show_col(p))

p = @inferred Plot(canvas, title="testtitle", xlabel="x", ylabel="y", margin=4, padding=5)
@test @inferred(annotate!(p, :l, ":l auto 1")) === p
@test @inferred(annotate!(p, :r, ":r auto 1", :red)) === p
test_ref("references/plot/padding.txt", @show_col(p))

p = @inferred Plot(
    canvas,
    title="testtitle",
    xlabel="x",
    ylabel="y",
    margin=4,
    padding=5,
    labels=false,
)
@test @inferred(annotate!(p, :l, ":l auto 1")) === p
@test @inferred(annotate!(p, :r, ":r auto 1", :red)) === p
test_ref("references/plot/padding_nolabels.txt", @show_col(p))

p = @inferred Plot(canvas, title="testtitle")
test_ref("references/plot/title.txt", @show_col(p))
@test @inferred(annotate!(p, :l, ":l auto 1")) === p
@test @inferred(annotate!(p, :r, ":r auto 1", :red)) === p
@test @inferred(annotate!(p, :l, ":l auto 2", :green)) === p
@test @inferred(annotate!(p, :r, ":r auto 2", :blue)) === p
test_ref("references/plot/title_auto.txt", @show_col(p))

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

@test @inferred(lines!(p, 0.0, 1.0, 1.0, 0.0, color=(0, 0, 255))) === p
@test @inferred(pixel!(p, 10, 1, color=(255, 255, 0))) === p
@test @inferred(points!(p, 0.05, 0.75, color=(0, 255, 0))) === p

ttl = "title!(plot, text)"
@test @inferred(title!(p, ttl)) === p
@test @inferred(title(p)) == ttl
xlab = "xlabel!(plot, text)"
@test @inferred(xlabel!(p, xlab)) === p
@test @inferred(xlabel(p)) == xlab
ylab = "ylabel!(plot, text)"
@test @inferred(ylabel!(p, ylab)) === p
@test @inferred(ylabel(p)) == ylab

test_ref("references/plot/full_deco.txt", @show_col(p))
tmp = tempname()
savefig(p, tmp; color=true)
test_ref("references/plot/full_deco.txt", read(tmp, String))

test_ref("references/plot/full_deco_nocolor.txt", @show_nocol(p))
tmp = tempname()
savefig(p, tmp; color=false)
test_ref("references/plot/full_deco_nocolor.txt", read(tmp, String))
