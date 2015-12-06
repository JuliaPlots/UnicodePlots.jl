abstract GraphicsArea
abstract Canvas <: GraphicsArea

origin(c::Canvas) = (origin_x(c), origin_y(c))
Base.size(c::Canvas) = (width(c), height(c))
pixel_size(c::Canvas) = (pixel_width(c), pixel_height(c))

function Base.print(io::IO, c::GraphicsArea)
    for row in 1:nrows(c)
        printrow(io, c, row)
        print(io, "\n")
    end
end

function Base.show(io::IO, c::GraphicsArea)
    b = border_dashed
    border_length = ncols(c)
    print_border_top(io, "", border_length, :solid)
    print(io, "\n")
    for row in 1:nrows(c)
        print_with_color(:white, io, b[:l])
        printrow(io, c, row)
        print_with_color(:white, io, b[:r], "\n")
    end
    print_border_bottom(io, "", border_length, :solid)
    print(io, "\n")
end

function pixel!(c::Canvas, pixel_x::Int, pixel_y::Int; color::Symbol = :white)
    pixel!(c, pixel_x, pixel_y, color)
end

function points!(c::Canvas, plot_x::Real, plot_y::Real, color::Symbol)
    origin_x(c) <= plot_x < origin_x(c) + width(c) || return c
    origin_y(c) <= plot_y < origin_y(c) + height(c) || return c
    plot_offset_x = plot_x - origin_x(c)
    pixel_x = plot_offset_x / width(c) * pixel_width(c)
    plot_offset_y = plot_y - origin_y(c)
    pixel_y = pixel_height(c) - plot_offset_y / height(c) * pixel_height(c)
    pixel!(c, floor(Int, pixel_x), floor(Int, pixel_y), color)
end

function points!(c::Canvas, plot_x::Real, plot_y::Real; color::Symbol = :white)
    points!(c, plot_x, plot_y, color)
end

function points!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}, color::Symbol)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for i in 1:length(X)
        points!(c, X[i], Y[i], color)
    end
    c
end

function points!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}; color::Symbol = :white)
    points!(c, X, Y, color)
end

# Implementation of the digital differential analyser (DDA)
function lines!(c::Canvas, x1::Real, y1::Real, x2::Real, y2::Real, color::Symbol)
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
    nsteps = abs(dx) > abs(dy) ? abs(dx): abs(dy)
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

function lines!(c::Canvas, x1::Real, y1::Real, x2::Real, y2::Real; color::Symbol = :white)
    lines!(c, x1, y1, x2, y2, color)
end

function lines!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}, color::Symbol)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for i in 1:(length(X)-1)
        lines!(c, X[i], Y[i], X[i+1], Y[i+1], color)
    end
    c
end

function lines!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}; color::Symbol = :white)
    lines!(c, X, Y, color)
end
