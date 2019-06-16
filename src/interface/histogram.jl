"""
    histogram(data; kwargs...)

Description
============

Draws a horizontal histogram of the given `data`. The positional
parameter `data` can either be a `StatsBase.Histogram`, or some
`AbstractArray`. In the later case the `Histogram` will be
fitted automatically.

Note internally that `histogram` is a simply wrapper for
[`barplot`](@ref), which means that it supports the same keyword
arguments.

Usage
======

    histogram(x; nbins, closed = :left, kwargs...)

    histogram(hist; xscale = identity, title = "", xlabel = "", ylabel = "", labels = true, border = :barplot, margin = 3, padding = 1, color = :green, width = 40, symb = "▇")

Arguments
==========

- **`x`** : Array of numbers for which the histogram should be computed.

- **`nbins`** : The approximate number of bins that should be used.

- **`closed`** : If `:left` (the default), the bin intervals are
  left-closed ``[a,b)``; if `:right`, intervals are right-closed
  ``(a,b]``.

- **`hist`** : A fitted `StatsBase.Histogram` that should be plotted.

- **`xscale`** : Function to transform the bar length before plotting.
  This effectively scales the x-axis without influencing the captions
  of the individual bars. e.g. use `xscale = log10` for logscale.

$DOC_PLOT_PARAMS

- **`symb`** : Specifies the character that should be used to
  render the individual bars.

Returns
========

A plot object of type `Plot{BarplotGraphics}`

Author(s)
==========

- Iain Dunning (Github: https://github.com/IainNZ)
- Christof Stocker (Github: https://github.com/Evizero)
- Kenta Sato (Github: https://github.com/bicycle1885)

Examples
=========

```julia-repl
julia> histogram(randn(1000) * 0.1, closed = :right, nbins = 15)
                  ┌                                        ┐
   (-0.3 , -0.25] ┤▇ 4
   (-0.25, -0.2 ] ┤▇▇ 12
   (-0.2 , -0.15] ┤▇▇▇▇▇▇▇▇▇ 48
   (-0.15, -0.1 ] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 114
   (-0.1 , -0.05] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 143
   (-0.05, -0.0 ] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 177
   ( 0.0 ,  0.05] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 192
   ( 0.05,  0.1 ] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 152
   ( 0.1 ,  0.15] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 83
   ( 0.15,  0.2 ] ┤▇▇▇▇▇▇▇▇ 45
   ( 0.2 ,  0.25] ┤▇▇▇▇ 23
   ( 0.25,  0.3 ] ┤▇ 6
   ( 0.3 ,  0.35] ┤ 1
                  └                                        ┘
                                  Frequency
```

See also
=========

[`Plot`](@ref), [`barplot`](@ref), [`BarplotGraphics`](@ref)
"""
function histogram(
        hist::Histogram;
        symb = "▇",
        xscale = identity,
        xlabel = transform_name(xscale, "Frequency"),
        kw...)
    edges, counts = hist.edges[1], hist.weights
    labels = Vector{String}(undef, length(counts))
    binwidth = typeof(edges.step) == Float64 ? edges.step : edges.step.hi
    # compute label padding based on all labels.
    # this is done to make all decimal points align.
    pad_left, pad_right = 0, 0
    for I in eachindex(edges)
        val1 = float_round_log10(edges[I], binwidth)
        val2 = float_round_log10(val1+binwidth, binwidth)
        a1 = Base.alignment(IOBuffer(), val1)
        a2 = Base.alignment(IOBuffer(), val2)
        pad_left = max(pad_left, a1[1], a2[1])
        pad_right = max(pad_right, a1[2], a2[2])
    end
    # compute the labels using the computed padding
    l_str = hist.closed == :right ? "(" : "["
    r_str = hist.closed == :right ? "]" : ")"
    for i in 1:length(counts)
        val1 = float_round_log10(edges[i], binwidth)
        val2 = float_round_log10(val1+binwidth, binwidth)
        a1 = Base.alignment(IOBuffer(), val1)
        a2 = Base.alignment(IOBuffer(), val2)
        labels[i] =
            "\e[90m" * l_str * "\e[0m" *
            repeat(" ", pad_left - a1[1]) *
            string(val1) *
            repeat(" ", pad_right - a1[2]) *
            "\e[90m, \e[0m" *
            repeat(" ", pad_left - a2[1]) *
            string(val2) *
            repeat(" ", pad_right - a2[2]) *
            "\e[90m" * r_str * "\e[0m"
    end
    barplot(labels, counts; symb = symb, xlabel = xlabel, xscale = xscale, kw...)
end

function histogram(x; bins = nothing, closed = :left, kw...)
    if bins != nothing
        Base.depwarn("The keyword parameter `bins` is deprecated, use `nbins` instead", :histogram)
        hist = fit(Histogram, x; nbins = bins, closed = closed)
    else
        hargs = filter(p -> p.first == :nbins, kw)
        hist = fit(Histogram, x; closed = closed, hargs...)
    end
    pargs = filter(p -> p.first != :nbins, kw)
    histogram(hist; pargs...)
end

@deprecate histogram(x::AbstractArray, nbins::Int; kw...) histogram(x; nbins = nbins, kw...)
