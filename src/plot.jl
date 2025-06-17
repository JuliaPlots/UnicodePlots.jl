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

- `label!(plot::Plot, where::Symbol, row::Integer, value::String)`

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
    series::RefValue{Int}
    title::RefValue{String}
    xlabel::RefValue{String}
    ylabel::RefValue{String}
    zlabel::RefValue{String}
    margin::RefValue{Int}
    padding::RefValue{Int}
    unicode_exponent::RefValue{Bool}
    thousands_separator::RefValue{Char}
    border::RefValue{Symbol}
    compact::RefValue{Bool}
    labels::RefValue{Bool}
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
    title::AbstractString = PLOT_KEYWORDS.title,
    xlabel::AbstractString = PLOT_KEYWORDS.xlabel,
    ylabel::AbstractString = PLOT_KEYWORDS.ylabel,
    zlabel::AbstractString = PLOT_KEYWORDS.zlabel,
    unicode_exponent::Bool = PLOT_KEYWORDS.unicode_exponent,
    thousands_separator::Char = PLOT_KEYWORDS.thousands_separator,
    border::Symbol = PLOT_KEYWORDS.border,
    compact::Bool = PLOT_KEYWORDS.compact,
    margin::Integer = PLOT_KEYWORDS.margin,
    padding::Integer = PLOT_KEYWORDS.padding,
    labels::Bool = PLOT_KEYWORDS.labels,
    colorbar::Bool = PLOT_KEYWORDS.colorbar,
    colorbar_border::Symbol = PLOT_KEYWORDS.colorbar_border,
    colorbar_lim = PLOT_KEYWORDS.colorbar_lim,
    colormap::Any = PLOT_KEYWORDS.colormap,
    projection::Union{Nothing,MVP} = nothing,
    ignored...,
) where {T<:GraphicsArea}
    margin < 0 && throw(ArgumentError("`margin` must be ≥ 0"))
    projection = something(projection, MVP())
    E = Val{is_enabled(projection)}
    F = typeof(projection.dist)
    Plot{T,E,F}(
        graphics,
        projection,
        Ref(0),
        Ref(0),
        Ref(string(title)),
        Ref(string(xlabel)),
        Ref(string(ylabel)),
        Ref(string(zlabel)),
        Ref(Int(margin)),
        Ref(Int(padding)),
        Ref(unicode_exponent),
        Ref(thousands_separator),
        Ref(border),
        Ref(compact),
        Ref(labels && graphics.visible),
        Dict{Int,String}(),
        Dict{Int,String}(),
        Dict{Int,ColorType}(),
        Dict{Int,ColorType}(),
        Dict{Symbol,String}(),
        Dict{Symbol,ColorType}(),
        ColorMap(colorbar_border, colorbar, colorbar_lim, colormap_callback(colormap)),
    )
end

"""
    validate_input(x, y, z = nothing)

# Description

Check for invalid input (length) and selects only finite input data.
"""
function validate_input(x::AbstractVector, y::AbstractVector, z::AbstractVector)
    (nx = length(x)) == (ny = length(y)) == (nz = length(z)) ||
        throw(DimensionMismatch("`x`, `y` and `z` must have same length"))
    if nx == ny == nz == 0
        x, y, z
    else
        idx =
            BitVector(map((i, j, k) -> isfinite(i) && isfinite(j) && isfinite(k), x, y, z))
        x[idx], y[idx], z[idx]
    end
end

function validate_input(x::AbstractVector, y::AbstractVector, z::Nothing)
    (nx = length(x)) == (ny = length(y)) ||
        throw(DimensionMismatch("`x` and `y` must have same length"))
    if nx == ny == 0
        x, y, z
    else
        idx = BitVector(map((i, j) -> isfinite(i) && isfinite(j), x, y))
        x[idx], y[idx], z
    end
end

Plot(; kw...) = Plot([], []; kw...)

function Plot(
    x::AbstractVector,
    y::AbstractVector,
    z::Union{AbstractVector,Nothing} = nothing,
    canvas::Type{<:Canvas} = BrailleCanvas;
    title::AbstractString = PLOT_KEYWORDS.title,
    xlabel::AbstractString = PLOT_KEYWORDS.xlabel,
    ylabel::AbstractString = PLOT_KEYWORDS.ylabel,
    zlabel::AbstractString = PLOT_KEYWORDS.zlabel,
    unicode_exponent::Bool = PLOT_KEYWORDS.unicode_exponent,
    thousands_separator::Char = PLOT_KEYWORDS.thousands_separator,
    xscale::Union{Symbol,Function} = PLOT_KEYWORDS.xscale,
    yscale::Union{Symbol,Function} = PLOT_KEYWORDS.yscale,
    height::Union{Integer,Nothing,Symbol} = nothing,
    width::Union{Integer,Nothing,Symbol} = nothing,
    border::Symbol = PLOT_KEYWORDS.border,
    compact::Bool = PLOT_KEYWORDS.compact,
    blend::Bool = PLOT_KEYWORDS.blend,
    xlim = PLOT_KEYWORDS.xlim,
    ylim = PLOT_KEYWORDS.ylim,
    margin::Integer = PLOT_KEYWORDS.margin,
    padding::Integer = PLOT_KEYWORDS.padding,
    labels::Bool = PLOT_KEYWORDS.labels,
    colorbar::Bool = PLOT_KEYWORDS.colorbar,
    colorbar_border::Symbol = PLOT_KEYWORDS.colorbar_border,
    colorbar_lim = PLOT_KEYWORDS.colorbar_lim,
    colormap::Any = PLOT_KEYWORDS.colormap,
    grid::Bool = PLOT_KEYWORDS.grid,
    yticks::Bool = PLOT_KEYWORDS.yticks,
    xticks::Bool = PLOT_KEYWORDS.xticks,
    min_height::Integer = PLOT_KEYWORDS.min_height,
    min_width::Integer = PLOT_KEYWORDS.min_width,
    yflip::Bool = PLOT_KEYWORDS.yflip,
    xflip::Bool = PLOT_KEYWORDS.xflip,
    projection::Union{Nothing,Symbol,MVP} = nothing,
    axes3d = PLOT_KEYWORDS.axes3d,
    canvas_kw = PLOT_KEYWORDS.canvas_kw,
    kw...,
)
    length(xlim) == length(ylim) == 2 ||
        throw(ArgumentError("`xlim` and `ylim` must be tuples or vectors of length 2"))

    x, y, z = validate_input(x, y, z)

    mvp = create_MVP(projection, x, y, z; kw...)

    xlim, ylim = unitless.(xlim), unitless.(ylim)

    (mx, Mx), (my, My) = if is_enabled(mvp)
        (scale_callback(xscale) ≢ identity || scale_callback(yscale) ≢ identity) &&
            throw(ArgumentError("`xscale` or `yscale` are unsupported in 3D"))
        grid = blend = false

        # normalized coordinates, but allow override (artifact for zooming):
        # using `xlim = (-0.5, 0.5)` & `ylim = (-0.5, 0.5)`
        # should be close to using `zoom = 2`.
        autolims(xlim), autolims(ylim)
    else
        extend_limits(x, xlim, xscale), extend_limits(y, ylim, yscale)
    end

    max_width_ylims_labels = 0
    if xticks || yticks
        base_x = xscale isa Symbol ? get(BASES, xscale, nothing) : nothing
        base_y = yscale isa Symbol ? get(BASES, yscale, nothing) : nothing

        m_x, M_x, m_y, M_y =
            nice_repr.((mx, Mx, my, My), Ref(unicode_exponent), Ref(thousands_separator))
        if unicode_exponent
            m_x, M_x = map(v -> base_x ≡ nothing ? v : superscript(v), (m_x, M_x))
            m_y, M_y = map(v -> base_y ≡ nothing ? v : superscript(v), (m_y, M_y))
        end
        if xticks
            base_x_str = base_x ≡ nothing ? "" : base_x * (unicode_exponent ? "" : "^")
            lab_x_bl = base_x_str * (xflip ? M_x : m_x)
            lab_x_br = base_x_str * (xflip ? m_x : M_x)
        end
        if yticks
            base_y_str = base_y ≡ nothing ? "" : base_y * (unicode_exponent ? "" : "^")
            lab_y_lt = base_y_str * (yflip ? M_y : m_y)
            lab_y_lb = base_y_str * (yflip ? m_y : M_y)
            max_width_ylims_labels = max(length(lab_y_lt), length(lab_y_lb))
        end
    end

    height, width = plot_size(;
        max_width_ylims_labels,
        height,
        width,
        title,
        ylabel,
        compact,
        margin,
        padding,
    )

    (visible = width ≥ 0) && (width = max(width, min_width))
    height = max(height, min_height)

    can = canvas(
        height,
        width;
        origin_y = my,
        origin_x = mx,
        height = My - my,
        width = Mx - mx,
        blend,
        visible,
        yscale,
        xscale,
        yflip,
        xflip,
        canvas_kw...,
    )
    plot = Plot(
        can;
        title,
        margin,
        padding,
        border,
        compact,
        labels,
        xlabel,
        ylabel,
        zlabel,
        colormap,
        colorbar,
        colorbar_border,
        colorbar_lim,
        unicode_exponent,
        thousands_separator,
        projection = mvp,
    )
    bc = BORDER_COLOR[]
    if xticks
        label!(plot, :bl, lab_x_bl; color = bc)
        label!(plot, :br, lab_x_br; color = bc)
    end
    if yticks
        label!(plot, :l, nrows(can), lab_y_lt; color = bc)
        label!(plot, :l, 1, lab_y_lb; color = bc)
    end
    if grid && (scale_callback(xscale) ≡ identity && scale_callback(yscale) ≡ identity)
        my < 0 < My && lines!(plot, mx, 0.0, Mx, 0.0)
        mx < 0 < Mx && lines!(plot, 0.0, my, 0.0, My)
    end

    (is_enabled(mvp) && axes3d) && draw_axes!(plot, 0.8 * mx, 0.8 * my, nothing)

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
    loc ∈ (:t, :b, :l, :r, :tl, :tr, :bl, :br) || throw(
        ArgumentError("unknown location $loc: try one of these :tl :t :tr :bl :b :br"),
    )
    if loc ≡ :l || loc ≡ :r
        for row ∈ 1:nrows(plot.graphics)
            if loc ≡ :l
                if !haskey(plot.labels_left, row) || isempty(plot.labels_left[row])
                    plot.labels_left[row] = value
                    plot.colors_left[row] = ansi_color(color)
                    break
                end
            elseif loc ≡ :r
                if !haskey(plot.labels_right, row) || isempty(plot.labels_right[row])
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
    row::Integer,
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
        throw(ArgumentError("unknown location $loc, try `:l` or `:r` instead"))
    end
    plot
end

label!(
    plot::Plot,
    loc::Symbol,
    row::Integer,
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
    text::Union{AbstractChar,AbstractString};
    color = :normal,
    kw...,
)
    color = color ≡ :auto ? next_color!(plot) : color
    annotate!(
        plot.graphics,
        x,
        y,
        text,
        ansi_color(color),
        blend_colors(plot.graphics, color);
        kw...,
    )
    plot
end

transform(tr, args...) = args  # catch all
transform(tr::MVP{Val{false}}, x, y, args...) = (x, y, args...)
transform(tr::MVP{Val{false}}, x, y, ::Nothing, args...) = (x, y, args...)  # drop z
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
