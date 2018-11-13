"""
`histogram(v; nargs...)` → `Plot`

Description
============

Draws a horizontal histogram of the given vector `v`.
If the parameter `bins` is not specified,
then it will be chosen based on *sturges rule*.
Note that `histogram` is a simply wrapper for `barplot`,
which means that it supports the same parameter arguments.

Usage
======

    histogram(v; bins = sturges(length(v)), symb = "▇", border = :solid, title = "", margin = 3, padding = 1, color = :green, width = 40, labels = true)

Arguments
==========

- **`v`** : Vector or range for which the histogram should be computed.

- **`bins`** : The approximate number of bins that should be used.

- **`border`** : The style of the bounding box of the plot.
Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`title`** : Text to display on the top of the plot.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`color`** : Color of the drawing. Can be any of `:blue`, `:red`, `:yellow`

- **`width`** : Number of characters per row that should be used for plotting.

- **`labels`** : Can be used to hide the labels by setting `labels=false`.

- **`symb`** : Specifies the character that should be used to render the bars

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

    julia> histogram(randn(1000), bins = 15, title = "Histogram")

                                 Histogram
                  ┌────────────────────────────────────────┐
      (-3.5,-3.0] │ 1                                      │
      (-3.0,-2.5] │ 2                                      │
      (-2.5,-2.0] │▇▇▇▇ 22                                 │
      (-2.0,-1.5] │▇▇▇▇▇▇▇▇▇▇ 53                           │
      (-1.5,-1.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 78                       │
      (-1.0,-0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 141          │
       (-0.5,0.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 191 │
        (0.0,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 193 │
        (0.5,1.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 150         │
        (1.0,1.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 101                  │
        (1.5,2.0] │▇▇▇▇▇▇▇▇ 42                             │
        (2.0,2.5] │▇▇▇ 17                                  │
        (2.5,3.0] │▇ 4                                     │
        (3.0,3.5] │▇ 5                                     │
                  └────────────────────────────────────────┘
                                 Frequency

See also
=========

`hist`, `Plot`, `barplot`, `BarplotGraphics`
"""
function histogram(v, bins::Int; symb = "▇", args...)
    result = fit(Histogram, v; nbins = bins, closed=:right)
    edges, counts = result.edges[1], result.weights
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
    for i in 1:length(counts)
        val1 = float_round_log10(edges[i], binwidth)
        val2 = float_round_log10(val1+binwidth, binwidth)
        a1 = Base.alignment(IOBuffer(), val1)
        a2 = Base.alignment(IOBuffer(), val2)
        labels[i] =
            "\e[90m(\e[0m" *
            repeat(" ", pad_left - a1[1]) *
            string(val1) *
            repeat(" ", pad_right - a1[2]) *
            "\e[90m, \e[0m" *
            repeat(" ", pad_left - a2[1]) *
            string(val2) *
            repeat(" ", pad_right - a2[2]) *
            "\e[90m]\e[0m"
    end
    plt = barplot(labels, counts; symb = symb, args...)
    xlabel!(plt, "Frequency")
    plt
end

function histogram(v; bins::Int = sturges(length(v)), args...)
    histogram(v, bins; args...)
end

# Sturges' rule
sturges(n) = n == 0 ? 1 : ceil(Int, log2(n) + 1)
