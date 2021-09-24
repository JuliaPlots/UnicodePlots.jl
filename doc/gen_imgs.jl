using UnicodePlots
using SparseArrays
using StableRNGs
using Random

RNG = StableRNG(1337)
function stable_sprand(r::AbstractRNG, m::Integer, n::Integer, density::AbstractFloat)
  I = Int[]
  J = Int[]
  for li in randsubseq(r, 1:(m * n), density)
    j, i = divrem(li - 1, m)
    push!(I, i + 1)
    push!(J, j + 1)
  end
  V = rand(r, length(I))
  return sparse(I, J, V)
end

save(p, nm) = savefig(p, "imgs/$(ARGS[1])/$(nm).txt"; color=true)

# High-level Interface
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example Plot", name="my line", xlabel="x", ylabel="y", border=:dotted); save(plt, "lineplot1")
save(lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example Plot", name="my line", xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii), "lineplot2")
save(lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name="other line"), "lineplot3")
# scatterplot
save(scatterplot(randn(RNG, 50), randn(RNG, 50), title="My Scatterplot", border=:dotted), "scatterplot1")
save(scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted), "scatterplot2")
save(scatterplot([1, 2, 3], [3, 4, 1], marker=:circle, border=:dotted), "scatterplot3")
# lineplot
save(lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot", border=:dotted), "lineplot4")
plt = lineplot([cos, sin], -π / 2, 2π, border=:dotted); save(plt, "lineplot5")
save(lineplot!(plt, -.5, .2, name="line"), "lineplot6")
# Staircase plot
save(stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], color=:red, style=:post, title="My Staircase Plot", border=:dotted), "stairs1")
# Barplot
save(barplot(["Paris", "New York", "Moskau", "Madrid"], [2.244, 8.406, 11.92, 3.165], title="Population"), "barplot1")
# Histogram
save(histogram(randn(RNG, 1000) .* .1, nbins=15, closed=:left), "histogram1")
save(histogram(randn(RNG, 1000) .* .1, nbins=15, closed=:right, xscale=:log10), "histogram2")
# Boxplot
save(boxplot([1, 3, 3, 4, 6, 10]), "boxplot1")
save(boxplot(["one", "two"], [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]], title="Grouped Boxplot", xlabel="x"), "boxplot2")
# Sparsity Pattern
save(spy(stable_sprand(RNG, 50, 120, .05), border=:dotted), "spy1")
# Density Plot
plt = densityplot(randn(RNG, 1000), randn(RNG, 1000))
save(densityplot!(plt, randn(RNG, 1000) .+ 2, randn(RNG, 1000) .+ 2), "densityplot1")
# Heatmap Plot
save(heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z"), "heatmap1")
save(heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno), "heatmap2")

# Options
save(lineplot(sin, 1:.5:20, width=60, border=:dotted), "width")
save(lineplot(sin, 1:.5:20, height=18, border=:dotted), "height")
save(lineplot([-1.,2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold), "border_bold")
save(lineplot([-1.,2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed), "border_dashed")
save(lineplot([-1.,2, 3, 7], [1.,2, 9, 4], border=:dotted), "border_dotted")
save(lineplot([-1.,2, 3, 7], [1.,2, 9, 4], border=:none), "border_none")
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
