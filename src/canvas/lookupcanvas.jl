# en.wikipedia.org/wiki/Plane_(Unicode)
const PLANE0_START = 0x00000
const PLANE0_STOP = 0x0FFFF
const PLANE1_START = 0x10000
const PLANE1_STOP = 0x1FFFF
const PLANE2_START = 0x20000
const PLANE2_STOP = 0x2FFFF

# TODO: maybe later support plane 1 (SMP) and plane 2 (CJK) (needs UInt16 -> UInt32 grid change)
const UNICODE_TABLE = Array{Char}(undef, (PLANE0_STOP - PLANE0_START + 1) + length(MARKERS))
for i in PLANE0_START:PLANE0_STOP
    UNICODE_TABLE[i + 1] = Char(i)
end

for (j, i) in enumerate(PLANE1_START:(PLANE1_START + (length(MARKERS) - 1)))
    UNICODE_TABLE[i + 1] = MARKERS[j]
end

abstract type LookupCanvas <: Canvas end

function CreateLookupCanvas(
    ::Type{T},
    G,
    min_max,
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
    min_char_height::Int = 5,
    min_char_width::Int = 2,
) where {T<:LookupCanvas}
    width > 0 || throw(ArgumentError("width has to be positive"))
    height > 0 || throw(ArgumentError("height has to be positive"))
    char_width   = max(char_width, min_char_width)
    char_height  = max(char_height, min_char_height)
    pixel_width  = char_width * x_pixel_per_char(T)
    pixel_height = char_height * y_pixel_per_char(T)
    grid         = fill(G(0), char_width, char_height)
    colors       = fill(INVALID_COLOR, char_width, char_height)
    T(
        grid,
        colors,
        NTuple{2,UInt64}(min_max),
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

function pixel!(
    c::T,
    pixel_x::Int,
    pixel_y::Int,
    color::UserColorType,
) where {T<:LookupCanvas}
    valid_x_pixel(c, pixel_x) || return c
    valid_y_pixel(c, pixel_y) || return c
    char_x, char_y, char_x_off, char_y_off = pixel_to_char_point_off(c, pixel_x, pixel_y)
    if checkbounds(Bool, c.grid, char_x, char_y)
        if (val = UInt64(c.grid[char_x, char_y])) == 0 || c.min_max[1] ≤ val ≤ c.min_max[2]
            c.grid[char_x, char_y] |= lookup_encode(c)[char_x_off, char_y_off]
        end
        blend = color isa Symbol && c.blend  # don't attempt to blend colors if they have been explicitly specified
        set_color!(c.colors, char_x, char_y, ansi_color(color), blend)
    end
    c
end

function printrow(io::IO, print_nc, print_col, c::LookupCanvas, row::Int)
    0 < row ≤ nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_col(io, c.colors[x, y], lookup_decode(c)[c.grid[x, y] + 1])
    end
    nothing
end
