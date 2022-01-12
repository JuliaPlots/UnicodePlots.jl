"""
    contour(x, y, z; kwargs...)

Description
============

Draws a contour plot on a new canvas.

"""

function contour(
    x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
    canvas::Type = BrailleCanvas, color::Union{UserColorType,AbstractVector} = :auto,
    name::AbstractString = "",
    kw...
)
    new_plot = Plot(x, y, canvas; kw...)
    scatterplot!(new_plot, x, y; color = color, name = name)
end

function contour!(
    plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractVector, z::AbstractMatrix;
    color::Union{UserColorType,AbstractVector} = :auto,
    name::AbstractString = "",
)
    color = color == :auto ? next_color!(plot) : color
    name == "" || label!(plot, :r, string(name), color isa AbstractVector ? color[1] : color)
    for cl in Contour.levels(Contour.contours(x, y, z))
        lvl = Contour.level(cl) # the z-value of this contour level
        for line in lines(cl)
            xs, ys = coordinates(line) # coordinates of this line segment
            lineplot!(plot, xs, ys, color=lvl)
        end
    end
end