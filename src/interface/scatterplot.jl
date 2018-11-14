"""
    scatterplot(x, y; nargs...)

Description
============

Draws the given points on a new canvas.

It uses the first parameter `x` (which should be some vector) to
denote the horizontal position of each point, and the second
parameter `y` (which should also be some vector) as their
vertical position. This means that the two vectors have to have
the same length.

Usage
======

    scatterplot([x], y; name = "", title = "", xlabel = "", ylabel = "", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, width = 40, height = 15, xlim = [0, 0], ylim = [0, 0], canvas = BrailleCanvas, grid = true)

Arguments
==========

- **`x`** : Optional. The horizontal coordinates for each point.
  If omitted, the axes of `y` will be used as `x`.

- **`y`** : The vertical coordinates for each point.

- **`name`** : Annotation of the current drawing to displayed
  on the right

$DOC_PLOT_PARAMS

- **`height`** : Number of rows that should be used for plotting.

- **`xlim`** : Plotting range for the x coordinate.
  `[0, 0]` stands for automatic.

- **`ylim`** : Plotting range for the y coordinate.
  `[0, 0]` stands for automatic.

- **`canvas`** : The type of canvas that should be used for drawing.

- **`grid`** : Can be used to hide the grid-lines at the origin

Returns
========

A plot object of type `Plot{T<:Canvas}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

```julia-repl
julia> scatterplot(randn(50), randn(50), title = "My Scatterplot")
                   My Scatterplot
      ┌────────────────────────────────────────┐
    3 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⡇⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠡⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠁⠀⡇⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠐⠄⠀⠀⠀⠀⡀⠀⠂⡇⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠤⠤⠤⠤⠤⠤⠴⠤⠤⠤⠬⠤⠬⠤⠤⠤⡧⢥⡤⠤⠤⡤⠤⠤⠤⠬⠤⠤⠤⠤⠤⠤⠤⠤⡤⠤⠤⠤⠤⠄│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⡗⠐⠨⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⡇⠀⠐⠀⠨⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠄⠀⠀⠀⠀⠀⡇⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠁⠂⠰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   -3 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      └────────────────────────────────────────┘
      -2                                       3
```

See also
=========

[`Plot`](@ref), [`lineplot`](@ref), [`stairs`](@ref), [`BrailleCanvas`](@ref), [`BlockCanvas`](@ref), [`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function scatterplot(
        x::AbstractVector{<:Number}, y::AbstractVector{<:Number};
        color::Symbol = :auto,
        name = "",
        canvas::Type = BrailleCanvas,
        kw...)
    new_plot = Plot(x, y, canvas; kw...)
    color = (color == :auto) ? next_color!(new_plot) : color
    name == "" || annotate!(new_plot, :r, string(name), color)
    points!(new_plot, x, y, color)
end

function scatterplot(x::AbstractVector; kw...)
    scatterplot(axes(x, 1), x; kw...)
end

function scatterplot!(
        plot::Plot{<:Canvas}, x::AbstractVector{<:Number}, y::AbstractVector{<:Number};
        color::Symbol = :auto,
        name = "",
        kw...)
    color = (color == :auto) ? next_color!(plot) : color
    name == "" || annotate!(plot, :r, string(name), color)
    points!(plot, x, y, color)
end

function scatterplot!(plot::Plot{<:Canvas}, x::AbstractVector; kw...)
    scatterplot!(plot, axes(x, 1), x; kw...)
end
