isdefined(Base, :__precompile__) && __precompile__()
module UnicodePlots

export Canvas, BrailleCanvas, BarplotCanvas, DensityCanvas
export setPixel!, setPoint!, drawLine!, addRow!
export printRow, nrows, ncols

export Plot
export title, xlabel, ylabel
export annotate!, title!, xlabel!, ylabel!

export barplot, lineplot, scatterplot, stairs, histogram, densityplot
export barplot!, lineplot!, scatterplot!, stairs!, densityplot!

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

end
