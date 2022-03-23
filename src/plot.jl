"""
    Plot(graphics; kw...)

# Description

Decoration for objects that are `GraphicsArea` (or `Canvas`).
It is used to surround the inner `GraphicsArea` object with
additional information such as a title, border, and axis labels.

# Usage

    Plot(graphics; $(keywords(; default = (), add = (:title, :xlabel, :ylabel, :zlabel, :border, :margin, :padding, :compact, :labels))))

    Plot(x, y, z, canvas; $(keywords()))

# Arguments

$(arguments(
    (; graphics = "the `GraphicsArea` (e.g. a subtype of `Canvas`) that the plot should decorate");
    add = (:x, :y, :z, :canvas)
))

# Methods

- `title!(plot::Plot, title::String)`

- `xlabel!(plot::Plot, xlabel::String)`

- `ylabel!(plot::Plot, xlabel::String)`

- `zlabel!(plot::Plot, zlabel::String)`

- `label!(plot::Plot, where::Symbol, value::String)`

- `label!(plot::Plot, where::Symbol, row::Int, value::String)`

Author(s)

- Christof Stocker (github.com/Evizero)

# See also

[`scatterplot`](@ref), [`lineplot`](@ref),
[`BarplotGraphics`](@ref), [`BrailleCanvas`](@ref),
[`BlockCanvas`](@ref), [`AsciiCanvas`](@ref)
"""
mutable struct Plot{T<:GraphicsArea,E,F}
    graphics::T
    title::String
    xlabel::String
    ylabel::String
    zlabel::String
    margin::Int
    padding::Int
    border::Symbol
    compact::Bool
    labels_left::Dict{Int,String}
    colors_left::Dict{Int,ColorType}
    labels_right::Dict{Int,String}
    colors_right::Dict{Int,ColorType}
    decorations::Dict{Symbol,String}
    colors_deco::Dict{Symbol,ColorType}
    labels::Bool
    colormap::Any
    colorbar::Bool
    colorbar_border::Symbol
    colorbar_lim::Tuple{Number,Number}
    autocolor::Int
    projection::MVP{E,F}
end

function Plot(
    graphics::T;
    title::AbstractString = KEYWORDS.title,
    xlabel::AbstractString = KEYWORDS.xlabel,
    ylabel::AbstractString = KEYWORDS.ylabel,
    zlabel::AbstractString = KEYWORDS.zlabel,
    border::Symbol = KEYWORDS.border,
    compact::Bool = KEYWORDS.compact,
    margin::Int = KEYWORDS.margin,
    padding::Int = KEYWORDS.padding,
    labels::Bool = KEYWORDS.labels,
    colorbar::Bool = KEYWORDS.colorbar,
    colorbar_border::Symbol = KEYWORDS.colorbar_border,
    colorbar_lim = KEYWORDS.colorbar_lim,
    colormap::Any = nothing,
    projection::MVP{E,F} = MVP(),
    ignored...,
) where {T<:GraphicsArea,E,F}
    margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
    rows = nrows(graphics)
    cols = ncols(graphics)
    labels_left = Dict{Int,String}()
    colors_left = Dict{Int,ColorType}()
    labels_right = Dict{Int,String}()
    colors_right = Dict{Int,ColorType}()
    decorations = Dict{Symbol,String}()
    colors_deco = Dict{Symbol,ColorType}()
    p = Plot{T,E,F}(
        graphics,
        title,
        xlabel,
        ylabel,
        zlabel,
        margin,
        padding,
        border,
        compact,
        labels_left,
        colors_left,
        labels_right,
        colors_right,
        decorations,
        colors_deco,
        labels && graphics.visible,
        colormap,
        colorbar,
        colorbar_border,
        colorbar_lim,
        0,
        projection,
    )
    if compact
        xlabel != "" && label!(p, :b, xlabel)
        ylabel != "" && label!(p, :l, round(Int, nrows(graphics) / 2), ylabel)
    end
    p
end

"""
    validate_input(x, y, z = nothing)

# Description

Check for invalid input (length) and selects only finite input data.
"""
function validate_input(
    x::AbstractVector{<:Number},
    y::AbstractVector{<:Number},
    z::AbstractVector{<:Number},
)
    length(x) == length(y) == length(z) ||
        throw(DimensionMismatch("x, y and z must have same length"))
    idx = BitVector(map(x, y, z) do i, j, k
        isfinite(i) && isfinite(j) && isfinite(k)
    end)
    x[idx], y[idx], z[idx]
end

function validate_input(
    x::AbstractVector{<:Number},
    y::AbstractVector{<:Number},
    z::Nothing,
)
    length(x) == length(y) || throw(DimensionMismatch("x and y must have same length"))
    idx = BitVector(map(x, y) do i, j
        isfinite(i) && isfinite(j)
    end)
    x[idx], y[idx], z
end

function Plot(
    x::AbstractVector{<:Number},
    y::AbstractVector{<:Number},
    z::Union{AbstractVector{<:Number},Nothing} = nothing,
    ::Type{C} = BrailleCanvas;
    title::AbstractString = KEYWORDS.title,
    xlabel::AbstractString = KEYWORDS.xlabel,
    ylabel::AbstractString = KEYWORDS.ylabel,
    zlabel::AbstractString = KEYWORDS.zlabel,
    xscale::Union{Symbol,Function} = KEYWORDS.xscale,
    yscale::Union{Symbol,Function} = KEYWORDS.yscale,
    width::Union{Int,Nothing} = nothing,
    height::Union{Int,Nothing} = nothing,
    border::Symbol = KEYWORDS.border,
    compact::Bool = KEYWORDS.compact,
    blend::Bool = KEYWORDS.blend,
    xlim = KEYWORDS.xlim,
    ylim = KEYWORDS.ylim,
    margin::Int = KEYWORDS.margin,
    padding::Int = KEYWORDS.padding,
    labels::Bool = KEYWORDS.labels,
    unicode_exponent::Bool = KEYWORDS.unicode_exponent,
    colorbar::Bool = KEYWORDS.colorbar,
    colorbar_border::Symbol = KEYWORDS.colorbar_border,
    colorbar_lim = KEYWORDS.colorbar_lim,
    colormap::Any = nothing,
    grid::Bool = KEYWORDS.grid,
    xticks::Bool = KEYWORDS.xticks,
    yticks::Bool = KEYWORDS.yticks,
    min_width::Int = 5,
    min_height::Int = 2,
    projection::Union{Nothing,Symbol,MVP} = nothing,
    axes3d = KEYWORDS.axes3d,
    kw...,
) where {C<:Canvas}
    length(xlim) == length(ylim) == 2 ||
        throw(ArgumentError("xlim and ylim must be tuples or vectors of length 2"))

    width === nothing && (width = DEFAULT_WIDTH[])
    height === nothing && (height = DEFAULT_HEIGHT[])

    (visible = width > 0) && (width = max(width, min_width))
    height = max(height, min_height)

    x, y, z = validate_input(x, y, z)

    base_x = xscale isa Symbol ? get(BASES, xscale, nothing) : nothing
    base_y = yscale isa Symbol ? get(BASES, yscale, nothing) : nothing

    xscale = scale_callback(xscale)
    yscale = scale_callback(yscale)

    if projection !== nothing  # 3D
        (xscale !== identity || yscale !== identity) &&
            throw(ArgumentError("xscale or yscale are unsupported in 3D"))

        projection isa Symbol && (projection = MVP(x, y, z; kw...))

        # normalized coordinates, but allow override (artifact for zooming):
        # using `xlim = (-0.5, 0.5)` & `ylim = (-0.5, 0.5)`
        # should be close to using `zoom = 2`
        mx, Mx = if xlim == (0, 0)
            -1.0, 1.0
        else
            as_float(xlim)
        end
        my, My = if ylim == (0, 0)
            -1.0, 1.0
        else
            as_float(ylim)
        end

        grid = blend = false
    else  # 2D
        projection = MVP()
        mx, Mx = extend_limits(x, xlim, xscale)
        my, My = extend_limits(y, ylim, yscale)
    end

    p_width = Mx - mx
    p_height = My - my

    canvas = C(
        width,
        height,
        blend = blend,
        visible = visible,
        origin_x = mx,
        origin_y = my,
        width = p_width,
        height = p_height,
        xscale = xscale,
        yscale = yscale,
    )
    plot = Plot(
        canvas,
        title = title,
        margin = margin,
        padding = padding,
        border = border,
        compact = compact,
        labels = labels,
        xlabel = xlabel,
        ylabel = ylabel,
        zlabel = zlabel,
        colormap = colormap,
        colorbar = colorbar,
        colorbar_border = colorbar_border,
        colorbar_lim = colorbar_lim,
        projection = projection,
    )
    if xticks || yticks
        m_x, M_x, m_y, M_y = map(
            v -> compact_repr(roundable(v) ? round(Int, v, RoundNearestTiesUp) : v),
            (mx, Mx, my, My),
        )
        if unicode_exponent
            m_x, M_x = map(v -> base_x !== nothing ? superscript(v) : v, (m_x, M_x))
            m_y, M_y = map(v -> base_y !== nothing ? superscript(v) : v, (m_y, M_y))
        end
        if xticks
            base_x_str = base_x === nothing ? "" : base_x * (unicode_exponent ? "" : "^")
            label!(plot, :bl, base_x_str * m_x, color = BORDER_COLOR[])
            label!(plot, :br, base_x_str * M_x, color = BORDER_COLOR[])
        end
        if yticks
            base_y_str = base_y === nothing ? "" : base_y * (unicode_exponent ? "" : "^")
            label!(plot, :l, nrows(canvas), base_y_str * m_y, color = BORDER_COLOR[])
            label!(plot, :l, 1, base_y_str * M_y, color = BORDER_COLOR[])
        end
    end
    if grid
        if my < 0 < My
            for i in range(mx, stop = Mx, length = width * x_pixel_per_char(C))
                points!(plot, i, 0.0, nothing)
            end
        end
        if mx < 0 < Mx
            for i in range(my, stop = My, length = height * y_pixel_per_char(C))
                points!(plot, 0.0, i, nothing)
            end
        end
    end

    (is_enabled(projection) && axes3d) && draw_axes!(plot, 0.8 .* [mx, my])

    plot
end

function next_color!(plot::Plot{<:GraphicsArea})
    cur_color = COLOR_CYCLE[][plot.autocolor + 1]
    plot.autocolor = ((plot.autocolor + 1) % length(COLOR_CYCLE[]))
    cur_color
end

"""
    title(plot) -> String

Returns the current title of the given plot.
Alternatively, the title can be changed with `title!`.
"""
title(plot::Plot) = plot.title

"""
    title!(plot, newtitle)

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
xlabel(plot::Plot) = plot.xlabel

"""
    xlabel!(plot, newlabel)

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
ylabel(plot::Plot) = plot.ylabel

"""
    ylabel!(plot, newlabel)

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
zlabel(plot::Plot) = plot.zlabel

"""
    zlabel!(plot, newlabel)

Sets a new z-label (colorbar label) for the given plot.
Alternatively, the current label can be
queried using `zlabel`
"""
function zlabel!(plot::Plot, zlabel::AbstractString)
    plot.zlabel = zlabel
    plot
end

"""
    label!(plot, where, value, [color])

    label!(plot, where, row, value, [color])

This method is responsible for the setting all the textual decorations of a plot.

Note that `where` can be any of: `:tl` (top-left),
`:t` (top-center), `:tr` (top-right),
`:bl` (bottom-left), `:b` (bottom-center),
`:br` (bottom-right), `:l` (left), `:r` (right).

If `where` is either `:l`, or `:r`, then `row` can be between 1
and the number of character rows of the plots canvas.
"""
function label!(plot::Plot, loc::Symbol, value::AbstractString, color::UserColorType)
    loc ∉ (:t, :b, :l, :r, :tl, :tr, :bl, :br) &&
        throw(ArgumentError("Unknown location: try one of these :tl :t :tr :bl :b :br"))
    if loc == :l || loc == :r
        for row in 1:nrows(plot.graphics)
            if loc == :l
                if !haskey(plot.labels_left, row) || plot.labels_left[row] == ""
                    plot.labels_left[row] = value
                    plot.colors_left[row] = ansi_color(color)
                    break
                end
            elseif loc == :r
                if !haskey(plot.labels_right, row) || plot.labels_right[row] == ""
                    plot.labels_right[row] = value
                    plot.colors_right[row] = ansi_color(color)
                    break
                end
            end
        end
    else
        plot.decorations[loc] = value
        plot.colors_deco[loc] = ansi_color(color)
    end
    plot
end

function annotate!(plot::Plot, loc::Symbol, value::AbstractString, color::UserColorType)
    Base.depwarn("`annotate!` has been renamed to `label!`", :Plot)
    label!(plot, loc, value, color)
end

label!(plot::Plot, loc::Symbol, value::AbstractString; color::UserColorType = :normal) =
    label!(plot, loc, value, color)

function annotate!(
    plot::Plot,
    loc::Symbol,
    value::AbstractString;
    color::UserColorType = :normal,
)
    Base.depwarn("`annotate!` has been renamed to `label!`", :Plot)
    label!(plot, loc, value, color)
end

function label!(
    plot::Plot,
    loc::Symbol,
    row::Int,
    value::AbstractString,
    color::UserColorType,
)
    if loc == :l
        plot.labels_left[row] = value
        plot.colors_left[row] = ansi_color(color)
    elseif loc == :r
        plot.labels_right[row] = value
        plot.colors_right[row] = ansi_color(color)
    else
        throw(ArgumentError("Unknown location \"$loc\", try `:l` or `:r` instead"))
    end
    plot
end

function annotate!(
    plot::Plot,
    loc::Symbol,
    row::Int,
    value::AbstractString,
    color::UserColorType,
)
    Base.depwarn("`annotate!` has been renamed to `label!`", :Plot)
    label!(plot, loc, row, value, color)
end

label!(
    plot::Plot,
    loc::Symbol,
    row::Int,
    value::AbstractString;
    color::UserColorType = :normal,
) = label!(plot, loc, row, value, color)

function annotate!(
    plot::Plot,
    loc::Symbol,
    row::Int,
    value::AbstractString;
    color::UserColorType = :normal,
)
    Base.depwarn("`annotate!` has been renamed to `label!`", :Plot)
    label!(plot, loc, row, value, color)
end

"""
    annotate!(plot, x, y, text; kw...)

# Description

Adds text to the plot at the position `(x, y)`.

# Arguments

$(arguments((; text = "a string of text"); default = (), add = (:x, :y, :color)))

# Examples

```julia-repl
julia> plt = lineplot([1, 2, 7], [9, -6, 8], title = "My Lineplot");

julia> annotate!(plt, 5, 5, "My text")
       ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀My Lineplot⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
       ┌────────────────────────────────────────┐ 
    10 │⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠│ 
       │⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊⠁⠀│ 
       │⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀My text⠀⠀⣀⠔⠊⠁⠀⠀⠀⠀│ 
       │⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠤⠤⠤⠼⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢤⠤⠶⠥⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤│ 
       │⠀⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠤⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⠀⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⣀⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⠀⠀⠀⢱⠀⠀⠀⠀⡠⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⠀⠀⠀⠀⢇⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
   -10 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│ 
       └────────────────────────────────────────┘ 
       ⠀1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀7⠀
```

# See also

[`Plot`](@ref), [`lineplot`](@ref), [`scatterplot`](@ref),
[`stairs`](@ref), [`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function annotate!(
    plot::Plot{<:Canvas},
    x::Number,
    y::Number,
    text::Union{Char,AbstractString};
    color = :normal,
    kw...,
)
    color = color == :auto ? next_color!(plot) : color
    annotate!(plot.graphics, x, y, text, color; kw...)
    plot
end

transform(tr, args...) = args  # catch all
transform(tr::MVP{Val{false}}, x, y, c::UserColorType) = (x, y, c)
transform(tr::MVP{Val{false}}, x, y, z::Nothing, c::UserColorType) = (x, y, c)  # drop z
transform(tr::MVP{Val{true}}, x, y, z::Union{AbstractVector,Number}, args...) =
    (tr(vcat(x', y', z', ones(1, length(x))))..., args...)

function lines!(plot::Plot{<:Canvas}, args...; kw...)
    lines!(plot.graphics, transform(plot.projection, args...)...; kw...)
    plot
end

function pixel!(plot::Plot{<:Canvas}, args...; kw...)
    pixel!(plot.graphics, transform(plot.projection, args...)...; kw...)
    plot
end

function points!(plot::Plot{<:Canvas}, args...; kw...)
    points!(plot.graphics, transform(plot.projection, args...)...; kw...)
    plot
end

function print_title(
    io::IO,
    print_nc,
    print_col,
    left_pad::AbstractString,
    title::AbstractString,
    right_pad::AbstractString,
    blank::Char;
    p_width::Int = 0,
    color::UserColorType = :normal,
)
    title == "" && return (0, 0)
    offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
    pre_pad = repeat(blank, offset > 0 ? offset : 0)
    print_nc(io, left_pad, pre_pad)
    print_col(io, color, title)
    post_pad = repeat(blank, max(0, p_width - length(pre_pad) - length(title)))
    print_nc(io, post_pad, right_pad)
    (
        count("\n", title) + 1,
        length(strip(left_pad * pre_pad * title * post_pad * right_pad, '\n')),
    )
end

function print_border(
    io::IO,
    print_nc,
    print_col,
    loc::Symbol,
    length::Int,
    left_pad::Union{Char,AbstractString},
    right_pad::Union{Char,AbstractString},
    bmap = BORDERMAP[:solid],
    color::UserColorType = BORDER_COLOR[],
)
    print_nc(io, left_pad)
    print_col(
        io,
        color,
        bmap[Symbol(loc, :l)],
        repeat(bmap[loc], length),
        bmap[Symbol(loc, :r)],
    )
    print_nc(io, right_pad)
    nothing
end

function print_labels(
    io::IO,
    print_nc,
    print_col,
    mloc::Symbol,
    p::Plot,
    border_length,
    left_pad::AbstractString,
    right_pad::AbstractString,
    blank::Char,
)
    p.labels || return
    bc        = BORDER_COLOR[]
    lloc      = Symbol(mloc, :l)
    rloc      = Symbol(mloc, :r)
    left_str  = get(p.decorations, lloc, "")
    left_col  = get(p.colors_deco, lloc, bc)
    mid_str   = get(p.decorations, mloc, "")
    mid_col   = get(p.colors_deco, mloc, bc)
    right_str = get(p.decorations, rloc, "")
    right_col = get(p.colors_deco, rloc, bc)
    if left_str != "" || right_str != "" || mid_str != ""
        left_len  = length(left_str)
        mid_len   = length(mid_str)
        right_len = length(right_str)
        print_nc(io, left_pad)
        print_col(io, left_col, left_str)
        cnt = round(Int, border_length / 2 - mid_len / 2 - left_len, RoundNearestTiesAway)
        pad = cnt > 0 ? repeat(blank, cnt) : ""
        print_nc(io, pad)
        print_col(io, mid_col, mid_str)
        cnt = border_length - right_len - left_len - mid_len + 2 - cnt
        pad = cnt > 0 ? repeat(blank, cnt) : ""
        print_nc(io, pad)
        print_col(io, right_col, right_str)
        print_nc(io, right_pad)
    end
    nothing
end

Base.show(io::IO, p::Plot) = _show(io, print, print_color, p)

function _show(io::IO, print_nc, print_col, p::Plot)
    c = p.graphics
    🗷 = Char(BLANK)  # blank outside canvas
    🗹 = Char(c isa BrailleCanvas ? BLANK_BRAILLE : 🗷)  # blank inside canvas
    ############################################################
    # 🗷 = 'x'  # debug
    # 🗹 = Char(typeof(c) <: BrailleCanvas ? '⠿' : 'o')  # debug
    ############################################################
    nr = nrows(c)
    nc = ncols(c)
    p_width = nc + 2  # left corner + border length (number of canvas cols) + right corner

    bmap = BORDERMAP[p.border === :none && c isa BrailleCanvas ? :bnone : p.border]

    # get length of largest strings to the left and right
    max_len_l = if p.labels && !isempty(p.labels_left)
        maximum([length(nocolor_string(l)) for l in values(p.labels_left)])
    else
        0
    end
    max_len_r = if p.labels && !isempty(p.labels_right)
        maximum([length(nocolor_string(l)) for l in values(p.labels_right)])
    else
        0
    end
    if !p.compact && p.labels && p.ylabel != ""
        max_len_l += length(p.ylabel) + 1
    end

    # offset where the plot (incl border) begins
    plot_offset = max_len_l + p.margin + p.padding

    # padding-string from left to border
    plot_padding = repeat(🗷, p.padding)

    if p.colorbar
        min_z, max_z = p.colorbar_lim
        min_z_str = string(isinteger(min_z) ? min_z : float_round_log10(min_z))
        max_z_str = string(isinteger(max_z) ? max_z : float_round_log10(max_z))
        cbar_max_len =
            max(length(min_z_str), length(max_z_str), length(nocolor_string(p.zlabel)))
        cbar_pad = plot_padding * repeat(🗹, 4) * plot_padding * repeat(🗷, cbar_max_len)
    else
        cbar_pad = ""
    end

    # padding-string between labels and border
    border_left_pad = repeat(🗷, plot_offset)

    # trailing
    border_right_pad = repeat(🗷, max_len_r) * plot_padding * cbar_pad

    # plot the title and the top border
    h_ttl, w_ttl = print_title(
        io,
        print_nc,
        print_col,
        border_left_pad,
        p.title,
        border_right_pad * '\n',
        🗹;
        p_width = p_width,
        color = Crayon(bold = true),
    )
    print_labels(
        io,
        print_nc,
        print_col,
        :t,
        p,
        nc - 2,
        border_left_pad * 🗹,
        🗹 * border_right_pad * '\n',
        🗹,
    )
    c.visible && print_border(
        io,
        print_nc,
        print_col,
        :t,
        nc,
        border_left_pad,
        border_right_pad * '\n',
        bmap,
    )

    # compute position of ylabel
    y_lab_row = round(nrows(c) / 2, RoundNearestTiesUp)

    callback = colormap_callback(p.colormap)

    bc = BORDER_COLOR[]

    # plot all rows
    for row in 1:nr
        # print left annotations
        print_nc(io, repeat(🗷, p.margin))
        if p.labels
            # Current labels to left and right of the row and their length
            left_str  = get(p.labels_left, row, "")
            left_col  = get(p.colors_left, row, bc)
            right_str = get(p.labels_right, row, "")
            right_col = get(p.colors_right, row, bc)
            left_len  = length(nocolor_string(left_str))
            right_len = length(nocolor_string(right_str))
            if !get(io, :color, false)
                left_str  = nocolor_string(left_str)
                right_str = nocolor_string(right_str)
            end
            if !p.compact && row == y_lab_row
                # print ylabel
                print_col(io, :normal, p.ylabel)
                print_nc(io, repeat(🗷, max_len_l - length(p.ylabel) - left_len))
            else
                # print padding to fill ylabel length
                print_nc(io, repeat(🗷, max_len_l - left_len))
            end
            # print the left annotation
            print_col(io, left_col, left_str)
        end
        if c.visible
            # print left border
            print_nc(io, plot_padding)
            print_col(io, bc, bmap[:l])
            # print canvas row
            printrow(io, print_nc, print_col, c, row)
            # print right label and padding
            print_col(io, bc, bmap[:r])
        end
        if p.labels
            print_nc(io, plot_padding)
            print_col(io, right_col, right_str)
            print_nc(io, repeat(🗷, max_len_r - right_len))
        end
        # print colorbar
        if p.colorbar
            print_nc(io, plot_padding)
            print_colorbar_row(
                io,
                print_nc,
                print_col,
                c,
                row,
                callback,
                p.colorbar_border,
                p.colorbar_lim,
                (min_z_str, max_z_str),
                plot_padding,
                p.zlabel,
                cbar_max_len,
                🗷,
            )
        end
        row < nrows(c) && print_nc(io, '\n')
    end

    # draw bottom border and bottom labels  
    c.visible && print_border(
        io,
        print_nc,
        print_col,
        :b,
        nc,
        '\n' * border_left_pad,
        border_right_pad,
        bmap,
    )
    h_lbl = w_lbl = 0
    if p.labels
        print_labels(
            io,
            print_nc,
            print_col,
            :b,
            p,
            nc - 2,
            '\n' * border_left_pad * 🗹,
            🗹 * border_right_pad,
            🗹,
        )
        h_lbl += 1
        if !p.compact
            h_w = print_title(
                io,
                print_nc,
                print_col,
                '\n' * border_left_pad,
                p.xlabel,
                border_right_pad,
                🗹;
                p_width = p_width,
            )
            h_lbl += h_w[1]
            w_lbl += h_w[2]
        end
    end
    # approximate image size
    (
        h_ttl + 1 + nr + 1 + h_lbl,  # +1: borders
        max(w_ttl, w_lbl, length(border_left_pad) + p_width + length(border_right_pad)),
    )
end

# COV_EXCL_START
default_font(mono::Bool = false) =
    if Sys.islinux()
        mono ? "DejaVu Sans Mono" : "DejaVu Sans"
    elseif Sys.isbsd()
        mono ? "Courier New" : "Helvetica"
    elseif Sys.iswindows()
        mono ? "Courier New" : "Arial"
    else
        @warn "unsupported $(Base.KERNEL)"
        mono ? "Courier" : "Helvetica"
    end
# COV_EXCL_STOP

"""
    savefig(p, filename; color = false, font = default_font(), pixelsize = 16, transparent = true, foreground = nothing, background = nothing)

Save the given plot to a `txt or `png` file.

# Arguments (`txt` files)
- `color::Bool = false`: output the ANSI color codes to the file.

# Arguments (`png` files)

- `pixelsize::Integer = 16`: controls the image size scaling.
- `font::AbstractString = default_font()`: select a font by name.
- `transparent::Bool = true`: use a transparent background.
- `foreground::UserColorType = nothing`: choose a foreground color for un-colored text.
- `background::UserColorType = nothing`, choose a background color for the rendered image.

# Examples

```julia-repl
julia> savefig(lineplot([0, 1]), "foo.txt")
julia> savefig(lineplot([0, 1]), "foo.png"; font = "JuliaMono", pixelsize = 32)
```
"""
function savefig(
    p::Plot,
    filename::String;
    color::Bool = false,
    font::AbstractString = default_font(),
    pixelsize::Integer = 16,
    transparent::Bool = true,
    foreground::UserColorType = nothing,
    background::UserColorType = nothing,
)
    ext = lowercase(splitext(filename)[2])
    if ext in ("", ".txt")
        open(filename, "w") do io
            show(IOContext(io, :color => color), p)
        end
    elseif ext == ".png"
        RGB24 = ColorTypes.RGB24
        RGBA = ColorTypes.RGBA
        RGB = ColorTypes.RGB

        fg_color = ansi_color(something(foreground, transparent ? :dark_gray : :light_gray))
        bg_color = ansi_color(something(background, :black))

        rgba(color::ColorType, alpha) = begin
            color == INVALID_COLOR && (color = fg_color)
            color < THRESHOLD || (color = LUT_8BIT[1 + (color - THRESHOLD)])
            RGBA{Float32}(convert(RGB{Float32}, reinterpret(RGB24, color)), alpha)
        end

        default_fg_color = rgba(fg_color, 1.0)
        default_bg_color = rgba(bg_color, transparent ? 0.0 : 1.0)

        # compute final image size
        noop = (args...) -> nothing
        nr, nc = _show(devnull, noop, noop, p)

        # hack printing to collect chars & colors
        chars = sizehint!(Char[], nr * nc)
        colors = sizehint!(RGBA{Float32}[], nr * nc)

        print_nc(io, args...) = begin
            line = string(args...)
            append!(chars, line)
            append!(colors, fill(default_fg_color, length(line)))
        end

        print_col(io, color, args...) = begin
            color = rgba(ansi_color(color), 1.0)
            line = string(args...)
            append!(chars, line)
            append!(colors, fill(color, length(line)))
        end

        # compute 1D stream of chars and colors
        _show(IOContext(devnull, :color => true), print_nc, print_col, p)

        # compute 2D grid (image) of chars and colors
        lchrs = sizehint!([Char[]], nr)
        lcols = sizehint!([RGBA{Float32}[]], nr)
        r = 1
        for (chr, col) in zip(chars, colors)
            if chr === '\n'
                r += 1
                push!(lchrs, Char[])
                push!(lcols, RGBA{Float32}[])
                continue
            end
            push!(lchrs[r], chr)
            push!(lcols[r], col)
        end

        # render image
        face = FreeTypeAbstraction.findfont(font)

        kr = ASPECT_RATIO
        kc = kr / 2

        img = fill(
            default_bg_color,
            ceil(Int, (kr * pixelsize) * nr),
            ceil(Int, (kc * pixelsize) * nc),
        )

        y0 = round(Int, kr * pixelsize)
        for (r, (chrs, cols)) in enumerate(zip(lchrs, lcols))
            y = round(Int, y0 + (kr * pixelsize) * (r - 1))
            FreeTypeAbstraction.renderstring!(
                img,
                String(chrs),
                face,
                pixelsize,
                y,
                0;
                fcolor = cols,
                bcolor = transparent ? nothing : default_bg_color,
                valign = :vbaseline,
                halign = :hleft,
            )
        end
        FileIO.save(filename, img)
    else
        error("`savefig` only supports writing to `txt` or `png` files")
    end
    nothing
end
