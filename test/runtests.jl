using UnicodePlots, Test

# Incorrect usage of LazyModules could easily bring up world age issues. We need to test
# this before loading all other test dependencies -- because otherwise potential world age
# issues get automatically resolved.
include("tst_world_age.jl")

using Dates: Date, Day
using ReferenceTests
import Random: seed!
using LinearAlgebra
using TimerOutputs
using ColorTypes
using StableRNGs
using StatsBase
using Crayons
using Unitful
import FileIO

include("fixes.jl")

const TO = TimerOutput()
const RNG = StableRNG(1337)
const T_SZ = (24, 80)  # default terminal size on unix

# see JuliaTesting/ReferenceTests.jl/pull/91
test_ref(reference, actual) = @test_reference(
    joinpath("references_$(UnicodePlots.colormode())", reference),
    actual,
    render = ReferenceTests.BeforeAfterFull(),
    format = "TXT"
)

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
const ID = typeof(identity)

macro binf(ex)
    :(@inferred(Plot{BrailleCanvas{ID,ID}}, $ex)) |> esc
end

macro hinf(ex)
    :(@inferred(Plot{HeatmapCanvas{ID,ID}}, $ex)) |> esc
end

macro timeit_include(path::AbstractString)
    :(@timeit TO $path @testset $path begin
        include($path)
    end) |> esc
end

withenv("FORCE_COLOR" => "X") do  # github.com/JuliaPlots/UnicodePlots.jl/issues/134
    UnicodePlots.CRAYONS_FAST[] = false
    println("\n== TESTING WITH $(UnicodePlots.colormode())bit COLORMODE ==\n")
    @timeit_include "tst_depwarn.jl"
    @timeit_include "tst_issues.jl"
    @timeit_include "tst_io.jl"
    @timeit_include "tst_common.jl"
    @timeit_include "tst_graphics.jl"
    @timeit_include "tst_canvas.jl"
    @timeit_include "tst_plot.jl"
    @timeit_include "tst_scatterplot.jl"
    @timeit_include "tst_lineplot.jl"
    @timeit_include "tst_densityplot.jl"
    @timeit_include "tst_histogram.jl"
    @timeit_include "tst_barplot.jl"
    @timeit_include "tst_spy.jl"
    @timeit_include "tst_boxplot.jl"
    @timeit_include "tst_contourplot.jl"
    @timeit_include "tst_polarplot.jl"
    @timeit_include "tst_heatmap.jl"
    @timeit_include "tst_volume.jl"
    @timeit_include "tst_surfaceplot.jl"
    @timeit_include "tst_isosurface.jl"
end

# ~ 166s & 15.0GiB on 1.7
print_timer(TO; compact = true, sortby = :firstexec)
