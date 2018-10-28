"""
`boxplot(data; nargs...)` → `Plot`

Description
============

Draws a box-and-whisker plot.
The first argument specifies the one dimensional vector of data to plot.
Alternatively, one can specify a boxplot using a dictionary.
In that case, the values, which have to be numeric, will be used as the data.


Usage
======

    boxplot(data; border = :solid, title = "", margin = 3, padding = 1, color = :blue, width = 40)

    boxplot(dictionary; nargs...)

Arguments
==========

- **`data`** : The 1-D vector of data the box plot is based on

- **`dictionary`** : A dictonary in which the keys will be used as `text`
and the values will be utilized as `heights`.

- **`border`** : The style of the bounding box of the plot.
Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`title`** : Text to display on the top of the plot.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space to the left and right of the plot.

- **`color`** : Colour of the drawing. Can be any of `:black`, `:blue`, `:cyan`,
`:green`, `:magenta`, `:red`, `:yellow`, `:white`, or a light version of the above (`:light_colour`).
By default no colouring is applied.

- **`width`** : Number of characters per row that should be used for plotting.

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
        data::AbstractVector{<:Number};
        border = :solid,
        title::AbstractString = "",
        margin::Int = 4,
        padding::Int = 0,
        color::Symbol = :normal,
        width::Int = 40,
        left::Number = min(data...) - 1,
        right::Number = max(data...) + 1)
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    width = max(width, 10)

    if left > min(data...) || right < max(data...)
        throw(ArgumentError("Plot range ($left, $right) too restrictive for data range ($(min(data...)), $(max(data...)))"))
    end

    area = BoxplotGraphics(data, width, color = color, left = left, right = right)
    new_plot = Plot(area, title = title, margin = margin,
                   padding = padding, border = border)

    annotate!(new_plot, :bl, string(left))
    annotate!(new_plot, :b, string((left + right) / 2))
    annotate!(new_plot, :br, string(right))
    new_plot
end

function boxplot(dict::Dict{T,N}; kw...) where {T, N <: Number}
    boxplot(collect(values(dict)); kw...)
end
