module UnicodePlots

using PrecompileTools
using LinearAlgebra
using StaticArrays
using ColorTypes
using Crayons
using Printf
using Dates

import StatsBase: Histogram, fit, percentile, sturges
import SparseArrays: AbstractSparseMatrix, findnz
import Base: RefValue

import MarchingCubes
import ColorSchemes
import NaNMath
import Contour

# composite types
export Plot,
    BarplotGraphics,
    BoxplotGraphics,
    GraphicsArea,
    BrailleCanvas,
    OctantCanvas,
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
    savefig,
    gridplot

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
include("canvas/octantcanvas.jl")
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
include("interface/imageplot.jl")

function __init__()
    forced_24bit() && return init_24bit()
    forced_8bit() && return init_8bit()
    get_have_truecolor() ? init_24bit() : init_8bit()
    return nothing
end

# COV_EXCL_START
function precompile_workload(io::IO = IOContext(devnull, :color => Base.get_have_color()))
    __init__()
    surf(x, y) = sinc(√(x^2 + y^2))
    for T in (  # most common types
            Float64,
            Int,
        )
        I = one(T)
        plots = (
            lineplot(I:2),
            lineplot(I:2, I:2),
            lineplot(-I, I, sin),
            lineplot((-I):I, sin),
            lineplot(-I, I, [sin, cos]),
            lineplot((-I):I, [sin, cos]),
            lineplot(I:2, T[0:1 2:3]),
            lineplot(I:2, I:2; xscale = :ln, yscale = :log10),
            lineplot([Date(2020), Date(2021)], I:2),
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
            heatmap(repeat(collect(T, 0:4)'; outer = (5, 1))),
            spy(T[1 -1 0; -1 2 1; 0 -1 1]),
            contourplot(surf.(meshgrid((-I):I, (-2I):(2I))...)),
            contourplot((-I):I, (-2I):(2I), surf),
            surfaceplot((-I):I, (-2I):(2I), surf; lines = true),
            surfaceplot((-I):I, (-2I):(2I), surf.(meshgrid((-I):I, (-2I):(2I))...)),
            isosurface((-I):4, I:2, I:3, (x, y, z) -> float(x^2 + y^2 - z^2 - 1)),
        )
        foreach(p -> show(io, p), plots)
    end
    return
end

@compile_workload begin
    precompile_workload()
end
# COV_EXCL_STOP

end
