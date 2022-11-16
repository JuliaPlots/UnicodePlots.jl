abstract type Canvas <: GraphicsArea end

grid_type(T::Type{<:Canvas}) = fieldtypes(T) |> first |> eltype
grid_type(c::Canvas) = grid_type(typeof(c))

# we store the grid as the transpose of an array of (w, h) => (height, width) = (nrows, ncols)
@inline nrows(c::Canvas) = size(c.grid, 1)
@inline ncols(c::Canvas) = size(c.grid, 2)

@inline lookup_offset(c::Canvas) = grid_type(c)(0)
@inline pixel_height(c::Canvas)::Int = c.pixel_height
@inline pixel_width(c::Canvas)::Int = c.pixel_width
@inline origin_y(c::Canvas)::Float64 = c.origin_y
@inline origin_x(c::Canvas)::Float64 = c.origin_x
@inline height(c::Canvas)::Float64 = c.height
@inline width(c::Canvas)::Float64 = c.width
@inline blend(c::Canvas, _)::Bool = c.blend

@inline y_to_pixel(c::Canvas, y::Number) = if c.yflip
    (y - origin_y(c)) / height(c) * pixel_height(c)
else
    (1 - (y - origin_y(c)) / height(c)) * pixel_height(c)
end::Float64
@inline x_to_pixel(c::Canvas, x::Number) = if c.xflip
    (1 - (x - origin_x(c)) / width(c)) * pixel_width(c)
else
    (x - origin_x(c)) / width(c) * pixel_width(c)
end::Float64

@inline scale_y_to_pixel(c::Canvas, y::Number) = y_to_pixel(c, c.yscale(y))
@inline scale_x_to_pixel(c::Canvas, x::Number) = x_to_pixel(c, c.xscale(x))

@inline valid_y(c::Canvas, y::Number) = origin_y(c) ≤ c.yscale(y) ≤ origin_y(c) + height(c)
@inline valid_x(c::Canvas, x::Number) = origin_x(c) ≤ c.xscale(x) ≤ origin_x(c) + width(c)

@inline valid_y_pixel(c::Canvas, pixel_y::Integer) = 0 ≤ pixel_y ≤ pixel_height(c)  # NOTE: relaxed upper bound [ref(1)]
@inline valid_x_pixel(c::Canvas, pixel_x::Integer) = 0 ≤ pixel_x ≤ pixel_width(c)

function char_point!(
    c::Canvas,
    char_x::Integer,
    char_y::Integer,
    char::AbstractChar,
    color::UserColorType,
    blend::Bool,
)
    if checkbounds(Bool, c.grid, char_y, char_x)
        c.grid[char_y, char_x] = lookup_offset(c) + grid_type(c)(char)
        set_color!(c, char_x, char_y, ansi_color(color), blend)
    end
    c
end

@inline function set_color!(
    c::Canvas,
    x::Integer,
    y::Integer,
    color::ColorType,
    blend::Bool,
)
    col::ColorType = c.colors[y, x]
    c.colors[y, x] = if col ≡ INVALID_COLOR || !blend
        color
    else
        blend_colors(col, color)
    end::ColorType
    nothing
end

"""
    pixel_size(c::Canvas)

Canvas pixel resolution (height, width).
"""
pixel_size(c::Canvas) = (pixel_height(c), pixel_width(c))
Base.size(c::Canvas) = (height(c), width(c))
origin(c::Canvas) = (origin_x(c), origin_y(c))

points!(c::Canvas, x::Number, y::Number, color::ColorType, blend::Bool) = pixel!(
    c,
    floor(Int, scale_x_to_pixel(c, x)),
    floor(Int, scale_y_to_pixel(c, y)),
    color,
    blend,
)

pixel!(c::Canvas, pixel_x::Integer, pixel_y::Integer; color::UserColorType = :normal) =
    pixel!(c, pixel_x, pixel_y, ansi_color(color), blend(c, color))

points!(c::Canvas, x::Number, y::Number; color::UserColorType = :normal) =
    points!(c, x, y, ansi_color(color), blend(c, color))

points!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) =
    points!(c, X, Y, color)

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) ||
        throw(DimensionMismatch("`X` and `Y` must be the same length"))
    bl = blend(c, color)
    col = ansi_color(color)
    @inbounds for I ∈ eachindex(X, Y)
        points!(c, X[I], Y[I], col, bl)
    end
    c
end

function points!(
    c::Canvas,
    X::AbstractVector,
    Y::AbstractVector,
    color::AbstractVector{T},
) where {T<:UserColorType}
    length(X) == length(Y) == length(color) ||
        throw(DimensionMismatch("`X`, `Y` and `color` must be the same length"))
    @inbounds for I ∈ eachindex(X)
        col = color[I]
        points!(c, X[I], Y[I], ansi_color(col), blend(c, col))  # slowish
    end
    c
end

# Implementation of the digital differential analyser (DDA)
function lines!(
    c::Canvas,
    x1::Number,
    y1::Number,
    x2::Number,
    y2::Number,
    c_or_v1::Union{AbstractFloat,UserColorType},  # either floating point values or colors
    c_or_v2::Union{AbstractFloat,UserColorType} = nothing,
    col_cb::Union{Nothing,Function} = nothing,  # color callback (map values to colors)
)
    (valid_x(c, x1) || valid_x(c, x2)) || return c
    (valid_y(c, y1) || valid_y(c, y2)) || return c

    Δx = scale_x_to_pixel(c, x2) - (cur_x = scale_x_to_pixel(c, x1))
    Δy = scale_y_to_pixel(c, y2) - (cur_y = scale_y_to_pixel(c, y1))

    nsteps = min(max(abs(Δx), abs(Δy)), typemax(Int32))  # hard limit
    len = min(floor(Int, nsteps), typemax(Int16))  # performance limit

    δx = Δx / nsteps
    δy = Δy / nsteps

    px, Px = x_to_pixel(c, origin_x(c)), x_to_pixel(c, origin_x(c) + width(c))
    py, Py = y_to_pixel(c, origin_y(c)), y_to_pixel(c, origin_y(c) + height(c))
    px, Px = min(px, Px), max(px, Px)
    py, Py = min(py, Py), max(py, Py)
    bl = blend(c, c_or_v1)

    if c_or_v1 isa AbstractFloat && c_or_v2 isa AbstractFloat && col_cb ≢ nothing
        # color interpolation
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), col_cb(c_or_v1), bl)
        start_x, start_y = cur_x, cur_y
        iΔ = 1 / √(Δx^2 + Δy^2)
        for _ ∈ range(1, length = len)
            cur_x += δx
            cur_y += δy
            (cur_y < py || cur_y > Py) && continue
            (cur_x < px || cur_x > Px) && continue
            weight = √((cur_x - start_x)^2 + (cur_y - start_y)^2) * iΔ
            pixel!(
                c,
                floor(Int, cur_x),
                floor(Int, cur_y),
                col_cb((1 - weight) * c_or_v1 + weight * c_or_v2),
                bl,
            )
        end
    else
        color = ansi_color(c_or_v1)  # hoisted out of the loop for performance
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), color, bl)
        for _ ∈ range(1, length = len)
            cur_x += δx
            cur_y += δy
            (cur_y < py || cur_y > Py) && continue
            (cur_x < px || cur_x > Px) && continue
            pixel!(c, floor(Int, cur_x), floor(Int, cur_y), color, bl)
        end
    end
    c
end

lines!(
    c::Canvas,
    x1::Number,
    y1::Number,
    x2::Number,
    y2::Number;
    color::UserColorType = :normal,
) = lines!(c, x1, y1, x2, y2, color)

function lines!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) ||
        throw(DimensionMismatch("`X` and `Y` must be the same length"))
    for i ∈ 2:length(X)
        (x = X[i]) |> isfinite || continue
        (y = Y[i]) |> isfinite || continue
        (xm1 = X[i - 1]) |> isfinite || continue
        (ym1 = Y[i - 1]) |> isfinite || continue
        lines!(c, xm1, ym1, x, y, color)
    end
    c
end

lines!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) =
    lines!(c, X, Y, color)

function get_canvas_dimensions_for_matrix(
    canvas::Type{T},
    nrow::Integer,
    ncol::Integer,
    max_height::Integer,
    max_width::Integer,
    height::Union{Nothing,Integer},
    width::Union{Nothing,Integer},
    margin::Integer,
    padding::Integer,
    out_stream::Union{Nothing,IO},
    fix_ar::Bool;
    extra_rows = 0,
    extra_cols = 0,
) where {T<:Canvas}
    canv_height = nrow / y_pixel_per_char(T)
    canv_width  = ncol / x_pixel_per_char(T)
    # e.g. heatmap(collect(1:2) * collect(1:2)') with nrow = 2, ncol = 2
    # on a HeatmapCanvas, x_pixel_per_char = 1 and y_pixel_per_char = 2
    # hence the canvas aspect ratio (canv_ar) is 2
    canv_ar = canv_width / canv_height

    # min_canv_height := minimal number of y canvas characters
    # (holding y_pixel_per_char pixels) to represent the input data
    min_canv_height = ceil(Int, canv_height)
    min_canv_width  = ceil(Int, canv_width)

    height_diff = extra_rows
    width_diff  = margin + padding + length(string(ncol)) + extra_cols

    term_height, term_width = out_stream_size(out_stream)
    max_height = max_height > 0 ? max_height : term_height - height_diff
    max_width = max_width > 0 ? max_width : term_width - width_diff

    (nrow == 0 && ncol == 0) && return 0, 0, max_width, max_height

    # Check if the size of the plot should be derived from the matrix
    # Note: if both width and height are 0, it means that there are no
    #       constraints and the plot should resemble the structure of
    #       the matrix as close as possible
    if width ≡ nothing && height ≡ nothing
        # If the interactive code did not take care of this then try
        # to plot the matrix in the correct aspect ratio (within specified bounds)
        if min_canv_height > min_canv_width
            # long matrix (according to pixel density)
            width  = min(min_canv_height * canv_ar, max_width)
            height = min(width / canv_ar, max_height)
            width  = min(height * canv_ar, max_width)
        else
            # wide matrix
            height = min(min_canv_width / canv_ar, max_height)
            width  = min(height * canv_ar, max_width)
            height = min(width / canv_ar, max_height)
        end
    end

    if width ≡ nothing && height > 0
        width = min(height * canv_ar, max_width)
    elseif height ≡ nothing && width > 0
        height = min(width / canv_ar, max_height)
    end

    height = round(Int, height / (fix_ar ? ASPECT_RATIO[] : 1))  # optional terminal aspect ratio (4:3) correction
    width  = round(Int, width)

    # the canvas will target a (height, width) grid to represent the input data
    height, width, max_height, max_width
end

function align_char_point(
    text::AbstractString,
    char_x::Integer,
    char_y::Integer,
    halign::Symbol,
    valign::Symbol,
)
    nchar = length(text)
    char_x = if halign ∈ (:center, :hcenter)
        char_x - nchar ÷ 2
    elseif halign ≡ :left
        char_x
    elseif halign ≡ :right
        char_x - (nchar - 1)
    else
        throw(ArgumentError("`halign=$halign` not supported"))
    end
    char_y = if valign ∈ (:center, :vcenter)
        char_y
    elseif valign ≡ :top
        char_y + 1
    elseif valign ≡ :bottom
        char_y - 1
    else
        throw(ArgumentError("`valign=$valign` not supported"))
    end
    char_x, char_y
end

function pixel_to_char_point(c::C, pixel_x::Number, pixel_y::Number) where {C<:Canvas}
    # when hitting boundaries with canvases capable of encoding more than 1 pixel per char (see ref(1))
    pixel_x ≥ pixel_width(c) && (pixel_x += c.xflip ? 1 : -1)
    pixel_y ≥ pixel_height(c) && (pixel_y += c.yflip ? 1 : -1)
    (
        floor(Int, pixel_x / x_pixel_per_char(C)) + 1,
        floor(Int, pixel_y / y_pixel_per_char(C)) + 1,
    )
end

function pixel_to_char_point_off(c::C, pixel_x::Number, pixel_y::Number) where {C<:Canvas}
    pixel_x ≥ pixel_width(c) && (pixel_x += c.xflip ? 1 : -1)
    pixel_y ≥ pixel_height(c) && (pixel_y += c.yflip ? 1 : -1)
    qx, rx = divrem(pixel_x, x_pixel_per_char(C))
    qy, ry = divrem(pixel_y, y_pixel_per_char(C))
    (Int(qx) + 1, Int(qy) + 1, Int(rx) + 1, Int(ry) + 1)
end

function annotate!(
    c::Canvas,
    x::Number,
    y::Number,
    text::AbstractString,
    color::UserColorType,
    blend::Bool;
    halign::Symbol = :center,
    valign::Symbol = :center,
)
    valid_x(c, x) || return c
    valid_y(c, y) || return c

    char_x, char_y = pixel_to_char_point(c, scale_x_to_pixel(c, x), scale_y_to_pixel(c, y))
    char_x, char_y = align_char_point(text, char_x, char_y, halign, valign)
    for char ∈ text
        char_point!(c, char_x, char_y, char, color, blend)
        char_x += 1
    end
    c
end

function annotate!(
    c::Canvas,
    x::Number,
    y::Number,
    text::AbstractChar,
    color::UserColorType,
    blend::Bool,
)
    valid_x(c, x) || return c
    valid_y(c, y) || return c

    char_x, char_y = pixel_to_char_point(c, scale_x_to_pixel(c, x), scale_y_to_pixel(c, y))
    char_point!(c, char_x, char_y, text, color, blend)
    c
end
