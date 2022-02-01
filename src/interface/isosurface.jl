"""
    isosurface(x, y, V; kwargs...)

Extract and plot isosurface from volumetric data, or implicit function.

# Usage

    isosurface(x, y, z, V; $(keywords(; add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        V = "`Array` (volume) of interest for which a surface is extracted, or `Function` evaluated as `f(x, y, z)`",
        isovalue = "surface isovalue",
    ); add = (Z_DESCRIPTION..., :x, :y, :z, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> torus(x, y, z, r = .2, R = .5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
julia> isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus; xlim = (-.5, .5), ylim = (-.5, .5), elevation = 50)
        ┌────────────────────────────────────────┐ 
    0.5 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢀⠀⠄⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠄⠔⠀⠡⠠⠁⠡⠠⠁⠈⠄⠌⠈⠄⠌⠀⠢⠠⠠⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⠀⠠⠐⠅⠌⠈⠄⠌⠀⡁⡀⠨⡀⠄⠠⠡⠠⡀⠥⠠⠈⠀⠡⠠⠁⠡⠡⠢⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⣔⠃⡁⠄⢊⠈⠄⡰⠐⡀⢂⡞⢈⠰⠨⡂⠆⡁⣱⠔⢁⠘⢀⠠⠁⡑⠠⢈⠘⣢⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠐⠥⠁⡀⠂⢂⠈⠄⡖⡋⠗⠈⠉⠀⠀⠀⠀⠀⠀⠉⠁⠱⢙⠱⠠⠁⡐⠐⢀⠈⢌⠆⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠜⠤⠁⡀⠂⢂⢈⠄⠦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡹⠠⡁⡐⠐⢀⠈⢤⢚⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠸⠗⠅⡀⠂⢂⢀⠂⢂⠃⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠂⡑⠐⡀⡐⠐⠀⠨⢔⠏⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⠉⠄⠌⠰⠀⡀⠂⢂⠀⡐⠐⠌⠔⠐⠄⠡⠂⠢⠡⠂⢂⠀⡐⠐⣀⠐⠠⡁⡃⠁⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⠀⠀⠀⠀⠈⠁⠄⠌⠀⡆⢀⠐⠐⢀⠐⠐⠀⠄⠂⠂⡀⠂⡂⡀⠂⢂⠀⡂⠐⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⢰⠀⠀⠀⠀⠀⠈⠀⠥⠀⡂⡃⠇⠃⡁⡡⠨⡈⡨⠈⠬⠨⠢⢈⠠⠑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠃⠓⠀⠊⠐⠂⠊⠈⠈⠘⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        │⠀⠀⣀⠼⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
   -0.5 │⠔⠉⠀⠀⠀⠈⠑⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
        └────────────────────────────────────────┘ 
        ⠀-0.5⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀0.5⠀ 
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
    transform::Union{MVP,Symbol} = KEYWORDS.transform,
    isovalue::Number = 0,
    centroid::Bool = true,
    kwargs...,
)
    if V isa Function
        xx = repeat(x', length(y), 1)
        yy = repeat(y, 1, length(x))
        X = repeat(xx, 1, 1, length(z))
        Y = repeat(yy, 1, 1, length(z))
        Z = zero(X)
        for (i, zi) ∈ enumerate(z)
            Z[:, :, i] .= zi
        end
        V = map(V, X, Y, Z) |> Array
    end
    callback = colormap_callback(colormap)

    plot = Plot(x, y, z, canvas; transform = transform, colormap = callback, kwargs...)
    isosurface!(
        plot, x, y, z, V;
        name = name, color = color, colormap = colormap, isovalue = isovalue, centroid = centroid
    )
end

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
    centroid::Bool = true,
)
    name == "" || label!(plot, :r, string(name))
    plot.colormap = callback = colormap_callback(colormap)

    mc = MarchingCubes.MC(V, Int; x = collect(x), y = collect(y), z = collect(z))
    MarchingCubes.march(mc, isovalue)

    tri2xyz(v1, v2, v3) = (
        @SVector([v1[1], v2[1], v3[1], v1[1]]),
        @SVector([v1[2], v2[2], v3[2], v1[2]]),
        @SVector([v1[3], v2[3], v3[3], v1[3]]),
    )
    F = float(eltype(x))
    color = color == :auto ? next_color!(plot) : color

    xs = F[]
    ys = F[]
    zs = F[]
    for t in mc.triangles
        v1 = mc.vertices[t[1]]
        v2 = mc.vertices[t[2]]
        v3 = mc.vertices[t[3]]
        # face culling
        dot(mc.normals[t[1]], plot.transform.view_dir) < 0 && continue
        dot(mc.normals[t[2]], plot.transform.view_dir) < 0 && continue
        dot(mc.normals[t[3]], plot.transform.view_dir) < 0 && continue
        if centroid
            c = (v1 .+ v2 .+ v3) ./ 3
            push!(xs, c[1])
            push!(ys, c[2])
            push!(zs, c[3])
        else
            append!(xs, @SVector([v1[1], v2[1], v3[1]]))
            append!(ys, @SVector([v1[2], v2[2], v3[2]]))
            append!(zs, @SVector([v1[3], v2[3], v3[3]]))
        end
    end
    # triangles vertices or centroid
    scatterplot!(plot, xs, ys, zs; color = color, name = name)
    plot
end
