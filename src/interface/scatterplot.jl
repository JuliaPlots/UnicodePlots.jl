"""
    scatterplot(x, y; kwargs...)

Description
============

Draws the given points on a new canvas.

The first (optional) vector `x` should contain the horizontal
positions for all the points. The second vector `y` should then
contain the corresponding vertical positions respectively. This
means that the two vectors must be of the same length and
ordering.

Usage
======

    scatterplot([x], y; name = "", marker = :pixel, title = "", xlabel = "", ylabel = "", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, xlim = (0, 0), ylim = (0, 0), canvas = BrailleCanvas, grid = true)

Arguments
==========

- **`x`** : Optional. The horizontal position for each point.
  If omitted, the axes of `y` will be used as `x`.

- **`y`** : The vertical position for each point.

- **`name`** : Annotation of the current drawing to be displayed on the right

- **`marker`** : Choose a marker from $(keys(MARKERS)), a `Char`, a unit length `String` or a vector of these

$DOC_PLOT_PARAMS

- **`height`** : Number of character rows that should be used for plotting.

- **`xlim`** : Plotting range for the x axis.
  `(0, 0)` stands for automatic.

- **`ylim`** : Plotting range for the y axis.
  `(0, 0)` stands for automatic.

- **`canvas`** : The type of canvas that should be used for drawing.

- **`grid`** : If `true`, draws grid-lines at the origin.

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

[`Plot`](@ref), [`lineplot`](@ref), [`stairs`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function scatterplot(
    x::AbstractVector, y::AbstractVector;
    canvas::Type = BrailleCanvas, color::Union{UserColorType,AbstractVector} = :auto,
    marker::Union{MarkerType,AbstractVector} = :pixel, name = "", kw...
)
    new_plot = Plot(x, y, canvas; kw...)
    scatterplot!(new_plot, x, y; color = color, name = name, marker = marker)
end

scatterplot(y::AbstractVector; kw...) = scatterplot(axes(y, 1), y; kw...)

function scatterplot!(
    plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractVector;
    color::Union{UserColorType,AbstractVector} = :auto,
    marker::Union{MarkerType,AbstractVector} = :pixel, name = ""
)
    color = (color == :auto) ? next_color!(plot) : color
    name == "" || label!(plot, :r, string(name), color isa AbstractVector ? color[1] : color)
    if marker ∈ (:pixel, :auto)
        points!(plot, x, y, color)
    else
        for (xi, yi, mi, ci) in zip(x, y, iterable(marker), iterable(color))
            annotate!(plot, xi, yi, char_marker(mi); color=ci)
        end
    end
    plot
end

scatterplot!(plot::Plot{<:Canvas}, y::AbstractVector; kw...) = scatterplot!(
  plot, axes(y, 1), y; kw...
)
