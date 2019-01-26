"""
    lineplot(x, y; kwargs...)

Description
============

Draws a path through the given points on a new canvas.

The first (optional) vector `x` should contain the horizontal
positions for all the points along the path. The second vector
`y` should then contain the corresponding vertical positions
respectively. This means that the two vectors must be of the same
length and ordering.

Usage
======

    lineplot([x], y; name = "", title = "", xlabel = "", ylabel = "", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, width = 40, height = 15, xlim = (0, 0), ylim = (0, 0), canvas = BrailleCanvas, grid = true)

    lineplot(fun, [start], [stop]; kwargs...)

Arguments
==========

- **`x`** : Optional. The horizontal position for each point.
  Can be a real number or of type `TimeType`.
  If omitted, the axes of `y` will be used as `x`.

- **`y`** : The vertical position for each point.

- **`fun`** : A unary function ``f: R -> R`` that should be
  evaluated, and drawn as a path from `start` to `stop`
  (numbers in the domain).

- **`name`** : Annotation of the current drawing to be displayed
  on the right.

$DOC_PLOT_PARAMS

- **`height`** : Number of character rows that should be used
  for plotting.

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
- Milktrader (Github: https://github.com/milktrader)

Examples
=========

```julia-repl
julia> lineplot([1, 2, 7], [9, -6, 8], title = "My Lineplot")
                      My Lineplot
       ┌────────────────────────────────────────┐
    10 │⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠│
       │⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊⠁⠀│
       │⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠁⠀⠀⠀⠀│
       │⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠤⠤⠤⠼⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢤⠤⠶⠥⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤│
       │⠀⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⢱⠀⠀⠀⠀⡠⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⠀⢇⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   -10 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       └────────────────────────────────────────┘
       1                                        7
```

See also
=========

[`Plot`](@ref), [`scatterplot`](@ref), [`stairs`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function lineplot(
        x::AbstractVector,
        y::AbstractVector;
        canvas::Type = BrailleCanvas,
        color::Symbol = :auto,
        name = "",
        kw...)
    new_plot = Plot(x, y, canvas; kw...)
    lineplot!(new_plot, x, y; color = color, name = name)
end

function lineplot(y::AbstractVector; kw...)
    lineplot(axes(y, 1), y; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        x::AbstractVector,
        y::AbstractVector;
        color::Symbol = :auto,
        name = "")
    color = color == :auto ? next_color!(plot) : color
    name == "" || annotate!(plot, :r, string(name), color)
    lines!(plot, x, y, color)
end

function lineplot!(plot::Plot{<:Canvas}, y::AbstractVector; kw...)
    lineplot!(plot, axes(y, 1), y; kw...)
end

# date time

function lineplot(
        x::AbstractVector{<:TimeType},
        y::AbstractVector;
        xlim = extrema(Dates.value.(x)),
        kw...)
    d = Dates.value.(x)
    new_plot = lineplot(d, y; xlim = xlim, kw...)
    annotate!(new_plot, :bl, string(minimum(x)), color = :light_black)
    annotate!(new_plot, :br, string(maximum(x)), color = :light_black)
end

function lineplot!(
        plot::Plot{<:Canvas},
        x::AbstractVector{<:TimeType},
        y::AbstractVector;
        kw...)
    d = Dates.value.(x)
    lineplot!(plot, d, y; kw...)
end

# slope and intercept

function lineplot!(
        plot::Plot{<:Canvas},
        intercept::Number,
        slope::Number;
        kw...)
    xmin = origin_x(plot.graphics)
    xmax = origin_x(plot.graphics) + width(plot.graphics)
    ymin = origin_y(plot.graphics)
    ymax = origin_y(plot.graphics) + height(plot.graphics)
    lineplot!(plot, [xmin, xmax], [intercept + xmin*slope, intercept + xmax*slope]; kw...)
end

# plotting a function

function lineplot(
        f::Function,
        x::AbstractVector;
        name = "",
        xlabel = "x",
        ylabel = "f(x)",
        kw...)
    y = Float64[f(i) for i in x]
    name = name == "" ? string(nameof(f), "(x)") : name
    new_plot = lineplot(x, y; name = name, xlabel = xlabel, ylabel = ylabel, kw...)
end

function lineplot(
        f::Function,
        startx::Number,
        endx::Number;
        width::Int = 40,
        kw...)
    diff = abs(endx - startx)
    x = startx:(diff/(3*width)):endx
    lineplot(f, x; width = width, kw...)
end

function lineplot(f::Function; kw...)
    lineplot(f, -10, 10; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        f::Function,
        x::AbstractVector;
        name = "",
        kw...)
    y = Float64[f(i) for i in x]
    name = name == "" ? string(nameof(f), "(x)") : name
    lineplot!(plot, x, y; name = name, kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        f::Function,
        startx::Number = origin_x(plot.graphics),
        endx::Number = origin_x(plot.graphics) + width(plot.graphics);
        kw...)
    diff = abs(endx - startx)
    x = startx:(diff/(3*ncols(plot.graphics))):endx
    lineplot!(plot, f, x; kw...)
end

# plotting vector of functions

function lineplot(F::AbstractVector{<:Function}; kw...)
    lineplot(F, -10, 10; kw...)
end

function lineplot(
        F::AbstractVector{<:Function},
        startx::Number,
        endx::Number;
        kw...)
    _lineplot(F, startx, endx; kw...)
end

function lineplot(
        F::AbstractVector{<:Function},
        x::AbstractVector;
        kw...)
    _lineplot(F, x; kw...)
end

function _lineplot(
        F::AbstractVector{<:Function},
        args...;
        color = :auto,
        name = "",
        kw...)
    n = length(F)
    n > 0 || throw(ArgumentError("Can not plot empty array of functions"))
    color_is_vec = color isa AbstractVector
    name_is_vec  = name  isa AbstractVector
    color_is_vec && (length(color) == n || throw(DimensionMismatch("\"color\" must be a symbol or same length as the function vector")))
    name_is_vec  && (length(name)  == n || throw(DimensionMismatch("\"name\" must be a string or same length as the function vector")))
    tcolor = color_is_vec ? color[1] : color
    tname  = name_is_vec  ? name[1]  : name
    new_plot = lineplot(F[1], args...; color = tcolor, name = tname, kw...)
    for i = 2:n
        tcolor = color_is_vec ? color[i] : color
        tname  = name_is_vec  ? name[i]  : name
        lineplot!(new_plot, F[i], args...; color = tcolor, name = tname)
    end
    new_plot
end
