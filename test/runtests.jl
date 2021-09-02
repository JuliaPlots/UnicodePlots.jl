using UnicodePlots, ReferenceTests, Test
using ReferenceTests: BeforeAfterFull
using Dates: Date, Day
using SparseArrays
using StableRNGs
using StatsBase
using Random

import Random: seed!

tests = [
    "tst_issues.jl",
    "tst_common.jl",
    "tst_graphics.jl",
    "tst_canvas.jl",
    "tst_plot.jl",
    "tst_barplot.jl",
    "tst_histogram.jl",
    "tst_scatterplot.jl",
    "tst_lineplot.jl",
    "tst_spy.jl",
    "tst_boxplot.jl",
    "tst_heatmap.jl"
]

const RNG = StableRNG(1337)

# see JuliaTesting/ReferenceTests.jl/pull/91
function test_ref(reference, actual)
    @test_reference(reference, actual, render = BeforeAfterFull(), format = "TXT")
end

# sprand or sprandn is not stable across versions (e.g. 1.0 vs 1.6)
function stable_sprand(r::AbstractRNG, m::Integer, n::Integer, density::AbstractFloat)
  I = Int[]
  J = Int[]
  for li in randsubseq(r, 1:(m*n), density)
    j, i = divrem(li - 1, m)
    push!(I, i + 1)
    push!(J, j + 1)
  end
  V = rand(r, length(I))
  return sparse(I, J, V)
end

for test in tests
    @testset "$test" begin
        include(test)
    end
end
