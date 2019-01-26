"""
    stairs(x, y; kwargs...)

Description
============

Draws a staircase plot on a new canvas.

The first (optional) vector `x` should contain the horizontal
positions for all the points. The second vector `y` should then
contain the corresponding vertical positions respectively. This
means that the two vectors must be of the same length and
ordering.

Usage
======

    stairs(x, y; style = :post, name = "", title = "", xlabel = "", ylabel = "", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, width = 40, height = 15, xlim = (0, 0), ylim = (0, 0), canvas = BrailleCanvas, grid = true)

Arguments
==========

- **`x`** : The horizontal position for each point.

- **`y`** : The vertical position for each point.

- **`style`** : Specifies where the transition of the stair takes
  plays. Can be either `:pre` or `:post`.

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
- Dominique (Github: https://github.com/dpo)

Examples
=========

```julia-repl
julia> stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], style = :post, title = "My Staircase Plot")
                 My Staircase Plot
     ┌────────────────────────────────────────┐
   7 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
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
```

See also
=========

[`Plot`](@ref), [`scatterplot`](@ref), [`lineplot`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function stairs(
        X::AbstractVector, Y::AbstractVector;
        style::Symbol = :post,
        kw...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot(x_vex, y_vex; kw...)
end

function stairs!(
        plot::Plot{<:Canvas}, X::AbstractVector, Y::AbstractVector;
        style::Symbol = :post,
        kw...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot!(plot, x_vex, y_vex; kw...)
end

function compute_stair_lines(
        X::AbstractVector{<:Number},
        Y::AbstractVector{<:Number},
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
