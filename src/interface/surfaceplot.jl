"""
    contourplot(x, y, A; kwargs...)

Draws a surface plot on a new canvas.

# Usage

    surfaceplot(x, y, z, A; $(keywords(; add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        V = "`Array` (volume) of interest for which a surface is extracted, or `Function` evaluated as `f(x, y, z)`",
        isovalue = "surface isovalue",
    ); add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> torus(x, y, z, r = .5, R = 1) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
julia> surfaceplot(-1:.1:1, -1:.1:1, -1:.1:1, torus)
...
```
"""
function surfaceplot(
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::Union{Function,AbstractArray},
    canvas::Type = BrailleCanvas,
    name::AbstractString = KEYWORDS.name,
    isovalue::Number = 0,
    elevation::Number = atand(1 / √2),
    azimuth::Number = -45,
    kw...,
)
    if V isa Function
        X = repeat(x', length(y), 1)
        Y = repeat(y, 1, length(x))
        Z = nothing
        V = map(V, X, Y, Z) |> Array
    end

    # projection step
    # then extract, x/y lims
    xl = extrema(x) |> collect
    yl = extrema(y) |> collect
    zl = extrema(z) |> collect

    cam_tr = PerspectiveMap() ∘ inv(AffineMap(cam_rotation, cam_position))
    cube = (
        (cam_tr((xl[1], yl[1], zl[1])), cam_tr((xl[1], yl[1], zl[1]))),
        (cam_tr((xl[1], yl[1], zl[1])), cam_tr((xl[2], yl[2], zl[1]))),
        (cam_tr((xl[1], yl[1], zl[1])), cam_tr((xl[2], yl[1], zl[2]))),
        (cam_tr((xl[1], yl[1], zl[1])), cam_tr((xl[1], yl[2], zl[1]))),
        (cam_tr((xl[1], yl[1], zl[1])), cam_tr((xl[1], yl[1], zl[2]))),
        (cam_tr((xl[2], yl[2], zl[1])), cam_tr((xl[1], yl[2], zl[1]))),
        (cam_tr((xl[2], yl[2], zl[1])), cam_tr((xl[2], yl[2], zl[2]))),
        (cam_tr((xl[1], yl[2], zl[1])), cam_tr((xl[2], yl[2], zl[2]))),
        (cam_tr((xl[2], yl[1], zl[2])), cam_tr((xl[1], yl[1], zl[2]))),
        (cam_tr((xl[2], yl[1], zl[2])), cam_tr((xl[2], yl[2], zl[2]))),
        (cam_tr((xl[1], yl[1], zl[2])), cam_tr((xl[2], yl[2], zl[2]))),
        (cam_tr((xl[2], yl[2], zl[2])), cam_tr((xl[2], yl[2], zl[2]))),
    )

    plot = Plot(xlim, ylim, canvas; kw...)
    surfaceplot!(plot, x, y, z, V)
end

function surfaceplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::AbstractArray,
    canvas::Type = BrailleCanvas,
    name::AbstractString = KEYWORDS.name,
    isovalue::Number = 0,
    elevation::Number = atand(1 / √2),
    azimuth::Number = -45,
)
    mc = MarchingCubes.MC(V, Int)
    march(mc, isovalue)

    # mc.triangles
    # mc.vertices
    # mc.normals

    scatterplot()

    plot
end
