"""
    densityplot(x, y; kw...)
    densityplot!(p, args...; kw...)

# Description

Draws a density plot for the given points.

The first vector `x` should contain the horizontal positions for all the points.
The second vector `y` should contain the corresponding vertical positions respectively.
The two vectors must thus be of the same length and ordering.
One can pass an arbitrary `dscale` (`Function` or `Symbol`) for transforming density counts (e.g. peaks damping).

# Usage

    densityplot(x, y; $(keywords((; dscale = :identity); remove = (:grid,))))

# Arguments

$(arguments((; dscale = "density scale function"); add = (:x, :y), remove = (:grid,)))

# Author(s)

- Christof Stocker (github.com/Evizero)

# Examples

```julia-repl
julia> densityplot(randn(1_000), randn(1_000), title = "Density Plot")
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
    dscale::Union{Symbol,Function} = :identity,
    kw...,
)
    pkw, okw = split_plot_kw(; kw...)
    plot = Plot(
        x,
        y,
        nothing,
        DensityCanvas;
        canvas_kw = (; dscale = scale_callback(dscale)),
        grid = false,
        pkw...,
    )
    scatterplot!(plot, x, y; okw...)
end

@doc (@doc densityplot) densityplot!(
    plot::Plot{<:DensityCanvas},
    x::AbstractVector,
    y::AbstractVector;
    kw...,
) = scatterplot!(plot, x, y; kw...)
