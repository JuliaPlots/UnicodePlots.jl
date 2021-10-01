abstract type Canvas <: GraphicsArea end

origin(c::Canvas) = (origin_x(c), origin_y(c))
Base.size(c::Canvas) = (width(c), height(c))
pixel_size(c::Canvas) = (pixel_width(c), pixel_height(c))

pixel!(
    c::Canvas, pixel_x::Integer, pixel_y::Integer; color::UserColorType = :normal
) = pixel!(c, pixel_x, pixel_y, color)

function points!(c::Canvas, x::Number, y::Number, color::UserColorType)
    origin_x(c) <= (xs = fscale(x, c.xscale)) <= origin_x(c) + width(c) || return c
    origin_y(c) <= (ys = fscale(y, c.yscale)) <= origin_y(c) + height(c) || return c
    pixel_x = (xs - origin_x(c)) / width(c) * pixel_width(c)
    pixel_y = pixel_height(c) - (ys - origin_y(c)) / height(c) * pixel_height(c)
    pixel!(c, floor(Int, pixel_x), floor(Int, pixel_y), color)
end

points!(c::Canvas, x::Number, y::Number; color::UserColorType = :normal) = points!(c, x, y, color)

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    @inbounds for I in eachindex(X, Y)
        points!(c, X[I], Y[I], color)
    end
    c
end

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::AbstractVector{T}) where {T <: UserColorType}
    (length(X) == length(color) && length(X) == length(Y)) || throw(
        DimensionMismatch("X, Y, and color must be the same length")
    )
    @inbounds for i in 1:length(X)
        points!(c, X[i], Y[i], color[i])
    end
    c
end

points!(
    c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal
) = points!(c, X, Y, color)

# Implementation of the digital differential analyser (DDA)
function lines!(c::Canvas, x1::Number, y1::Number, x2::Number, y2::Number, color::UserColorType)
    x1 = fscale(x1, c.xscale)
    x2 = fscale(x2, c.xscale)
    y1 = fscale(y1, c.yscale)
    y2 = fscale(y2, c.yscale)

    mx = origin_x(c)
    Mx = origin_x(c) + width(c)
    (x1 < mx && x2 < mx) || (x1 > Mx && x2 > Mx) && return c

    my = origin_y(c)
    My = origin_y(c) + height(c)
    (y1 < my && y2 < my) || (y1 > My && y2 > My) && return c

    x2p(x) = (x - mx) / width(c) * pixel_width(c)
    y2p(y) = pixel_height(c) - (y - my) / height(c) * pixel_height(c)

    Δx = x2p(x2) - (cur_x = x2p(x1))
    Δy = y2p(y2) - (cur_y = y2p(y1))

    nsteps = abs(Δx) > abs(Δy) ? abs(Δx) : abs(Δy)
    nsteps = min(nsteps, typemax(Int32))  # hard limit

    δx = Δx / nsteps
    δy = Δy / nsteps

    px, Px = extrema([x2p(mx), x2p(Mx)])
    py, Py = extrema([y2p(my), y2p(My)])

    pixel!(c, floor(Int, cur_x), floor(Int, cur_y), color)
    max_num_iter = typemax(Int16)  # performance limit
    for _ = if nsteps > max_num_iter
        range(1, stop=nsteps, length=max_num_iter)
    else
        range(1, stop=nsteps, step=1)
    end
        cur_x += δx
        cur_y += δy
        (cur_y < py || cur_y > Py) && continue
        (cur_x < px || cur_x > Px) && continue
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), color)
    end
    c
end

lines!(
    c::Canvas, x1::Number, y1::Number, x2::Number, y2::Number; color::UserColorType = :normal
) = lines!(c, x1, y1, x2, y2, color)

function lines!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    @inbounds for i in 1:(length(X)-1)
        if !(isfinite(X[i]) && isfinite(X[i+1]) && isfinite(Y[i]) && isfinite(Y[i+1]))
            continue
        end
        lines!(c, X[i], Y[i], X[i+1], Y[i+1], color)
    end
    c
end

lines!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) = lines!(c, X, Y, color)

function get_canvas_dimensions_for_matrix(
    canvas::Type{T}, nrow::Int, ncol::Int, maxwidth::Int, maxheight::Int,
    width::Int, height::Int, margin::Int, padding::Int, out_stream::Union{Nothing,IO};
    extra_rows::Int = 0, extra_cols::Int = 0
) where {T <: Canvas}
    min_canvheight = ceil(Int, nrow / y_pixel_per_char(T))
    min_canvwidth  = ceil(Int, ncol / x_pixel_per_char(T))
    aspect_ratio = min_canvwidth / min_canvheight
    height_diff = extra_rows
    width_diff  = margin + padding + length(string(ncol)) + extra_cols

    term_height, term_width = out_stream === nothing ? displaysize() : displaysize(out_stream)
    maxheight = maxheight > 0 ? maxheight : term_height - height_diff
    maxwidth  = maxwidth > 0 ? maxwidth : term_width - width_diff

    if nrow == 0 && ncol == 0
        return 0, 0, maxwidth, maxheight
    end

    # Check if the size of the plot should be derived from the matrix
    # Note: if both width and height are 0, it means that there are no
    #       constraints and the plot should resemble the structure of
    #       the matrix as close as possible
    if width == 0 && height == 0
        # If the interactive code did not take care of this then try
        # to plot the matrix in the correct aspect ratio (within specified bounds)
        if min_canvheight > min_canvwidth
            # long matrix (according to pixel density)
            height = min_canvheight
            width  = height * aspect_ratio
            if width > maxwidth
                width  = maxwidth
                height = width / aspect_ratio
            end
            if height > maxheight
                height = maxheight
                width  = min(height * aspect_ratio, maxwidth)
            end
        else
            # wide matrix
            width  = min_canvwidth
            height = width / aspect_ratio
            if height > maxheight
                height = maxheight
                width  = height * aspect_ratio
            end
            if width > maxwidth
                width = maxwidth
                height = min(width / aspect_ratio, maxheight)
            end
        end
    end
    if width == 0 && height > 0
        width  = min(height * aspect_ratio, maxwidth)
    elseif width > 0 && height == 0
        height = min(width / aspect_ratio, maxheight)
    end
    width  = round(Int, width)
    height = round(Int, height)

    width, height, maxwidth, maxheight
end


function align_char_point(text::AbstractString, char_x::Integer, char_y::Integer, halign::Symbol, valign::Symbol)
    nchar = length(text)
    char_x = if halign in (:center, :hcenter)
        char_x - nchar ÷ 2
    elseif halign == :left
        char_x
    elseif halign == :right
        char_x - (nchar - 1)
    else
        error("Argument `halign=$halign` not supported.")
    end
    char_y = if valign in (:center, :vcenter)
        char_y
    elseif valign == :top
        char_y + 1
    elseif valign == :bottom
        char_y - 1
    else
        error("Argument `valign=$valign` not supported.")
    end
    char_x, char_y
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
    xs = fscale(x, c.xscale)
    ys = fscale(y, c.yscale)
    pixel_x = (xs - origin_x(c)) / width(c) * pixel_width(c)
    pixel_y = pixel_height(c) - (ys - origin_y(c)) / height(c) * pixel_height(c)

    char_x, char_y = pixel_to_char_point(c, pixel_x, pixel_y)
    char_x, char_y = align_char_point(text, char_x, char_y, halign, valign)
    for char in text
        char_point!(c, char_x, char_y, char, color)
        char_x += 1
    end
    c
end

function annotate!(
    c::Canvas,
    x::Number,
    y::Number,
    text::Char,
    color::UserColorType
  )
    xs = fscale(x, c.xscale)
    ys = fscale(y, c.yscale)
    pixel_x = (xs - origin_x(c)) / width(c) * pixel_width(c)
    pixel_y = pixel_height(c) - (ys - origin_y(c)) / height(c) * pixel_height(c)

    char_x, char_y = pixel_to_char_point(c, pixel_x, pixel_y)
    char_point!(c, char_x, char_y, text, color)
    c
end
