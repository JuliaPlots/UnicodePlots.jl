"""
`lineplot(x, y; nargs...)` → `Plot`

Description
============

Draws a path through the given points on a new canvas.
It uses the first parameter `x`
(which should be a vector or range) to denote
the horizontal position of each point,
and the second parameter `y`
(which should also be a vector or range)
as their vertical position.
This means that the two vectors have to have the same length.

Usage
======

    lineplot(x, y; title = "", name = "", width = 40, height = 15, border = :solid, xlim = [0, 0], ylim = [0, 0], margin = 3, padding = 1, color = :auto, labels = true, canvas = BrailleCanvas, grid = true)

    lineplot(fun[, start, end]; title = "", name = "", width = 40, height = 15, border = :solid, xlim = [0, 0], ylim = [0, 0], margin = 3, padding = 1, color = :auto, labels = true, canvas = BrailleCanvas, grid = true)

Arguments
==========

- **`x`** : The horizontal dimension for each point. Can be a Real number or of type `TimeType`

- **`y`** : The vertical dimension for each point.

- **`fun`** : A function f: R -> R that should be drawn from `start` to `end`

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
- Milktrader (Github: https://github.com/milktrader)

Examples
=========

    julia> lineplot([1, 2, 7], [9, -6, 8], title = "My Lineplot")

                        My Lineplot
         ┌────────────────────────────────────────┐
       9 │⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠊│
         │⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀│
         │⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠁⠀⠀⠀⠀│
         │⠀⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠊⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⠸⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠒⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠉⠉⠉⠉⡏⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢉⠭⠋⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁│
         │⠀⠀⠀⠀⢱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⠀⠀⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⠀⠀⠀⢣⠀⠀⠀⠀⠀⢀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         │⠀⠀⠀⠀⠀⠸⡀⠀⠀⡠⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      -6 │⠀⠀⠀⠀⠀⠀⢇⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
         └────────────────────────────────────────┘
         1                                        7


See also
=========

`Plot`, `scatter`, `stairs`, `BrailleCanvas`, `BlockCanvas`, `AsciiCanvas`
"""
function lineplot(
        x::AbstractVector{<:Number},
        y::AbstractVector{<:Number};
        color::Symbol = :auto,
        name::AbstractString = "",
        canvas::Type = BrailleCanvas,
        kw...)
    X = convert(Vector{Float64},x)
    Y = convert(Vector{Float64},y)
    new_plot = Plot(X, Y, canvas; kw...)
    color = color == :auto ? next_color!(new_plot) : color
    name == "" || annotate!(new_plot, :r, name, color)
    lines!(new_plot, X, Y, color)
end

function lineplot!(
        plot::Plot{<:Canvas},
        x::AbstractVector{<:Number},
        y::AbstractVector{<:Number};
        color::Symbol = :auto,
        name::AbstractString = "",
        kw...)
    X = convert(Vector{Float64},x)
    Y = convert(Vector{Float64},y)
    color = color == :auto ? next_color!(plot) : color
    name == "" || annotate!(plot, :r, name, color)
    lines!(plot, X, Y, color)
end

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

function lineplot!(
        plot::Plot{<:Canvas},
        Y::Function,
        x::AbstractRange;
        kw...)
    X = collect(x)
    lineplot!(plot, Y, X; kw...)
end

function lineplot(
        Y::Function,
        x::AbstractRange;
        kw...)
    X = collect(x)
    lineplot(Y, X; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        Y::Function,
        X::AbstractVector{<:Number};
        name::AbstractString = "",
        kw...)
    y = convert(Vector{Float64}, [Y(i) for i in X])
    name = name == "" ? string(Y, "(x)") : name
    lineplot!(plot, X, y; name = name, kw...)
end

function lineplot(
        Y::Function,
        X::AbstractVector{<:Number};
        name::AbstractString = "",
        kw...)
    y = convert(Vector{Float64}, [Y(i) for i in X])
    name = name == "" ? string(Y, "(x)") : name
    new_plot = lineplot(X, y; name = name, kw...)
    xlabel!(new_plot, "x")
    ylabel!(new_plot, "f(x)")
end

function lineplot!(
        plot::Plot{<:Canvas},
        Y::Function,
        startx::Number,
        endx::Number;
        kw...)
    diff = abs(endx - startx)
    X = collect(startx:(diff/(3*ncols(plot.graphics))):endx)
    lineplot!(plot, Y, X; kw...)
end

function lineplot(Y::Function; kw...)
    lineplot(Y, -10, 10; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        Y::Function;
        kw...)
    lineplot!(plot, Y, origin_x(plot.graphics), origin_x(plot.graphics) + width(plot.graphics); kw...)
end

function lineplot(
        Y::Function,
        startx::Number,
        endx::Number;
        width::Int = 40,
        kw...)
    diff = abs(endx - startx)
    X = collect(startx:(diff/(3*width)):endx)
    lineplot(Y, X; width = width, kw...)
end

function lineplot(Y::AbstractVector{<:Function}; kw...)
    lineplot(Y, -10, 10; kw...)
end

function lineplot(
        Y::AbstractVector{<:Function},
        startx::Number,
        endx::Number;
        kw...)
    n = length(Y)
    @assert n > 0
    new_plot = lineplot(Y[1], startx, endx; kw...)
    for i = 2:n
        lineplot!(new_plot, Y[i], startx, endx; kw...)
    end
    new_plot
end

function lineplot(
        X::AbstractRange{<:Number},
        Y::AbstractRange{<:Number};
        kw...)
    lineplot(collect(X), collect(Y); kw...)
end

function lineplot(
        X::AbstractRange,
        Y::AbstractVector{<:Number};
        kw...)
    lineplot(collect(X), Y; kw...)
end

function lineplot(
        X::AbstractVector{<:Number},
        Y::AbstractRange;
        kw...)
    lineplot(X, collect(Y); kw...)
end

function lineplot(X::AbstractVector; kw...)
    lineplot(1:length(X), X; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        X::AbstractVector;
        kw...)
    lineplot!(plot, 1:length(X), X; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        X::AbstractRange{<:Number},
        Y::AbstractRange{<:Number};
        kw...)
    lineplot!(plot, collect(X), collect(Y); kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        X::AbstractRange,
        Y::AbstractVector{<:Number};
        kw...)
    lineplot!(plot, collect(X), Y; kw...)
end

function lineplot!(
        plot::Plot{<:Canvas},
        X::AbstractVector{<:Number},
        Y::AbstractRange;
        kw...)
    lineplot!(plot, X, collect(Y); kw...)
end

function lineplot(
        X::AbstractVector{<:TimeType},
        Y::AbstractVector{<:Number};
        kw...)
    d = convert(Vector{Float64}, Dates.value.(X))
    new_plot = lineplot(d, Y; kw...)
    annotate!(new_plot, :bl, string(first(X)))
    annotate!(new_plot, :br, string(last(X)))
end
