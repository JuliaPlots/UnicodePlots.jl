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
    colors_left::Dict{Int,JuliaColorType}
    labels_right::Dict{Int,String}
    colors_right::Dict{Int,JuliaColorType}
    decorations::Dict{Symbol,String}
    colors_deco::Dict{Symbol,JuliaColorType}
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
    colors_left = Dict{Int,JuliaColorType}()
    labels_right = Dict{Int,String}()
    colors_right = Dict{Int,JuliaColorType}()
    decorations = Dict{Symbol,String}()
    colors_deco = Dict{Symbol,JuliaColorType}()
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
    m_x, M_x, m_y, M_y = map(
        v -> compact_repr(roundable(v) ? round(Int, v, RoundNearestTiesUp) : v),
        (mx, Mx, my, My),
    )
    if unicode_exponent
        m_x, M_x = map(v -> base_x !== nothing ? superscript(v) : v, (m_x, M_x))
        m_y, M_y = map(v -> base_y !== nothing ? superscript(v) : v, (m_y, M_y))
    end
    base_x_str = base_x === nothing ? "" : base_x * (unicode_exponent ? "" : "^")
    base_y_str = base_y === nothing ? "" : base_y * (unicode_exponent ? "" : "^")
    label!(plot, :l, nrows(canvas), base_y_str * m_y, color = :light_black)
    label!(plot, :l, 1, base_y_str * M_y, color = :light_black)
    label!(plot, :bl, base_x_str * m_x, color = :light_black)
    label!(plot, :br, base_x_str * M_x, color = :light_black)
    if grid
        if my < 0 < My
            for i in range(mx, stop = Mx, length = width * x_pixel_per_char(C))
                points!(plot, i, 0.0, :normal)
            end
        end
        if mx < 0 < Mx
            for i in range(my, stop = My, length = height * y_pixel_per_char(C))
                points!(plot, 0.0, i, :normal)
            end
        end
    end

    (is_enabled(projection) && axes3d) && draw_axes!(plot, 0.8 .* [mx, my])

    plot
end

function next_color!(plot::Plot{<:GraphicsArea})
    cur_color = COLOR_CYCLE[plot.autocolor + 1]
    plot.autocolor = ((plot.autocolor + 1) % length(COLOR_CYCLE))
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
                    plot.colors_left[row] = julia_color(color)
                    break
                end
            elseif loc == :r
                if !haskey(plot.labels_right, row) || plot.labels_right[row] == ""
                    plot.labels_right[row] = value
                    plot.colors_right[row] = julia_color(color)
                    break
                end
            end
        end
    else
        plot.decorations[loc] = value
        plot.colors_deco[loc] = julia_color(color)
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
        plot.colors_left[row] = julia_color(color)
    elseif loc == :r
        plot.labels_right[row] = value
        plot.colors_right[row] = julia_color(color)
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
    left_pad::AbstractString,
    title::AbstractString,
    right_pad::AbstractString,
    blank::Char;
    p_width::Int = 0,
    color = :normal,
)
    title == "" && return
    offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
    pre_pad = repeat(blank, offset > 0 ? offset : 0)
    print(io, left_pad, pre_pad)
    print_color(color, io, title)
    post_pad = repeat(blank, max(0, p_width - length(pre_pad) - length(title)))
    print(io, post_pad, right_pad)
    nothing
end

function print_border(
    io::IO,
    loc::Symbol,
    length::Int,
    left_pad::AbstractString,
    right_pad::AbstractString,
    bmap = BORDERMAP[:solid],
    color::UserColorType = :light_black,
)
    print(io, left_pad)
    print_color(
        color,
        io,
        bmap[Symbol(loc, :l)],
        repeat(bmap[loc], length),
        bmap[Symbol(loc, :r)],
    )
    print(io, right_pad)
    nothing
end

_nocolor_string(str) = replace(string(str), r"\e\[[0-9]+m" => "")

function print_labels(
    io::IO,
    mloc::Symbol,
    p::Plot,
    border_length,
    left_pad::AbstractString,
    right_pad::AbstractString,
    blank::Char,
)
    p.labels || return
    lloc      = Symbol(mloc, :l)
    rloc      = Symbol(mloc, :r)
    left_str  = get(p.decorations, lloc, "")
    left_col  = get(p.colors_deco, lloc, :light_black)
    mid_str   = get(p.decorations, mloc, "")
    mid_col   = get(p.colors_deco, mloc, :light_black)
    right_str = get(p.decorations, rloc, "")
    right_col = get(p.colors_deco, rloc, :light_black)
    if left_str != "" || right_str != "" || mid_str != ""
        left_len  = length(left_str)
        mid_len   = length(mid_str)
        right_len = length(right_str)
        print(io, left_pad)
        print_color(left_col, io, left_str)
        cnt = round(Int, border_length / 2 - mid_len / 2 - left_len, RoundNearestTiesAway)
        pad = cnt > 0 ? repeat(blank, cnt) : ""
        print(io, pad)
        print_color(mid_col, io, mid_str)
        cnt = border_length - right_len - left_len - mid_len + 2 - cnt
        pad = cnt > 0 ? repeat(blank, cnt) : ""
        print(io, pad)
        print_color(right_col, io, right_str)
        print(io, right_pad)
    end
    nothing
end

function Base.show(io::IO, p::Plot)
    c = p.graphics
    🗷 = Char(BLANK)  # blank outside canvas
    🗹 = Char(c isa BrailleCanvas ? BLANK_BRAILLE : 🗷)  # blank inside canvas
    ############################################################
    # 🗷 = 'x'  # debug
    # 🗹 = Char(typeof(c) <: BrailleCanvas ? '⠿' : 'o')  # debug
    ############################################################
    border_length = ncols(c)
    p_width = border_length + 2  # left corner + border + right corner

    bmap = BORDERMAP[p.border === :none && c isa BrailleCanvas ? :bnone : p.border]

    # get length of largest strings to the left and right
    max_len_l = if p.labels && !isempty(p.labels_left)
        maximum([length(_nocolor_string(l)) for l in values(p.labels_left)])
    else
        0
    end
    max_len_r = if p.labels && !isempty(p.labels_right)
        maximum([length(_nocolor_string(l)) for l in values(p.labels_right)])
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
            max(length(min_z_str), length(max_z_str), length(_nocolor_string(p.zlabel)))
        cbar_pad = plot_padding * repeat(🗹, 4) * plot_padding * repeat(🗷, cbar_max_len)
    else
        cbar_pad = ""
    end

    # padding-string between labels and border
    border_left_pad = repeat(🗷, plot_offset)

    # trailing
    border_right_pad = repeat(🗷, max_len_r) * plot_padding * cbar_pad

    # plot the title and the top border
    print_title(
        io,
        border_left_pad,
        p.title,
        border_right_pad * '\n',
        🗹;
        p_width = p_width,
        color = :bold,
    )
    print_labels(
        io,
        :t,
        p,
        border_length - 2,
        border_left_pad * 🗹,
        🗹 * border_right_pad * '\n',
        🗹,
    )
    c.visible &&
        print_border(io, :t, border_length, border_left_pad, border_right_pad * '\n', bmap)

    # compute position of ylabel
    y_lab_row = round(nrows(c) / 2, RoundNearestTiesUp)

    callback = colormap_callback(p.colormap)

    # plot all rows
    for row in 1:nrows(c)
        # print left annotations
        print(io, repeat(🗷, p.margin))
        if p.labels
            # Current labels to left and right of the row and their length
            left_str  = get(p.labels_left, row, "")
            left_col  = get(p.colors_left, row, :light_black)
            right_str = get(p.labels_right, row, "")
            right_col = get(p.colors_right, row, :light_black)
            left_len  = length(_nocolor_string(left_str))
            right_len = length(_nocolor_string(right_str))
            if !get(io, :color, false)
                left_str  = _nocolor_string(left_str)
                right_str = _nocolor_string(right_str)
            end
            if !p.compact && row == y_lab_row
                # print ylabel
                print_color(:normal, io, p.ylabel)
                print(io, repeat(🗷, max_len_l - length(p.ylabel) - left_len))
            else
                # print padding to fill ylabel length
                print(io, repeat(🗷, max_len_l - left_len))
            end
            # print the left annotation
            print_color(left_col, io, left_str)
        end
        if c.visible
            # print left border
            print(io, plot_padding)
            print_color(:light_black, io, bmap[:l])
            # print canvas row
            printrow(io, c, row)
            # print right label and padding
            print_color(:light_black, io, bmap[:r])
        end
        if p.labels
            print(io, plot_padding)
            print_color(right_col, io, right_str)
            print(io, repeat(🗷, max_len_r - right_len))
        end
        # print colorbar
        if p.colorbar
            print(io, plot_padding)
            printcolorbarrow(
                io,
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
        row < nrows(c) && println(io)
    end

    # draw bottom border and bottom labels  
    c.visible &&
        print_border(io, :b, border_length, '\n' * border_left_pad, border_right_pad, bmap)
    if p.labels
        print_labels(
            io,
            :b,
            p,
            border_length - 2,
            '\n' * border_left_pad * 🗹,
            🗹 * border_right_pad,
            🗹,
        )
        p.compact || print_title(
            io,
            '\n' * border_left_pad,
            p.xlabel,
            border_right_pad,
            🗹;
            p_width = p_width,
        )
    end
    nothing
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
function savefig(p::Plot, filename::String; color::Bool = false)
    ext = lowercase(splitext(filename)[2])
    if ext in (".png", ".jpg", ".jpeg", ".tif", ".gif", ".svg")
        @warn "`UnicodePlots.savefig` only support writing to text files"
    end
    open(filename, "w") do io
        print(IOContext(io, :color => color), p)
    end
    nothing
end
