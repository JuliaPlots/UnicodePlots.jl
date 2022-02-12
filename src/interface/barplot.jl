"""
    barplot(text, heights; kw...)

# Description

Draws a horizontal barplot.
It uses the first parameter (`text`) to denote the names for the bars,
and the second parameter (`heights`) as their values.
This means that the two vectors have to have the same length.
Alternatively, one can specify a barplot using a dictionary `dict`.
In that case, the keys will be used as the names and the values,
which have to be numeric, will be used as the heights of the bars.

# Usage
    
    barplot(text, heights; $(keywords((border = :barplot, color = :green, maximum = nothing), remove = (:xlim, :ylim, :yscale, :height, :grid), add = (:symbols,))))

    barplot(dict; kw...)

# Arguments

$(arguments(
    (
        text = "the labels / captions of the bars",
        heights = "the values / heights of the bars",
        dict = "a dictonary in which the keys will be used as `text` and the values will be used as `heights`",
        xscale = "`Function` or `Symbol` to transform the bar length before plotting: this effectively scales the `x`-axis without influencing the captions of the individual bars (use `xscale = :log10` for logscale)",
        color = "`Vector` of colors, or scalar - $(DESCRIPTION[:color])",
        maximum = "optional maximal height"
    ); remove = (:xlim, :ylim, :yscale, :height, :grid), add = (:symbols,),
))

# Author(s)

- Christof Stocker (github.com/Evizero)

# Examples

```julia-repl
julia> barplot(["Paris", "New York", "Moskau", "Madrid"],
               [2.244, 8.406, 11.92, 3.165],
               xlabel = "population [in mil]")
            ┌                                        ┐
      Paris ┤■■■■■■ 2.244
   New York ┤■■■■■■■■■■■■■■■■■■■■■■■ 8.406
     Moskau ┤■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 11.92
     Madrid ┤■■■■■■■■■ 3.165
            └                                        ┘
                       population [in mil]
```

# See also

[`Plot`](@ref), [`histogram`](@ref), [`BarplotGraphics`](@ref)
"""
function barplot(
    text::AbstractVector{<:AbstractString},
    heights::AbstractVector{<:Number};
    border = :barplot,
    color::Union{UserColorType,AbstractVector} = :green,
    out_stream::Union{Nothing,IO} = nothing,
    width::Int = out_stream_width(out_stream),
    symb = nothing,  # deprecated
    symbols = KEYWORDS.symbols,
    xscale = KEYWORDS.xscale,
    xlabel = transform_name(xscale),
    maximum::Union{Nothing,Number} = nothing,
    name::AbstractString = KEYWORDS.name,
    kw...,
)
    length(text) == length(heights) ||
        throw(DimensionMismatch("The given vectors must be of the same length"))
    minimum(heights) >= 0 || throw(
        ArgumentError("All values have to be positive. Negative bars are not supported."),
    )

    if any('\n' in t for t in text)
        _text = eltype(text)[]
        _heights = eltype(heights)[]
        for (t, h) in zip(text, heights)
            lines = split(t, '\n')
            if (n = length(lines)) > 1
                append!(_text, lines)
                for i in 1:n
                    push!(_heights, i == n ? h : -1)
                end
            else
                push!(_text, t)
                push!(_heights, h)
            end
        end
        text, heights = _text, _heights
    end

    area = BarplotGraphics(
        heights,
        width,
        xscale;
        color = color,
        symbols = _handle_deprecated_symb(symb, symbols),
        maximum = maximum,
    )
    plot = Plot(area; border = border, xlabel = xlabel, kw...)
    for i in 1:length(text)
        label!(plot, :l, i, text[i])
    end
    name == "" || label!(plot, :r, string(name), suitable_color(plot.graphics, color))

    plot
end

barplot(dict::Dict{T,N}; kw...) where {T,N<:Number} =
    barplot(sorted_keys_values(dict)...; kw...)
barplot(label, height::Number; kw...) = barplot([string(label)], [height]; kw...)

function barplot(text::AbstractVector, heights::AbstractVector{<:Number}; kw...)
    text_str = map(string, text)
    barplot(text_str, heights; kw...)
end

"""
    barplot!(plot, text, heights)

Mutating variant of `barplot`, in which the first parameter
(`plot`) specifies the existing plot to draw additional bars on.

See [`barplot`](@ref) for more information.
"""
function barplot!(
    plot::Plot{<:BarplotGraphics},
    text::AbstractVector{<:AbstractString},
    heights::AbstractVector{<:Number};
    color::Union{UserColorType,AbstractVector} = nothing,
    name::AbstractString = KEYWORDS.name,
)
    length(text) == length(heights) ||
        throw(DimensionMismatch("The given vectors must be of the same length"))
    isempty(text) && throw(ArgumentError("Can't append empty array to barplot"))
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights, color)
    for i in 1:length(heights)
        label!(plot, :l, curidx + i, text[i])
    end
    name == "" || label!(plot, :r, string(name), suitable_color(plot.graphics, color))
    plot
end

barplot!(plot::Plot{<:BarplotGraphics}, dict::Dict{T,N}; kw...) where {T,N<:Number} =
    barplot!(plot, sorted_keys_values(dict)...; kw...)

function barplot!(
    plot::Plot{<:BarplotGraphics},
    text::AbstractVector,
    heights::AbstractVector{<:Number};
    kw...,
)
    text_str = map(string, text)
    barplot!(plot, text_str, heights; kw...)
end

function barplot!(
    plot::Plot{<:BarplotGraphics},
    label,
    heights::Number;
    color::UserColorType = nothing,
    name::AbstractString = KEYWORDS.name,
)
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights, color)
    label!(plot, :l, curidx + 1, string(label))
    name == "" || label!(plot, :r, string(name), suitable_color(plot.graphics))
    plot
end
