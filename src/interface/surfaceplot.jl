"""
    surfaceplot(x, y, z; kwargs...)

Draws a 3D surface plot on a new canvas.

# Usage

    surfaceplot(x, y, z; $(keywords(; add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        z = "`Matrix` of surface heights, or `Function` evaluated as `f(x, y)`",
    ); add = (Z_DESCRIPTION..., :x, :y, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> sombrero(x, y) = sinc(√(x^2 + y^2) / π)
julia> surfaceplot(-6:.5:10, -8:.5:10, sombrero)
...
```
"""
function surfaceplot(
    x::AbstractVector{<:Number},
    y::AbstractVector{<:Number},
    z::Union{Function,AbstractMatrix{<:Number}};
    canvas::Type = BrailleCanvas,
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    transform::Union{MVP,Symbol} = :orthographic,
    colormap = KEYWORDS.colormap,
    kw...,
)
    X = repeat(x', length(y), 1)
    Y = repeat(y, 1, length(x))
    if z isa Function
        Z = map(z, X, Y) |> Matrix
    end
    callback = colormap_callback(colormap)

    plot = Plot(X[:], Y[:], Z[:], canvas; transform = transform, colormap = callback, kw...)
    surfaceplot!(plot, X, Y, Z; name = name, color = color, colormap = colormap)
end

function surfaceplot!(
    plot::Plot{<:Canvas},
    x::AbstractMatrix{<:Number},
    y::AbstractMatrix{<:Number},
    z::AbstractMatrix{<:Number};
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    colormap = KEYWORDS.colormap,
)
    plot.colormap = callback = colormap_callback(colormap)

    scatterplot!(plot, x[:], y[:], z[:]; color = color, name = name)
    plot
end
