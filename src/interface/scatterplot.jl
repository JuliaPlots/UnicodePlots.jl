"""
`scatterplot(x, y; nargs...)` → `Plot`

Description
============

Draws the given points on a new canvas.
It uses the first parameter `x`
(which should be a vector or range) to denote
the horizontal position of each point,
and the second parameter `y`
(which should also be a vector or range)
as their vertical position.
This means that the two vectors have to have the same length.

Usage
======

    scatterplot(x, y; title = "", name = "", width = 40, height = 15, border = :solid, xlim = [0, 0], ylim = [0, 0], margin = 3, padding = 1, color = :blue, labels = true, canvas = BrailleCanvas, grid = true)

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

- **`canvas`** : The type of canvas that should be used for drawing.

- **`grid`** : Can be used to hide the gridlines at the origin

Returns
========

A plot object of type `Plot{T<:Canvas}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

    julia> scatterplot(randn(50), randn(50), title = "My Scatterplot", color = :red)

                        My Scatterplot
           ┌────────────────────────────────────────┐
       2.1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⡧⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⡀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⢀⠐⠂⠀⠀⠀⠀⠀⡇⠁⠐⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀│
           │⠠⠀⠀⠀⠀⠀⠐⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠄⡇⢀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠒⠖⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠒⠚⠒⠒⡗⠒⠒⠒⢒⠒⠒⠒⠒⠒⠒⠒⠖⠒⠒⠒⠒⠒⠢│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠠⠀⠁⡇⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⡇⠀⠀⠀⠀⢀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      -2.2 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
           └────────────────────────────────────────┘
           -2.1                                   1.9

See also
=========

`Plot`, `lineplot`, `stairs`, `BrailleCanvas`, `BlockCanvas`, `AsciiCanvas`
"""
function scatterplot{F<:Real,R<:Real}(
        x::AbstractVector{F}, y::AbstractVector{R};
        color::Symbol = :auto,
        name::AbstractString = "",
        canvas::Type = BrailleCanvas,
        args...)
    X = convert(Vector{Float64}, x)
    Y = convert(Vector{Float64}, y)
    new_plot = Plot(X, Y, canvas; args...)
    color = (color == :auto) ? next_color!(new_plot) : color
    name == "" || annotate!(new_plot, :r, name, color)
    points!(new_plot, X, Y, color)
end

function scatterplot!{T<:Canvas,F<:Real,R<:Real}(
        plot::Plot{T}, x::AbstractVector{F}, y::AbstractVector{R};
        color::Symbol = :auto,
        name::AbstractString = "",
        args...)
    X = convert(Vector{Float64}, x)
    Y = convert(Vector{Float64}, y)
    color = (color == :auto) ? next_color!(plot) : color
    name == "" || annotate!(plot, :r, name, color)
    points!(plot, X, Y, color)
end

function scatterplot{F<:Real,R<:Real}(X::Range{F}, Y::Range{R}; args...)
    scatterplot(collect(X), collect(Y); args...)
end

function scatterplot{F<:Real}(X::Range, Y::AbstractVector{F}; args...)
    scatterplot(collect(X), Y; args...)
end

function scatterplot{F<:Real}(X::AbstractVector{F}, Y::Range; args...)
    scatterplot(X, collect(Y); args...)
end

function scatterplot(X::AbstractVector; args...)
    scatterplot(1:length(X), X; args...)
end

function scatterplot!{T<:Canvas}(plot::Plot{T}, X::AbstractVector; args...)
    scatterplot!(plot, 1:length(X), X; args...)
end

function scatterplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::Range{F}, Y::Range{R}; args...)
    scatterplot!(plot, collect(X), collect(Y); args...)
end

function scatterplot!{T<:Canvas,F<:Real}(plot::Plot{T}, X::Range, Y::AbstractVector{F}; args...)
    scatterplot!(plot, collect(X), Y; args...)
end

function scatterplot!{T<:Canvas,F<:Real}(plot::Plot{T}, X::AbstractVector{F}, Y::Range; args...)
    scatterplot!(plot, X, collect(Y); args...)
end
