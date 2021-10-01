using UnicodePlots, ReferenceTests, Test
using ReferenceTests: BeforeAfterFull
using Dates: Date, Day
using SparseArrays
using ColorTypes
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
    "tst_heatmap.jl",
    "tst_deprecated_warns.jl",
]

const RNG = StableRNG(1337)
const T_SZ = (24, 80)  # terminal size

# see JuliaTesting/ReferenceTests.jl/pull/91
test_ref(reference, actual) = @test_reference(reference, actual, render = BeforeAfterFull(), format = "TXT")

# helpers
macro show_col(p, kv...)
    :(@io2str($(Expr(:call, :show, Expr(:call, :IOContext, :(::IO), :color=>true, kv...), esc(p)))))
end
macro show_nocol(p, kv...)
    :(@io2str($(Expr(:call, :show, Expr(:call, :IOContext, :(::IO), :color=>false, kv...), esc(p)))))
end
macro print_col(p, kv...)
    :(@io2str($(Expr(:call, :print, Expr(:call, :IOContext, :(::IO), :color=>true, kv...), esc(p)))))
end
macro print_nocol(p, kv...)
    :(@io2str($(Expr(:call, :print, Expr(:call, :IOContext, :(::IO), :color=>false, kv...), esc(p)))))
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
  sparse(I, J, V)
end

withenv("FORCE_COLOR"=>"X") do  # github.com/JuliaPlots/UnicodePlots.jl/issues/134
    for test in tests
        @testset "$test" begin
            include(test)
        end
    end
end
