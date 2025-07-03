"""
    boxplot(data; kw...)
    boxplot!(p, args...; kw...)

# Description

Draws a box-and-whisker plot.

The first argument specifies the data to plot.
This is a vector of vectors, with each inner vector representing a data series.
We use a vector of vectors over a matrix to allow series of different lengths.
Optionally, a list of text may be provided, with length equal to the number of series.

Alternatively, one can specify a boxplot using a dictionary.
In that case, the values, which have to be numeric, will be used as the data series,
and the keys, which have to be strings, will be used as the labels.

# Usage
    
    boxplot([text], data; $(keywords((border = :corners, color = :green), remove = (:ylim, :height, :grid))))
    boxplot(dict; kw...)

# Arguments

$(
    arguments(
        (
            text = "the labels/captions of the boxes (optional)",
            data = "a vector of vectors, with each inner vector representing a data series (choose a vector of vectors over a matrix to allow series of different lengths)",
            dict = "a dictionary in which the keys will be used as `text` and the values will be used as `data`",
            color = "`Vector` of colors, or scalar - $(DESCRIPTION[:color])",
        ); remove = (:ylim, :yscale, :height, :grid)
    )
)

# Author(s)

- Matthew Lake (github.com/mgtlake)

# Examples

```julia-repl
julia> boxplot([1, 2, 3, 7]; title = "Test")
                       Test                    
    ┌                                        ┐ 
     ╷   ┌────┬─────────┐                   ╷  
     ├───┤    │         ├───────────────────┤  
     ╵   └────┴─────────┘                   ╵  
    └                                        ┘ 
     1                  4                   7  
```

# See also

[`Plot`](@ref), [`histogram`](@ref), [`BoxplotGraphics`](@ref)
"""
function boxplot(
        text::AbstractVector{<:AbstractString},
        data::AbstractVector{<:AbstractArray{<:Number}};
        color::Union{UserColorType, AbstractVector} = :green,
        width::Union{Nothing, Integer} = nothing,
        xlim = KEYWORDS.xlim,
        kw...,
    )
    pkw, okw = split_plot_kw(kw)
    length(xlim) == 2 ||
        throw(ArgumentError("`xlim` must be a tuple or a vector of length 2"))
    length(text) == length(data) || throw(DimensionMismatch("wrong number of text"))
    min_x, max_x = extend_limits(reduce(vcat, data), xlim)
    width = max(something(width, DEFAULT_WIDTH[]), 10)

    area = BoxplotGraphics(first(data), width; color, min_x, max_x, okw...)
    foreach(i -> addseries!(area, data[i]), 2:length(data))
    plot = Plot(area; border = :corners, pkw...)

    min_x_str, mean_x_str, max_x_str =
        nice_repr.((min_x, (min_x + max_x) / 2, max_x), Ref(plot))
    label!(plot, :bl, min_x_str; color = BORDER_COLOR[])
    label!(plot, :b, mean_x_str; color = BORDER_COLOR[])
    label!(plot, :br, max_x_str; color = BORDER_COLOR[])

    for (i, name) in enumerate(text)
        # Find end of last 3-line region, then add 2 for center of current
        length(name) > 0 && label!(plot, :l, 3(i - 1) + 2, name)
    end
    return plot
end

@doc (@doc boxplot) function boxplot!(
        plot::Plot{<:BoxplotGraphics},
        data::AbstractVector{<:Number};
        name = KEYWORDS.name,
        kw...,
    )
    isempty(data) && throw(ArgumentError("can't append empty array to boxplot"))

    addseries!(plot.graphics, data)

    # Find end of last 3-line region, then add 2 for center of current
    label!(plot, :l, 3(length(plot.graphics.data) - 1) + 2, name)

    min_x = plot.graphics.min_x[]
    max_x = plot.graphics.max_x[]
    min_x_str, mean_x_str, max_x_str =
        nice_repr.((min_x, (min_x + max_x) / 2, max_x), Ref(plot))
    label!(plot, :bl, min_x_str)
    label!(plot, :b, mean_x_str)
    label!(plot, :br, max_x_str)
    return plot
end

boxplot!(plot, name, data::AbstractVector{<:Number}; kw...) =
    boxplot!(plot, data; name, kw...)
boxplot(data::AbstractVector{<:AbstractArray{<:Number}}; kw...) =
    boxplot(fill("", length(data)), data; kw...)
boxplot(text::AbstractString, data::AbstractVector{<:Number}; kw...) =
    boxplot([text], [data]; kw...)
boxplot(data::AbstractVector{<:Number}; kw...) = boxplot("", data; kw...)
boxplot(dict::AbstractDict; kw...) = boxplot(sorted_keys_values(dict)...; kw...)
