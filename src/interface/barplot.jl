"""
    barplot(text, heights; nargs...)

Description
============

Draws a horizontal barplot. It uses the first parameter (`text`)
to denote the names for the bars, and the second parameter
(`heights`) as their values. This means that the two vectors have
to have the same length. Alternatively, one can specify a barplot
using a dictionary `dict`. In that case, the keys will be used as
the names and the values, which have to be numeric, will be used
as the heights of the bars.

Usage
======

    barplot(text, heights; xscale = identity, title = "", xlabel = "", ylabel = "", labels = true, border = :barplot, margin = 3, padding = 1, color = :green, width = 40, symb = "■")

    barplot(dict; kwargs...)

Arguments
==========

- **`text`** : The labels / captions of the bars.

- **`heights`** : The values / heights of the bars.

- **`dict`** : A dictonary in which the keys will be used
  as `text` and the values will be utilized as `heights`.

- **`xscale`** : Function to transform the bar length before plotting.
  This effectively scales the x-axis without influencing the captions
  of the individual bars. e.g. use `xscale = log10` for logscale.

$DOC_PLOT_PARAMS

- **`symb`** : Specifies the character that should be used to
  render the bars

Returns
========

A plot object of type `Plot{BarplotGraphics}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

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

See also
=========

[`Plot`](@ref), [`histogram`](@ref), [`BarplotGraphics`](@ref)
"""
function barplot(
        text::AbstractVector{<:AbstractString},
        heights::AbstractVector{<:Number};
        border = :barplot,
        color = :green,
        width = 40,
        symb = "■",
        xscale = identity,
        xlabel = transform_name(xscale),
        kw...)
    length(text) == length(heights) || throw(DimensionMismatch("The given vectors must be of the same length"))
    minimum(heights) >= 0 || throw(ArgumentError("All values have to be positive. Negative bars are not supported."))

    area = BarplotGraphics(heights, width, xscale, color = color, symb = symb)
    new_plot = Plot(area; border = border, xlabel = xlabel, kw...)
    for i in 1:length(text)
        annotate!(new_plot, :l, i, text[i])
    end
    new_plot
end

function barplot(dict::Dict{T,N}; kw...) where {T, N <: Number}
    barplot(collect(keys(dict)), collect(values(dict)); kw...)
end

function barplot(text::AbstractVector, heights::AbstractVector{<:Number}; kw...)
    text_str = map(string, text)
    barplot(text_str, heights; kw...)
end

function barplot(label, height::Number; kw...)
    barplot([string(label)], [height]; kw...)
end

"""
    barplot!(plot, text, heights) -> plot

Mutating variant of `barplot`, in which the first parameter
(`plot`) specifies the existing plot to draw additional bars on.

See [`barplot`](@ref) for more information.
"""
function barplot!(
        plot::Plot{<:BarplotGraphics},
        text::AbstractVector{<:AbstractString},
        heights::AbstractVector{<:Number})
    length(text) == length(heights) || throw(DimensionMismatch("The given vectors must be of the same length"))
    isempty(text) && throw(ArgumentError("Can't append empty array to barplot"))
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights)
    for i = 1:length(heights)
        annotate!(plot, :l, curidx + i, text[i])
    end
    plot
end

function barplot!(
        plot::Plot{<:BarplotGraphics},
        dict::Dict{T,N}) where {T, N <: Number}
    barplot!(plot, collect(keys(dict)), collect(values(dict)))
end

function barplot!(
        plot::Plot{<:BarplotGraphics},
        text::AbstractVector,
        heights::AbstractVector{<:Number})
    text_str = map(string, text)
    barplot!(plot, text_str, heights)
end

function barplot!(
        plot::Plot{<:BarplotGraphics},
        label,
        heights::Number)
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights)
    annotate!(plot, :l, curidx + 1, string(label))
    plot
end
