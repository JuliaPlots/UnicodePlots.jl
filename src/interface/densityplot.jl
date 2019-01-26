"""
    densityplot(x, y; kwargs...)

Description
============

Draws a density plot for the given points.

The first vector `x` should contain the horizontal
positions for all the points. The second vector `y` should then
contain the corresponding vertical positions respectively. This
means that the two vectors must be of the same length and
ordering.

Usage
======

    densityplot(x, y; name = "", title = "", xlabel = "", ylabel = "", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, width = 40, height = 15, xlim = (0, 0), ylim = (0, 0), grid = false)

Arguments
==========

- **`x`** : The horizontal position for each point.
  If omitted, the axes of `y` will be used as `x`.

- **`y`** : The vertical position for each point.

- **`name`** : Annotation of the current drawing to be displayed
  on the right

$DOC_PLOT_PARAMS

- **`height`** : Number of character rows that should be used
  for plotting.

- **`xlim`** : Plotting range for the x axis.
  `(0, 0)` stands for automatic.

- **`ylim`** : Plotting range for the y axis.
  `(0, 0)` stands for automatic.

- **`grid`** : If `true`, draws grid-lines at the origin.

Returns
========

A plot object of type `Plot{DensityCanvas}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

```julia-repl
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
```

See also
=========

[`Plot`](@ref), [`scatterplot`](@ref), [`DensityCanvas`](@ref)
"""
function densityplot(
        x::AbstractVector,
        y::AbstractVector;
        color::Symbol = :auto,
        grid = false,
        name = "",
        kw...)
    new_plot = Plot(x, y, DensityCanvas; grid = grid, kw...)
    scatterplot!(new_plot, x, y; color = color, name = name)
end

function densityplot!(
        plot::Plot{<:DensityCanvas},
        x::AbstractVector,
        y::AbstractVector;
        kw...)
    scatterplot!(plot, x, y; kw...)
end
