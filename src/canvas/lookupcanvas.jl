abstract type LookupCanvas <: Canvas end

function lookup_encode end
function lookup_decode end

@inline pixel_width(c::LookupCanvas) = c.pixel_width
@inline pixel_height(c::LookupCanvas) = c.pixel_height
@inline origin_x(c::LookupCanvas) = c.origin_x
@inline origin_y(c::LookupCanvas) = c.origin_y
@inline width(c::LookupCanvas) = c.width
@inline height(c::LookupCanvas) = c.height
@inline grid(c::LookupCanvas) = c.grid
@inline colors(c::LookupCanvas) = c.colors
@inline nrows(c::LookupCanvas) = size(grid(c), 2)
@inline ncols(c::LookupCanvas) = size(grid(c), 1)

function CreateLookupCanvas(
        ::Type{T},
        char_width::Int,
        char_height::Int;
        origin_x::Number = 0.,
        origin_y::Number = 0.,
        width::Number = 1.,
        height::Number = 1.) where {T <: LookupCanvas}
    width  > 0 || throw(ArgumentError("width has to be positive"))
    height > 0 || throw(ArgumentError("height has to be positive"))
    char_width  = max(char_width, 5)
    char_height = max(char_height, 2)
    pixel_width  = char_width * x_pixel_per_char(T)
    pixel_height = char_height * y_pixel_per_char(T)
    grid   = fill(0x00, char_width, char_height)
    colors = fill(0x00, char_width, char_height)
    T(grid, colors, pixel_width, pixel_height,
      Float64(origin_x), Float64(origin_y),
      Float64(width), Float64(height))
end

function pixel!(c::T, pixel_x::Int, pixel_y::Int, color::Symbol) where {T <: LookupCanvas}
    0 <= pixel_x <= pixel_width(c) || return c
    0 <= pixel_y <= pixel_height(c) || return c
    pixel_x = pixel_x < pixel_width(c) ? pixel_x : pixel_x - 1
    pixel_y = pixel_y < pixel_height(c) ? pixel_y : pixel_y - 1
    cw, ch = size(grid(c))
    tmp = pixel_x / pixel_width(c) * cw
    char_x = floor(Int, tmp) + 1
    char_x_off = (pixel_x % x_pixel_per_char(T)) + 1
    if char_x < round(Int, tmp, RoundNearestTiesUp) + 1 && char_x_off == 1
        char_x = char_x + 1
    end
    char_y = floor(Int, pixel_y / pixel_height(c) * ch) + 1
    char_y_off = (pixel_y % y_pixel_per_char(T)) + 1
    grid(c)[char_x, char_y] = grid(c)[char_x,char_y] | lookup_encode(c)[char_x_off, char_y_off]
    colors(c)[char_x, char_y] = colors(c)[char_x,char_y] | color_encode[color]
    c
end

function printrow(io::IO, c::LookupCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_color(colors(c)[x,y], io, lookup_decode(c)[grid(c)[x,y] + 1])
    end
end
