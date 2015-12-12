"""
`densityplot(x, y; nargs...)` → `Plot`

Description
============

Draws a density plot for the given points.
It uses the first parameter `x`
(which should be a vector or range) to denote
the horizontal position of each point,
and the second parameter `y`
(which should also be a vector or range)
as their vertical position.
This means that the two vectors have to have the same length.

Usage
======

    densityplot(x, y; title = "", name = "", width = 40, height = 15, border = :solid, xlim = [0, 0], ylim = [0, 0], margin = 3, padding = 1, color = :white, labels = true)

Arguments
==========

- **`x`** : The horizontal dimension for each point.

- **`y`** : The vertical dimension for each point.

- **`title`** : Text to display on the top of the plot.

- **`name`** : Annotation of the current drawing to displayed on the right

- **`width`** : Number of characters per row that should be used for plotting.

- **`height`** : Number of rows that should be used for plotting. Not applicable to `barplot`.

- **`border`** : The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`xlim`** : Plotting range for the x coordinate. `[0, 0]` stands for automatic.

- **`ylim`** : Plotting range for the y coordinate. `[0, 0]` stands for automatic.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`color`** : Color of the drawing. Can be any of `:blue`, `:red`, `:yellow`

- **`labels`** : Can be used to hide the labels by setting `labels=false`.

Returns
========

A plot object of type `Plot{DensityCanvas}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

    julia> densityplot(randn(1000), randn(1000), title = "Density Plot")

                         Density Plot
           ┌────────────────────────────────────────┐
       2.9 │                    ░                   │
           │                ░    ░  ░               │
           │                ░░░  ░ ░ ░      ░       │
           │             ░░░ ░░▒░▒░░░ ▒ ░           │
           │          ░░ ░░ ░▒░░▒▒▒▒░░░░░░░         │
           │         ░░ ░▒░░░░░▓▒▒░▒░▒░▓░▒░░░       │
           │        ░ ░░░░▓▓▒▓▒▒█▒▓▒▒▓▒▒░▒ ░ ░      │
           │           ░ ▒▒▒▒▓▓▒▓▓▓▓▒█▒▒░░░░░░ ░    │
           │     ░   ░░░░░░░▒▒▓░░▓▒█▒▒▓▓▒▒ ░    ░   │
           │           ░ ░░▒▒░░▒░░▒░░░░ ░░  ░ ░     │
           │         ░   ░ ░ ░░░░░░ ░░ ░░ ░         │
           │              ░  ░ ░ ░  ░ ░   ░░░       │
           │                ░░  ░                   │
           │                                        │
      -3.3 │                                        │
           └────────────────────────────────────────┘
           -3.4                                   2.9

See also
=========

`Plot`, `scatterplot`, `DensityCanvas`
"""
function densityplot{F<:Real,R<:Real}(
        x::Vector{F},
        y::Vector{R};
        color::Symbol = :white,
        args...)
    X = convert(Vector{Float64}, x)
    Y = convert(Vector{Float64}, y)
    new_plot = Plot(X, Y, DensityCanvas; grid = false, args...)
    points!(new_plot, X, Y, color)
end

function densityplot!{T<:Canvas,F<:Real,R<:Real}(
        plot::Plot{T},
        x::Vector{F},
        y::Vector{R};
        color::Symbol = :white,
        args...)
    X = convert(Vector{Float64}, x)
    Y = convert(Vector{Float64}, y)
    points!(plot, X, Y, color)
end
