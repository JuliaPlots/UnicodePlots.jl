"""
    surfaceplot(x, y, A; kw...)
    surfaceplot!(p, args...; kw...)

Draws a 3D surface plot on a new canvas (masking values using `NaN`s is supported).
To plot a slice one can pass an anonymous function which maps to a constant height: `zscale = z -> a_constant`.

# Usage

    surfaceplot(x, y, A; $(keywords((; lines = false); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid, :xscale, :yscale))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of surface heights, or `Function` evaluated as `f(x, y)`",
        lines = "use `lineplot` instead of `scatterplot` (for regular increasing data)",
        zscale = "scale heights (`:identity`, `:aspect`, tuple of (min, max) values, or arbitrary scale function)",
    ); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :x, :y, :canvas), remove = (:blend, :grid, :name, :xscale, :yscale)
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

`Plot`, `MVP`, `lineplot`, `BrailleCanvas`
"""
function surfaceplot(
    x::AbstractVecOrMat,
    y::AbstractVecOrMat,
    A::Union{Function,AbstractVecOrMat};
    canvas::Type = KEYWORDS.canvas,
    zscale::Union{Symbol,Function,NTuple{2}} = :identity,
    colormap = KEYWORDS.colormap,
    kw...,
)
    pkw, okw = split_plot_kw(; kw...)
    X, Y = if x isa AbstractVector && y isa AbstractVector && !(A isa AbstractVector)
        meshgrid(x, y)
    else
        x, y
    end
    H = A isa Function ? A.(X, Y) : A

    ex, ey = map(extrema, (x, y))
    eh = NaNMath.extrema(as_float(H))

    if zscale ≡ :identity
        ez = eh
        Z = H
    elseif zscale isa Function
        ez = zscale.(eh)
        Z = zscale.(H)
    elseif zscale ≡ :aspect || zscale isa NTuple{2}
        mh, Mh = eh
        mz, Mz = ez = if zscale ≡ :aspect
            diff(ex |> collect) > diff(ey |> collect) ? ex : ey
        else
            zscale
        end
        Z = (H .- mh) .* ((Mz - mz) / (Mh - mh)) .+ mz
    else
        throw(ArgumentError("zscale=$zscale not understood"))
    end

    plot = Plot(
        collect.((ex, ey, ez))...,
        canvas;
        projection = KEYWORDS.projection,
        colormap = colormap,
        pkw...,
    )
    surfaceplot!(plot, X, Y, Z, H; colormap = colormap, okw...)
end

@doc (@doc surfaceplot) function surfaceplot!(
    plot::Plot{<:Canvas},
    X::AbstractVecOrMat,  # support AbstractVector for `Plots.jl`
    Y::AbstractVecOrMat,
    Z::AbstractVecOrMat,
    H::Union{AbstractVecOrMat,Nothing} = nothing;
    color::UserColorType = nothing,  # NOTE: nothing as default (uses colormap), but allow single color
    colormap = KEYWORDS.colormap,
    lines::Bool = false,
    zlim = KEYWORDS.zlim,
    kw...,
)
    H = something(H, Z)
    length(X) == length(Y) == length(Z) == length(H) ||
        throw(DimensionMismatch("`X`, `Y`, `Z` and `H` must have same length"))

    cmapped = color ≡ nothing
    color = color ≡ :auto ? next_color!(plot) : color

    plot.cmap.lim = (mh, Mh) = is_auto(zlim) ? NaNMath.extrema(as_float(H)) : zlim
    plot.cmap.callback = callback = colormap_callback(colormap)
    plot.cmap.bar |= cmapped

    F = float(promote_type(eltype(X), eltype(Y), eltype(Z)))
    if (
        lines &&
        cmapped &&
        X isa AbstractMatrix &&
        Y isa AbstractMatrix &&
        Z isa AbstractMatrix &&
        H isa AbstractMatrix
    )
        m, n = size(X)
        col_cb = h -> callback(h, mh, Mh)
        buf = MMatrix{4,2,F}(undef)
        incs = (0, 0, 1, 0), (0, 0, 0, 1), (0, 0, 1, 1), (1, 0, 0, 1)
        @inbounds for j ∈ axes(X, 2), i ∈ axes(X, 1)
            for inc ∈ incs
                (i1 = i + inc[1]) > m && continue
                (j1 = j + inc[2]) > n && continue
                (i2 = i + inc[3]) > m && continue
                (j2 = j + inc[4]) > n && continue
                plot.projection(
                    buf,
                    @SMatrix(
                        [
                            X[i1, j1] X[i2, j2]
                            Y[i1, j1] Y[i2, j2]
                            Z[i1, j1] Z[i2, j2]
                            1 1
                        ]
                    )
                )
                lines!(
                    plot.graphics,
                    buf[1, 1],
                    buf[2, 1],
                    buf[1, 2],
                    buf[2, 2],
                    H[i1, j1],
                    H[i2, j2],
                    col_cb,
                )
            end
            (i == m || j == n) &&
                points!(plot, X[i, j], Y[i, j], Z[i, j], cmapped ? col_cb(H[i, j]) : color)
        end
    else
        cmapped && (color = map(h -> callback(h, mh, Mh), H))
        npts = length(Z)
        buf = Array{F}(undef, 4, npts)
        plot.projection(
            buf,
            vcat(reshape(X, 1, :), reshape(Y, 1, :), reshape(Z, 1, :), ones(1, npts)),
        )
        points!(
            plot.graphics,
            @view(buf[1, :]),
            @view(buf[2, :]),
            cmapped ? @view(color[:]) : color,
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
