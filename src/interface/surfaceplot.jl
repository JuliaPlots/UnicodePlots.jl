"""
    surfaceplot(x, y, A; kwargs...)

Draws a 3D surface plot on a new canvas. Values can be masked using `NaN`s.

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
    1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  ┌──┐ 1
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
      │⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⢷⢵⢾⡷⡮⡾⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⢀⡠⠼⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⢕⡯⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  │▄▄│  
   -1 │⠊⠁⠀⠀⠀⠀⠉⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│  └──┘ 0
      └────────────────────────────────────────┘  ⠀⠀⠀⠀  
      ⠀-1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀  ⠀⠀⠀⠀  
```

# See also

`Plot`, `scatterplot`
"""
function surfaceplot(
    x::AbstractVecOrMat,
    y::AbstractVecOrMat,
    A::Union{Function,AbstractMatrix};
    canvas::Type = BrailleCanvas,
    name::AbstractString = KEYWORDS.name,
    projection::Union{MVP,Symbol} = KEYWORDS.projection,
    colormap = KEYWORDS.colormap,
    colorbar::Bool = true,
    lines::Bool = false,
    kwargs...,
)
    X, Y = if x isa AbstractVector && y isa AbstractVector
        repeat(x', length(y), 1), repeat(y, 1, length(x))
    else
        x, y
    end
    Z = if A isa Function
        map(A, X, Y) |> Matrix
    else
        A
    end
    length(X) == length(Y) == length(Z) ||
        throw(DimensionMismatch("x, y and z must have same length"))

    callback = colormap_callback(colormap)
    plot = Plot(
        @view(X[:]),
        @view(Y[:]),
        @view(Z[:]),
        canvas;
        projection = projection,
        colormap = callback,
        colorbar = colorbar,
        kwargs...,
    )
    surfaceplot!(plot, X, Y, Z; name = name, colormap = colormap, lines = lines)
    plot
end

function surfaceplot!(
    plot::Plot{<:Canvas},
    X::AbstractMatrix,
    Y::AbstractMatrix,
    Z::AbstractMatrix;
    name::AbstractString = KEYWORDS.name,
    colormap = KEYWORDS.colormap,
    lines::Bool = false,
)
    name == "" || label!(plot, :r, string(name))
    plot.colormap = callback = colormap_callback(colormap)

    mZ, MZ = NaNMath.extrema(Z)
    color = UserColorType[isfinite(z) ? callback(z, mZ, MZ) : nothing for z in @view(Z[:])]
    callable = lines ? lineplot! : scatterplot!
    callable(plot, @view(X[:]), @view(Y[:]), @view(Z[:]); color = color, name = name)
    plot
end

"""
    surfaceplot(A; kwargs...)

# Usage

Draws a surface plot of matrix `A` along axis `x` and `y` on a new canvas.
"""
surfaceplot(A::AbstractMatrix; kwargs...) =
    surfaceplot(axes(A, 1), axes(A, 2), A; kwargs...)
