module UnicodePlots

export BrailleCanvas, setPixel!, setPoint!, drawLine!
export drawRow, nrows, ncols
export barplot, lineplot, scatterplot, stairs

include("common.jl")
include("canvas.jl")
include("barplot.jl")
include("scatterplot.jl")

end # module
