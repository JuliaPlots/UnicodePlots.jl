"""
    Plot(graphics; nargs...)

Description
============

Decoration for objects that are `GraphicsArea` (or `Canvas`).
It is used to surround the inner `GraphicsArea` object with
additional information such as a title, border, and axis labels.

Usage
======

    Plot(graphics; title = "", xlabel = "", ylabel = "", border = :solid, margin = 3, padding = 1, labels = true)

    Plot(x, y, canvastype; title = "", xlabel = "", ylabel = "", width = 40, height = 15, border = :solid, xlim = (0, 0), ylim = (0, 0), margin = 3, padding = 1, labels = true, grid = true)

Arguments
==========

- **`graphics`** : The `GraphicsArea` (e.g. a subtype of
  `Canvas`) that the plot should decorate.

- **`x`** : The horizontal position for each point.

- **`y`** : The vertical position for each point.

- **`canvastype`** : The type of canvas that should be used for
  drawing.

$DOC_PLOT_PARAMS

- **`height`** : Number of character rows that should be used
  for plotting.

- **`xlim`** : Plotting range for the x axis.
  `[0, 0]` stands for automatic.

- **`ylim`** : Plotting range for the y axis.
  `[0, 0]` stands for automatic.

- **`grid`** : If `true`, draws grid-lines at the origin.

Methods
========

- `title!(plot::Plot, title::String)`

- `xlabel!(plot::Plot, xlabel::String)`

- `ylabel!(plot::Plot, xlabel::String)`

- `zlabel!(plot::Plot, zlabel::String)`

- `annotate!(plot::Plot, where::Symbol, value::String)`

- `annotate!(plot::Plot, where::Symbol, row::Int, value::String)`

Author(s)
==========

- Christof Stocker (Github: https://github.com/Evizero)

see also
=========

[`scatterplot`](@ref), [`lineplot`](@ref),
[`BarplotGraphics`](@ref), [`BrailleCanvas`](@ref),
[`BlockCanvas`](@ref), [`AsciiCanvas`](@ref)
"""
mutable struct Plot{T<:GraphicsArea}
    graphics::T
    title::String
    xlabel::String
    ylabel::String
    zlabel::String
    margin::Int
    padding::Int
    border::Symbol
    labels_left::Dict{Int,String}
    colors_left::Dict{Int,JuliaColorType}
    labels_right::Dict{Int,String}
    colors_right::Dict{Int,JuliaColorType}
    decorations::Dict{Symbol,String}
    colors_deco::Dict{Symbol,JuliaColorType}
    show_labels::Bool
    colormap::Any
    show_colorbar::Bool
    colorbar_border::Symbol
    colorbar_lim::Tuple{Number, Number}
    autocolor::Int
end

function Plot(
        graphics::T;
        title::AbstractString = "",
        xlabel::AbstractString = "",
        ylabel::AbstractString = "",
        zlabel::AbstractString = "",
        border::Symbol = :solid,
        margin::Int = 3,
        padding::Int = 1,
        labels = true,
        colormap = nothing,
        colorbar = false,
        colorbar_border::Symbol = :solid,
        colorbar_lim = (0., 1.)) where T<:GraphicsArea
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    rows = nrows(graphics)
    cols = ncols(graphics)
    labels_left = Dict{Int,String}()
    colors_left = Dict{Int,JuliaColorType}()
    labels_right = Dict{Int,String}()
    colors_right = Dict{Int,JuliaColorType}()
    decorations = Dict{Symbol,String}()
    colors_deco = Dict{Symbol,JuliaColorType}()
    Plot{T}(graphics, title, xlabel, ylabel, zlabel,
            margin, padding, border,
            labels_left, colors_left, labels_right, colors_right,
            decorations, colors_deco, labels, colormap, colorbar, colorbar_border, colorbar_lim, 0)
end

function Plot(
        X::AbstractVector{<:Number},
        Y::AbstractVector{<:Number},
        ::Type{C} = BrailleCanvas;
        title::AbstractString = "",
        xlabel::AbstractString = "",
        ylabel::AbstractString = "",
        zlabel::AbstractString = "",
        width::Int = 40,
        height::Int = 15,
        border::Symbol = :solid,
        xlim = (0.,0.),
        ylim = (0.,0.),
        margin::Int = 3,
        padding::Int = 1,
        labels::Bool = true,
        colormap = nothing,
        colorbar = false,
        colorbar_border::Symbol = :solid,
        colorbar_lim = (0., 1.),
        grid::Bool = true,
        min_width::Int = 5,
        min_height::Int = 2) where {C<:Canvas}
    length(xlim) == length(ylim) == 2 || throw(ArgumentError("xlim and ylim must be tuples or vectors of length 2"))
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    width = max(width, min_width)
    height = max(height, min_height)

    min_x, max_x = extend_limits(X, xlim)
    min_y, max_y = extend_limits(Y, ylim)
    origin_x = min_x
    origin_y = min_y
    p_width = max_x - origin_x
    p_height = max_y - origin_y

    canvas = C(width, height,
               origin_x = origin_x, origin_y = origin_y,
               width = p_width, height = p_height)
    new_plot = Plot(canvas, title = title, margin = margin,
                    padding = padding, border = border, labels = labels,
                    xlabel = xlabel, ylabel = ylabel, zlabel = zlabel,
                    colormap = colormap, colorbar = colorbar, colorbar_border = colorbar_border, colorbar_lim = colorbar_lim)

    min_x_str = compact_repr(roundable(min_x) ? round(Int, min_x, RoundNearestTiesUp) : min_x)
    max_x_str = compact_repr(roundable(max_x) ? round(Int, max_x, RoundNearestTiesUp) : max_x)
    min_y_str = compact_repr(roundable(min_y) ? round(Int, min_y, RoundNearestTiesUp) : min_y)
    max_y_str = compact_repr(roundable(max_y) ? round(Int, max_y, RoundNearestTiesUp) : max_y)
    annotate!(new_plot, :l, nrows(canvas), min_y_str, color = :light_black)
    annotate!(new_plot, :l, 1, max_y_str, color = :light_black)
    annotate!(new_plot, :bl, min_x_str, color = :light_black)
    annotate!(new_plot, :br, max_x_str, color = :light_black)
    if grid
        if min_y < 0 < max_y
            for i in range(min_x, stop=max_x, length=width * x_pixel_per_char(typeof(canvas)))
                points!(new_plot, i, 0., :normal)
            end
        end
        if min_x < 0 < max_x
            for i in range(min_y, stop=max_y, length=height * y_pixel_per_char(typeof(canvas)))
                points!(new_plot, 0., i, :normal)
            end
        end
    end
    new_plot
end

function next_color!(plot::Plot{<:GraphicsArea})
    cur_color = color_cycle[plot.autocolor + 1]
    plot.autocolor = ((plot.autocolor + 1) % length(color_cycle))
    cur_color
end

"""
    title(plot) -> String

Returns the current title of the given plot.
Alternatively, the title can be changed with `title!`.
"""
function title(plot::Plot)
    plot.title
end

"""
    title!(plot, newtitle) -> plot

Sets a new title for the given plot.
Alternatively, the current title can be
queried using `title`.
"""
function title!(plot::Plot, title::AbstractString)
    plot.title = title
    plot
end

"""
    xlabel(plot) -> String

Returns the current label for the x-axis.
Alternatively, the x-label can be changed with `xlabel!`
"""
function xlabel(plot::Plot)
    plot.xlabel
end

"""
    xlabel!(plot, newlabel) -> plot

Sets a new x-label for the given plot.
Alternatively, the current label can be
queried using `xlabel`
"""
function xlabel!(plot::Plot, xlabel::AbstractString)
    plot.xlabel = xlabel
    plot
end

"""
    ylabel(plot) -> String

Returns the current label for the y-axis.
Alternatively, the y-label can be changed with `ylabel!`
"""
function ylabel(plot::Plot)
    plot.ylabel
end

"""
    ylabel!(plot, newlabel) -> plot

Sets a new y-label for the given plot.
Alternatively, the current label can be
queried using `ylabel`
"""
function ylabel!(plot::Plot, ylabel::AbstractString)
    plot.ylabel = ylabel
    plot
end

"""
    zlabel(plot) -> String

Returns the current label for the z-axis (colorbar).
Alternatively, the z-label can be changed with `zlabel!`
"""
function zlabel(plot::Plot)
    plot.zlabel
end

"""
    zlabel!(plot, newlabel) -> plot

Sets a new z-label (colorbar label) for the given plot.
Alternatively, the current label can be
queried using `zlabel`
"""
function zlabel!(plot::Plot, zlabel::AbstractString)
    plot.zlabel = zlabel
    plot
end

"""
    annotate!(plot, where, value, [color])

    annotate!(plot, where, row, value, [color])

This method is responsible for the setting
all the textual decorations of a plot.

Note that `where` can be any of: `:tl` (top-left),
`:t` (top-center), `:tr` (top-right),
`:bl` (bottom-left), `:b` (bottom-center),
`:br` (bottom-right), `:l` (left), `:r` (right).

If `where` is either `:l`, or `:r`, then `row`
can be between 1 and the number of character rows
of the plots canvas.
"""
function annotate!(plot::Plot, loc::Symbol, value::AbstractString, color::UserColorType)
    loc == :t || loc == :b || loc == :l || loc == :r || loc == :tl || loc == :tr || loc == :bl || loc == :br || throw(ArgumentError("Unknown location: try one of these :tl :t :tr :bl :b :br"))
    if loc == :l || loc == :r
        for row = 1:nrows(plot.graphics)
            if loc == :l
                if(!haskey(plot.labels_left, row) || plot.labels_left[row] == "")
                    plot.labels_left[row] = value
                    plot.colors_left[row] = julia_color(color)
                    return plot
                end
            elseif loc == :r
                if(!haskey(plot.labels_right, row) || plot.labels_right[row] == "")
                    plot.labels_right[row] = value
                    plot.colors_right[row] = julia_color(color)
                    return plot
                end
            end
        end
    else
        plot.decorations[loc] = value
        plot.colors_deco[loc] = julia_color(color)
        return plot
    end
    plot
end

function annotate!(plot::Plot, loc::Symbol, value::AbstractString; color::UserColorType=:normal)
    annotate!(plot, loc, value, color)
end

function annotate!(plot::Plot, loc::Symbol, row::Int, value::AbstractString, color::UserColorType)
    if loc == :l
        plot.labels_left[row] = value
        plot.colors_left[row] = julia_color(color)
    elseif loc == :r
        plot.labels_right[row] = value
        plot.colors_right[row] = julia_color(color)
    else
        throw(ArgumentError("Unknown location \"$(string(loc))\", try `:l` or `:r` instead"))
    end
    plot
end

function annotate!(plot::Plot, loc::Symbol, row::Int, value::AbstractString; color::UserColorType=:normal)
    annotate!(plot, loc, row, value, color)
end

function lines!(plot::Plot{<:Canvas}, args...; vars...)
    lines!(plot.graphics, args...; vars...)
    plot
end

function pixel!(plot::Plot{<:Canvas}, args...; vars...)
    pixel!(plot.graphics, args...; vars...)
    plot
end

function points!(plot::Plot{<:Canvas}, args...; vars...)
    points!(plot.graphics, args...; vars...)
    plot
end

function print_title(io::IO, padding::AbstractString, title::AbstractString; p_width::Int = 0, color = :normal)
    if title != ""
        offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
        offset = offset > 0 ? offset : 0
        tpad = repeat(" ", offset)
        print_color(color, io, padding, tpad, title)
    end
end

function print_border_top(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid, color::UserColorType = :light_black)
    b = bordermap[border]
    border == :none || print_color(color, io, padding, b[:tl], repeat(b[:t], length), b[:tr])
end

function print_border_bottom(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid, color::UserColorType = :light_black)
    b = bordermap[border]
    border == :none || print_color(color, io, padding, b[:bl], repeat(b[:b], length), b[:br])
end

_nocolor_string(str) = replace(string(str), r"\e\[[0-9]+m" => "")

function Base.show(io::IO, p::Plot)
    b = UnicodePlots.bordermap[p.border]
    c = p.graphics
    border_length = ncols(c)

    # get length of largest strings to the left and right
    max_len_l = p.show_labels && !isempty(p.labels_left)  ? maximum([length(_nocolor_string(l)) for l in values(p.labels_left)]) : 0
    max_len_r = p.show_labels && !isempty(p.labels_right) ? maximum([length(_nocolor_string(l)) for l in values(p.labels_right)]) : 0
    if p.show_labels && p.ylabel != ""
        max_len_l += length(p.ylabel) + 1
    end

    # offset where the plot (incl border) begins
    plot_offset = max_len_l + p.margin + p.padding

    # padding-string from left to border
    plot_padding = repeat(" ", p.padding)

    # padding-string between labels and border
    border_padding = repeat(" ", plot_offset)

    # plot the title and the top border
    print_title(io, border_padding, p.title, p_width = border_length, color = :bold)
    p.title != "" && println(io)
    if p.show_labels
        topleft_str  = get(p.decorations, :tl, "")
        topleft_col  = get(p.colors_deco, :tl, :light_black)
        topmid_str   = get(p.decorations, :t, "")
        topmid_col   = get(p.colors_deco, :t, :light_black)
        topright_str = get(p.decorations, :tr, "")
        topright_col = get(p.colors_deco, :tr, :light_black)
        if topleft_str != "" || topright_str != "" || topmid_str != ""
            topleft_len  = length(topleft_str)
            topmid_len   = length(topmid_str)
            topright_len = length(topright_str)
            print_color(topleft_col, io, border_padding, topleft_str)
            cnt = round(Int, border_length / 2 - topmid_len / 2 - topleft_len, RoundNearestTiesUp)
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_color(topmid_col, io, pad, topmid_str)
            cnt = border_length - topright_len - topleft_len - topmid_len + 2 - cnt
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_color(topright_col, io, pad, topright_str, "\n")
        end
    end
    print_border_top(io, border_padding, border_length, p.border)
    print(io, repeat(" ", max_len_r), plot_padding, "\n")

    # compute position of ylabel
    y_lab_row = round(nrows(c) / 2, RoundNearestTiesUp)

    # plot all rows
    for row in 1:nrows(c)
        # Current labels to left and right of the row and their length
        left_str  = get(p.labels_left,  row, "")
        left_col  = get(p.colors_left,  row, :light_black)
        right_str = get(p.labels_right, row, "")
        right_col = get(p.colors_right, row, :light_black)
        left_len  = length(_nocolor_string(left_str))
        right_len = length(_nocolor_string(right_str))
        if !get(io, :color, false)
            left_str  = _nocolor_string(left_str)
            right_str = _nocolor_string(right_str)
        end
        # print left annotations
        print(io, repeat(" ", p.margin))
        if p.show_labels
            if row == y_lab_row
                # print ylabel
                print_color(:normal, io, p.ylabel)
                print(io, repeat(" ", max_len_l - length(p.ylabel) - left_len))
            else
                # print padding to fill ylabel length
                print(io, repeat(" ", max_len_l - left_len))
            end
            # print the left annotation
            print_color(left_col, io, left_str)
        end
        # print left border
        print_color(:light_black, io, plot_padding, b[:l])
        # print canvas row
        printrow(io, c, row)
        # print right label and padding
        print_color(:light_black, io, b[:r])
        if p.show_labels
            print(io, plot_padding)
            print_color(right_col, io, right_str)
            print(io, repeat(" ", max_len_r - right_len))
        end
        # print colorbar
        if p.show_colorbar
            print(io, plot_padding)
            printcolorbarrow(io, c, row, p.colormap, p.colorbar_border, p.colorbar_lim, plot_padding, p.zlabel)
        end
        print(io, "\n")
    end

    # draw bottom border and bottom labels
    print_border_bottom(io, border_padding, border_length, p.border)
    print(io, repeat(" ", max_len_r), plot_padding)
    if p.show_labels
        botleft_str  = get(p.decorations, :bl, "")
        botleft_col  = get(p.colors_deco, :bl, :light_black)
        botmid_str   = get(p.decorations, :b, "")
        botmid_col   = get(p.colors_deco, :b, :light_black)
        botright_str = get(p.decorations, :br, "")
        botright_col = get(p.colors_deco, :br, :light_black)
        if botleft_str != "" || botright_str != "" || botmid_str != ""
            println(io)
            botleft_len  = length(botleft_str)
            botmid_len   = length(botmid_str)
            botright_len = length(botright_str)
            print_color(botleft_col, io, border_padding, botleft_str)
            cnt = round(Int, border_length / 2 - botmid_len / 2 - botleft_len, RoundNearestTiesUp)
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_color(botmid_col, io, pad, botmid_str)
            cnt = border_length - botright_len - botleft_len - botmid_len + 2 - cnt
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            print_color(botright_col, io, pad, botright_str)
        end
        # abuse the print_title function to print the xlabel. maybe refactor this
        p.xlabel != "" && println(io)
        print_title(io, border_padding, p.xlabel, p_width = border_length)
    end
end

"""
    savefig(p, filename; color=false)

Print the given plot `p` to a text file.

By default, it does not write ANSI color codes to the file. To enable this, set the keyword `color=true`.

# Examples
```julia-repl
julia> savefig(lineplot([0, 1]), "foo.txt")

```
"""
function savefig(p::Plot, filename::String; color::Bool=false)
    ext = lowercase(splitext(filename)[2])
    if ext in (".png", ".jpg", ".jpeg", ".tif", ".gif", ".svg")
        @warn "`UnicodePlots.savefig` only support writing to text files"
    end
    open(filename, "w") do io
        print(IOContext(io, :color=>color), p)
    end
end
