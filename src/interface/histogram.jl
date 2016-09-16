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

    histogram(v; bins = sturges(length(v)), symb = "▇", border = :solid, title = "", margin = 3, padding = 1, color = :blue, width = 40, labels = true)

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

See also
=========

`hist`, `Plot`, `barplot`, `BarplotGraphics`
"""
function histogram(v, bins::Int; symb = "▇", args...)
    result = fit(Histogram, v; nbins = bins)
    edges, counts = result.edges[1], result.weights
    labels = Array(String, length(counts))
    binwidth = edges.step / edges.divisor
    @inbounds for i in 1:length(counts)
        val = float_round_log10(edges[i], binwidth)
        labels[i] = string("(", val, ",", float_round_log10(val+binwidth, binwidth), "]")
    end
    barplot(labels, counts; symb = symb, args...)
end

function histogram(v; bins::Int = sturges(length(v)), args...)
    histogram(v, bins; args...)
end

# Sturges' rule
sturges(n) = n == 0 ? 1 : ceil(Int, log2(n) + 1)
