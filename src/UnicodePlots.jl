module UnicodePlots

using Dates
using StatsBase: Histogram, fit, percentile
using SparseArrays: AbstractSparseMatrix, findnz

export

    GraphicsArea,
        Canvas,
            BrailleCanvas,
            DensityCanvas,
            BlockCanvas,
            AsciiCanvas,
            DotCanvas,
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
    title, title!,
    xlabel, xlabel!,
    ylabel, ylabel!,
    annotate!,

    barplot, barplot!,
    lineplot, lineplot!,
    scatterplot, scatterplot!,
    stairs, stairs!,
    histogram,
    densityplot, densityplot!,
    spy,
    boxplot, boxplot!

include("common.jl")

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

include("plot.jl")
include("interface/barplot.jl")
include("interface/histogram.jl")
include("interface/scatterplot.jl")
include("interface/lineplot.jl")
include("interface/stairs.jl")
include("interface/densityplot.jl")
include("interface/spy.jl")
include("interface/boxplot.jl")

end
