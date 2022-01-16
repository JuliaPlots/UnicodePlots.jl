# https://en.wikipedia.org/wiki/Plane_(Unicode)
const plane0_start = 0x00000
const plane0_stop = 0x0FFFF
const plane1_start = 0x10000
const plane1_stop = 0x1FFFF
const plane2_start = 0x20000
const plane2_stop = 0x2FFFF

# TODO: maybe later support plane 1 (SMP) and plane 2 (CJK) (needs UInt16 -> UInt32 grid change)
const unicode_table = Array{Char}(undef, (plane0_stop - plane0_start + 1) + length(MARKERS))
for i in plane0_start:plane0_stop
    unicode_table[i + 1] = Char(i)
end

for (j, i) in enumerate(plane1_start:plane1_start+(length(MARKERS) - 1))
    unicode_table[i + 1] = MARKERS[j]
end

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
        height::Number = 1.,
        xscale::Union{Symbol,Function} = :identity,
        yscale::Union{Symbol,Function} = :identity,
        min_char_height::Int = 5,
        min_char_width::Int = 2) where {T <: LookupCanvas}
    width  > 0 || throw(ArgumentError("width has to be positive"))
    height > 0 || throw(ArgumentError("height has to be positive"))
    char_width  = max(char_width, min_char_width)
    char_height = max(char_height, min_char_height)
    pixel_width  = char_width * x_pixel_per_char(T)
    pixel_height = char_height * y_pixel_per_char(T)
    grid = fill(0x00, char_width, char_height)
    colors = fill(nothing, char_width, char_height)
    T(grid, colors, pixel_width, pixel_height,
      Float64(origin_x), Float64(origin_y),
      Float64(width), Float64(height), xscale, yscale)
end

function pixel_to_char_point(c::T, pixel_x::Number, pixel_y::Number) where {T <: LookupCanvas}
    pixel_x = pixel_x < pixel_width(c) ? pixel_x : pixel_x - 1
    pixel_y = pixel_y < pixel_height(c) ? pixel_y : pixel_y - 1
    cw, ch = size(grid(c))
    tmp = pixel_x / pixel_width(c) * cw
    char_x = floor(Int, tmp) + 1
    char_x_off = (pixel_x % x_pixel_per_char(T)) + 1
    if char_x < round(Int, tmp, RoundNearestTiesUp) + 1 && char_x_off == 1
        char_x += 1
    end
    char_y = floor(Int, pixel_y / pixel_height(c) * ch) + 1
    char_y_off = (pixel_y % y_pixel_per_char(T)) + 1
    char_x, char_y, char_x_off, char_y_off
end

function pixel!(c::T, pixel_x::Int, pixel_y::Int, color::UserColorType) where {T <: LookupCanvas}
    0 <= pixel_x <= pixel_width(c) || return c
    0 <= pixel_y <= pixel_height(c) || return c
    char_x, char_y, char_x_off, char_y_off = pixel_to_char_point(c, pixel_x, pixel_y)
    grid(c)[char_x, char_y] |= lookup_encode(c)[char_x_off, char_y_off]
    force = !(color isa Symbol)  # don't attempt to blend colors if they have been explicitly specified
    set_color!(c.colors, char_x, char_y, ansi_color(color); force=force)
    c
end

function printrow(io::IO, c::LookupCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_color(colors(c)[x,y], io, lookup_decode(c)[grid(c)[x,y] + 1])
    end
    nothing
end
