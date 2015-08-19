module UnicodePlots

export Canvas, BrailleCanvas, BarplotCanvas, DensityCanvas
export setPixel!, setPoint!, drawLine!, addRow!
export printRow, nrows, ncols

export Plot
export annotate!, setTitle!

export barplot, lineplot, scatterplot, stairs, histogram, densityplot
export barplot!, lineplot!, scatterplot!, stairs!

export spy

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
end # module
