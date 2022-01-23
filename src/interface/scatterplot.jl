"""
    scatterplot(x, y; kwargs...)

# Description

Draws the given points on a new canvas.

The first (optional) vector `x` should contain the horizontal
positions for all the points. The second vector `y` should then
contain the corresponding vertical positions respectively.
This means that the two vectors must be of the same length and ordering.

# Usage

    scatterplot([x], y; $(keywords(; add = (:canvas,)))

# Arguments

$(arguments(
    (; marker = "choose a marker from $(keys(MARKERS)), a `Char`, a unit length `String` or a `Vector` of these");
    add = (:x, :y, :canvas)
))

# Returns

A plot object of type `Plot{T<:Canvas}`

Author(s)

- Christof Stocker (github.com/Evizero)

# Examples

```julia-repl
julia> scatterplot(randn(50), randn(50), title = "My Scatterplot")
                   My Scatterplot
      ┌────────────────────────────────────────┐
    3 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⡇⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠡⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠁⠀⡇⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠐⠄⠀⠀⠀⠀⡀⠀⠂⡇⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠤⠤⠤⠤⠤⠤⠴⠤⠤⠤⠬⠤⠬⠤⠤⠤⡧⢥⡤⠤⠤⡤⠤⠤⠤⠬⠤⠤⠤⠤⠤⠤⠤⠤⡤⠤⠤⠤⠤⠄│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⡗⠐⠨⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⡇⠀⠐⠀⠨⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⠄⠀⠀⠀⠀⠀⡇⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠁⠂⠰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   -3 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      └────────────────────────────────────────┘
      -2                                       3
```

# See also

[`Plot`](@ref), [`lineplot`](@ref), [`stairs`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function scatterplot(
    x::AbstractVector,
    y::AbstractVector;
    canvas::Type = KEYWORDS.canvas,
    color::Union{UserColorType,AbstractVector} = KEYWORDS.color,
    marker::Union{MarkerType,AbstractVector} = :pixel,
    name = "",
    kw...,
)
    plot = Plot(x, y, canvas; kw...)
    scatterplot!(plot, x, y; color = color, name = name, marker = marker)
end

scatterplot(y::AbstractVector; kw...) = scatterplot(axes(y, 1), y; kw...)

function scatterplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector;
    color::Union{UserColorType,AbstractVector} = KEYWORDS.color,
    marker::Union{MarkerType,AbstractVector} = :pixel,
    name = "",
)
    color = (color == :auto) ? next_color!(plot) : color
    name == "" ||
        label!(plot, :r, string(name), color isa AbstractVector ? color[1] : color)
    if marker ∈ (:pixel, :auto)
        points!(plot, x, y, color)
    else
        for (xi, yi, mi, ci) in zip(x, y, iterable(marker), iterable(color))
            annotate!(plot, xi, yi, char_marker(mi); color = ci)
        end
    end
    plot
end

scatterplot!(plot::Plot{<:Canvas}, y::AbstractVector; kw...) =
    scatterplot!(plot, axes(y, 1), y; kw...)
