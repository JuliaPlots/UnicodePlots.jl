"""
`stairs(x, y; nargs...)` → `Plot`

Description
============

Draws a staircase plot on a new canvas.
It uses the first parameter `x`
(which should be a vector or range) to denote
the horizontal position of each point,
and the second parameter `y`
(which should also be a vector or range)
as their vertical position.
This means that the two vectors have to have the same length.

Usage
======

    stairs(x, y; style = :post, title = "", name = "", width = 40, height = 15, border = :solid, xlim = [0, 0], ylim = [0, 0], margin = 3, padding = 1, color = :blue, labels = true, canvas = BrailleCanvas, grid = true)

Arguments
==========

- **`x`** : The horizontal dimension for each point.

- **`y`** : The vertical dimension for each point.

- **`style`** : Specifies where the transition of the stair takes plays. Can be either `:pre` or `:post`

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

- **`canvas`** : The type of canvas that should be used for drawing.

- **`grid`** : Can be used to hide the gridlines at the origin

Returns
========

A plot object of type `Plot{T<:Canvas}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)
- Dominique (Github: https://github.com/dpo)

Examples
=========

    julia> stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], style = :post, title = "My Staircase Plot")

                    My Staircase Plot
        ┌────────────────────────────────────────┐
      7 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⡄⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⢸⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
        │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠧⠤⠤⠤⠤⠼│
        │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      1 │⣀⣀⣀⣀⣀⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
        └────────────────────────────────────────┘
        1                                        8


See also
=========

`Plot`, `lineplot`, `scatterplot`, `BrailleCanvas`, `BlockCanvas`, `AsciiCanvas`
"""
function stairs{F<:Real,R<:Real}(
        X::Vector{F}, Y::Vector{R};
        style::Symbol = :post,
        args...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot(x_vex, y_vex; args...)
end

function stairs!{T<:Canvas,F<:Real,R<:Real}(
        plot::Plot{T}, X::AbstractVector{F}, Y::AbstractVector{R};
        style::Symbol = :post,
        args...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot!(plot, x_vex, y_vex; args...)
end

function compute_stair_lines{F<:Real,R<:Real}(
        X::AbstractVector{F},
        Y::AbstractVector{R},
        style::Symbol)
    if style == :post
        x_vex = zeros(length(X) * 2 - 1)
        y_vex = zeros(length(X) * 2 - 1)
        x_vex[1] = X[1]
        y_vex[1] = Y[1]
        o = 0
        for i = 2:(length(X))
            x_vex[i + o] = X[i]
            x_vex[i + o + 1] = X[i]
            y_vex[i + o] = Y[i-1]
            y_vex[i + o + 1] = Y[i]
            o += 1
        end
        x_vex, y_vex
    elseif style == :pre
        x_vex = zeros(length(X) * 2 - 1)
        y_vex = zeros(length(X) * 2 - 1)
        x_vex[1] = X[1]
        y_vex[1] = Y[1]
        o = 0
        for i = 2:(length(X))
            x_vex[i + o] = X[i-1]
            x_vex[i + o + 1] = X[i]
            y_vex[i + o] = Y[i]
            y_vex[i + o + 1] = Y[i]
            o += 1
        end
        x_vex, y_vex
    end
end
