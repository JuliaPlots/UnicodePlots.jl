"""
    scatterplot(x, y; kw...)
    scatterplot!(p, args...; kw...)

# Description

Draws the given points on a new canvas.

The first (optional) vector `x` should contain the horizontal positions for all the points.
The second vector `y` should then contain the corresponding vertical positions respectively.
This means that the two vectors must be of the same length and ordering.

# Usage

    scatterplot([x], y; $(keywords(; add = (:canvas,))))

# Arguments

$(arguments(
    (
        marker = "choose a marker from $(keys(MARKERS)), a `Char`, a unit length `String` or a `Vector` of these",
        color = "`Vector` of colors, or scalar - $(DESCRIPTION[:color])",
    ); add = (:x, :y, :canvas)
))

Author(s)

- Christof Stocker (github.com/Evizero)

# Examples

```julia-repl
julia> scatterplot(randn(50), randn(50), title = "My Scatterplot")
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀My Scatterplot⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
      ┌────────────────────────────────────────┐ 
    3 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠠⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠠⠀⠀⠂⡀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀│ 
      │⠈⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠌⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⡇⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⡀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⡀⡏⠀⠉⠀⠀⠂⠀⠠⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠤⠤⠤⠤⠤⠤⠤⠴⠤⢤⠤⠤⠤⠤⠤⠤⠬⠤⢤⠤⡧⠤⢤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠂⠀⠀⡇⠀⠀⠀⠂⠠⡀⠀⡀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠈⠀⠀⡇⠀⠀⠀⠀⠈⠀⠀⠀⠁⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⡇⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
   -3 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
      └────────────────────────────────────────┘ 
      ⠀-2⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀2⠀ 
```

# See also

[`Plot`](@ref), [`lineplot`](@ref), [`stairs`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function scatterplot(
    x::AbstractVector,
    y::AbstractVector,
    z::Union{AbstractVector,Nothing} = nothing;
    canvas::Type = KEYWORDS.canvas,
    kw...,
)
    pkw, okw = split_plot_kw(kw)
    scatterplot!(Plot(x, y, z, canvas; pkw...), x, y, z; okw...)
end

scatterplot(y::AbstractVector; kw...) = scatterplot(axes(y, 1), y; kw...)

@doc (@doc scatterplot) function scatterplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    z::Union{AbstractVector,Nothing} = nothing;
    color::Union{UserColorType,AbstractVector} = KEYWORDS.color,
    marker::Union{MarkerType,AbstractVector} = :pixel,
    name = KEYWORDS.name,
    kw...,
)
    color = color ≡ :auto ? next_color!(plot) : color
    col_vec = color isa AbstractVector
    isempty(name) || label!(plot, :r, string(name), col_vec ? first(color) : color)
    if marker ∈ (:pixel, :auto)
        if col_vec
            @inbounds for i ∈ eachindex(color)
                points!(plot, x[i], y[i], z ≡ nothing ? z : z[i]; color = color[i])
            end
        else
            points!(plot, x, y, z; color)
        end
    else
        z ≡ nothing || throw(ArgumentError("unsupported scatter with 3D data"))
        for (xi, yi, mi, ci) ∈ zip(x, y, iterable(marker), iterable(color))
            annotate!(plot, xi, yi, char_marker(mi); color = ci, kw...)
        end
    end
    plot.series[] += 1
    plot
end

scatterplot!(plot::Plot{<:Canvas}, y::AbstractVector; kw...) =
    scatterplot!(plot, axes(y, 1), y; kw...)

# ---------------------------------------------------------------------------- #
# multiple series
function scatterplot(x::AbstractVector, y::AbstractMatrix; kw...)
    names, colors, markers = multiple_series_defaults(y, kw, 1)
    plot = scatterplot(
        x,
        y[:, begin];
        ylim = extrema(y),
        name = first(names),
        color = first(colors),
        marker = first(markers),
        filter(k -> k.first ∉ (:name, :color, :marker), kw)...,
    )
    for (i, (name, color, marker, ys)) ∈ enumerate(zip(names, colors, markers, eachcol(y)))
        i == 1 && continue
        scatterplot!(plot, x, ys; name, color, marker)
    end
    plot
end

function scatterplot!(plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractMatrix; kw...)
    names, colors, markers = multiple_series_defaults(y, kw, plot.series[] + 1)
    for (name, color, marker, ys) ∈ zip(names, colors, markers, eachcol(y))
        scatterplot!(plot, x, ys; name, color, marker)
    end
    plot
end
