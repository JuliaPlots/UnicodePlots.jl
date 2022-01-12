"""
    contourplot(x, y, z; kwargs...)

Description
============

Draws a contour plot on a new canvas. `levels` controls the number of contour levels.

Usage
=====
    contourplot(x, y, z; kwargs...)

Arguments
=========

- **`levels`** : The number of contour levels. 

- **`colormap`** : The colormap to use for the contour lines. 

- **`colorbar`** : Toggle the colorbar. 

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

function contourplot(
    x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
    canvas::Type = BrailleCanvas, name::AbstractString = "", levels::Integer = 5, colormap = :viridis,
    force = true, grid = false, colorbar = true, kw...
)   
    colormap = func_cmapcolor(colormap)
    new_plot = Plot(
        collect(extrema(x)),
        collect(extrema(y)), canvas;
        force = force, grid = grid, colorbar = colorbar, colormap = colormap,
        kw...
    )
    contourplot!(new_plot, x, y, z; name = name, levels = levels, colormap = colormap)
end

function contourplot!(
    plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
    name::AbstractString = "", levels::Integer = 5, colormap = :viridis, 
)
    name == "" || label!(plot, :r, string(name))

    colormap = colormap isa Function ? colormap : func_cmapcolor(colormap)
    minz, maxz = extrema(z)

    for cl in Contour.levels(Contour.contours(y, x, z, levels))
        color = colormap(Contour.level(cl), minz, maxz)
        for line in Contour.lines(cl)
            lineplot!(plot, reverse(Contour.coordinates(line))..., color=color)
        end
    end
    plot
end
