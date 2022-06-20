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
struct Plot{T<:GraphicsArea,E,F}
    graphics::T
    projection::MVP{E,F}
    autocolor::RefValue{Int}
    title::RefValue{String}
    xlabel::RefValue{String}
    ylabel::RefValue{String}
    zlabel::RefValue{String}
    margin::Int
    padding::Int
    border::Symbol
    compact::Bool
    labels::Bool
    labels_left::Dict{Int,String}
    labels_right::Dict{Int,String}
    colors_left::Dict{Int,ColorType}
    colors_right::Dict{Int,ColorType}
    decorations::Dict{Symbol,String}
    colors_deco::Dict{Symbol,ColorType}
    cmap::ColorMap
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
    projection::Union{Nothing,MVP} = nothing,
    ignored...,
) where {T<:GraphicsArea}
    margin < 0 && throw(ArgumentError("Margin must be greater than or equal to 0"))
    projection = something(projection, MVP())
    E = Val{is_enabled(projection)}
    F = typeof(projection.dist)
    p = Plot{T,E,F}(
        graphics,
        projection,
        Ref(0),
        Ref(string(title)),
        Ref(string(xlabel)),
        Ref(string(ylabel)),
        Ref(string(zlabel)),
        margin,
        padding,
        border,
        compact,
        labels && graphics.visible,
        Dict{Int,String}(),
        Dict{Int,String}(),
        Dict{Int,ColorType}(),
        Dict{Int,ColorType}(),
        Dict{Symbol,String}(),
        Dict{Symbol,ColorType}(),
        ColorMap(colorbar_border, colorbar, colorbar_lim, colormap_callback(colormap)),
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
    canvas_kw = (;),
    kw...,
) where {C<:Canvas}
    length(xlim) == length(ylim) == 2 ||
        throw(ArgumentError("xlim and ylim must be tuples or vectors of length 2"))

    height = something(height, DEFAULT_HEIGHT[])
    width = something(width, DEFAULT_WIDTH[])

    (visible = width > 0) && (width = max(width, min_width))
    height = max(height, min_height)

    x, y, z = validate_input(x, y, z)

    base_x = xscale isa Symbol ? get(BASES, xscale, nothing) : nothing
    base_y = yscale isa Symbol ? get(BASES, yscale, nothing) : nothing

    xscale = scale_callback(xscale)
    yscale = scale_callback(yscale)

    if projection ≢ nothing  # 3D
        (xscale ≢ identity || yscale ≢ identity) &&
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
        height,
        width;
        blend = blend,
        visible = visible,
        origin_y = my,
        origin_x = mx,
        height = p_height,
        width = p_width,
        yscale = yscale,
        xscale = xscale,
        canvas_kw...,
    )
    plot = Plot(
        canvas;
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
        m_x, M_x, m_y, M_y = nice_repr.((mx, Mx, my, My))
        if unicode_exponent
            m_x, M_x = map(v -> base_x ≢ nothing ? superscript(v) : v, (m_x, M_x))
            m_y, M_y = map(v -> base_y ≢ nothing ? superscript(v) : v, (m_y, M_y))
        end
        if xticks
            base_x_str = base_x ≡ nothing ? "" : base_x * (unicode_exponent ? "" : "^")
            label!(plot, :bl, base_x_str * m_x, color = BORDER_COLOR[])
            label!(plot, :br, base_x_str * M_x, color = BORDER_COLOR[])
        end
        if yticks
            base_y_str = base_y ≡ nothing ? "" : base_y * (unicode_exponent ? "" : "^")
            label!(plot, :l, nrows(canvas), base_y_str * m_y, color = BORDER_COLOR[])
            label!(plot, :l, 1, base_y_str * M_y, color = BORDER_COLOR[])
        end
    end
    if grid && (xscale ≡ identity && yscale ≡ identity)
        my < 0 < My && lines!(plot, mx, 0.0, Mx, 0.0)
        mx < 0 < Mx && lines!(plot, 0.0, my, 0.0, My)
    end

    (is_enabled(projection) && axes3d) && draw_axes!(plot, 0.8 .* [mx, my])

    plot
end

function next_color!(plot::Plot)
    next_idx = plot.autocolor[] + 1
    next_color = COLOR_CYCLE[][next_idx]
    plot.autocolor[] = next_idx % length(COLOR_CYCLE[])
    next_color
end

"""
    title(plot) -> String

Returns the current title of the given plot.
Alternatively, the title can be changed with `title!`.
"""
@inline title(plot::Plot) = plot.title[]

"""
    title!(plot, newtitle)

Sets a new title for the given plot.
Alternatively, the current title can be queried using `title`.
"""
function title!(plot::Plot, title::AbstractString)
    plot.title[] = title
    plot
end

"""
    xlabel(plot) -> String

Returns the current label for the x-axis.
Alternatively, the x-label can be changed with `xlabel!`.
"""
@inline xlabel(plot::Plot) = plot.xlabel[]

"""
    xlabel!(plot, newlabel)

Sets a new x-label for the given plot.
Alternatively, the current label can be queried using `xlabel`.
"""
function xlabel!(plot::Plot, xlabel::AbstractString)
    plot.xlabel[] = xlabel
    plot
end

"""
    ylabel(plot) -> String

Returns the current label for the y-axis.
Alternatively, the y-label can be changed with `ylabel!`.
"""
@inline ylabel(plot::Plot) = plot.ylabel[]

"""
    ylabel!(plot, newlabel)

Sets a new y-label for the given plot.
Alternatively, the current label can be
queried using `ylabel`
"""
function ylabel!(plot::Plot, ylabel::AbstractString)
    plot.ylabel[] = ylabel
    plot
end

"""
    zlabel(plot) -> String

Returns the current label for the z-axis (colorbar).
Alternatively, the z-label can be changed with `zlabel!`.
"""
@inline zlabel(plot::Plot) = plot.zlabel[]

"""
    zlabel!(plot, newlabel)

Sets a new z-label (colorbar label) for the given plot.
Alternatively, the current label can be queried using `zlabel`.
"""
function zlabel!(plot::Plot, zlabel::AbstractString)
    plot.zlabel[] = zlabel
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
    if loc ≡ :l || loc == :r
        for row in 1:nrows(plot.graphics)
            if loc ≡ :l
                if !haskey(plot.labels_left, row) || plot.labels_left[row] == ""
                    plot.labels_left[row] = value
                    plot.colors_left[row] = ansi_color(color)
                    break
                end
            elseif loc ≡ :r
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

label!(plot::Plot, loc::Symbol, value::AbstractString; color::UserColorType = :normal) =
    label!(plot, loc, value, color)

function label!(
    plot::Plot,
    loc::Symbol,
    row::Int,
    value::AbstractString,
    color::UserColorType,
)
    if loc ≡ :l
        plot.labels_left[row] = value
        plot.colors_left[row] = ansi_color(color)
    elseif loc ≡ :r
        plot.labels_right[row] = value
        plot.colors_right[row] = ansi_color(color)
    else
        throw(ArgumentError("Unknown location \"$loc\", try `:l` or `:r` instead"))
    end
    plot
end

label!(
    plot::Plot,
    loc::Symbol,
    row::Int,
    value::AbstractString;
    color::UserColorType = :normal,
) = label!(plot, loc, row, value, color)

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
    color = color ≡ :auto ? next_color!(plot) : color
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
    print_nocol,
    print_color,
    left_pad::AbstractString,
    title::AbstractString,
    right_pad::AbstractString,
    blank::Char;
    p_width::Int = 0,
    color::UserColorType = :normal,
)
    title == "" && return (0, 0)
    offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
    pre_pad = blank^(offset > 0 ? offset : 0)
    print_nocol(io, left_pad, pre_pad)
    print_color(io, color, title)
    post_pad = blank^(max(0, p_width - length(pre_pad) - length(title)))
    print_nocol(io, post_pad, right_pad)
    (
        count("\n", title) + 1,
        length(strip(left_pad * pre_pad * title * post_pad * right_pad, '\n')),
    )
end

function print_border(
    io::IO,
    print_nocol,
    print_color,
    loc::Symbol,
    length::Int,
    left_pad::Union{Char,AbstractString},
    right_pad::Union{Char,AbstractString},
    bmap = BORDERMAP[:solid],
    color::UserColorType = BORDER_COLOR[],
)
    print_nocol(io, left_pad)
    print_color(io, color, bmap[Symbol(loc, :l)], bmap[loc]^length, bmap[Symbol(loc, :r)])
    print_nocol(io, right_pad)
    nothing
end

function print_labels(
    io::IO,
    print_nocol,
    print_color,
    mloc::Symbol,
    p::Plot,
    border_length,
    left_pad::AbstractString,
    right_pad::AbstractString,
    blank::Char,
)
    p.labels || return 0
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
        print_nocol(io, left_pad)
        print_color(io, left_col, left_str)
        cnt = round(Int, border_length / 2 - mid_len / 2 - left_len, RoundNearestTiesAway)
        print_nocol(io, cnt > 0 ? blank^cnt : "")
        print_color(io, mid_col, mid_str)
        cnt = border_length - right_len - left_len - mid_len + 2 - cnt
        print_nocol(io, cnt > 0 ? blank^cnt : "")
        print_color(io, right_col, right_str)
        print_nocol(io, right_pad)
        return 1
    end
    return 0
end

Base.show(io::IO, p::Plot) = _show(io, print, print_color, p)

function _show(io::IO, print_nocol, print_color, p::Plot)
    io_color = get(io, :color, false)
    c = p.graphics
    🗷 = Char(BLANK)  # blank outside canvas
    🗹 = blank(c)  # blank inside canvas
    ############################################################
    # 🗷 = 'x'  # debug
    # 🗹 = Char(typeof(c) <: BrailleCanvas ? '⠿' : 'o')  # debug
    ############################################################
    nr = nrows(c)
    nc = ncols(c)
    p_width = nc + 2  # left corner + border length (number of canvas cols) + right corner

    bmap = BORDERMAP[p.border ≡ :none && c isa BrailleCanvas ? :bnone : p.border]
    bc = BORDER_COLOR[]

    # get length of largest strings to the left and right
    max_len_l = if p.labels && !isempty(p.labels_left)
        maximum(map(length ∘ no_ansi_escape, values(p.labels_left)))
    else
        0
    end
    max_len_r = if p.labels && !isempty(p.labels_right)
        maximum(map(length ∘ no_ansi_escape, values(p.labels_right)))
    else
        0
    end
    if !p.compact && p.labels && ylabel(p) != ""
        max_len_l += length(ylabel(p)) + 1
    end

    # offset where the plot (incl border) begins
    plot_offset = max_len_l + p.margin + p.padding

    # padding-string from left to border
    plot_padding = 🗷^p.padding

    cbar_pad = if p.cmap.bar
        min_max_z_str = lims_repr.(p.cmap.lim)
        cbar_max_len = maximum(length.((min_max_z_str..., no_ansi_escape(zlabel(p)))))
        plot_padding * 🗹^4 * plot_padding * 🗷^cbar_max_len
    else
        ""
    end

    # padding-string between labels and border
    border_left_pad = 🗷^plot_offset

    # trailing
    border_right_pad = 🗷^max_len_r * (p.labels ? plot_padding : "") * cbar_pad

    # plot the title and the top border
    h_ttl, w_ttl = print_title(
        io,
        print_nocol,
        print_color,
        border_left_pad,
        title(p),
        border_right_pad * '\n',
        🗹;
        p_width = p_width,
        color = io_color ? Crayon(foreground = :white, bold = true) : nothing,
    )
    h_lbl = print_labels(
        io,
        print_nocol,
        print_color,
        :t,
        p,
        nc - 2,
        border_left_pad * 🗹,
        🗹 * border_right_pad * '\n',
        🗹,
    )
    c.visible && print_border(
        io,
        print_nocol,
        print_color,
        :t,
        nc,
        border_left_pad,
        border_right_pad * '\n',
        bmap,
    )

    # compute position of ylabel
    y_lab_row = round(nr / 2, RoundNearestTiesUp)

    postprocess! = preprocess!(c)

    # plot all rows
    for row in 1:nr
        # print left annotations
        print_nocol(io, 🗷^p.margin)
        if p.labels
            # Current labels to left and right of the row and their length
            left_str   = get(p.labels_left, row, "")
            left_col   = get(p.colors_left, row, bc)
            right_str  = get(p.labels_right, row, "")
            right_col  = get(p.colors_right, row, bc)
            left_str_  = no_ansi_escape(left_str)
            right_str_ = no_ansi_escape(right_str)
            left_len   = length(left_str_)
            right_len  = length(right_str_)
            if !io_color
                left_str  = left_str_
                right_str = right_str_
            end
            if !p.compact && row == y_lab_row
                # print ylabel
                print_color(io, :normal, ylabel(p))
                print_nocol(io, 🗷^(max_len_l - length(ylabel(p)) - left_len))
            else
                # print padding to fill ylabel length
                print_nocol(io, 🗷^(max_len_l - left_len))
            end
            # print the left annotation
            print_color(io, left_col, left_str)
        end
        if c.visible
            # print left border
            print_nocol(io, plot_padding)
            print_color(io, bc, bmap[:l])
            # print canvas row
            print_row(io, print_nocol, print_color, c, row)
            # print right label and padding
            print_color(io, bc, bmap[:r])
        end
        if p.labels
            print_nocol(io, plot_padding)
            print_color(io, right_col, right_str)
            print_nocol(io, 🗷^(max_len_r - right_len))
        end
        # print colorbar
        if p.cmap.bar
            print_nocol(io, plot_padding)
            print_colorbar_row(
                io,
                print_nocol,
                print_color,
                c,
                row,
                p.cmap,
                min_max_z_str,
                plot_padding,
                zlabel(p),
                cbar_max_len,
                🗷,
            )
        end
        row < nrows(c) && print_nocol(io, '\n')
    end

    postprocess!(c)

    # draw bottom border
    c.visible && print_border(
        io,
        print_nocol,
        print_color,
        :b,
        nc,
        '\n' * border_left_pad,
        border_right_pad,
        bmap,
    )
    # print bottom labels
    w_lbl = 0
    if p.labels
        h_lbl += print_labels(
            io,
            print_nocol,
            print_color,
            :b,
            p,
            nc - 2,
            '\n' * border_left_pad * 🗹,
            🗹 * border_right_pad,
            🗹,
        )
        if !p.compact
            h_w = print_title(
                io,
                print_nocol,
                print_color,
                '\n' * border_left_pad,
                xlabel(p),
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
        h_ttl + 1 + nr + 1 + h_lbl,  # +1 for borders
        max(w_ttl, w_lbl, length(border_left_pad) + p_width + length(border_right_pad)),
    )
end

# COV_EXCL_START
fallback_font(mono::Bool = false) =
    if Sys.islinux()
        mono ? "DejaVu Sans Mono" : "DejaVu Sans"
    elseif Sys.isbsd()
        mono ? "Courier New" : "Helvetica"
    elseif Sys.iswindows()
        mono ? "Courier New" : "Arial"
    else
        @warn "Unsupported $(Base.KERNEL)"
        mono ? "Courier" : "Helvetica"
    end
# COV_EXCL_STOP

const FT_FONTS = Dict{String,FreeTypeAbstraction.FTFont}()

"""
    png_image(p::Plot, font = nothing, pixelsize = 16, transparent = true, foreground = nothing, background = nothing, bounding_box = nothing, bounding_box_glyph = nothing)

Render `png` image.

# Arguments
- `pixelsize::Integer = 16`: controls the image size scaling.
- `font::Union{Nothing,AbstractString} = nothing`: select a font by name, or fall-back to a system font.
- `transparent::Bool = true`: use a transparent background.
- `foreground::UserColorType = nothing`: choose a foreground color for un-colored text.
- `background::UserColorType = nothing`: choose a background color for the rendered image.
- `bounding_box::UserColorType = nothing`: debugging bounding box color.
- `bounding_box_glyph::UserColorType = nothing`: debugging glyph bounding box color.
- `row_fact::Union{Nothing,Real} = nothing`: row spacing multiplier (e.g. for histogram).
"""
function png_image(
    p::Plot;
    font::Union{Nothing,AbstractString} = nothing,
    pixelsize::Integer = 16,
    transparent::Bool = true,
    foreground::UserColorType = nothing,
    background::UserColorType = nothing,
    bounding_box_glyph::UserColorType = nothing,
    bounding_box::UserColorType = nothing,
    row_fact::Union{Nothing,Real} = nothing,
)
    canvas = p.graphics
    #####################################
    # visual fixes
    incx = if canvas isa HeatmapCanvas || canvas isa BarplotGraphics || p.cmap.bar
        -1
    else
        0
    end
    row_fact = something(row_fact, if canvas isa BarplotGraphics  # histogram
        1.08
    else
        1.0
    end)
    #####################################

    RGB24 = ColorTypes.RGB24
    RGBA = ColorTypes.RGBA
    RGB = ColorTypes.RGB

    fg_color = ansi_color(something(foreground, transparent ? 244 : 252))
    bg_color = ansi_color(something(background, 235))

    rgba(color::ColorType, alpha = 1.0) = begin
        color == INVALID_COLOR && (color = fg_color)
        color < THRESHOLD || (color = LUT_8BIT[1 + (color - THRESHOLD)])
        RGBA{Float32}(convert(RGB{Float32}, reinterpret(RGB24, color)), alpha)
    end

    default_fg_color = rgba(fg_color)
    default_bg_color = rgba(bg_color, transparent ? 0.0 : 1.0)
    bbox = if bounding_box ≢ nothing
        rgba(ansi_color(bounding_box))
    else
        bounding_box
    end
    bbox_glyph = if bounding_box_glyph ≢ nothing
        rgba(ansi_color(bounding_box_glyph))
    else
        bounding_box_glyph
    end

    # compute final image size
    noop = (args...; kw...) -> nothing
    nr, nc = _show(devnull, noop, noop, p)

    # hack printing to collect chars & colors
    fchars = sizehint!(Char[], nr * nc)
    gchars = sizehint!(Char[], nr * nc)
    fcolors = sizehint!(RGBA{Float32}[], nr * nc)
    gcolors = sizehint!(RGBA{Float32}[], nr * nc)

    print_nocol(io, args...) = begin
        line = string(args...)
        len = length(line)
        append!(fchars, line)
        append!(gchars, line)
        append!(fcolors, fill(default_fg_color, len))
        append!(gcolors, fill(default_bg_color, len))
        nothing
    end

    print_color(io, color, args...; bgcol = missing) = begin
        fcolor = rgba(ansi_color(color))
        gcolor = if ismissing(bgcol)
            default_bg_color
        else
            rgba(ansi_color(bgcol))
        end
        line = string(args...)
        len = length(line)
        append!(fchars, line)
        append!(gchars, ismissing(bgcol) ? line : fill(FULL_BLOCK, len))  # for heatmap, colorbars - BORDER_SOLID[:l]
        append!(fcolors, fill(fcolor, len))
        append!(gcolors, fill(gcolor, len))
        nothing
    end

    # compute 1D stream of chars and colors
    _show(IOContext(devnull, :color => true), print_nocol, print_color, p)

    # compute 2D grid (image) of chars and colors
    lfchars = sizehint!([Char[]], nr)
    lgchars = sizehint!([Char[]], nr)
    lfcols = sizehint!([RGBA{Float32}[]], nr)
    lgcols = sizehint!([RGBA{Float32}[]], nr)
    r = 1
    for (fchar, gchar, fcol, gcol) in zip(fchars, gchars, fcolors, gcolors)
        if fchar ≡ '\n'
            r += 1
            push!(lfchars, Char[])
            push!(lgchars, Char[])
            push!(lfcols, RGBA{Float32}[])
            push!(lgcols, RGBA{Float32}[])
            continue
        end
        push!(lfchars[r], fchar)
        push!(lgchars[r], gchar)
        push!(lfcols[r], fcol)
        push!(lgcols[r], gcol)
    end

    # render image
    face = nothing
    for name in filter(!isnothing, (font, "JuliaMono", fallback_font()))
        if haskey(FT_FONTS, name)
            face = FT_FONTS[name]
            break
        elseif (ft = FreeTypeAbstraction.findfont(name)) ≢ nothing
            face = FT_FONTS[name] = ft
            break
        end
    end

    kr = ASPECT_RATIO[]
    kc = kr / 2

    img = fill(
        default_bg_color,
        ceil(Int, kr * pixelsize * nr * row_fact),
        ceil(Int, kc * pixelsize * nc),
    )

    y0 = ceil(Int, (kr * pixelsize) / 2)
    x0 = ceil(Int, (kc * pixelsize * nc) / 2)

    for (r, (fchars, gchars, fcols, gcols)) in
        enumerate(zip(lfchars, lgchars, lfcols, lgcols))
        y = ceil(Int, y0 + (kr * pixelsize * row_fact) * (r - 1))
        incy = FreeTypeAbstraction.renderstring!(
            img,
            fchars,
            face,
            pixelsize,
            y,
            x0;
            fcolor = fcols,
            gcolor = gcols,
            bcolor = nothing,  # not needed (initial fill, avoid overlaps)
            valign = :vcenter,
            halign = :hcenter,
            bbox_glyph = bbox_glyph,
            bbox = bbox,
            gstr = gchars,
            off_bg = 1,
            incx = incx,
        )
    end

    img
end

"""
    savefig(p, filename; color = false, kw...)

Save the given plot to a `txt or `png` file.

# Arguments - `txt`
- `color::Bool = false`: output the ANSI color codes to the file.

# Arguments - `png`
see help?> UnicodePlots.png_image

# Examples

```julia-repl
julia> savefig(lineplot([0, 1]), "foo.txt")
julia> savefig(lineplot([0, 1]), "foo.png"; font = "JuliaMono", pixelsize = 32)
```
"""
function savefig(p::Plot, filename::AbstractString; color::Bool = false, kw...)
    ext = lowercase(splitext(filename)[2])
    if ext in ("", ".txt")
        open(filename, "w") do io
            show(IOContext(io, :color => color), p)
        end
    elseif ext == ".png"
        FileIO.save(filename, png_image(p; kw...))
    else
        error("`savefig` only supports writing to `txt` or `png` files")
    end
    nothing
end

function Base.string(p::Plot; color = false)
    io = PipeBuffer()
    show(IOContext(io, :color => color), p)
    read(io, String)
end
