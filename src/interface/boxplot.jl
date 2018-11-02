"""
`boxplot(data; nargs...)` → `Plot`

Description
============

Draws a box-and-whisker plot.
The first argument specifies the data to plot. This is a vector of vectors, with each
inner vector representing a data series. We use a vector of vectors over a matrix
to allow series of different lengths.
Optionally, a list of labels may be provided, with length equal to the number of series.
Alternatively, one can specify a boxplot using a dictionary.
In that case, the values, which have to be numeric, will be used as the data series,
and the keys, which have to be strings, will be used as the labels.


Usage
======

    boxplot(data; labels = [" " for _ in 1:size(data, 1)], border = :solid, title = "",
            margin = 3, padding = 1, color = :blue, width = 40,
            left=minimum(map(minimum, data)) - 1, right=maximum(map(maximum, data)) + 1)

    boxplot(dictionary; nargs...)

Arguments
==========

- **`data`** : The data the box plot is based on. A vector of vectors, with each
  inner vector representing a data series. Choose a vector of vectors over a matrix
  to allow series of different lengths.

- **`labels`** : A list of labels for the data series. Must be the same length as the number of series.

- **`dictionary`** : A dictonary in which the keys will be used as `labels`
  and the values will be utilized as `data`.

- **`border`** : The style of the bounding box of the plot.
  Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`title`** : Text to display on the top of the plot.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`color`** : Colour of the drawing. Can be any of `:black`, `:blue`, `:cyan`,
  `:green`, `:magenta`, `:red`, `:yellow`, `:white`, or a light version of the above (`:light_colour`).
  By default no colouring is applied.

- **`width`** : Number of characters per row that should be used for plotting.

- **`left`** : The value of the left-hand edge of the plot.

- **`right`** : The value of the right-hand edge of the plot.

Returns
========

A plot object of type `Plot{BoxplotGraphics}`

Author(s)
==========

- Matthew Lake (Github: https://github.com/mgtlake)

Examples
=========

    julia> boxplot([1, 2, 3, 7], title = "Test")

                       Test
     ┌────────────────────────────────────────┐
     │    │   ┌──┬───────┐              │     │
     │    ├───┤  │       ├──────────────┤     │
     │    │   └──┴───────┘              │     │
     └────────────────────────────────────────┘
     0                  4.0                   8

See also
=========

`Plot`, `histogram`, `BoxplotGraphics`
"""
function boxplot(
        data::AbstractVector;
        labels::AbstractVector{<:AbstractString} = [" " for _ in 1:size(data, 1)],
        border = :solid,
        title::AbstractString = "",
        margin::Int = 3,
        padding::Int = 1,
        color::Symbol = :normal,
        width::Int = 40,
        left::Number = minimum(map(minimum, data)) - 1,
        right::Number = maximum(map(maximum, data)) + 1)
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    length(labels) == length(data) || throw(DimensionMismatch("Wrong number of labels"))

    width = max(width, 10)

    if left > minimum(map(minimum, data)) || right < maximum(map(maximum, data))
        throw(ArgumentError("Plot range ($left, $right) too restrictive for data range ($(min(data...)), $(max(data...)))"))
    end

    area = BoxplotGraphics(data[1], width, color = color,
                           left = left, right = right, labels = labels)
    for i in 2:length(data)
        addseries!(area, data[i])
    end

    new_plot = Plot(area, title = title, margin = margin,
                   padding = padding, border = border)

    annotate!(new_plot, :bl, string(left))
    annotate!(new_plot, :b, string((left + right) / 2))
    annotate!(new_plot, :br, string(right))

    for (i, label) in enumerate(labels)
        # Find end of last 3-line region, then add 2 for centre of current
        annotate!(new_plot, :l, (i-1)*3+2, label)
    end

    new_plot
end

"""
`boxplot!(plot, data; nargs)` → `Plot`

Mutating variant of `boxplot`, in which the first parameter (`plot`) specifies
the existing plot to draw on.

See `boxplot` for more information.
"""
function boxplot!(
        plot::Plot{<:BoxplotGraphics},
        data::AbstractVector{<:Number};
        label = " ",
        kw...)
    !isempty(data)|| throw(ArgumentError("Can't append empty array to boxplot"))

    if plot.graphics.left > minimum(data)
        plot.graphics.left = minimum(data) - 1
    end
    if plot.graphics.right < maximum(data)
        plot.graphics.right = maximum(data) + 1
    end

    addseries!(plot.graphics, data)

    # Find end of last 3-line region, then add 2 for centre of current
    annotate!(plot, :l, (length(plot.graphics.data)-1)*3+2, label)

    annotate!(plot, :bl, string(plot.graphics.left))
    annotate!(plot, :b, string((plot.graphics.left + plot.graphics.right) / 2))
    annotate!(plot, :br, string(plot.graphics.right))

    plot
end

function boxplot(data::AbstractVector{<:Number}; kw...) where {T, N <: Number}
    boxplot([data]; kw...)
end

function boxplot(dict::Dict; kw...) where {T, N <: Number}
    boxplot(collect(values(dict)); labels=collect(keys(dict)), kw...)
end
