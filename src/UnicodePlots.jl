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
    ctx = IOContext(devnull, :color => Base.get_have_color())
    @precompile_all_calls begin
        for T ∈ (Int, Float64)  # most common types
            I = one(T)
            plots = (
                lineplot(I:2),
                lineplot(I:2, I:2),
                lineplot(I:2, T[0:1 2:3]),
                lineplot([cos, sin], -π / 2, 2π),
                scatterplot(I:2),
                scatterplot(I:2, I:2),
                scatterplot(I:2, T[0:1 2:3]),
                stairs(T[1, 2, 4], T[1, 3, 4]),
                barplot(["Paris", "New York"], T[2, 8]),
                boxplot(T[1, 2, 3]),
                boxplot(["one", "two"], [collect(I:3), collect(I:4)]),
                histogram(T[1, 2, 3]),
                histogram(T[1, 2, 3]; vertical = true),
                polarplot(0:(π / 4):π, I:5),
                densityplot(T[1, 2], T[3, 4]; dscale = x -> log(1 + x)),
                heatmap(repeat(collect(T, 0:4)', outer = (5, 1))),
                spy(T[1 -1 0; -1 2 1; 0 -1 1]),
                contourplot(I:4, I:2, (x, y) -> exp(-(x / 2)^2 - (y - 2)^2)),
                surfaceplot(I:4, I:2, (x, y) -> sinc(√(x^2 + y^2)); lines = true),
                isosurface(I:4, I:2, I:3, (x, y, z) -> float(x^2 + y^2 - z^2 - 1)),
            )
            foreach(p -> show(ctx, p), plots)
        end
    end
end

end
