abstract type Canvas <: GraphicsArea end

@inline nrows(c::Canvas) = size(c.grid, 2)
@inline ncols(c::Canvas) = size(c.grid, 1)
@inline pixel_height(c::Canvas) = c.pixel_height
@inline pixel_width(c::Canvas) = c.pixel_width
@inline origin_x(c::Canvas) = c.origin_x
@inline origin_y(c::Canvas) = c.origin_y
@inline height(c::Canvas) = c.height
@inline width(c::Canvas) = c.width

@inline scale_x_to_pixel(c::Canvas, x::Number) = x_to_pixel(c, c.xscale(x))
@inline scale_y_to_pixel(c::Canvas, y::Number) = y_to_pixel(c, c.yscale(y))

@inline x_to_pixel(c::Canvas, x::Number) = (x - origin_x(c)) / width(c) * pixel_width(c)
@inline y_to_pixel(c::Canvas, y::Number) =
    (1 - (y - origin_y(c)) / height(c)) * pixel_height(c)

@inline valid_x(c::Canvas, x::Number) = origin_x(c) ≤ c.xscale(x) ≤ origin_x(c) + width(c)
@inline valid_y(c::Canvas, y::Number) = origin_y(c) ≤ c.yscale(y) ≤ origin_y(c) + height(c)

@inline valid_x_pixel(c::Canvas, pixel_x::Integer) = 0 ≤ pixel_x ≤ pixel_width(c)  # NOTE: relaxed upper bound for |=
@inline valid_y_pixel(c::Canvas, pixel_y::Integer) = 0 ≤ pixel_y ≤ pixel_height(c)

"""
    pixel_size(c::Canvas)

Canvas pixel resolution.
"""
pixel_size(c::Canvas) = (pixel_width(c), pixel_height(c))
origin(c::Canvas) = (origin_x(c), origin_y(c))
Base.size(c::Canvas) = (width(c), height(c))

pixel!(c::Canvas, pixel_x::Integer, pixel_y::Integer; color::UserColorType = :normal) =
    pixel!(c, pixel_x, pixel_y, color)

points!(c::Canvas, x::Number, y::Number; color::UserColorType = :normal) =
    points!(c, x, y, color)

points!(c::Canvas, x::Number, y::Number, color::UserColorType) =
    pixel!(c, floor(Int, scale_x_to_pixel(c, x)), floor(Int, scale_y_to_pixel(c, y)), color)

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for I in eachindex(X, Y)
        points!(c, X[I], Y[I], color)
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
        throw(DimensionMismatch("X, Y, and color must be the same length"))
    for i in eachindex(X)
        points!(c, X[i], Y[i], color[i])
    end
    c
end

points!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) =
    points!(c, X, Y, color)

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

    if c_or_v1 isa AbstractFloat && c_or_v2 isa AbstractFloat && col_cb ≢ nothing
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), col_cb(c_or_v1))
        start_x, start_y = cur_x, cur_y
        iΔ = 1 / √(Δx^2 + Δy^2)
        for _ in range(1, length = len)
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
            )
        end
    else
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), c_or_v1)
        for _ in range(1, length = len)
            cur_x += δx
            cur_y += δy
            (cur_y < py || cur_y > Py) && continue
            (cur_x < px || cur_x > Px) && continue
            pixel!(c, floor(Int, cur_x), floor(Int, cur_y), c_or_v1)
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
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for i in 2:length(X)
        isfinite(X[i - 1]) || continue
        isfinite(Y[i - 1]) || continue
        isfinite(X[i]) || continue
        isfinite(Y[i]) || continue
        lines!(c, X[i - 1], Y[i - 1], X[i], Y[i], color)
    end
    c
end

lines!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) =
    lines!(c, X, Y, color)

function get_canvas_dimensions_for_matrix(
    canvas::Type{T},
    nrow::Int,
    ncol::Int,
    max_width::Int,
    max_height::Int,
    width::Int,
    height::Int,
    margin::Int,
    padding::Int,
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

    if nrow == 0 && ncol == 0
        return 0, 0, max_width, max_height
    end

    # Check if the size of the plot should be derived from the matrix
    # Note: if both width and height are 0, it means that there are no
    #       constraints and the plot should resemble the structure of
    #       the matrix as close as possible
    if width == 0 && height == 0
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

    if width == 0 && height > 0
        width = min(height * canv_ar, max_width)
    elseif width > 0 && height == 0
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
    char_x = if halign in (:center, :hcenter)
        char_x - nchar ÷ 2
    elseif halign ≡ :left
        char_x
    elseif halign ≡ :right
        char_x - (nchar - 1)
    else
        error("Argument `halign=$halign` not supported.")
    end
    char_y = if valign in (:center, :vcenter)
        char_y
    elseif valign ≡ :top
        char_y + 1
    elseif valign ≡ :bottom
        char_y - 1
    else
        error("Argument `valign=$valign` not supported.")
    end
    char_x, char_y
end

function pixel_to_char_point(c::C, pixel_x::Number, pixel_y::Number) where {C<:Canvas}
    # when hitting right boundary with canvases capable of encoding more than 1 pixel per char
    pixel_x ≥ pixel_width(c) && (pixel_x -= 1)
    pixel_y ≥ pixel_height(c) && (pixel_y -= 1)
    (
        floor(Int, pixel_x / x_pixel_per_char(C)) + 1,
        floor(Int, pixel_y / y_pixel_per_char(C)) + 1,
    )
end

function pixel_to_char_point_off(c::C, pixel_x::Number, pixel_y::Number) where {C<:Canvas}
    pixel_x ≥ pixel_width(c) && (pixel_x -= 1)
    pixel_y ≥ pixel_height(c) && (pixel_y -= 1)
    (
        floor(Int, pixel_x / x_pixel_per_char(C)) + 1,
        floor(Int, pixel_y / y_pixel_per_char(C)) + 1,
        floor(Int, pixel_x % x_pixel_per_char(C)) + 1,
        floor(Int, pixel_y % y_pixel_per_char(C)) + 1,
    )
end

function annotate!(
    c::Canvas,
    x::Number,
    y::Number,
    text::AbstractString,
    color::UserColorType;
    halign = :center,
    valign = :center,
)
    valid_x(c, x) || return c
    valid_y(c, y) || return c

    char_x, char_y = pixel_to_char_point(c, scale_x_to_pixel(c, x), scale_y_to_pixel(c, y))
    char_x, char_y = align_char_point(text, char_x, char_y, halign, valign)
    for char in text
        char_point!(c, char_x, char_y, char, color)
        char_x += 1
    end
    c
end

function annotate!(c::Canvas, x::Number, y::Number, text::Char, color::UserColorType)
    valid_x(c, x) || return c
    valid_y(c, y) || return c

    char_x, char_y = pixel_to_char_point(c, scale_x_to_pixel(c, x), scale_y_to_pixel(c, y))
    char_point!(c, char_x, char_y, text, color)
    c
end

function print_colorbar_row(
    io::IO,
    print_nc,
    print_col,
    c::Canvas,
    row::Int,
    colormap::Function,
    border::Symbol,
    lim,
    lim_str,
    plot_padding,
    zlabel,
    max_len,
    blank::Char,
)
    b = BORDERMAP[border]
    bc = BORDER_COLOR[]
    min_z, max_z = lim
    label = ""
    if row == 1
        label = lim_str[2]
        # print top border and maximum z value
        print_col(io, bc, b[:tl], b[:t], b[:t], b[:tr])
        print_nc(io, plot_padding)
        print_col(io, bc, label)
    elseif row == nrows(c)
        label = lim_str[1]
        # print bottom border and minimum z value
        print_col(io, bc, b[:bl], b[:b], b[:b], b[:br])
        print_nc(io, plot_padding)
        print_col(io, bc, label)
    else
        # print gradient
        print_col(io, bc, b[:l])
        if min_z == max_z  # if min and max are the same, single color
            fgcol = bgcol = colormap(1, 1, 1)
        else  # otherwise, blend from min to max
            n = 2(nrows(c) - 2)
            r = row - 2
            fgcol = colormap(n - 2r - 1, 1, n)
            bgcol = colormap(n - 2r, 1, n)
        end
        print_col(io, fgcol, HALF_BLOCK, HALF_BLOCK; bgcol = bgcol)
        print_col(io, bc, b[:r])
        print_nc(io, plot_padding)
        # print z label
        if row == div(nrows(c), 2) + 1
            label = zlabel
            print_nc(io, label)
        end
    end
    print_nc(io, repeat(blank, max_len - length(label)))
    nothing
end
