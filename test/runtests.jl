using UnicodePlots, ReferenceTests, Test
using SparseArrays: sprand
using Random: seed!
import Dates: Date, Day
using ReferenceTests: BeforeAfterFull

tests = [
    "tst_common.jl",
    "tst_canvas.jl",
    #"old_tests.jl",
]

for test in tests
    @testset "$test" begin
        include(test)
    end
end
