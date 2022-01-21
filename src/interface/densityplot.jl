"""
    densityplot(x, y; kwargs...)

# Description

Draws a density plot for the given points.

The first vector `x` should contain the horizontal
positions for all the points. The second vector `y` should then
contain the corresponding vertical positions respectively. This
means that the two vectors must be of the same length and
ordering.

# Usage

    densityplot(x, y; $(keywords(; remove = (:grid,))))

# Arguments

$(arguments(; add = (:x, :y), remove = (:grid,)))

# Returns

A plot object of type `Plot{DensityCanvas}`.

# Author(s)

- Christof Stocker (github.com/Evizero)

# Examples

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

# See also

[`Plot`](@ref), [`scatterplot`](@ref), [`DensityCanvas`](@ref)
"""
function densityplot(
    x::AbstractVector,
    y::AbstractVector;
    color::UserColorType = :auto,
    grid = false,
    name = "",
    kw...,
)
    plot = Plot(x, y, DensityCanvas; grid = grid, kw...)
    scatterplot!(plot, x, y; color = color, name = name)
end

densityplot!(plot::Plot{<:DensityCanvas}, x::AbstractVector, y::AbstractVector; kw...) =
    scatterplot!(plot, x, y; kw...)
