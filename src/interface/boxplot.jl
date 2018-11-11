"""
`boxplot(data; nargs...)` → `Plot`

Description
============

Draws a box-and-whisker plot.
The first argument specifies the data to plot. This is a vector of vectors, with each
inner vector representing a data series. We use a vector of vectors over a matrix
to allow series of different lengths.
Optionally, a list of text may be provided, with length equal to the number of series.
Alternatively, one can specify a boxplot using a dictionary.
In that case, the values, which have to be numeric, will be used as the data series,
and the keys, which have to be strings, will be used as the labels.


Usage
======

    boxplot(data; labels = [" " for _ in 1:size(data, 1)], border = :solid, title = "",
            margin = 3, padding = 1, color = :green, width = 40,
            min_x=minimum(map(minimum, data)) - 1, max_x=maximum(map(maximum, data)) + 1)

    boxplot(dictionary; nargs...)

Arguments
==========

- **`data`** : The data the box plot is based on. A vector of vectors, with each
  inner vector representing a data series. Choose a vector of vectors over a matrix
  to allow series of different lengths.

- **`name`** : A list of labels for the data series. Must be the same length as the number of series.

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

- **`min_x`** : The value of the left-hand edge of the plot.

- **`max_x`** : The value of the right-hand edge of the plot.

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
        text::AbstractVector{<:AbstractString},
        data::AbstractVector{<:AbstractArray{<:Number}};
        border = :solid,
        title::AbstractString = "",
        margin::Int = 3,
        padding::Int = 1,
        color::Symbol = :green,
        width::Int = 40,
        labels::Bool = true,
        xlim::AbstractVector = [minimum(map(minimum, data)), maximum(map(maximum, data))])
    length(xlim) == 2 || throw(ArgumentError("xlim must only be vectors of length 2"))
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    length(text) == length(data) || throw(DimensionMismatch("Wrong number of text"))
    min_x, max_x = xlim
    width = max(width, 10)

    area = BoxplotGraphics(data[1], width, color = color,
                           min_x = min_x, max_x = max_x)
    for i in 2:length(data)
        addseries!(area, data[i])
    end

    new_plot = Plot(area, title = title, margin = margin,
                    labels = labels, padding = padding, border = border)

    mean_x = (min_x + max_x) / 2
    min_x_str = string(roundable(min_x) ? round(Int, Float64(min_x), RoundNearestTiesUp) : min_x)
    mean_x_str = string(roundable(mean_x) ? round(Int, Float64(mean_x), RoundNearestTiesUp) : mean_x)
    max_x_str = string(roundable(max_x) ? round(Int, Float64(max_x), RoundNearestTiesUp) : max_x)
    annotate!(new_plot, :bl, min_x_str, color = :light_black)
    annotate!(new_plot, :b,  mean_x_str, color = :light_black)
    annotate!(new_plot, :br, max_x_str, color = :light_black)

    for (i, name) in enumerate(text)
        # Find end of last 3-line region, then add 2 for centre of current
        length(name) > 0 && annotate!(new_plot, :l, (i-1)*3+2, name)
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
        name = " ",
        kw...)
    !isempty(data)|| throw(ArgumentError("Can't append empty array to boxplot"))

    plot.graphics.min_x = min(plot.graphics.min_x, minimum(data))
    plot.graphics.max_x = min(plot.graphics.max_x, maximum(data))

    addseries!(plot.graphics, data)

    # Find end of last 3-line region, then add 2 for centre of current
    annotate!(plot, :l, (length(plot.graphics.data)-1)*3+2, name)

    min_x = plot.graphics.min_x
    max_x = plot.graphics.max_x
    mean_x = (min_x + max_x) / 2
    min_x_str = string(roundable(min_x) ? round(Int, Float64(min_x), RoundNearestTiesUp) : min_x)
    mean_x_str = string(roundable(mean_x) ? round(Int, Float64(mean_x), RoundNearestTiesUp) : mean_x)
    max_x_str = string(roundable(max_x) ? round(Int, Float64(max_x), RoundNearestTiesUp) : max_x)
    annotate!(plot, :bl, min_x_str)
    annotate!(plot, :b,  mean_x_str)
    annotate!(plot, :br, max_x_str)

    plot
end

function boxplot(data::AbstractVector{<:AbstractArray{<:Number}}; kw...)
    boxplot(fill("", length(data)), data; kw...)
end

function boxplot(data::AbstractVector{<:Number}; kw...)
    boxplot("", data; kw...)
end

function boxplot(text::AbstractString, data::AbstractVector{<:Number}; kw...)
    boxplot([text], [data]; kw...)
end

function boxplot(dict::Dict; kw...)
    boxplot(collect(keys(dict)), collect(values(dict)); kw...)
end
