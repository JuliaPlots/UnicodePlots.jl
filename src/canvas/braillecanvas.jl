const BRAILLE_SIGNS = [
    '⠁' '⠂' '⠄' '⡀'
    '⠈' '⠐' '⠠' '⢀'
]

"""
The type of canvas with the highest resolution for Unicode-based plotting.
It uses the Unicode characters for the Braille symbols to represent individual pixel.
This effectively turns every character into 8 pixels that can individually be manipulated using binary operations.
"""
struct BrailleCanvas{XS<:Function,YS<:Function} <: Canvas
    grid::Matrix{Char}
    colors::Matrix{ColorType}
    blend::Bool
    visible::Bool
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
    xscale::XS
    yscale::YS
end

@inline blank(c::BrailleCanvas) = Char(BLANK_BRAILLE)

@inline x_pixel_per_char(::Type{C}) where {C<:BrailleCanvas} = 2
@inline y_pixel_per_char(::Type{C}) where {C<:BrailleCanvas} = 4

function BrailleCanvas(
    char_width::Int,
    char_height::Int;
    blend::Bool = true,
    visible::Bool = true,
    origin_x::Number = 0.0,
    origin_y::Number = 0.0,
    width::Number = 1.0,
    height::Number = 1.0,
    xscale::Function = identity,
    yscale::Function = identity,
)
    width > 0 || throw(ArgumentError("`width` has to be positive"))
    height > 0 || throw(ArgumentError("`height` has to be positive"))
    char_width   = max(char_width, 5)
    char_height  = max(char_height, 2)
    pixel_width  = char_width * x_pixel_per_char(BrailleCanvas)
    pixel_height = char_height * y_pixel_per_char(BrailleCanvas)
    grid         = fill(Char(BLANK_BRAILLE), char_width, char_height)
    colors       = fill(INVALID_COLOR, char_width, char_height)
    BrailleCanvas(
        grid,
        colors,
        blend,
        visible,
        pixel_width,
        pixel_height,
        float(origin_x),
        float(origin_y),
        float(width),
        float(height),
        xscale,
        yscale,
    )
end

function pixel!(c::BrailleCanvas, pixel_x::Int, pixel_y::Int, color::UserColorType)
    valid_x_pixel(c, pixel_x) || return c
    valid_y_pixel(c, pixel_y) || return c
    char_x, char_y, char_x_off, char_y_off = pixel_to_char_point_off(c, pixel_x, pixel_y)
    if checkbounds(Bool, c.grid, char_x, char_y)
        if BLANK_BRAILLE ≤ (val = UInt64(c.grid[char_x, char_y])) ≤ FULL_BRAILLE
            c.grid[char_x, char_y] =
                Char(val | UInt64(BRAILLE_SIGNS[char_x_off, char_y_off]))
        end
        set_color!(c.colors, char_x, char_y, ansi_color(color), c.blend)
    end
    c
end

function char_point!(
    c::BrailleCanvas,
    char_x::Int,
    char_y::Int,
    char::Char,
    color::UserColorType,
)
    if checkbounds(Bool, c.grid, char_x, char_y)
        c.grid[char_x, char_y] = char
        set_color!(c.colors, char_x, char_y, ansi_color(color), c.blend)
    end
    c
end

function printrow(io::IO, print_nc, print_col, c::BrailleCanvas, row::Int)
    0 < row ≤ nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_col(io, c.colors[x, y], c.grid[x, y])
    end
    nothing
end
