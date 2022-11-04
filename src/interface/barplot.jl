"""
    barplot(text, heights; kw...)
    barplot!(p, args...; kw...)

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
julia> barplot(["Paris", "New York", "Madrid"],
               [2.244, 8.406, 3.165],
               xlabel = "population [in mil]")
            ┌                                        ┐ 
      Paris ┤■■■■■■■■■ 2.244                           
   New York ┤■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 8.406   
     Madrid ┤■■■■■■■■■■■■ 3.165                        
            └                                        ┘ 
                        population [in mil]
```

# See also

[`Plot`](@ref), [`histogram`](@ref), [`BarplotGraphics`](@ref)
"""
function barplot(
    text::AbstractVector{<:AbstractString},
    heights::AbstractVector{<:Number};
    color::Union{UserColorType,AbstractVector} = :green,
    width::Union{Nothing,Integer} = nothing,
    xscale = KEYWORDS.xscale,
    name::AbstractString = KEYWORDS.name,
    kw...,
)
    pkw, okw = split_plot_kw(; kw...)
    length(text) == length(heights) ||
        throw(DimensionMismatch("the given vectors must be of the same length"))
    minimum(heights) ≥ 0 || throw(ArgumentError("all values have to be ≥ 0"))

    if any(map(t -> occursin('\n', t), text))
        _text = eltype(text)[]
        _heights = eltype(heights)[]
        for (t, h) ∈ zip(text, heights)
            lines = split(t, '\n')
            if (n = length(lines)) > 1
                append!(_text, lines)
                for i ∈ eachindex(lines)
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
        something(width, DEFAULT_WIDTH[]),
        xscale;
        symbols = KEYWORDS.symbols,
        maximum = nothing,
        color,
        okw...,
    )
    plot = Plot(area; border = :barplot, xlabel = transform_name(xscale), pkw...)

    isempty(name) || label!(plot, :r, string(name), suitable_color(plot.graphics, color))
    for i ∈ eachindex(text)
        label!(plot, :l, i, text[i])
    end

    plot
end

barplot(label, height::Number; kw...) = barplot([string(label)], [height]; kw...)
barplot(dict::AbstractDict{<:Any,<:Number}; kw...) =
    barplot(sorted_keys_values(dict)...; kw...)
barplot(text::AbstractVector, heights::AbstractVector{<:Number}; kw...) =
    barplot(map(string, text), heights; kw...)

@doc (@doc barplot) function barplot!(
    plot::Plot{<:BarplotGraphics},
    text::AbstractVector{<:AbstractString},
    heights::AbstractVector{<:Number};
    color::Union{UserColorType,AbstractVector} = nothing,
    name::AbstractString = KEYWORDS.name,
)
    length(text) == length(heights) ||
        throw(DimensionMismatch("the given vectors must be of the same length"))
    isempty(text) && throw(ArgumentError("can't append empty array to barplot"))
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights, color)
    for i ∈ eachindex(heights)
        label!(plot, :l, curidx + i, text[i])
    end
    isempty(name) || label!(plot, :r, string(name), suitable_color(plot.graphics, color))
    plot
end

barplot!(plot::Plot{<:BarplotGraphics}, dict::AbstractDict{<:Any,<:Number}; kw...) =
    barplot!(plot, sorted_keys_values(dict)...; kw...)

barplot!(
    plot::Plot{<:BarplotGraphics},
    text::AbstractVector,
    heights::AbstractVector{<:Number};
    kw...,
) = barplot!(plot, map(string, text), heights; kw...)

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
    isempty(name) || label!(plot, :r, string(name), suitable_color(plot.graphics))
    plot
end
