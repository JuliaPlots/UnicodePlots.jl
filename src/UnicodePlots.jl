isdefined(Base, :__precompile__) && __precompile__()
module UnicodePlots

export

    GraphicsArea,
      Canvas,
        BrailleCanvas,
        DensityCanvas,
      BarplotGraphics,

    printRow,
    nrows,
    ncols,

    setPixel!,
    setPoint!,
    drawLine!,
    addRow!,

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
include("braillecanvas.jl")
include("densitycanvas.jl")
include("plot.jl")
include("barplot.jl")
include("histogram.jl")
include("scatterplot.jl")
include("densityplot.jl")
include("spy.jl")

end
