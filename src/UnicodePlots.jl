isdefined(Base, :__precompile__) && __precompile__()
module UnicodePlots

export

    GraphicsArea,
      Canvas,
        BrailleCanvas,
        DensityCanvas,
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
