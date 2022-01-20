"""
    contourplot(x, y, A; kwargs...)

Draws a contour plot on a new canvas. `A` can be a `Matrix` or a `Function` evaluated as `f(x, y)`.

# Arguments
- **`levels`** : the number of contour levels. 
- **`colormap`** : the colormap to use for the contour lines. 
- **`colorbar`** : toggle the colorbar. 
$DOC_PLOT_PARAMS
- **`height`**: number of character rows that should be used for plotting.
- **`xlim`**: plotting range for the x axis. `(0, 0)` stands for automatic.
- **`ylim`**: plotting range for the y axis. `(0, 0)` stands for automatic.
- **`grid`**: if `true`, draws grid-lines at the origin.

# Author(s)
- T Bltg (github.com/t-bltg)
"""
function contourplot(
    x::AbstractVector,
    y::AbstractVector,
    A::Union{Function,AbstractMatrix};
    canvas::Type = BrailleCanvas,
    name::AbstractString = "",
    levels::Integer = 3,
    colormap = :viridis,
    blend = false,
    grid = false,
    colorbar = true,
    kw...,
)
    callback = colormap_callback(colormap)
    plot = Plot(
        extrema(x) |> collect,
        extrema(y) |> collect,
        canvas;
        blend = blend,
        grid = grid,
        colorbar = colorbar,
        colormap = callback,
        kw...,
    )
    if A isa Function
        X = repeat(x', length(y), 1)
        Y = repeat(y, 1, length(x))
        A = map(A, X, Y) |> Matrix
    end
    contourplot!(plot, x, y, A; name = name, levels = levels, colormap = callback)
end

function contourplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    A::AbstractMatrix;
    name::AbstractString = "",
    levels::Integer = 3,
    colormap = :viridis,
)
    name == "" || label!(plot, :r, string(name))

    plot.colormap = callback = colormap_callback(colormap)
    mA, MA = extrema(A)

    for cl in Contour.levels(Contour.contours(y, x, A, levels))
        color = callback(Contour.level(cl), mA, MA)
        for line in Contour.lines(cl)
            yi, xi = Contour.coordinates(line)
            lineplot!(plot, xi, yi, color = color)
        end
    end
    plot
end

"""
    contourplot(A; kwargs...)

Draws a contour plot of matrix `A` along axis `x` and `y` on a new canvas.

The `y` axis is flipped by default:

```
Julia matrices (images) │ UnicodePlots
                        │
           axes(A, 2)   │
           o───────→    │   ↑
           │            │   │
axes(A, 1) │            │ y │
           │            │   │
           ↓            │   o───────→
                        │       x
```
"""
contourplot(A::AbstractMatrix; kwargs...) =
    contourplot(axes(A, 2) |> collect, axes(A, 1) |> reverse |> collect, A; kwargs...)
