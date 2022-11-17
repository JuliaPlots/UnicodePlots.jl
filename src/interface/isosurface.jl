"""
    isosurface(x, y, z, V; kw...)
    isosurface!(p, args...; kw...)

Extract and plot an isosurface from volumetric data, or a given implicit function.

# Usage

    isosurface(x, y, z, V; $(keywords((isovalue = 0, centroid = true); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid, :name, :xscale, :yscale))))

# Arguments

$(arguments(
    (
        V = "`Array` (volume) of interest for which a surface is extracted, or `Function` evaluated as `f(x, y, z)`",
        isovalue = "chosen surface isovalue",
        cull = "cull (hide) back faces",
        legacy = "use the legacy Marching Cubes algorithm instead of the topology enhanced algorithm",
        centroid = "display triangulation centroid instead of triangle vertices",
    ); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :x, :y, :z, :canvas), remove = (:blend, :grid, :xscale, :yscale)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> torus(x, y, z, r = .2, R = .5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
julia> isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus, elevation = 50, zoom = 2, cull = true)
    ┌────────────────────────────────────────┐ 
    │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢀⢀⠠⢄⢄⠄⠄⡠⡠⠤⡀⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠔⠌⠜⠀⠡⠠⠁⠡⠠⠁⠈⠄⠌⠈⠄⠌⠀⠪⠠⠤⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠀⠀⡠⠔⠅⠌⠈⠄⠌⠀⡁⡀⠨⡀⠄⠠⠡⠠⡀⠥⠠⠈⠀⠡⠠⠁⠡⠱⠢⡀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⢀⣜⠃⡁⠄⢊⠈⠄⡰⠐⡀⢂⡞⢈⡰⡨⡂⢆⡁⣱⠔⢁⠘⢀⠠⠁⡑⠠⢈⠘⣲⡀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⡚⠥⠁⡀⠂⢂⠈⠄⡖⡫⠗⠋⠉⠀⠀⠀⠀⠀⠈⠉⠉⠱⢝⠱⠠⠁⡐⠐⢀⠈⢌⢧⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⡟⠤⠁⡀⠂⢂⢈⠄⢮⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⠠⡁⡐⠐⢀⠈⢤⢚⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⢽⠗⠅⡀⠂⢂⢀⠂⢂⠓⡢⡄⣀⠀⠀⠀⠀⠀⢀⡀⢀⢰⠂⡑⠐⡀⡐⠐⠀⠨⢔⡟⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠈⠭⠄⠌⠰⠀⡀⠂⢂⠀⡐⠐⠌⠔⠑⠅⠡⠊⠢⠡⠂⢂⠀⡐⠐⣀⠐⠠⡁⡃⡑⠁⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠀⠀⠈⠨⠅⠄⠌⠀⡆⢀⠐⠐⢀⠐⠐⠀⠄⠂⠂⡀⠂⡂⡀⠂⢂⠀⡂⢐⠔⠈⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⢥⢀⡂⡃⠇⠃⡁⡡⠨⡈⡨⠈⠬⠨⠢⢈⢠⠑⠒⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠋⠓⠂⠊⠒⠂⠚⠘⠚⠙⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠀⠀⣀⠼⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    │⠔⠉⠀⠀⠀⠈⠑⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
    └────────────────────────────────────────┘ 
```

# See also

`Plot`, `MVP`, `surfaceplot`, `BrailleCanvas`
"""
function isosurface(
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::Union{Function,AbstractArray};
    canvas::Type = BrailleCanvas,
    kw...,
)
    pkw, okw = split_plot_kw(kw)
    V isa Function && (V = V.(x, y', reshape(z, 1, 1, length(z))))

    plot = Plot(
        map(collect ∘ extrema, (x, y, z))...,
        canvas;
        projection = KEYWORDS.projection,
        labels = false,
        pkw...,
    )
    isosurface!(plot, x, y, z, V; okw...)
end

@doc (@doc isosurface) function isosurface!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::AbstractArray;
    color::UserColorType = KEYWORDS.color,
    isovalue::Number = 0,
    centroid::Bool = true,
    legacy::Bool = false,
    cull::Bool = false,
)
    F = float(promote_type(eltype(x), eltype(y), eltype(z), eltype(V)))

    mc = MarchingCubes.MC(V, Int; x = collect(F, x), y = collect(F, y), z = collect(F, z))
    if legacy
        MarchingCubes.march_legacy(mc, isovalue)
    else
        MarchingCubes.march(mc, isovalue)
    end

    ntri = length(mc.triangles)
    npts = centroid ? ntri : 3ntri
    X, Y, Z = map(_ -> sizehint!(F[], npts), 1:3)
    C = sizehint!(ColorType[], npts)

    color = ansi_color(color ≡ :auto ? next_color!(plot) : color)
    @inbounds for (i1, i2, i3) ∈ mc.triangles
        (i1 ≤ 0 || i2 ≤ 0 || i3 ≤ 0) && continue  # invalid triangle
        back_face = (
            dot(mc.normals[i1], plot.projection.view_dir) < 0 &&
            dot(mc.normals[i2], plot.projection.view_dir) < 0 &&
            dot(mc.normals[i3], plot.projection.view_dir) < 0
        )
        (cull && back_face) && continue
        v1 = mc.vertices[i1]
        v2 = mc.vertices[i2]
        v3 = mc.vertices[i3]
        vc = back_face ? complement(color) : color
        if centroid
            push!(X, (v1[1] + v2[1] + v3[1]) / 3)
            push!(Y, (v1[2] + v2[2] + v3[2]) / 3)
            push!(Z, (v1[3] + v2[3] + v3[3]) / 3)
            push!(C, vc)
        else
            push!(X, v1[1], v2[1], v3[1])
            push!(Y, v1[2], v2[2], v3[2])
            push!(Z, v1[3], v2[3], v3[3])
            push!(C, vc, vc, vc)
        end
    end
    # triangles vertices or centroid
    points!(plot, X, Y, Z, C, falses(length(X)))
end
