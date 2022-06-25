module UnicodePlots

using SparseArrays: AbstractSparseMatrix, findnz
using StatsBase: Histogram, fit, percentile
using LinearAlgebra
using ColorSchemes
using StaticArrays
using LazyModules
using ColorTypes
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
export horizontal_histogram, vertical_histogram, histogram, heatmap, spy

include("common.jl")
include("lut.jl")

include("graphics.jl")
include("graphics/bargraphics.jl")
include("graphics/boxgraphics.jl")

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

end
