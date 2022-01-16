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
function test_ref(reference, actual)
    depth = UnicodePlots.COLORMODE[] == UnicodePlots.Crayons.COLORS_24BIT ? 24 : 8
    @test_reference(joinpath("references_$depth", reference), actual, render = BeforeAfterFull(), format = "TXT")
end

# helpers
macro show_col(p, kv...)
    :(@io2str($(Expr(:call, :show, Expr(:call, :IOContext, :(::IO), :color=>true, kv...), p |> esc))))
end
macro show_nocol(p, kv...)
    :(@io2str($(Expr(:call, :show, Expr(:call, :IOContext, :(::IO), :color=>false, kv...), p |> esc))))
end
macro print_col(p, kv...)
    :(@io2str($(Expr(:call, :print, Expr(:call, :IOContext, :(::IO), :color=>true, kv...), p |> esc))))
end
macro print_nocol(p, kv...)
    :(@io2str($(Expr(:call, :print, Expr(:call, :IOContext, :(::IO), :color=>false, kv...), p |> esc))))
end

withenv("FORCE_COLOR"=>"X") do  # github.com/JuliaPlots/UnicodePlots.jl/issues/134
    UnicodePlots.CRAYONS_FAST[] = false  # safe mode

    for depth in (
        8,
        # 24,  # NOTE: for now only test 8bit mode
    )
        UnicodePlots.colormode(depth)
        for test in (
            "tst_common.jl",
            "tst_issues.jl",
            "tst_graphics.jl",
            "tst_canvas.jl",
            "tst_plot.jl",
            "tst_scatterplot.jl",
            "tst_lineplot.jl",
            "tst_barplot.jl",
            "tst_boxplot.jl",
            "tst_histogram.jl",
            "tst_heatmap.jl",
            "tst_spy.jl",
            "tst_deprecated_warns.jl",
        )
            @testset "$test" begin
                include(test)
            end
        end
    end
end
