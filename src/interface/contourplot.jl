"""
    contourplot(x, y, A; kwargs...)

Draws a contour plot on a new canvas.

# Arguments
- `levels`: the number of contour levels. 
- `colormap`: the colormap to use for the contour lines. 
- `colorbar`: toggle the colorbar. 
$DOC_PLOT_PARAMS
- `height`: number of character rows that should be used for plotting.
- `xlim`: plotting range for the x axis. `(0, 0)` stands for automatic.
- `ylim`: plotting range for the y axis. `(0, 0)` stands for automatic.
- `grid`: if `true`, draws grid-lines at the origin.

# Author(s)
- T Bltg (https://github.com/t-bltg)
"""
function contourplot(
    x::AbstractVector, y::AbstractVector, A::AbstractMatrix;
    canvas::Type = BrailleCanvas, name::AbstractString = "", levels::Integer = 3, colormap = :viridis,
    blend = false, grid = false, colorbar = true, kw...
)   
    callback = colormap_callback(colormap)
    plot = Plot(
        extrema(x) |> collect,
        extrema(y) |> collect, canvas;
        blend = blend, grid = grid, colorbar = colorbar, colormap = callback,
        kw...
    )
    contourplot!(plot, x, y, A; name = name, levels = levels, colormap = callback)
end

function contourplot!(
    plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractVector, A::AbstractMatrix;
    name::AbstractString = "", levels::Integer = 3, colormap = :viridis, 
)
    name == "" || label!(plot, :r, string(name))

    plot.colormap = callback = colormap_callback(colormap)
    mA, MA = extrema(A)

    for cl in Contour.levels(Contour.contours(y, x, A, levels))
        color = callback(Contour.level(cl), mA, MA)
        for line in Contour.lines(cl)
            yi, xi = Contour.coordinates(line)
            lineplot!(plot, xi, yi, color=color)
        end
    end
    plot
end

"""
    contourplot(A; kwargs...)

Contour plot for images (flips the y axis by default)
"""
contourplot(A::AbstractMatrix; kwargs...) =
    contourplot(axes(A, 2) |> collect, axes(A, 1) |> collect |> reverse, A; kwargs...)
