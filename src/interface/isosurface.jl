"""
    isosurface(x, y, z, V; kw...)

Extract and plot isosurface from volumetric data, or implicit function.

# Usage

    isosurface(x, y, z, V; $(keywords((isovalue = 0, centroid = true); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        V = "`Array` (volume) of interest for which a surface is extracted, or `Function` evaluated as `f(x, y, z)`",
        isovalue = "chosen surface isovalue",
        legacy = "use the legacy Marching Cubes algorithm instead of the topology enhanced algorithm",
        cull = "cull (hide) back faces",
        centroid = "display triangulation centroid instead of triangle vertices",
    ); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :x, :y, :z, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> torus(x, y, z, r = .2, R = .5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
julia> isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus, elevation = 50, zoom = 2)
      ┌────────────────────────────────────────┐ 
    1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣄⡤⢄⢄⠤⠄⣤⣠⢤⣠⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠔⢌⠞⡁⡣⡦⡅⡡⡱⢑⢉⢕⢌⢚⢔⠬⠨⠪⢲⠤⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⡠⠔⠅⠬⢈⠅⠎⠈⡡⡠⠨⡠⠤⠠⠣⠤⡄⠥⠤⠍⠁⠭⠤⠑⠱⢱⡢⡀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⢀⣜⠫⣉⠴⢊⠉⠄⡼⠐⡡⢢⣞⢪⡰⡪⡒⢆⡕⣱⠔⢍⠘⢡⠠⠉⡱⠰⣘⡘⣲⡀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⣺⡧⡃⡁⠆⢎⠈⠄⡞⡯⠗⠋⠉⠀⠀⠀⠀⠀⠈⠉⠉⠹⢝⡱⠠⠁⡱⠰⢀⢘⢮⣧⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⣿⠶⡁⡁⠆⢎⢈⠆⢾⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠰⡁⡱⠰⢈⢈⢾⢾⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⢽⡗⡅⡁⠆⢎⢀⠂⢧⣗⡦⣄⣀⠀⠀⠀⠀⠀⢀⣀⣀⣰⣪⡱⠐⡀⡱⠰⠈⢨⢞⡟⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠈⠯⡄⡍⠲⢌⣀⠂⢳⠠⡑⠜⢯⢜⠱⢕⠥⠎⡣⡹⠢⣊⢠⡘⠐⣀⡱⠰⣉⣣⡝⠁⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠘⠨⡇⢆⢌⠂⣆⢀⡑⠑⢐⠑⠒⠐⡔⠒⠃⡒⠒⣂⡀⡒⢒⡀⡒⣐⠔⠈⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠢⢧⢢⡂⡓⠗⡃⡑⡱⡨⣈⡪⢊⢬⠪⢢⢈⢴⠑⠒⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠋⠓⠊⠊⠒⠂⠛⠙⠚⠙⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⣀⠼⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
   -1 │⠔⠉⠀⠀⠀⠈⠑⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      └────────────────────────────────────────┘ 
      ⠀-1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀ 
```

# See also

`Plot`, `scatterplot`
"""
function isosurface(
    x::AbstractVector,
    y::AbstractVector,
    z::AbstractVector,
    V::Union{Function,AbstractArray};
    canvas::Type = BrailleCanvas,
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    projection::Union{MVP,Symbol} = KEYWORDS.projection,
    isovalue::Number = 0,
    centroid::Bool = true,
    legacy::Bool = false,
    cull::Bool = false,
    kw...,
)
    V isa Function && (V = V.(x, y', reshape(z, 1, 1, length(z))))

    plot = Plot(
        extrema(x) |> collect,
        extrema(y) |> collect,
        extrema(z) |> collect,
        canvas;
        projection = projection,
        kw...,
    )

    color = color == :auto ? next_color!(plot) : color

    mc = MarchingCubes.MC(V, Int; x = collect(x), y = collect(y), z = collect(z))
    (legacy ? MarchingCubes.march_legacy : MarchingCubes.march)(mc, isovalue)

    xs = float(eltype(x))[]
    ys = float(eltype(y))[]
    zs = float(eltype(z))[]
    cs = UserColorType[]

    for (i1, i2, i3) in mc.triangles
        (i1 <= 0 || i2 <= 0 || i3 <= 0) && continue  # invalid triangle
        v1 = mc.vertices[i1]
        v2 = mc.vertices[i2]
        v3 = mc.vertices[i3]
        back_face = (
            dot(mc.normals[i1], plot.projection.view_dir) < 0 &&
            dot(mc.normals[i2], plot.projection.view_dir) < 0 &&
            dot(mc.normals[i3], plot.projection.view_dir) < 0
        )
        (cull && back_face) && continue
        vc = back_face ? complement(color) : color
        if centroid
            c = (v1 .+ v2 .+ v3) ./ 3
            push!(xs, c[1])
            push!(ys, c[2])
            push!(zs, c[3])
            push!(cs, vc)
        else
            push!(xs, v1[1], v2[1], v3[1])
            push!(ys, v1[2], v2[2], v3[2])
            push!(zs, v1[3], v2[3], v3[3])
            push!(cs, vc, vc, vc)
        end
    end
    # triangles vertices or centroid
    scatterplot!(plot, xs, ys, zs; color = cs, name = name)
end
