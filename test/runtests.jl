using UnicodePlots, ReferenceTests, Test
using ReferenceTests: BeforeAfterFull
using Dates: Date, Day
import Random: seed!
using ColorTypes
using StableRNGs
using StatsBase

include("fixes.jl")

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

withenv("FORCE_COLOR"=>"X") do  # github.com/JuliaPlots/UnicodePlots.jl/issues/134
    for test in (
        "tst_issues.jl",
        "tst_common.jl",
        "tst_graphics.jl",
        "tst_canvas.jl",
        "tst_plot.jl",
        "tst_scatterplot.jl",
        "tst_lineplot.jl",
        "tst_barplot.jl",
        "tst_contourplot.jl",
        "tst_histogram.jl",
        "tst_boxplot.jl",
        "tst_heatmap.jl",
        "tst_spy.jl",
        "tst_deprecated_warns.jl",
    )
        @testset "$test" begin
            include(test)
        end
    end
end
