using UnicodePlots, StableRNGs
include(joinpath(dirname(pathof(UnicodePlots)), "..", "test", "fixes.jl"))

RNG = StableRNG(1337)

save(p, nm) = savefig(p, "imgs/$(ARGS[1])/$(nm).txt"; color=true)

# High-level Interface
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example Plot", name="my line", xlabel="x", ylabel="y", border=:dotted); save(plt, "lineplot1")
save(lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example Plot", name="my line", xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii), "lineplot2")
save(lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name="other line"), "lineplot3")
# Scatter Plot
save(scatterplot(randn(RNG, 50), randn(RNG, 50), title="My Scatterplot", border=:dotted), "scatterplot1")
save(scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted), "scatterplot2")
save(scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted, unicode_exponent=false), "scatterplot3")
save(scatterplot([1, 2, 3], [3, 4, 1], marker=[:circle, '😀', "∫"], color=[:red, nothing, :yellow], border=:dotted), "scatterplot4")
# Line Plot
save(lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot", border=:dotted), "lineplot4")
plt = lineplot([cos, sin], -π / 2, 2π, border=:dotted); save(plt, "lineplot5")
save(lineplot!(plt, -.5, .2, name="line"), "lineplot6")
# Staircase Plot
save(stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], color=:red, style=:post, title="My Staircase Plot", border=:dotted), "stairs1")
# Bar Plot
save(barplot(["Paris", "New York", "Moskau", "Madrid"], [2.244, 8.406, 11.92, 3.165], title="Population"), "barplot1")
# Histogram
save(histogram(randn(RNG, 1000) .* .1, nbins=15, closed=:left), "histogram1")
save(histogram(randn(RNG, 1000) .* .1, nbins=15, closed=:right, xscale=:log10), "histogram2")
# Box Plot
save(boxplot([1, 3, 3, 4, 6, 10]), "boxplot1")
save(boxplot(["one", "two"], [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]], title="Grouped Boxplot", xlabel="x"), "boxplot2")
# Sparsity Pattern
save(spy(_stable_sprand(RNG, 50, 120, .05), border=:dotted), "spy1")
save(spy(_stable_sprand(RNG, 50, 120, .9), show_zeros=true, border=:dotted), "spy2")
# Density Plot
plt = densityplot(randn(RNG, 1000), randn(RNG, 1000))
save(densityplot!(plt, randn(RNG, 1000) .+ 2, randn(RNG, 1000) .+ 2), "densityplot1")
# Heatmap Plot
save(heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z"), "heatmap1")
save(heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno), "heatmap2")
# Contour Plot
save(contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2), border=:dotted), "contourplot1")

# Options
save(lineplot(sin, 1:.5:20, width=60, border=:dotted), "width")
save(lineplot(sin, 1:.5:20, height=18, border=:dotted), "height")
save(lineplot([-1., 2, 3, 7], [1., 2, 9, 4], canvas=DotCanvas, border=:bold), "border_bold")
save(lineplot([-1., 2, 3, 7], [1., 2, 9, 4], canvas=DotCanvas, border=:dashed), "border_dashed")
save(lineplot([-1., 2, 3, 7], [1., 2, 9, 4], border=:dotted), "border_dotted")
save(lineplot([-1., 2, 3, 7], [1., 2, 9, 4], border=:none), "border_none")
save(lineplot(sin, 1:.5:20, labels=false, border=:dotted), "labels")

# Methods
x = y = collect(1:10)
plt = lineplot(x, y, canvas=DotCanvas, width=30, height=10)
lineplot!(plt, x, reverse(y))
title!(plt, "Plot Title")
for loc in (:tl, :t, :tr, :bl, :b, :br)
  label!(plt, loc, ":$(loc)")
end
label!(plt, :l, ":l")
label!(plt, :r, ":r")
for i in 1:10
  label!(plt, :l, i, string(i))
  label!(plt, :r, i, string(i))
end
save(plt, "decorate")

# Low-level Interface
canvas = BrailleCanvas(40, 15, origin_x=0., origin_y=0., width=1., height=1.)
lines!(canvas, 0., 0., 1., 1., :blue)
points!(canvas, rand(RNG, 50), rand(RNG, 50), :red)
lines!(canvas, 0., 1., .5, 0., :yellow)
pixel!(canvas, 5, 8, :green)
save(Plot(canvas, border=:dotted), "canvas")

canvas = BrailleCanvas(40, 15, origin_x=0., origin_y=0., width=1., height=1.)
lines!(canvas, 0., 0., 1., 1., :blue)
lines!(canvas, .25, 1., .5, 0., :yellow)
lines!(canvas, .2, .8, 1., 0., :red)
save(Plot(canvas, border=:dotted), "blending")
