module UnicodePlots

using LazyModules

using Dates
using Crayons
using StatsBase: Histogram, fit, percentile
using SparseArrays: AbstractSparseMatrix, findnz
using LinearAlgebra
using StaticArrays
using Printf

import Unitful: Quantity, RealOrRealQuantity, ustrip, unit
import MarchingCubes
import NaNMath
import Contour

@lazy import FreeTypeAbstraction = "663a7486-cb36-511b-a19d-713bb74d65c9"
import ColorTypes
@lazy import FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"

export GraphicsArea,
    Canvas,
    BrailleCanvas,
    DensityCanvas,
    BlockCanvas,
    AsciiCanvas,
    DotCanvas,
    HeatmapCanvas,
    BarplotGraphics,
    BoxplotGraphics,
    pixel_width,
    pixel_height,
    pixel_size,
    width,
    height,
    origin_x,
    origin_y,
    origin,
    printrow,
    nrows,
    ncols,
    pixel!,
    points!,
    lines!,
    addrow!,
    Plot,
    title,
    title!,
    xlabel,
    xlabel!,
    ylabel,
    ylabel!,
    zlabel,
    zlabel!,
    label!,
    annotate!,
    barplot,
    barplot!,
    lineplot,
    lineplot!,
    scatterplot,
    scatterplot!,
    contourplot,
    contourplot!,
    surfaceplot,
    surfaceplot!,
    isosurface,
    isosurface!,
    stairs,
    stairs!,
    histogram,
    vertical_histogram,
    horizontal_histogram,
    densityplot,
    densityplot!,
    heatmap,
    spy,
    boxplot,
    boxplot!,
    polarplot,
    polarplot!,
    MVP,
    savefig

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
include("colormaps.jl")
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
