module UnicodePlots

export Canvas, BrailleCanvas
export setPixel!, setPoint!, drawLine!
export drawRow, nrows, ncols

export Plot
export annotate!, setTitle!

export barplot, lineplot, scatterplot, stairs

include("common.jl")
include("canvas.jl")
include("plot.jl")
include("barplot.jl")
include("scatterplot.jl")

end # module
