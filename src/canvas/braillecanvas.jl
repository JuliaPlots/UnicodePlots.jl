const braille_signs = ['⠁' '⠂' '⠄' '⡀';
                       '⠈' '⠐' '⠠' '⢀']

"""
The type of canvas with the highest resolution
for Unicode-based plotting.
It uses the Unicode characters for
the Braille symbols to represent individual pixel.
This effectively turns every character into 8 pixels
that can individually be manipulated using binary operations.
"""
struct BrailleCanvas <: Canvas
    grid::Array{Char,2}
    colors::Array{UInt8,2}
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
end

@inline pixel_width(c::BrailleCanvas) = c.pixel_width
@inline pixel_height(c::BrailleCanvas) = c.pixel_height
@inline origin_x(c::BrailleCanvas) = c.origin_x
@inline origin_y(c::BrailleCanvas) = c.origin_y
@inline width(c::BrailleCanvas) = c.width
@inline height(c::BrailleCanvas) = c.height
@inline nrows(c::BrailleCanvas) = size(c.grid, 2)
@inline ncols(c::BrailleCanvas) = size(c.grid, 1)

@inline x_pixel_per_char(::Type{BrailleCanvas}) = 2
@inline y_pixel_per_char(::Type{BrailleCanvas}) = 4

function BrailleCanvas(char_width::Int, char_height::Int;
                       origin_x::Number = 0.,
                       origin_y::Number = 0.,
                       width::Number  = 1.,
                       height::Number = 1.)
    width > 0 || throw(ArgumentError("width has to be positive"))
    height > 0 || throw(ArgumentError("height has to be positive"))
    char_width = max(char_width, 5)
    char_height = max(char_height, 2)
    pixel_width = char_width * x_pixel_per_char(BrailleCanvas)
    pixel_height = char_height * y_pixel_per_char(BrailleCanvas)
    grid = fill(Char(0x2800), char_width, char_height)
    colors = fill(0x00, char_width, char_height)
    BrailleCanvas(grid, colors,
                  pixel_width, pixel_height,
                  Float64(origin_x), Float64(origin_y),
                  Float64(width), Float64(height))
end

function pixel!(c::BrailleCanvas, pixel_x::Int, pixel_y::Int, color::Symbol)
    0 <= pixel_x <= c.pixel_width  || return c
    0 <= pixel_y <= c.pixel_height || return c
    pixel_x = pixel_x < c.pixel_width ? pixel_x : pixel_x - 1
    pixel_y = pixel_y < c.pixel_height ? pixel_y : pixel_y - 1
    cw, ch = size(c.grid)
    tmp = pixel_x / c.pixel_width * cw
    char_x = floor(Int, tmp) + 1
    char_x_off = (pixel_x % 2) + 1
    if char_x < round(Int, tmp, RoundNearestTiesUp) + 1 && char_x_off == 1
        char_x = char_x + 1
    end
    char_y = floor(Int, pixel_y / c.pixel_height * ch) + 1
    char_y_off = (pixel_y % 4) + 1
    c.grid[char_x,char_y] = Char(UInt64(c.grid[char_x,char_y]) | UInt64(braille_signs[char_x_off, char_y_off]))
    c.colors[char_x,char_y] = c.colors[char_x,char_y] | color_encode[color]
    c
end

function printrow(io::IO, c::BrailleCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_color(c.colors[x,y], io, c.grid[x,y])
    end
end
