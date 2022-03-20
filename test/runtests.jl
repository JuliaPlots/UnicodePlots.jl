using UnicodePlots, ReferenceTests, Test
using ReferenceTests: BeforeAfterFull
using Dates: Date, Day
import Random: seed!
using LinearAlgebra
using ColorTypes
using StableRNGs
using StatsBase
using Unitful

include("fixes.jl")

const RNG = StableRNG(1337)
const T_SZ = (24, 80)  # terminal size

# see JuliaTesting/ReferenceTests.jl/pull/91
test_ref(reference, actual) =
    @test_reference(reference, actual, render = BeforeAfterFull(), format = "TXT")

# helpers
macro show_col(p, kv...)
    :(@io2str(
        $(Expr(
            :call,
            :show,
            Expr(:call, :IOContext, :(::IO), :color => true, kv...),
            esc(p),
        ))
    ))
end
macro show_nocol(p, kv...)
    :(@io2str(
        $(Expr(
            :call,
            :show,
            Expr(:call, :IOContext, :(::IO), :color => false, kv...),
            esc(p),
        ))
    ))
end
macro print_col(p, kv...)
    :(@io2str(
        $(Expr(
            :call,
            :print,
            Expr(:call, :IOContext, :(::IO), :color => true, kv...),
            esc(p),
        ))
    ))
end
macro print_nocol(p, kv...)
    :(@io2str(
        $(Expr(
            :call,
            :print,
            Expr(:call, :IOContext, :(::IO), :color => false, kv...),
            esc(p),
        ))
    ))
end

# return type Plot{BrailleCanvas{typeof(identity), typeof(identity)}} does not match
# inferred return type Plot{var"#s129"} where var"#s129"<:Canvas

macro binf(ex)
    :(@inferred(Plot{BrailleCanvas{typeof(identity),typeof(identity)}}, $ex)) |> esc
end

macro hinf(ex)
    :(@inferred(Plot{HeatmapCanvas{typeof(identity),typeof(identity)}}, $ex)) |> esc
end

macro dinf(ex)
    :(@inferred(Plot{DensityCanvas{typeof(identity),typeof(identity)}}, $ex)) |> esc
end

withenv("FORCE_COLOR" => "X") do  # github.com/JuliaPlots/UnicodePlots.jl/issues/134
    UnicodePlots.colormode_8bit()  # NOTE: for now only test 8bit mode
    UnicodePlots.CRAYONS_FAST[] = false
    for test in (
        "tst_issues.jl",
        "tst_common.jl",
        "tst_graphics.jl",
        "tst_canvas.jl",
        "tst_plot.jl",
        "tst_scatterplot.jl",
        "tst_lineplot.jl",
        "tst_densityplot.jl",
        "tst_histogram.jl",
        "tst_barplot.jl",
        "tst_spy.jl",
        "tst_boxplot.jl",
        "tst_heatmap.jl",
        "tst_contourplot.jl",
        "tst_volume.jl",
        "tst_surfaceplot.jl",
        "tst_isosurface.jl",
        "tst_deprecated_warns.jl",
    )
        @testset "$test" begin
            include(test)
        end
    end
end
