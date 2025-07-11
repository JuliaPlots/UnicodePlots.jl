import Pkg
Pkg.precompile()
Pkg.status(; outdated = true, mode = Pkg.PKGMODE_MANIFEST)

using ImageInTerminal, FreeType, FileIO, IntervalSets, Unitful, Term  # weak deps, or @require
using UnicodePlots, Test

import UnicodePlots: lines!, points!, pixel!, nrows, ncols
import UnicodePlots: print_row, preprocess!, addrow!

import Dates: DateTime, Date, Day
import DataFrames: DataFrame
import Random: seed!
import ColorSchemes
import FileIO
import Aqua

using ReferenceTests
using LinearAlgebra
using TimerOutputs
using TestImages
using ColorTypes
using StableRNGs
using AllocCheck
using StatsBase
using Crayons
using Unitful

include("fixes.jl")

const TO = TimerOutput()
const RNG = StableRNG(1_337)
const T_SZ = (24, 80)  # default terminal size on unix

# see JuliaTesting/ReferenceTests.jl/pull/91
test_ref(reference, actual) = @test_reference(
    joinpath("references_$(UnicodePlots.colormode())", reference),
    actual,
    render = ReferenceTests.BeforeAfterFull(),
    format = "TXT"
)

is_ci() = Base.get_bool_env("CI", false)
is_pkgeval() = Base.get_bool_env("JULIA_PKGEVAL", false)
"""
julia> is_prerelease("DEV")
julia> is_prerelease("alpha")
julia> is_prerelease("beta")
julia> is_prerelease("rc")
"""
is_prerelease(label) =
    length(VERSION.prerelease) > 0 && startswith(first(VERSION.prerelease), label)

const STABLE = Base.get_bool_env("UP_STABLE", false) || isempty(VERSION.prerelease)
const PRE = is_prerelease("alpha") || is_prerelease("beta") || is_prerelease("rc")

# helpers

"a plot must be square"
macro check_padding(x)
    tmp = gensym()
    return quote
        $tmp = UnicodePlots.no_ansi_escape($x)
        if length.(split($tmp, '\n')) |> unique |> length == 1
            @test true
        else
            println($x)
            @test false
        end
    end |> esc
end

macro show_col(p, kv...)
    tmp = gensym()
    return quote
        $tmp = @io2str $(:(show(IOContext(::IO, :color => true, $(kv...)), $p)))
        @check_padding $tmp
        $tmp
    end |> esc
end
macro show_nocol(p, kv...)
    tmp = gensym()
    return quote
        $tmp = @io2str $(:(show(IOContext(::IO, :color => false, $(kv...)), $p)))
        @check_padding $tmp
        $tmp
    end |> esc
end
macro print_col(p, kv...)
    tmp = gensym()
    return quote
        $tmp = @io2str $(:(print(IOContext(::IO, :color => true, $(kv...)), $p)))
        @check_padding $tmp
        $tmp
    end |> esc
end
macro print_nocol(p, kv...)
    tmp = gensym()
    return quote
        $tmp = @io2str $(:(print(IOContext(::IO, :color => false, $(kv...)), $p)))
        @check_padding $tmp
        $tmp
    end |> esc
end

# return type Plot{BrailleCanvas{typeof(identity), typeof(identity)}} does not match
# inferred return type Plot{var"#s129"} where var"#s129"<:Canvas
const ID = typeof(identity)

macro binf(ex)
    return :(@inferred(Plot{BrailleCanvas{ID, ID}}, $ex)) |> esc
end

macro oinf(ex)
    return :(@inferred(Plot{OctantCanvas{ID, ID}}, $ex)) |> esc
end

macro hinf(ex)
    return :(@inferred(Plot{HeatmapCanvas{ID, ID}}, $ex)) |> esc
end

macro timeit_include(path::AbstractString)
    return :(
        @timeit TO $path @testset $path begin
            include($path)
        end
    ) |> esc
end

macro no_allocs(ex)
    f = gensym()
    return quote
        @check_allocs $f() = $ex
        $f()
    end |> esc
end

println("\n== start: testing with $(UnicodePlots.colormode())bit colormode ==\n")

#! format: off
withenv("FORCE_COLOR" => "X") do  # JuliaPlots/UnicodePlots.jl/issues/134
    @timeit_include "tst_freetype.jl"
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
    @timeit_include "tst_imageplot.jl"
    @timeit_include "tst_quality.jl"
end
#! format: on

# ~ 94s & 9.88GiB on 1.11
print_timer(TO; compact = true, sortby = :firstexec)

println("\n== end: testing with $(UnicodePlots.colormode())bit colormode ==")
