using UnicodePlots, ReferenceTests, Test
using ReferenceTests: BeforeAfterFull
using StatsBase
using SparseArrays
using Random: seed!
using Dates: Date, Day

tests = [
    "tst_common.jl",
    "tst_graphics.jl",
    "tst_canvas.jl",
    "tst_plot.jl",
    "tst_barplot.jl",
    "tst_histogram.jl",
#    "old_tests.jl",
]

for test in tests
    @testset "$test" begin
        include(test)
    end
end
