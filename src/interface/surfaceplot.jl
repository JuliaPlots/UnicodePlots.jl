"""
    surfaceplot(x, y, A; kw...)

Draws a 3D surface plot on a new canvas (masking values using `NaN`s is supported).
For plotting a slice one can pass an anonymous function which maps to a constant height: `hscale = x -> some_constant_height`.

# Usage

    surfaceplot(x, y, A; $(keywords((; lines = false); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of surface heights, or `Function` evaluated as `f(x, y)`",
        lines = "use `lineplot` instead of `scatterplot`",
        hscale = "scale heights (`:identity`, `:aspect`, tuple of (min, max) values, or arbitrary scale function)",
    ); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :x, :y, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
julia> surfaceplot(-8:.5:8, -8:.5:8, sombrero)
      ┌────────────────────────────────────────┐  ⠀⠀⠀⠀     
    1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  ┌──┐ 15.0
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡫⢟⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡔⠌⡡⢢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣰⣭⣊⣑⣭⣆⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠴⣚⠯⡫⢝⣿⣿⡻⣟⣿⣿⡫⢝⠽⣓⠦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣯⡭⠭⠒⢊⠔⢱⢍⡘⡖⣳⢃⡩⡎⠢⡑⠒⠭⢭⣽⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣞⠭⠭⠥⢒⣿⣋⣵⢜⡧⣮⣙⣿⡒⠬⠭⠭⣳⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠴⢾⠿⠯⠛⠛⠽⢿⣯⣶⣮⡽⠛⠫⡉⠃⠙⢉⠝⠛⢯⣵⣶⣽⡿⠯⠛⠛⠽⠿⡷⠦⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⢶⣶⣶⡺⣗⣶⣶⡶⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⢷⢵⢾⡷⡮⡾⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
      │⠀⠀⣀⠤⠧⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⢕⡯⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│     
   -1 │⠐⠉⠀⠀⠀⠀⠈⠑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  └──┘ -3.0
      └────────────────────────────────────────┘  ⠀⠀⠀⠀     
      ⠀-1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀  ⠀⠀⠀⠀     
```

# See also

[`Plot`](@ref), [`scatterplot`](@ref)
"""
function surfaceplot(
    x::AbstractVecOrMat,
    y::AbstractVecOrMat,
    A::Union{Function,AbstractVecOrMat};
    canvas::Type = BrailleCanvas,
    name::AbstractString = KEYWORDS.name,
    color::UserColorType = nothing,  # NOTE: nothing as default (uses colormap), but allow single color
    colormap = KEYWORDS.colormap,
    colorbar::Bool = true,
    projection::Union{MVP,Symbol} = KEYWORDS.projection,
    hscale::Union{Symbol,Function,NTuple{2}} = :identity,
    lines::Bool = false,
    kw...,
)
    X, Y = if x isa AbstractVector && y isa AbstractVector && !(A isa AbstractVector)
        repeat(x, 1, length(y)), repeat(y', length(x), 1)
    else
        x, y
    end
    H = A isa Function ? A.(X, Y) : A

    ex = extrema(x)
    ey = extrema(y)
    eh = NaNMath.extrema(as_float(H))

    if hscale === :identity
        ez = eh
        Z = H
    elseif hscale isa Function
        ez = hscale.(eh)
        Z = hscale.(H)
    elseif hscale === :aspect || hscale isa NTuple{2}
        mh, Mh = eh
        mz, Mz = ez = if hscale === :aspect
            diff(ex |> collect) > diff(ey |> collect) ? ex : ey
        else
            hscale
        end
        Z = (H .- mh) .* ((Mz - mz) / (Mh - mh)) .+ mz
    else
        throw(ArgumentError("hscale=$hscale not understood"))
    end

    length(X) == length(Y) == length(Z) == length(H) ||
        throw(DimensionMismatch("X, Y, Z and H must have same length"))

    plot =
        Plot(collect(ex), collect(ey), collect(ez), canvas; projection = projection, kw...)
    surfaceplot!(
        plot,
        X,
        Y,
        Z,
        H;
        name = name,
        color = color,
        colormap = colormap,
        colorbar = colorbar,
        lines = lines,
    )
end

function surfaceplot!(
    plot::Plot{<:Canvas},
    X::AbstractVecOrMat,
    Y::AbstractVecOrMat,
    Z::AbstractVecOrMat,
    H::AbstractVecOrMat;
    name::AbstractString = KEYWORDS.name,
    color::UserColorType = nothing,
    colormap = KEYWORDS.colormap,
    colorbar::Bool = true,
    lines::Bool = false,
)
    plot.colorbar_lim = mh, Mh = NaNMath.extrema(as_float(H))
    plot.colormap = callback = colormap_callback(colormap)
    plot.colorbar = colorbar && color === nothing

    if color === nothing
        color =
            UserColorType[isfinite(h) ? callback(h, mh, Mh) : nothing for h in @view(H[:])]
    end

    callable = lines ? lineplot! : scatterplot!
    callable(plot, @view(X[:]), @view(Y[:]), @view(Z[:]); color = color, name = name)
end

"""
    surfaceplot(A; kw...)

# Usage

Draws a surface plot of matrix `A` along axis `x` and `y` on a new canvas.
"""
surfaceplot(A::AbstractMatrix; kw...) = surfaceplot(axes(A, 1), axes(A, 2), A; kw...)
