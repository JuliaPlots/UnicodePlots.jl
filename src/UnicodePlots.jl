module UnicodePlots

using SparseArrays: AbstractSparseMatrix, findnz
using StatsBase: Histogram, fit, percentile
using SnoopPrecompile
using LinearAlgebra
using ColorSchemes
using StaticArrays
using LazyModules
using ColorTypes
using Requires
using Crayons
using Printf
using Dates

import Unitful: Quantity, RealOrRealQuantity, ustrip, unit
import LinearAlgebra: Transpose
import Base: RefValue
import MarchingCubes
import NaNMath
import Contour

@lazy import FreeTypeAbstraction = "663a7486-cb36-511b-a19d-713bb74d65c9"
import FileIO

# composite types
export Plot,
    BarplotGraphics,
    BoxplotGraphics,
    GraphicsArea,
    BrailleCanvas,
    DensityCanvas,
    HeatmapCanvas,
    BlockCanvas,
    AsciiCanvas,
    DotCanvas,
    Canvas,
    MVP

# helpers
export default_size!,
    annotate!,
    title!,
    title,
    label!,
    xlabel!,
    xlabel,
    ylabel!,
    ylabel,
    zlabel!,
    zlabel,
    vline!,
    hline!,
    savefig

# methods with mutating variants
export scatterplot!,
    scatterplot,
    lineplot!,
    lineplot,
    densityplot!,
    densityplot,
    contourplot!,
    contourplot,
    surfaceplot!,
    surfaceplot,
    isosurface!,
    isosurface,
    polarplot!,
    polarplot,
    barplot!,
    barplot,
    boxplot!,
    boxplot,
    stairs!,
    stairs

# methods without mutating variants
export horizontal_histogram, vertical_histogram, histogram, heatmap, spy, imageplot

include("common.jl")
include("lut.jl")

include("graphics.jl")
include("graphics/bargraphics.jl")
include("graphics/boxgraphics.jl")
include("graphics/imagegraphics.jl")

include("canvas.jl")
include("canvas/lookupcanvas.jl")
include("canvas/braillecanvas.jl")
include("canvas/densitycanvas.jl")
include("canvas/blockcanvas.jl")
include("canvas/asciicanvas.jl")
include("canvas/dotcanvas.jl")
include("canvas/heatmapcanvas.jl")

include("description.jl")
include("volume.jl")

include("plot.jl")
include("show.jl")
include("interface/barplot.jl")
include("interface/histogram.jl")
include("interface/scatterplot.jl")
include("interface/contourplot.jl")
include("interface/surfaceplot.jl")
include("interface/isosurface.jl")
include("interface/lineplot.jl")
include("interface/stairs.jl")
include("interface/densityplot.jl")
include("interface/heatmap.jl")
include("interface/spy.jl")
include("interface/boxplot.jl")
include("interface/polarplot.jl")

@precompile_setup begin
    buf = IOContext(PipeBuffer(), :color => true, :displaysize => displaysize(stdout))
    @precompile_all_calls begin
        plots = (
            lineplot(1:2),
            lineplot(1:2, 1:2),
            lineplot(1:2, [0:1 2:3]),
            lineplot([cos, sin], -π / 2, 2π),
            scatterplot(1:2),
            scatterplot(1:2, 1:2),
            scatterplot(1:2, [0:1 2:3]),
            stairs([1.0, 2, 4], [1, 3, 4]),
            barplot(["Paris", "New York"], [2.244, 8.406]),
            boxplot([1.0, 2, 3]),
            boxplot(["one", "two"], [collect(1:3), collect(3:4)]),
            histogram([1.0, 2, 3]),
            histogram([1.0, 2, 3]; vertical = true),
            polarplot(0:(π / 4):π, 0:4),
            densityplot([1.0, 2, 3], [1.0, 2, 3]; dscale = x -> log(1 + x)),
            heatmap(repeat(collect(0:4)', outer = (5, 1))),
            spy([1 -1 0; -1 2 1; 0 -1 1]),
            contourplot(-2:2, -2:2, (x, y) -> exp(-(x / 2)^2 - (y + 2)^2)),
            surfaceplot(-1.0:1.0, -1.0:1.0, (x, y) -> sinc(√(x^2 + y^2)); lines = true),
            isosurface(-1.0:1.0, -1.0:1.0, -1.0:1.0, (x, y, z) -> x^2 + y^2 - z^2 - 1),
        )
        foreach(p -> show(buf, p), plots)
    end
end

end
