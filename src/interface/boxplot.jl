"""
    boxplot(data; kwargs...)

# Description

Draws a box-and-whisker plot.

The first argument specifies the data to plot. This is a vector
of vectors, with each inner vector representing a data series. We
use a vector of vectors over a matrix to allow series of
different lengths. Optionally, a list of text may be provided,
with length equal to the number of series.

Alternatively, one can specify a boxplot using a dictionary. In
that case, the values, which have to be numeric, will be used as
the data series, and the keys, which have to be strings, will be
used as the labels.

# Usage
    
    boxplot([text], data; $(keywords((border = :corners, color = :green,), remove = (:ylim, :height, :grid)))

    boxplot(dict; kwargs...)

# Arguments

$(arguments(
    (
        text = "the labels/captions of the boxes (optional)",
        data = "a vector of vectors, with each inner vector representing a data series (choose a vector of vectors over a matrix to allow series of different lengths)",
        dict = "a dictonary in which the keys will be used as `text` and the values will be used as `data`",
    ); remove = (:ylim, :yscale, :height, :grid)
))

# Returns

A plot object of type `Plot{BoxplotGraphics}`.

# Author(s)

- Matthew Lake (github.com/mgtlake)

# Examples

```julia-repl
julia> boxplot([1, 2, 3, 7], title = "Test")
                      Test
    ┌                                        ┐
     ╷   ┌────┬─────────┐                   ╷
     ├───┤    │         ├───────────────────┤
     ╵   └────┴─────────┘                   ╵
    └                                        ┘
    1                   4                    7
```

# See also

[`Plot`](@ref), [`histogram`](@ref), [`BoxplotGraphics`](@ref)
"""
function boxplot(
    text::AbstractVector{<:AbstractString},
    data::AbstractVector{<:AbstractArray{<:Number}};
    border = :corners,
    color::UserColorType = :green,
    out_stream::Union{Nothing,IO} = nothing,
    width::Int = out_stream_width(out_stream),
    xlim = (0, 0),
    kw...,
)
    length(xlim) == 2 ||
        throw(ArgumentError("xlim must be a tuple or a vector of length 2"))
    length(text) == length(data) || throw(DimensionMismatch("Wrong number of text"))
    min_x, max_x = extend_limits(reduce(vcat, data), xlim)
    width = max(width, 10)

    area = BoxplotGraphics(data[1], width, color = color, min_x = min_x, max_x = max_x)
    for i in 2:length(data)
        addseries!(area, data[i])
    end

    plot = Plot(area; border = border, kw...)

    mean_x = (min_x + max_x) / 2
    min_x_str = compact_repr(
        roundable(min_x) ? round(Int, Float64(min_x), RoundNearestTiesUp) : min_x,
    )
    mean_x_str = compact_repr(
        roundable(mean_x) ? round(Int, Float64(mean_x), RoundNearestTiesUp) : mean_x,
    )
    max_x_str = compact_repr(
        roundable(max_x) ? round(Int, Float64(max_x), RoundNearestTiesUp) : max_x,
    )
    label!(plot, :bl, min_x_str, color = :light_black)
    label!(plot, :b, mean_x_str, color = :light_black)
    label!(plot, :br, max_x_str, color = :light_black)

    for (i, name) in enumerate(text)
        # Find end of last 3-line region, then add 2 for center of current
        length(name) > 0 && label!(plot, :l, 3(i - 1) + 2, name)
    end
    plot
end

"""
    boxplot!(plot, data; kwargs...)

Mutating variant of `boxplot`, in which the first parameter (`plot`) specifies the existing plot to draw on.

See `boxplot` for more information.
"""
function boxplot!(
    plot::Plot{<:BoxplotGraphics},
    data::AbstractVector{<:Number};
    name = " ",
    kw...,
)
    !isempty(data) || throw(ArgumentError("Can't append empty array to boxplot"))

    # min_x, max_x = extend_limits(data, xlim)
    # plot.graphics.min_x = max(plot.graphics.min_x, min_x)
    # plot.graphics.max_x = min(plot.graphics.max_x, max_x)

    addseries!(plot.graphics, data)

    # Find end of last 3-line region, then add 2 for center of current
    label!(plot, :l, (length(plot.graphics.data) - 1) * 3 + 2, name)

    min_x = plot.graphics.min_x
    max_x = plot.graphics.max_x
    mean_x = (min_x + max_x) / 2
    min_x_str = compact_repr(
        roundable(min_x) ? round(Int, Float64(min_x), RoundNearestTiesUp) : min_x,
    )
    mean_x_str = compact_repr(
        roundable(mean_x) ? round(Int, Float64(mean_x), RoundNearestTiesUp) : mean_x,
    )
    max_x_str = compact_repr(
        roundable(max_x) ? round(Int, Float64(max_x), RoundNearestTiesUp) : max_x,
    )
    label!(plot, :bl, min_x_str)
    label!(plot, :b, mean_x_str)
    label!(plot, :br, max_x_str)
    plot
end

boxplot!(plot, name, data::AbstractVector{<:Number}; kw...) =
    boxplot!(plot, data; name = name, kw...)
boxplot(data::AbstractVector{<:AbstractArray{<:Number}}; kw...) =
    boxplot(fill("", length(data)), data; kw...)
boxplot(text::AbstractString, data::AbstractVector{<:Number}; kw...) =
    boxplot([text], [data]; kw...)
boxplot(data::AbstractVector{<:Number}; kw...) = boxplot("", data; kw...)
boxplot(dict::Dict; kw...) = boxplot(sorted_keys_values(dict)...; kw...)
