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
    margin::Int
    padding::Int
    border::Symbol
    labels_left::Dict{Int,String}
    colors_left::Dict{Int,Symbol}
    labels_right::Dict{Int,String}
    colors_right::Dict{Int,Symbol}
    decorations::Dict{Symbol,String}
    colors_deco::Dict{Symbol,Symbol}
    show_labels::Bool
    autocolor::Int
end

function Plot(
        graphics::T;
        title::AbstractString = "",
        xlabel::AbstractString = "",
        ylabel::AbstractString = "",
        border::Symbol = :solid,
        margin::Int = 3,
        padding::Int = 1,
        labels = true) where T<:GraphicsArea
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    rows = nrows(graphics)
    cols = ncols(graphics)
    labels_left = Dict{Int,String}()
    colors_left = Dict{Int,Symbol}()
    labels_right = Dict{Int,String}()
    colors_right = Dict{Int,Symbol}()
    decorations = Dict{Symbol,String}()
    colors_deco = Dict{Symbol,Symbol}()
    Plot{T}(graphics, title, xlabel, ylabel,
            margin, padding, border,
            labels_left, colors_left, labels_right, colors_right,
            decorations, colors_deco, labels, 0)
end

function Plot(
        X::AbstractVector{<:Number},
        Y::AbstractVector{<:Number},
        ::Type{C} = BrailleCanvas;
        title::AbstractString = "",
        xlabel::AbstractString = "",
        ylabel::AbstractString = "",
        width::Int = 40,
        height::Int = 15,
        border::Symbol = :solid,
        xlim = (0.,0.),
        ylim = (0.,0.),
        margin::Int = 3,
        padding::Int = 1,
        labels::Bool = true,
        grid::Bool = true) where {C<:Canvas}
    length(xlim) == length(ylim) == 2 || throw(ArgumentError("xlim and ylim must be tuples or vectors of length 2"))
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    width = max(width, 5)
    height = max(height, 2)

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
                    xlabel = xlabel, ylabel = ylabel)

    min_x_str = string(roundable(min_x) ? round(Int, min_x, RoundNearestTiesUp) : min_x)
    max_x_str = string(roundable(max_x) ? round(Int, max_x, RoundNearestTiesUp) : max_x)
    min_y_str = string(roundable(min_y) ? round(Int, min_y, RoundNearestTiesUp) : min_y)
    max_y_str = string(roundable(max_y) ? round(Int, max_y, RoundNearestTiesUp) : max_y)
    annotate!(new_plot, :l, 1, max_y_str, color = :light_black)
    annotate!(new_plot, :l, height, min_y_str, color = :light_black)
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
function annotate!(plot::Plot, loc::Symbol, value::AbstractString, color::Symbol)
    loc == :t || loc == :b || loc == :l || loc == :r || loc == :tl || loc == :tr || loc == :bl || loc == :br || throw(ArgumentError("Unknown location: try one of these :tl :t :tr :bl :b :br"))
    if loc == :l || loc == :r
        for row = 1:nrows(plot.graphics)
            if loc == :l
                if(!haskey(plot.labels_left, row) || plot.labels_left[row] == "")
                    plot.labels_left[row] = value
                    plot.colors_left[row] = color
                    return plot
                end
            elseif loc == :r
                if(!haskey(plot.labels_right, row) || plot.labels_right[row] == "")
                    plot.labels_right[row] = value
                    plot.colors_right[row] = color
                    return plot
                end
            end
        end
    else
        plot.decorations[loc] = value
        plot.colors_deco[loc] = color
        return plot
    end
    plot
end

function annotate!(plot::Plot, loc::Symbol, value::AbstractString; color::Symbol=:normal)
    annotate!(plot, loc, value, color)
end

function annotate!(plot::Plot, loc::Symbol, row::Int, value::AbstractString, color::Symbol)
    if loc == :l
        plot.labels_left[row] = value
        plot.colors_left[row] = color
    elseif loc == :r
        plot.labels_right[row] = value
        plot.colors_right[row] = color
    else
        throw(ArgumentError("Unknown location \"$(string(loc))\", try `:l` or `:r` instead"))
    end
    plot
end

function annotate!(plot::Plot, loc::Symbol, row::Int, value::AbstractString; color::Symbol=:normal)
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
        printstyled(io, padding, tpad, title; color = color)
    end
end

function print_border_top(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid, color::Symbol = :light_black)
    b = bordermap[border]
    border == :none || printstyled(io, padding, b[:tl], repeat(b[:t], length), b[:tr]; color = color)
end

function print_border_bottom(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid, color::Symbol = :light_black)
    b = bordermap[border]
    border == :none || printstyled(io, padding, b[:bl], repeat(b[:b], length), b[:br]; color = color)
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
            printstyled(io, border_padding, topleft_str; color = topleft_col)
            cnt = round(Int, border_length / 2 - topmid_len / 2 - topleft_len, RoundNearestTiesUp)
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            printstyled(io, pad, topmid_str; color = topmid_col)
            cnt = border_length - topright_len - topleft_len - topmid_len + 2 - cnt
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            printstyled(io, pad, topright_str, "\n"; color = topright_col)
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
                printstyled(io, p.ylabel; color = :normal)
                print(io, repeat(" ", max_len_l - length(p.ylabel) - left_len))
            else
                # print padding to fill ylabel length
                print(io, repeat(" ", max_len_l - left_len))
            end
            # print the left annotation
            printstyled(io, left_str; color = left_col)
        end
        # print left border
        printstyled(io, plot_padding, b[:l]; color = :light_black)
        # print canvas row
        printrow(io, c, row)
        #print right label and padding
        printstyled(io, b[:r]; color = :light_black)
        if p.show_labels
            print(io, plot_padding)
            printstyled(io, right_str; color = right_col)
            print(io, repeat(" ", max_len_r - right_len))
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
            printstyled(io, border_padding, botleft_str; color = botleft_col)
            cnt = round(Int, border_length / 2 - botmid_len / 2 - botleft_len, RoundNearestTiesUp)
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            printstyled(io, pad, botmid_str; color = botmid_col)
            cnt = border_length - botright_len - botleft_len - botmid_len + 2 - cnt
            pad = cnt > 0 ? repeat(" ", cnt) : ""
            printstyled(io, pad, botright_str; color = botright_col)
        end
        # abuse the print_title function to print the xlabel. maybe refactor this
        p.xlabel != "" && println(io)
        print_title(io, border_padding, p.xlabel, p_width = border_length)
    end
end
