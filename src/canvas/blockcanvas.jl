const BLOCK_SIGNS = [
    0b1000 0b0010
    0b0100 0b0001
]

const N_BLOCK = 16
const BLOCK_DECODE = Vector{Char}(undef, typemax(UInt16))
BLOCK_DECODE[1] = ' '
BLOCK_DECODE[2] = '▗'
BLOCK_DECODE[3] = '▖'
BLOCK_DECODE[4] = '▄'
BLOCK_DECODE[5] = '▝'
BLOCK_DECODE[6] = '▐'
BLOCK_DECODE[7] = '▞'
BLOCK_DECODE[8] = '▟'
BLOCK_DECODE[9] = '▘'
BLOCK_DECODE[10] = '▚'
BLOCK_DECODE[11] = '▌'
BLOCK_DECODE[12] = '▙'
BLOCK_DECODE[13] = '▀'
BLOCK_DECODE[14] = '▜'
BLOCK_DECODE[15] = '▛'
BLOCK_DECODE[16] = '█'
BLOCK_DECODE[(N_BLOCK + 1):typemax(UInt16)] = UNICODE_TABLE[1:(typemax(UInt16) - N_BLOCK)]

"""
The `BlockCanvas` is also Unicode-based.
It has half the resolution of the `BrailleCanvas`.
In contrast to BrailleCanvas, the pixels don't have visible spacing between them.
This canvas effectively turns every character into 4 pixels that can individually be manipulated using binary operations.
"""
struct BlockCanvas{XS<:Function,YS<:Function} <: LookupCanvas
    grid::Matrix{UInt16}
    colors::Matrix{ColorType}
    min_max::NTuple{2,UInt64}
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

@inline x_pixel_per_char(::Type{C}) where {C<:BlockCanvas} = 2
@inline y_pixel_per_char(::Type{C}) where {C<:BlockCanvas} = 2

@inline lookup_encode(::BlockCanvas) = BLOCK_SIGNS
@inline lookup_decode(::BlockCanvas) = BLOCK_DECODE

BlockCanvas(args...; kw...) =
    CreateLookupCanvas(BlockCanvas, UInt16, (0b0000, 0b1111), args...; kw...)

function char_point!(
    c::BlockCanvas,
    char_x::Int,
    char_y::Int,
    char::Char,
    color::UserColorType,
)
    if checkbounds(Bool, c.grid, char_x, char_y)
        c.grid[char_x, char_y] = N_BLOCK + char
        set_color!(c.colors, char_x, char_y, ansi_color(color), c.blend)
    end
    c
end
