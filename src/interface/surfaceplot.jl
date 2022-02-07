"""
    surfaceplot(x, y, A; kw...)

Draws a 3D surface plot on a new canvas (masking values using `NaN`s is supported).
For plotting a slice one can pass an anonymous function which maps to a constant height: `zscale = x -> some_constant_height`.

# Usage

    surfaceplot(x, y, A; $(keywords((; lines = false); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of surface heights, or `Function` evaluated as `f(x, y)`",
        lines = "use `lineplot` instead of `scatterplot` (for regular increasing data)",
        zscale = "scale heights (`:identity`, `:aspect`, tuple of (min, max) values, or arbitrary scale function)",
    ); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :x, :y, :canvas), remove = (:blend, :grid, :name)
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
    color::UserColorType = nothing,  # NOTE: nothing as default (uses colormap), but allow single color
    colormap = KEYWORDS.colormap,
    colorbar::Bool = true,
    projection::Union{MVP,Symbol} = KEYWORDS.projection,
    zscale::Union{Symbol,Function,NTuple{2}} = :identity,
    zlim = KEYWORDS.zlim,
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

    if zscale === :identity
        ez = eh
        Z = H
    elseif zscale isa Function
        ez = zscale.(eh)
        Z = zscale.(H)
    elseif zscale === :aspect || zscale isa NTuple{2}
        mh, Mh = eh
        mz, Mz = ez = if zscale === :aspect
            diff(ex |> collect) > diff(ey |> collect) ? ex : ey
        else
            zscale
        end
        Z = (H .- mh) .* ((Mz - mz) / (Mh - mh)) .+ mz
    else
        throw(ArgumentError("zscale=$zscale not understood"))
    end

    plot =
        Plot(collect(ex), collect(ey), collect(ez), canvas; projection = projection, kw...)
    surfaceplot!(
        plot,
        X,
        Y,
        Z,
        H;
        color = color,
        colormap = colormap,
        colorbar = colorbar,
        lines = lines,
        zlim = zlim,
    )
end

function surfaceplot!(
    plot::Plot{<:Canvas},
    X::AbstractMatrix,
    Y::AbstractMatrix,
    Z::AbstractMatrix,
    H::AbstractMatrix;
    color::UserColorType = nothing,
    colormap = KEYWORDS.colormap,
    colorbar::Bool = true,
    zlim = KEYWORDS.zlim,
    lines::Bool = false,
)
    length(X) == length(Y) == length(Z) == length(H) ||
        throw(DimensionMismatch("X, Y, Z and H must have same length"))

    plot.colorbar_lim = mh, Mh = zlim == (0, 0) ? NaNMath.extrema(as_float(H)) : zlim
    plot.colormap = callback = colormap_callback(colormap)
    plot.colorbar = colorbar && color === nothing

    if (cmapped = color === nothing)
        color = map(h -> isfinite(h) ? callback(h, mh, Mh) : nothing, H)
    end

    if lines
        nx, ny = size(X)
        @inbounds for j in axes(X, 2), i in axes(X, 1)
            c = cmapped ? color[i, j] : color
            scatter = false
            if i < nx
                lines!(plot, X[i:(i + 1), j], Y[i:(i + 1), j], Z[i:(i + 1), j], c)
            else
                scatter = true
            end
            if j < ny
                lines!(plot, X[i, j:(j + 1)], Y[i, j:(j + 1)], Z[i, j:(j + 1)], c)
            else
                scatter = true
            end
            if i < nx && j < ny
                lines!(
                    plot,
                    [X[i, j], X[i + 1, j + 1]],
                    [Y[i, j], Y[i + 1, j + 1]],
                    [Z[i, j], Z[i + 1, j + 1]],
                    c,
                )
                lines!(
                    plot,
                    [X[i + 1, j], X[i, j + 1]],
                    [Y[i + 1, j], Y[i, j + 1]],
                    [Z[i + 1, j], Z[i, j + 1]],
                    c,
                )
            end
            scatter && points!(plot, X[i, j], Y[i, j], Z[i, j], c)
        end
    else
        scatterplot!(
            plot,
            @view(X[:]),
            @view(Y[:]),
            @view(Z[:]);
            color = cmapped ? @view(color[:]) : color,
        )
    end
    plot
end

"""
    surfaceplot(A; kw...)

# Usage

Draws a surface plot of matrix `A` along axis `x` and `y` on a new canvas.
"""
surfaceplot(A::AbstractMatrix; kw...) = surfaceplot(axes(A, 1), axes(A, 2), A; kw...)