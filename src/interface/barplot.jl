"""
`barplot(text, heights; nargs...)` → `Plot`

Description
============

Draws a horizontal barplot. It uses the first parameter (`text`) to denote
the names for the bars, and the second parameter (`heights`) as their values.
This means that the two vectors have to have the same length.
Alternatively, one can specify a barplot using a dictionary.
In that case, the keys will be used as the names and the values,
which have to be numeric, will be used as the heights of the bars.


Usage
======

    barplot(text, heights; border = :solid, title = "", margin = 3, padding = 1, color = :blue, width = 40, labels = true, symb = "▪")

    barplot(dictionary; nargs...)

Arguments
==========

- **`text`** : The labels/captions of the bars

- **`heights`** : The values/heights of the bars

- **`dictionary`** : A dictonary in which the keys will be used as `text`
and the values will be utilized as `heights`.

- **`border`** : The style of the bounding box of the plot.
Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`title`** : Text to display on the top of the plot.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`color`** : Color of the drawing. Can be any of `:blue`, `:red`, `:yellow`

- **`width`** : Number of characters per row that should be used for plotting.

- **`labels`** : Can be used to hide the labels by setting `labels=false`.

- **`symb`** : Specifies the character that should be used to render the bars

Returns
========

A plot object of type `Plot{BarplotGraphics}`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

Examples
=========

    julia> barplot(["Paris", "New York", "Moskau", "Madrid"],
                   [2.244, 8.406, 11.92, 3.165],
                   title = "Population")

                            Population
             ┌────────────────────────────────────────┐
       Paris │▪▪▪▪▪▪ 2.244                            │
    New York │▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪ 8.406           │
      Moskau │▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪ 11.92 │
      Madrid │▪▪▪▪▪▪▪▪▪ 3.165                         │
             └────────────────────────────────────────┘

See also
=========

`Plot`, `histogram`, `BarplotGraphics`
"""
function barplot{T<:AbstractString,N<:Real}(
        text::Vector{T}, heights::Vector{N};
        border = :solid,
        title::AbstractString = "",
        margin::Int = 3,
        padding::Int = 1,
        color::Symbol = :blue,
        width::Int = 40,
        labels::Bool = true,
        symb = "▪")
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    length(text) == length(heights) || throw(DimensionMismatch("The given vectors must be of the same length"))
    minimum(heights) >= 0 || throw(ArgumentError("All values have to be positive. Negative bars are not supported."))
    width = max(width, 5)

    area = BarplotGraphics(heights, width, color = color, symb = symb)
    new_plot = Plot(area, title = title, margin = margin,
                   padding = padding, border = border, labels = labels)
    for i in 1:length(text)
        annotate!(new_plot, :l, i, text[i])
    end
    new_plot
end


"""
`barplot!(plot, text, heights; nargs)` → `Plot`

Mutating variant of `barplot`, in which the first parameter (`plot`) specifies
the existing plot to draw on.

See `barplot` for more information.
"""
function barplot!{C<:BarplotGraphics,T<:AbstractString,N<:Real}(
        plot::Plot{C},
        text::Vector{T},
        heights::Vector{N};
        args...)
    length(text) == length(heights) || throw(DimensionMismatch("The given vectors must be of the same length"))
    !isempty(text)|| throw(ArgumentError("Can't append empty array to barplot"))
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights)
    for i = 1:length(heights)
        annotate!(plot, :l, curidx + i, text[i])
    end
    plot
end

function barplot!{C<:BarplotGraphics,T<:AbstractString,N<:Real}(
        plot::Plot{C},
        text::T,
        heights::N;
        args...)
    text == "" && throw(ArgumentError("Can't append empty array to barplot"))
    curidx = nrows(plot.graphics)
    addrow!(plot.graphics, heights)
    annotate!(plot, :l, curidx + 1, text)
    plot
end

function barplot{T,N<:Real}(dict::Dict{T,N}; args...)
    barplot(collect(keys(dict)), collect(values(dict)); args...)
end

function barplot{T,N<:Real}(labels::Vector{T}, heights::Vector{N}; args...)
    labels_str = map(string, labels)
    barplot(labels_str, heights; args...)
end
