"""
    contour(x, y, z; kwargs...)

Description
============

Draws a contour plot on a new canvas. `levels` controls the number of contour levels.

Usage
=====
    contour(x, y, z; kwargs...)

Arguments
=========

- **`levels`** : The number of contour levels. 

- **`colormap`** : The colormap to use for the contour lines. 

$DOC_PLOT_PARAMS

- **`height`** : Number of character rows that should be used
  for plotting.

- **`xlim`** : Plotting range for the x axis.
  `(0, 0)` stands for automatic.

- **`ylim`** : Plotting range for the y axis.
  `(0, 0)` stands for automatic.

- **`grid`** : If `true`, draws grid-lines at the origin.

Author(s)
==========

- T Bltg (https://github.com/t-bltg)
"""

function contour(
    x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
    canvas::Type = BrailleCanvas, name::AbstractString = "", levels::Integer = 10, colormap = :viridis,
    force = true, grid = false, kw...
)   
    # NOTE: force the colors (avoid color blend on contour lines)
    new_plot = Plot(collect(extrema(x)), collect(extrema(y)), canvas; force = force, grid = grid, kw...)
    contour!(new_plot, x, y, z; name = name, levels = levels, colormap = colormap)
end

function contour!(
    plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
    name::AbstractString = "", levels::Integer = 10, colormap = :viridis, 
)
    (size(z, 1) != size(x, 1) && size(z, 2) != size(y, 1)) && (z = permutedims(z))
    name == "" || label!(plot, :r, string(name))

    colormap = func_cmapcolor(colormap)
    minz, maxz = extrema(z)

    for cl in Contour.levels(Contour.contours(x, y, z, levels))
        color = colormap(Contour.level(cl), minz, maxz)
        for line in Contour.lines(cl)
            lineplot!(plot, Contour.coordinates(line)..., color=color)
        end
    end
    plot
end
