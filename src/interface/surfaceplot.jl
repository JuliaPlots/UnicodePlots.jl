"""
    surfaceplot(x, y, A; kwargs...)

Draws a 3D surface plot on a new canvas.

# Usage

    surfaceplot(x, y, A; $(keywords((; mask_small = true); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of surface heights, or `Function` evaluated as `f(x, y)`",
        mask_small = "mask small values (close to 0)",
    ); add = (Z_DESCRIPTION..., PROJ_DESCRIPTION..., :x, :y, :mask_small, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
julia> surfaceplot(-8:.5:8, -8:.5:8, sombrero)
      ┌────────────────────────────────────────┐ 
    1 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡫⢟⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡔⠌⡡⢢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣰⣭⣊⣑⣭⣆⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠴⣚⠯⡫⢝⣿⣿⡻⣟⣿⣿⡫⢝⠽⣓⠦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣯⡭⠭⠒⢊⠔⢱⢍⡘⡖⣳⢃⡩⡎⠢⡑⠒⠭⢭⣽⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣞⠭⠭⠥⢒⣿⣋⣵⢜⡧⣮⣙⣿⡒⠬⠭⠭⣳⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠴⢾⠿⠯⠛⠛⠽⢿⣯⣶⣮⡽⠛⠫⡉⠃⠙⢉⠝⠛⢯⣵⣶⣽⡿⠯⠛⠛⠽⠿⡷⠦⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⢶⣶⣶⡺⣗⣶⣶⡶⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⢷⢵⢾⡷⡮⡾⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⢀⡠⠼⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⢕⡯⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
   -1 │⠊⠁⠀⠀⠀⠀⠉⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      └────────────────────────────────────────┘ 
      ⠀-1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀ 
```
"""
function surfaceplot(
    x::Union{AbstractVector,AbstractMatrix},
    y::Union{AbstractVector,AbstractMatrix},
    A::Union{Function,AbstractMatrix};
    canvas::Type = BrailleCanvas,
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    projection::Union{MVP,Symbol} = KEYWORDS.projection,
    colormap = KEYWORDS.colormap,
    mask_small = false,
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
        mask_small ? copy(A) : A
    end
    length(X) == length(Y) == length(Z) ||
        throw(DimensionMismatch("x, y and z must have same length"))

    mask_small && (Z[abs.(Z) .< eps(eltype(Z))] .= NaN)

    callback = colormap_callback(colormap)
    plot = Plot(
        @view(X[:]),
        @view(Y[:]),
        @view(Z[:]),
        canvas;
        projection = projection,
        colormap = callback,
        kwargs...,
    )
    surfaceplot!(plot, X, Y, Z; name = name, color = color, colormap = colormap)

    plot
end

function surfaceplot!(
    plot::Plot{<:Canvas},
    X::AbstractMatrix,
    Y::AbstractMatrix,
    Z::AbstractMatrix;
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    colormap = KEYWORDS.colormap,
)
    name == "" || label!(plot, :r, string(name))
    plot.colormap = callback = colormap_callback(colormap)

    scatterplot!(plot, @view(X[:]), @view(Y[:]), @view(Z[:]); color = color, name = name)
    plot
end

"""
    surfaceplot(A; kwargs...)

# Usage

Draws a surface plot of matrix `A` along axis `x` and `y` on a new canvas.
"""
surfaceplot(A::AbstractMatrix; kwargs...) =
    surfaceplot(axes(A, 1), axes(A, 2), A; kwargs...)
