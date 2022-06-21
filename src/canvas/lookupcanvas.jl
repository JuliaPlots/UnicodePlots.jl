# en.wikipedia.org/wiki/Plane_(Unicode)
const PLANE0_START = 0x00000
const PLANE0_STOP = 0x0ffff
const PLANE1_START = 0x10000
const PLANE1_STOP = 0x1ffff
const PLANE2_START = 0x20000
const PLANE2_STOP = 0x2ffff

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
    min_max,
    char_height::Int,
    char_width::Int;
    blend::Bool = true,
    visible::Bool = true,
    origin_y::Number = 0.0,
    origin_x::Number = 0.0,
    height::Number = 1.0,
    width::Number = 1.0,
    yscale::Union{Symbol,Function} = :identity,
    xscale::Union{Symbol,Function} = :identity,
    min_char_height::Int = 5,
    min_char_width::Int = 2,
) where {T<:LookupCanvas}
    height > 0 || throw(ArgumentError("height has to be positive"))
    width > 0 || throw(ArgumentError("width has to be positive"))
    char_height  = max(char_height, min_char_height)
    char_width   = max(char_width, min_char_width)
    pixel_height = char_height * y_pixel_per_char(T)
    pixel_width  = char_width * x_pixel_per_char(T)
    grid         = transpose(fill(grid_type(T)(0), char_width, char_height))
    colors       = transpose(fill(INVALID_COLOR, char_width, char_height))
    T(
        grid,
        colors,
        NTuple{2,UInt32}(min_max),  # `UInt32` is enough to hold all values of `UNICODE_TABLE`
        blend,
        visible,
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

function pixel!(
    c::T,
    pixel_x::Int,
    pixel_y::Int,
    color::UserColorType,
) where {T<:LookupCanvas}
    valid_x_pixel(c, pixel_x) || return c
    valid_y_pixel(c, pixel_y) || return c
    char_x, char_y, char_x_off, char_y_off = pixel_to_char_point_off(c, pixel_x, pixel_y)
    if checkbounds(Bool, c.grid, char_y, char_x)
        if (val = UInt32(c.grid[char_y, char_x])) == 0 || c.min_max[1] ≤ val ≤ c.min_max[2]
            c.grid[char_y, char_x] |= lookup_encode(c)[char_y_off, char_x_off]
        end
        blend = color isa Symbol && c.blend  # don't attempt to blend colors if they have been explicitly specified
        set_color!(c.colors, char_x, char_y, ansi_color(color), blend)
    end
    c
end

function print_row(io::IO, _, print_color, c::LookupCanvas, row::Int)
    0 < row ≤ nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    for col in 1:ncols(c)
        print_color(io, c.colors[row, col], lookup_decode(c)[c.grid[row, col] + 1])
    end
    nothing
end
