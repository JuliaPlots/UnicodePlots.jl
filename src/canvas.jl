abstract type Canvas <: GraphicsArea end

origin(c::Canvas) = (origin_x(c), origin_y(c))
Base.size(c::Canvas) = (width(c), height(c))
pixel_size(c::Canvas) = (pixel_width(c), pixel_height(c))

function pixel!(c::Canvas, pixel_x::Integer, pixel_y::Integer; color::Union{Int, Symbol} = :normal)
    pixel!(c, pixel_x, pixel_y, color)
end

function points!(c::Canvas, x::Number, y::Number, color::Union{Int, Symbol})
    origin_x(c) <= x <= origin_x(c) + width(c) || return c
    origin_y(c) <= y <= origin_y(c) + height(c) || return c
    plot_offset_x = x - origin_x(c)
    pixel_x = plot_offset_x / width(c) * pixel_width(c)
    plot_offset_y = y - origin_y(c)
    pixel_y = pixel_height(c) - plot_offset_y / height(c) * pixel_height(c)
    pixel!(c, floor(Int, pixel_x), floor(Int, pixel_y), color)
end

function points!(c::Canvas, x::Number, y::Number; color::Union{Int, Symbol} = :normal)
    points!(c, x, y, color)
end

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::Union{Int, Symbol})
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for I in eachindex(X, Y)
        points!(c, X[I], Y[I], color)
    end
    c
end

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::AbstractVector{T}) where {T <: Union{Int, Symbol}}
    (length(X) == length(color) && length(X) == length(Y)) || throw(DimensionMismatch("X, Y, and color must be the same length"))
    for i in 1:length(X)
        points!(c, X[i], Y[i], color[i])
    end
    c
end

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::Union{Int, Symbol} = :normal)
    points!(c, X, Y, color)
end

# Implementation of the digital differential analyser (DDA)
function lines!(c::Canvas, x1::Number, y1::Number, x2::Number, y2::Number, color::Union{Int, Symbol})
    if (x1 < origin_x(c) && x2 < origin_x(c)) ||
        (x1 > origin_x(c) + width(c) && x2 > origin_x(c) + width(c))
        return c
    end
    if (y1 < origin_y(c) && y2 < origin_y(c)) ||
        (y1 > origin_y(c) + height(c) && y2 > origin_y(c) + height(c))
        return c
    end
    toff = x1 - origin_x(c)
    px1 = toff / width(c) * pixel_width(c)
    toff = x2 - origin_x(c)
    px2 = toff / width(c) * pixel_width(c)
    toff = y1 - origin_y(c)
    py1 = pixel_height(c) - toff / height(c) * pixel_height(c)
    toff = y2 - origin_y(c)
    py2 = pixel_height(c) - toff / height(c) * pixel_height(c)
    dx = px2 - px1
    dy = py2 - py1
    nsteps = abs(dx) > abs(dy) ? abs(dx) : abs(dy)
    inc_x = dx / nsteps
    inc_y = dy / nsteps
    cur_x = px1
    cur_y = py1
    fpw = Float64(pixel_width(c))
    fph = Float64(pixel_height(c))
    pixel!(c, floor(Int, cur_x), floor(Int, cur_y), color)
    for i = 1:nsteps
        cur_x += inc_x
        cur_y += inc_y
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), color)
    end
    c
end

function lines!(c::Canvas, x1::Number, y1::Number, x2::Number, y2::Number; color::Union{Int, Symbol} = :normal)
    lines!(c, x1, y1, x2, y2, color)
end

function lines!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::Union{Int, Symbol})
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for i in 1:(length(X)-1)
        lines!(c, X[i], Y[i], X[i+1], Y[i+1], color)
    end
    c
end

function lines!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::Union{Int, Symbol} = :normal)
    lines!(c, X, Y, color)
end


function get_canvas_dimensions_for_matrix(canvas::Type{T}, nrow::Int, ncol::Int, maxwidth::Int, maxheight::Int, width::Int, height::Int, margin::Int, padding::Int; extra_rows::Int = 0, extra_cols::Int = 0) where {T <: Canvas}
    min_canvheight = ceil(Int, nrow / y_pixel_per_char(T))
    min_canvwidth  = ceil(Int, ncol / x_pixel_per_char(T))
    aspect_ratio = min_canvwidth / min_canvheight
    height_diff = extra_rows
    width_diff  = margin + padding + length(string(ncol)) + extra_cols

    term_height, term_width = Base.displaysize()
    maxheight = maxheight > 0 ? maxheight : term_height - height_diff
    maxwidth  = maxwidth > 0 ? maxwidth : term_width - width_diff

    if nrow == 0 && ncol == 0
        return (0, 0, maxwidth, maxheight)
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

    (width, height, maxwidth, maxheight)
end
