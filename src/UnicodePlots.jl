__precompile__()
module UnicodePlots

using Base.Dates
using Compat
import StatsBase: Histogram, fit

export

    GraphicsArea,
        Canvas,
            BrailleCanvas,
            DensityCanvas,
            BlockCanvas,
            AsciiCanvas,
            DotCanvas,
        BarplotGraphics,

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
    spy

include("common.jl")
include("canvas.jl")
include("graphics/lookupcanvas.jl")
include("graphics/braillecanvas.jl")
include("graphics/densitycanvas.jl")
include("graphics/blockcanvas.jl")
include("graphics/asciicanvas.jl")
include("graphics/dotcanvas.jl")
include("graphics/bargraphics.jl")
include("plot.jl")
include("interface/barplot.jl")
include("interface/histogram.jl")
include("interface/scatterplot.jl")
include("interface/lineplot.jl")
include("interface/stairs.jl")
include("interface/densityplot.jl")
include("interface/spy.jl")
include("deprecated.jl")

end
