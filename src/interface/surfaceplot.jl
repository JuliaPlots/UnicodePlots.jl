"""
    surfaceplot(x, y, A; kw...)

Draws a 3D surface plot on a new canvas. Values can be masked using `NaN`s. Pass 

# Usage

    surfaceplot(x, y, A; $(keywords((; lines = false); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of surface heights, or `Function` evaluated as `f(x, y)`",
        lines = "use `lineplot` instead of `scatterplot`",
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

`Plot`, `scatterplot`
"""
function surfaceplot(
    x::AbstractVecOrMat,
    y::AbstractVecOrMat,
    A::Union{Function,AbstractVecOrMat};
    canvas::Type = BrailleCanvas,
    name::AbstractString = KEYWORDS.name,
    color::UserColorType = nothing,  # NOTE: nothing as default to override colormap
    colormap = KEYWORDS.colormap,
    colorbar::Bool = true,
    projection::Union{MVP,Symbol} = KEYWORDS.projection,
    zscale::Union{Symbol,Function} = :identity,
    lines::Bool = false,
    kw...,
)
    X, Y = if x isa AbstractVector && y isa AbstractVector && !(A isa AbstractVector)
        repeat(x', length(y), 1), repeat(y, 1, length(x))
    else
        x, y
    end
    H = A isa Function ? A.(X, Y) : A

    mx, Mx = extrema(x)
    my, My = extrema(y)
    mh, Mh = NaNMath.extrema(H)

    if zscale === :identity
        mz, Mz = mh, Mh
        Z = H
    elseif zscale === :aspect
        mz, Mz = min(mx, my), max(Mx, My)
        Z = (Mz - mz) .* (H .- mh) ./ (Mh - mh) .+ mz
    elseif zscale isa Function
        mz, Mz = zscale(mh), zscale(Mh)
        Z = zscale.(H)
    else
        throw(error("zscale=$zscale not understood"))
    end

    length(X) == length(Y) == length(Z) == length(H) ||
        throw(DimensionMismatch("X, Y, Z and H must have same length"))

    callback = colormap_callback(colormap)
    plot = Plot(
        [mx, Mx],
        [my, My],
        [mz, Mz],
        canvas;
        projection = projection,
        colormap = callback,
        colorbar = colorbar && color === nothing,
        colorbar_lim = (mh, Mh),
        kw...,
    )

    if color === nothing
        color =
            UserColorType[isfinite(h) ? callback(h, mh, Mh) : nothing for h in @view(H[:])]
    end
    callable = lines ? lineplot! : scatterplot!
    callable(plot, @view(X[:]), @view(Y[:]), @view(Z[:]); color = color, name = name)
    plot
end

"""
    surfaceplot(A; kw...)

# Usage

Draws a surface plot of matrix `A` along axis `x` and `y` on a new canvas.
"""
surfaceplot(A::AbstractMatrix; kw...) = surfaceplot(axes(A, 1), axes(A, 2), A; kw...)
