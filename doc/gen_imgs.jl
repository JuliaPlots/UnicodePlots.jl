using UnicodePlots
using SparseArrays

save(p, nm) = savefig(p, "imgs/$(ARGS[1])/$(nm).txt"; color=true)

# High-level Interface
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example Plot", name="my line", xlabel="x", ylabel="y", border=:dotted); save(plt, "lineplot1")
save(lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example Plot", name="my line", xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii), "lineplot2")
save(lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name="other line"), "lineplot3")
# scatterplot
save(scatterplot(randn(50), randn(50), title="My Scatterplot", border=:dotted), "scatterplot1")
save(scatterplot(1:10, 1:10, xscale=:log10, yscale=:log10), "scatterplot2")
# lineplot
save(lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot", border=:dotted), "lineplot4")
plt = lineplot([cos, sin], -π / 2, 2π, border=:dotted); save(plt, "lineplot5")
save(lineplot!(plt, -.5, .2, name="line"), "lineplot6")
# Staircase plot
save(stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], color=:red, style=:post, title="My Staircase Plot", border=:dotted), "stairs1")
# Barplot
save(barplot(["Paris", "New York", "Moskau", "Madrid"], [2.244, 8.406, 11.92, 3.165], title="Population"), "barplot1")
# Histogram
save(histogram(randn(1000) .* .1, nbins=15, closed=:left), "histogram1")
save(histogram(randn(1000) .* .1, nbins=15, closed=:right, xscale=log10), "histogram2")
# Boxplot
save(boxplot([1, 3, 3, 4, 6, 10]), "boxplot1")
save(boxplot(["one", "two"], [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]], title="Grouped Boxplot", xlabel="x"), "boxplot2")
# Sparsity Pattern
save(spy(sprandn(50, 120, .05), border=:dotted), "spy1")
# Density Plot
plt = densityplot(randn(1000), randn(1000))
save(densityplot!(plt, randn(1000) .+ 2, randn(1000) .+ 2), "density1")
# Heatmap Plot
save(heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z"), "heatmap1")
save(heatmap(collect(0:30) * collect(0:30)', xscale=.1, yscale=.1, xoffset=-1.5, colormap=:inferno), "heatmap2")

# Options
save(lineplot(sin, 1:.5:20, width=60, border=:dotted), "width")
save(lineplot(sin, 1:.5:20, height=18, border=:dotted), "height")
save(lineplot(sin, 1:.5:20, labels=false, border=:dotted), "labels")
