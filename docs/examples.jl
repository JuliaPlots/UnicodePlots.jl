# lineplot1
using UnicodePlots
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
               title="Example Plot", name="my line", xlabel="x", ylabel="y", border=:dotted)

# lineplot2
lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
         title="Example Plot", name="my line",
         xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii)

# lineplot3
lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name="other line")
# scatterplot1
scatterplot(randn(50), randn(50), title="My Scatterplot", border=:dotted)
# scatterplot2
scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted)
# scatterplot3
scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted, unicode_exponent=false)
# scatterplot4
scatterplot([1, 2, 3], [3, 4, 1],
            marker=[:circle, '😀', "∫"], color=[:red, nothing, :yellow], border=:dotted)

# lineplot4
lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot", border=:dotted)
# lineplot5
plt = lineplot([cos, sin], -π/2, 2π, border=:dotted)
# lineplot6
lineplot!(plt, -.5, .2, name="line")
# stairs1
# supported style are :pre and :post
stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7],
        color=:red, style=:post, title="My Staircase Plot", border=:dotted)

# barplot1
barplot(["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title="Population")

# histogram1
histogram(randn(1000) .* .1, nbins=15, closed=:left)
# histogram2
histogram(randn(1000) .* .1, nbins=15, closed=:right, xscale=:log10)
# boxplot1
boxplot([1, 3, 3, 4, 6, 10])
# boxplot2
boxplot(["one", "two"],
        [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
        title="Grouped Boxplot", xlabel="x")

# spy1
using SparseArrays
spy(sprandn(50, 120, .05), border=:dotted)
# spy2
using SparseArrays
spy(sprandn(50, 120, .9), show_zeros=true, border=:dotted)
# densityplot1
plt = densityplot(randn(1000), randn(1000))
densityplot!(plt, randn(1000) .+ 2, randn(1000) .+ 2)

# contourplot1
contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2))
# heatmap1
heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
# heatmap2
heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno)
# width
lineplot(sin, 1:.5:20, width=60)
# height
lineplot(sin, 1:.5:20, height=18)
# labels
lineplot(sin, 1:.5:20, labels=false)
# border_bold
lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold)
# border_dashed
lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed)
# border_dotted
lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:dotted)
# border_none
lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:none)
# decorate
x = y = collect(1:10)
plt = lineplot(x, y, canvas=DotCanvas, width=30, height=10)
lineplot!(plt, x, reverse(y))
title!(plt, "Plot Title")
for loc in (:tl, :t, :tr, :bl, :b, :br)
  label!(plt, loc, string(':', loc))
end
label!(plt, :l, ":l")
label!(plt, :r, ":r")
for i in 1:10
  label!(plt, :l, i, string(i))
  label!(plt, :r, i, string(i))
end

# canvas
canvas = BrailleCanvas(40, 10,                    # number of columns and rows (characters)
                       origin_x=0., origin_y=0.,  # position in virtual space
                       width=1., height=1.)       # size of the virtual space
lines!(canvas, 0., 0., 1., 1., :blue)      # virtual space
points!(canvas, rand(50), rand(50), :red)  # virtual space
lines!(canvas, 0., 1., .5, 0., :yellow)    # virtual space
pixel!(canvas, 5, 8, :red)                 # pixel space

# blending
canvas = BrailleCanvas(40, 15, origin_x=0., origin_y=0., width=1., height=1.)
lines!(canvas, 0., 0., 1., 1., :blue)
lines!(canvas, .25, 1., .5, 0., :yellow)
lines!(canvas, .2, .8, 1., 0., :red)

