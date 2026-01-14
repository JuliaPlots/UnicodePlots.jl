"""
    lineplot(; kw...)
    lineplot(y; kw...)
    lineplot(x, y; kw...)
    lineplot!(p, args...; kw...)

# Description

Draws a path through the given points on a new canvas.

The first (optional) vector `x` should contain the horizontal positions for all the points along the path.
The second vector `y` should then contain the corresponding vertical positions respectively.
This means that the two vectors must be of the same length and ordering.

# Usage

    lineplot([x], y; $(keywords((; head_tail = nothing, head_tail_frac = 5 / 100); add = (:canvas,))))
    lineplot([start], [stop], fun; kw...)

# Arguments

$(
    arguments(
        (
            fun = "a unary function ``f: R -> R`` that should be evaluated, and drawn as a path from `start` to `stop` (numbers in the domain)",
            head_tail = "color the line head and/or tail with the complement of the chosen color (`:head`, `:tail`, `:both`)",
            head_tail_frac = "fraction of the arrow head or tail (e.g. provide `0.1` for 10%)",
            x = "horizontal position for each point (can be a real number or of type `TimeType`), if omitted, the axes of `y` will be used as `x`",
            format = "specify the ticks date format (`TimeType` only)",
            color = "`Vector` of colors, or scalar - $(DESCRIPTION[:color])",
        ); add = (:x, :y, :canvas)
    )
)

# Author(s)

- Christof Stocker (github.com/Evizero)
- Milktrader (github.com/milktrader)

# Examples

```julia-repl
julia> lineplot([1, 2, 7], [9, -6, 8]; title = "My Lineplot")
       ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀My Lineplot⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
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
       ⠀1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀7⠀
```

# See also

[`Plot`](@ref), [`scatterplot`](@ref), [`stairs`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function lineplot(
        x::AbstractVector,
        y::AbstractVector,
        z::Union{AbstractVector, Nothing} = nothing;
        canvas::Type = KEYWORDS.canvas,
        kw...,
    )
    pkw, okw = split_plot_kw(kw)
    return lineplot!(Plot(x, y, z, canvas; pkw...), x, y, z; okw...)
end

lineplot(; kw...) = lineplot([]; kw...)
lineplot(y::AbstractVector; kw...) = lineplot(axes(y, 1), y; kw...)

@doc (@doc lineplot) function lineplot!(
        plot::Plot{<:Canvas},
        x::AbstractVector,
        y::AbstractVector,
        z::Union{AbstractVector, Nothing} = nothing;
        color::Union{UserColorType, AbstractVector} = KEYWORDS.color,
        name::AbstractString = KEYWORDS.name,
        head_tail::Union{Nothing, Symbol} = nothing,
        head_tail_frac::Number = 5 / 100,
    )
    color = color ≡ :auto ? next_color!(plot) : color
    col_vec = color isa AbstractVector
    isempty(name) || label!(plot, :r, string(name), col_vec ? first(color) : color)
    (nx = length(x)) == length(y) ||
        throw(ArgumentError("`x`, `y` must be the same length"))
    if col_vec
        nx == length(color) ||
            throw(ArgumentError("`x`, `y` and `color` must be the same length"))
        @inbounds for i in eachindex(color)
            lines!(plot, x[i], y[i], z ≡ nothing ? z : z[i]; color = color[i])
        end
    else
        lines!(plot, x, y, z; color)
    end
    (head_tail ≡ nothing || nx == 0) && return plot

    n = min(round(Int, head_tail_frac * nx, RoundToZero), nx - 1)
    callable = n > 0 ? lines! : points!
    if head_tail ∈ (:head, :both)
        callable(
            plot,
            x[(end - n):end],
            y[(end - n):end],
            z ≡ nothing ? z : z[(end - n):end];
            color = complement(col_vec ? color[(end - n):end] : color),
        )
    end
    if head_tail ∈ (:tail, :both)
        callable(
            plot,
            x[begin:(begin + n)],
            y[begin:(begin + n)],
            z ≡ nothing ? z : z[begin:(begin + n)];
            color = complement(col_vec ? color[begin:(begin + n)] : color),
        )
    end
    plot.series[] += 1
    return plot
end

lineplot!(plot::Plot{<:Canvas}, y::AbstractVector; kw...) =
    lineplot!(plot, axes(y, 1), y; kw...)

# ---------------------------------------------------------------------------- #
# multiple series
function lineplot(x::AbstractVector, y::AbstractMatrix; kw...)
    names, colors = multiple_series_defaults(y, kw, 1)
    plot = lineplot(
        x,
        y[:, begin];
        ylim = extrema(y),
        name = first(names),
        color = first(colors),
        filter(a -> a.first ∉ (:name, :color), kw)...,
    )
    for (i, (name, color, ys)) in enumerate(zip(names, colors, eachcol(y)))
        i == 1 && continue
        lineplot!(plot, x, ys; name, color)
    end
    return plot
end

function lineplot!(plot::Plot{<:Canvas}, x::AbstractVector, y::AbstractMatrix; kw...)
    names, colors = multiple_series_defaults(y, kw, plot.series[] + 1)
    for (name, color, ys) in zip(names, colors, eachcol(y))
        lineplot!(plot, x, ys; name, color)
    end
    return plot
end

# ---------------------------------------------------------------------------- #
# date time

format_date(dt, ::Nothing) = string(dt)
format_date(dt, format::AbstractString) = Dates.format(dt, format)

function lineplot(
        x::AbstractVector{D},
        y::AbstractVector;
        format::Union{Nothing, AbstractString} = nothing,
        xlim = extrema(x),
        xticks = true,
        kw...,
    ) where {D <: TimeType}
    dlim = (Dates.value ∘ D).(xlim)
    plot = lineplot(Dates.value.(x), y; xlim = dlim, xticks = xticks, kw...)
    if xticks
        label!(plot, :bl, format_date(xlim[1], format); color = BORDER_COLOR[])
        label!(plot, :br, format_date(xlim[2], format); color = BORDER_COLOR[])
    end
    return plot
end

lineplot!(plot::Plot{<:Canvas}, x::AbstractVector{<:TimeType}, y::AbstractVector; kw...) =
    lineplot!(plot, Dates.value.(x), y; kw...)

# ---------------------------------------------------------------------------- #
# slope and intercept
function lineplot!(plot::Plot{<:Canvas}, intercept::Number, slope::Number; kw...)
    xmin = origin_x(plot.graphics)
    xmax = origin_x(plot.graphics) + width(plot.graphics)
    ymin = origin_y(plot.graphics)
    ymax = origin_y(plot.graphics) + height(plot.graphics)
    return lineplot!(
        plot,
        [xmin, xmax],
        [intercept + xmin * slope, intercept + xmax * slope];
        kw...,
    )
end

# ---------------------------------------------------------------------------- #
# functions
lineplot(
    x::AbstractVector{<:Number},
    f::Function;
    name = KEYWORDS.name,
    xlabel = "x",
    ylabel = "f(x)",
    kw...,
) = lineplot(x, (float ∘ f).(x); name = function_name(f, name), xlabel, ylabel, kw...)

function lineplot(startx::Number, endx::Number, f::Function; kw...)
    _, width = plot_size(; kw...)
    x = startx:(abs(endx - startx) / 3width):endx
    return lineplot(x, f; width, kw...)
end

lineplot(f::Function; kw...) = lineplot(-10, 10, f; kw...)

lineplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector{<:Number},
    f::Function;
    name = KEYWORDS.name,
    kw...,
) = lineplot!(plot, x, (float ∘ f).(x); name = function_name(f, name), kw...)

lineplot!(plot::Plot{<:Canvas}, f::Function; kw...) = lineplot!(
    plot,
    origin_x(plot.graphics),
    origin_x(plot.graphics) + width(plot.graphics),
    f;
    kw...,
)

function lineplot!(plot::Plot{<:Canvas}, startx::Number, endx::Number, f::Function; kw...)
    x = startx:(abs(endx - startx) / 3ncols(plot.graphics)):endx
    return lineplot!(plot, x, f; kw...)
end

# ---------------------------------------------------------------------------- #
# vector of functions
lineplot(F::AbstractVector{<:Function}; kw...) = lineplot(-10, 10, F; kw...)

lineplot(startx::Number, endx::Number, F::AbstractVector{<:Function}; kw...) =
    _lineplot((startx, endx), F; kw...)

lineplot(x::AbstractVector{<:Number}, F::AbstractVector{<:Function}; kw...) =
    _lineplot((x,), F; kw...)

function _lineplot(args, F::AbstractVector{<:Function}; color = :auto, name = "", kw...)
    (n = length(F)) > 0 || throw(ArgumentError("cannot plot empty array of functions"))
    color_is_vec = color isa AbstractVector
    name_is_vec = name isa AbstractVector
    if color_is_vec
        length(color) == n ||
            "`color` must be a symbol or same length as the function vector" |>
            DimensionMismatch |>
            throw
    end
    if name_is_vec
        length(name) == n ||
            "`name` must be a string or same length as the function vector" |>
            DimensionMismatch |>
            throw
    end
    tcolor = color_is_vec ? first(color) : color
    tname = name_is_vec ? first(name) : name
    plot = lineplot(args..., first(F); color = tcolor, name = tname, kw...)
    for i in eachindex(F)
        i == 1 && continue
        tcolor = color_is_vec ? color[i] : color
        tname = name_is_vec ? name[i] : name
        lineplot!(plot, args..., F[i]; color = tcolor, name = tname)
    end
    return plot
end

# ---------------------------------------------------------------------------- #
# helpers

"""
    vline!(plot::Plot{<:Canvas}, x::Number, y::Union{AbstractVector{<:Number},Nothing} = nothing; kw...)

Draws a vertical line at position `x` (and optional `y` values).
"""
function vline!(
        plot::Plot{<:Canvas},
        x::Number,
        y::Union{AbstractVector{<:Number}, Nothing} = nothing;
        kw...,
    )
    o = origin_y(plot.graphics)
    ys = something(y, range(o, o + height(plot.graphics); length = nrows(plot.graphics)))
    return lineplot!(plot, fill(x, length(ys)), ys; kw...)
end

"""
    vline!(plot::Plot{<:Canvas}, x::AbstractVector{<:Number}, y::Union{AbstractVector{<:Number},Nothing} = nothing; kw...)

Draws vertical lines at positions given in `x` (and optional `y` values).
"""
function vline!(
        plot::Plot{<:Canvas},
        x::AbstractVector{<:Number},
        y::Union{AbstractVector{<:Number}, Nothing} = nothing;
        kw...,
    )
    foreach(v -> vline!(plot, v, y; kw...), x)
    return plot
end

"""
    hline!(plot::Plot{<:Canvas}, y::Number, x::Union{AbstractVector{<:Number},Nothing} = nothing; kw...)

Draws an horizontal line at position `y` (and optional `x` values).
"""
function hline!(
        plot::Plot{<:Canvas},
        y::Number,
        x::Union{AbstractVector{<:Number}, Nothing} = nothing;
        kw...,
    )
    o = origin_x(plot.graphics)
    xs = something(x, range(o, o + width(plot.graphics); length = ncols(plot.graphics)))
    return lineplot!(plot, xs, fill(y, length(xs)); kw...)
end

"""
    hline!(plot::Plot{<:Canvas}, y::AbstractVector{<:Number}, x::Union{AbstractVector{<:Number},Nothing} = nothing; kw...)

Draws horizontal lines at positions given in `y` (and optional `x` values).
"""
function hline!(
        plot::Plot{<:Canvas},
        y::AbstractVector{<:Number},
        x::Union{AbstractVector{<:Number}, Nothing} = nothing;
        kw...,
    )
    foreach(v -> hline!(plot, v, x; kw...), y)
    return plot
end
