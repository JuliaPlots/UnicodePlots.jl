"""
    isosurface(x, y, V; kwargs...)

Extract and plot isosurface from volumetric data.

# Usage

    isosurface(x, y, z, V; $(keywords(; add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        V = "`Array` (volume) of interest for which a surface is extracted, or `Function` evaluated as `f(x, y, z)`",
        isovalue = "surface isovalue",
    ); add = (Z_DESCRIPTION..., :x, :y, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> torus(x, y, z, r = .5, R = 1) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
julia> isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus)
...
```
"""
function isosurface(
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::Union{Function,AbstractArray};
    canvas::Type = BrailleCanvas,
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    colormap = KEYWORDS.colormap,
    transform::Union{MVP,Symbol} = :orthographic,
    isovalue::Number = 0,
    kwargs...,
)
    if V isa Function
        xx = repeat(x', length(y), 1)
        yy = repeat(y, 1, length(x))
        X = repeat(xx, 1, 1, length(z))
        Y = repeat(yy, 1, 1, length(z))
        Z = zero(X)
        for (i, v) ∈ enumerate(z)
            Z[:, :, i] .= v
        end
        V = map(V, X, Y, Z) |> Array
    end
    callback = colormap_callback(colormap)

    plot = Plot(x, y, z, canvas; transform = transform, colormap = callback, kwargs...)
    isosurface!(plot, x, y, z, V; name = name, color = color, colormap = colormap, isovalue = isovalue)
end

tri2xyz(v1, v2, v3) = (
    [v1[1], v2[1], v3[1], v1[1]],
    [v1[2], v2[2], v3[2], v1[2]],
    [v1[3], v2[3], v3[3], v1[3]],
)

function isosurface!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::AbstractArray;
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    colormap = KEYWORDS.colormap,
    isovalue::Number = 0,
)
    name == "" || label!(plot, :r, string(name))
    plot.colormap = callback = colormap_callback(colormap)

    mc = MarchingCubes.MC(V, Int; x = collect(x), y = collect(y), z = collect(z))
    MarchingCubes.march(mc, isovalue)

    # mc.triangles - mc.vertices - mc.normals
    # TODO: performa face culling

    for t in mc.triangles
        lineplot!(plot, tri2xyz(mc.vertices[t[1]], mc.vertices[t[2]], mc.vertices[t[3]])...; color = color, name = name)
    end
    plot
end
