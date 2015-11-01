isdefined(Base, :__precompile__) && __precompile__()
module UnicodePlots

using Base.Dates

export

    GraphicsArea,
      Canvas,
        BrailleCanvas,
        DensityCanvas,
        BlockCanvas,
        AsciiCanvas,
        DotCanvas,
      BarplotGraphics,

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

if VERSION >= v"0.4.0-dev+5512"
  include("precompile.jl")
end

end
