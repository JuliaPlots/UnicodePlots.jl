# braille dots composing ⣿
const BRAILLE_SIGNS = UnicodeType.([
    '⠁' '⠈'
    '⠂' '⠐'
    '⠄' '⠠'
    '⡀' '⢀'
])

"""
The type of canvas with the highest resolution for Unicode-based plotting.
It uses the Unicode characters for the Braille symbols to represent individual pixel.
This effectively turns every character into 8 pixels that can individually be manipulated using binary operations.
"""
struct BrailleCanvas{YS<:Function,XS<:Function} <: Canvas
    grid::Transpose{UnicodeType,Matrix{UnicodeType}}
    colors::Transpose{ColorType,Matrix{ColorType}}
    visible::Bool
    blend::Bool
    yflip::Bool
    xflip::Bool
    pixel_height::Int
    pixel_width::Int
    origin_y::Float64
    origin_x::Float64
    height::Float64
    width::Float64
    yscale::YS
    xscale::XS
end

@inline blank(c::BrailleCanvas) = Char(BLANK_BRAILLE)

@inline y_pixel_per_char(::Type{<:BrailleCanvas}) = 4
@inline x_pixel_per_char(::Type{<:BrailleCanvas}) = 2

function BrailleCanvas(
    char_height::Integer,
    char_width::Integer;
    blend::Bool = KEYWORDS.blend,
    visible::Bool = KEYWORDS.visible,
    origin_y::Number = 0.0,
    origin_x::Number = 0.0,
    height::Number = 1.0,
    width::Number = 1.0,
    yflip::Bool = KEYWORDS.xflip,
    xflip::Bool = KEYWORDS.yflip,
    yscale::Union{Symbol,Function} = :identity,
    xscale::Union{Symbol,Function} = :identity,
)
    height > 0 || throw(ArgumentError("`height` has to be positive"))
    width > 0 || throw(ArgumentError("`width` has to be positive"))
    char_height  = max(char_height, 2)
    char_width   = max(char_width, 5)
    pixel_height = char_height * y_pixel_per_char(BrailleCanvas)
    pixel_width  = char_width * x_pixel_per_char(BrailleCanvas)
    grid         = transpose(fill(grid_type(BrailleCanvas)(BLANK_BRAILLE), char_width, char_height))
    colors       = transpose(fill(INVALID_COLOR, char_width, char_height))
    BrailleCanvas(
        grid,
        colors,
        visible,
        blend,
        yflip,
        xflip,
        pixel_height,
        pixel_width,
        float(origin_y),
        float(origin_x),
        float(height),
        float(width),
        scale_callback(yscale),
        scale_callback(xscale),
    )
end

function pixel!(c::BrailleCanvas, pixel_x::Integer, pixel_y::Integer, color::UserColorType)
    valid_x_pixel(c, pixel_x) || return c
    valid_y_pixel(c, pixel_y) || return c
    char_x, char_y, char_x_off, char_y_off = pixel_to_char_point_off(c, pixel_x, pixel_y)
    if checkbounds(Bool, c.grid, char_y, char_x)
        if BLANK_BRAILLE ≤ (val = c.grid[char_y, char_x]) ≤ FULL_BRAILLE
            c.grid[char_y, char_x] = val | BRAILLE_SIGNS[char_y_off, char_x_off]
        end
        set_color!(c, char_x, char_y, ansi_color(color))
    end
    c
end

function print_row(io::IO, _, print_color, c::BrailleCanvas, row::Integer)
    0 < row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    for col ∈ 1:ncols(c)
        print_color(io, c.colors[row, col], Char(c.grid[row, col]))
    end
    nothing
end
