module UnicodePlots

export Canvas, BrailleCanvas, BarplotCanvas
export setPixel!, setPoint!, drawLine!, addRow!
export printRow, nrows, ncols

export Plot
export annotate!, setTitle!

export barplot, lineplot, scatterplot, stairs
export barplot!, lineplot!, scatterplot!, stairs!

include("common.jl")
include("canvas.jl")
include("braillecanvas.jl")
include("plot.jl")
include("barplot.jl")
include("scatterplot.jl")

end # module
