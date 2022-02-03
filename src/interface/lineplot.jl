"""
    lineplot(x, y; kw...)

# Description

Draws a path through the given points on a new canvas.

The first (optional) vector `x` should contain the horizontal positions for all the points along the path.
The second vector `y` should then contain the corresponding vertical positions respectively.
This means that the two vectors must be of the same length and ordering.

# Usage

    lineplot([x], y; $(keywords(; add = (:canvas,)))

    lineplot(fun, [start], [stop]; kw...)

# Arguments

$(arguments(
    (
        fun = "a unary function ``f: R -> R`` that should be evaluated, and drawn as a path from `start` to `stop` (numbers in the domain)",
        head_tail = "color the line head and/or tail with the complement of the chosen color (`:head`, `:tail`, `:both`)",
        x = "horizontal position for each point (can be a real number or of type `TimeType`), if omitted, the axes of `y` will be used as `x`",
    ) ; add = (:x, :y, :canvas)
))

# Returns

A plot object of type `Plot{T<:Canvas}`.

# Author(s)

- Christof Stocker (github.com/Evizero)
- Milktrader (github.com/milktrader)

# Examples

```julia-repl
julia> lineplot([1, 2, 7], [9, -6, 8], title = "My Lineplot")
                      My Lineplot
       ┌────────────────────────────────────────┐
    10 │⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠│
       │⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊⠁⠀│
       │⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠁⠀⠀⠀⠀│
       │⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠤⠤⠤⠼⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢤⠤⠶⠥⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤│
       │⠀⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⢱⠀⠀⠀⠀⡠⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⠀⢇⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   -10 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
       └────────────────────────────────────────┘
       1                                        7
```

# See also

[`Plot`](@ref), [`scatterplot`](@ref), [`stairs`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function lineplot(
    x::AbstractVector,
    y::AbstractVector,
    z::Union{AbstractVector,Nothing} = nothing;
    canvas::Type = KEYWORDS.canvas,
    color::UserColorType = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    head_tail::Union{Nothing,Symbol} = nothing,
    kw...,
)
    plot = Plot(x, y, z, canvas; kw...)
    lineplot!(plot, x, y, z; color = color, name = name, head_tail = head_tail)
end

lineplot(y::AbstractVector; kw...) = lineplot(axes(y, 1), y; kw...)

function lineplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    z::Union{AbstractVector,Nothing} = nothing;
    color::Union{UserColorType,AbstractVector} = KEYWORDS.color,
    name::AbstractString = KEYWORDS.name,
    head_tail::Union{Nothing,Symbol} = nothing,
)
    color = color == :auto ? next_color!(plot) : color
    name == "" ||
        label!(plot, :r, string(name), color isa AbstractVector ? color[1] : color)
    if color isa AbstractVector
        for i in 1:length(color)
            lines!(plot, x[i], y[i], z === nothing ? z : z[i], color[i])
        end
    else
        lines!(plot, x, y, z, color)
    end
    z === nothing || return plot  # 3D arrows unsupported for now
    color isa AbstractVector && return plot
    (head_tail === nothing || length(x) == 0 || length(y) == 0) && return plot
    head_tail_color = complement(color)
    if head_tail in (:head, :both)
        points!(plot, last(x), last(y), head_tail_color)
    end
    if head_tail in (:tail, :both)
        points!(plot, first(x), first(y), head_tail_color)
    end
    plot
end

lineplot!(plot::Plot{<:Canvas}, y::AbstractVector; kw...) =
    lineplot!(plot, axes(y, 1), y; kw...)

# date time

function lineplot(
    x::AbstractVector{D},
    y::AbstractVector;
    xlim = extrema(x),
    kw...,
) where {D<:TimeType}
    d = Dates.value.(x)
    dlim = Dates.value.(D.(xlim))
    plot = lineplot(d, y; xlim = dlim, kw...)
    label!(plot, :bl, string(xlim[1]), color = :light_black)
    label!(plot, :br, string(xlim[2]), color = :light_black)
end

function lineplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector{<:TimeType},
    y::AbstractVector;
    kw...,
)
    d = Dates.value.(x)
    lineplot!(plot, d, y; kw...)
end

# slope and intercept

function lineplot!(plot::Plot{<:Canvas}, intercept::Number, slope::Number; kw...)
    xmin = origin_x(plot.graphics)
    xmax = origin_x(plot.graphics) + width(plot.graphics)
    ymin = origin_y(plot.graphics)
    ymax = origin_y(plot.graphics) + height(plot.graphics)
    lineplot!(
        plot,
        [xmin, xmax],
        [intercept + xmin * slope, intercept + xmax * slope];
        kw...,
    )
end

# plotting a function

function lineplot(
    f::Function,
    x::AbstractVector;
    name = KEYWORDS.name,
    xlabel = "x",
    ylabel = "f(x)",
    kw...,
)
    y = Float64[f(i) for i in x]
    name = name == "" ? string(nameof(f), "(x)") : name
    plot = lineplot(x, y; name = name, xlabel = xlabel, ylabel = ylabel, kw...)
end

function lineplot(
    f::Function,
    startx::Number,
    endx::Number;
    out_stream::Union{Nothing,IO} = nothing,
    width::Int = out_stream_width(out_stream),
    kw...,
)
    diff = abs(endx - startx)
    x = startx:(diff / (3 * width)):endx
    lineplot(f, x; width = width, kw...)
end

lineplot(f::Function; kw...) = lineplot(f, -10, 10; kw...)

function lineplot!(plot::Plot{<:Canvas}, f::Function, x::AbstractVector; name = "", kw...)
    y = Float64[f(i) for i in x]
    name = name == "" ? string(nameof(f), "(x)") : name
    lineplot!(plot, x, y; name = name, kw...)
end

function lineplot!(
    plot::Plot{<:Canvas},
    f::Function,
    startx::Number = origin_x(plot.graphics),
    endx::Number = origin_x(plot.graphics) + width(plot.graphics);
    kw...,
)
    diff = abs(endx - startx)
    x = startx:(diff / (3ncols(plot.graphics))):endx
    lineplot!(plot, f, x; kw...)
end

# plotting vector of functions

lineplot(F::AbstractVector{<:Function}; kw...) = lineplot(F, -10, 10; kw...)

lineplot(F::AbstractVector{<:Function}, startx::Number, endx::Number; kw...) =
    _lineplot(F, startx, endx; kw...)

lineplot(F::AbstractVector{<:Function}, x::AbstractVector; kw...) = _lineplot(F, x; kw...)

function _lineplot(F::AbstractVector{<:Function}, args...; color = :auto, name = "", kw...)
    n = length(F)
    n > 0 || throw(ArgumentError("Can not plot empty array of functions"))
    color_is_vec = color isa AbstractVector
    name_is_vec  = name isa AbstractVector
    color_is_vec && (
        length(color) == n || throw(
            DimensionMismatch(
                "\"color\" must be a symbol or same length as the function vector",
            ),
        )
    )
    name_is_vec && (
        length(name) == n || throw(
            DimensionMismatch(
                "\"name\" must be a string or same length as the function vector",
            ),
        )
    )
    tcolor = color_is_vec ? color[1] : color
    tname  = name_is_vec ? name[1] : name
    plot   = lineplot(F[1], args...; color = tcolor, name = tname, kw...)
    for i in 2:n
        tcolor = color_is_vec ? color[i] : color
        tname  = name_is_vec ? name[i] : name
        lineplot!(plot, F[i], args...; color = tcolor, name = tname)
    end
    plot
end
