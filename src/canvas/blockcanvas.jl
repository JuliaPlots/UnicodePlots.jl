const block_signs = [
    0b1000 0b0010
    0b0100 0b0001
]

const n_block = 16
const block_decode = Vector{Char}(undef, typemax(UInt16))
block_decode[0b0000 + 1] = ' '
block_decode[0b0001 + 1] = '▗'
block_decode[0b0010 + 1] = '▖'
block_decode[0b0011 + 1] = '▄'
block_decode[0b0100 + 1] = '▝'
block_decode[0b0101 + 1] = '▐'
block_decode[0b0110 + 1] = '▞'
block_decode[0b0111 + 1] = '▟'
block_decode[0b1000 + 1] = '▘'
block_decode[0b1001 + 1] = '▚'
block_decode[0b1010 + 1] = '▌'
block_decode[0b1011 + 1] = '▙'
block_decode[0b1100 + 1] = '▀'
block_decode[0b1101 + 1] = '▜'
block_decode[0b1110 + 1] = '▛'
block_decode[0b1111 + 1] = '█'
block_decode[(n_block + 1):typemax(UInt16)] = unicode_table[1:(typemax(UInt16) - n_block)]

"""
The `BlockCanvas` is also Unicode-based.
It has half the resolution of the `BrailleCanvas`.
In contrast to BrailleCanvas, the pixels don't
have visible spacing between them.
This canvas effectively turns every character
into 4 pixels that can individually be manipulated
using binary operations.
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

@inline lookup_encode(::BlockCanvas) = block_signs
@inline lookup_decode(::BlockCanvas) = block_decode

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
        c.grid[char_x, char_y] = n_block + char
        set_color!(c.colors, char_x, char_y, ansi_color(color), c.blend)
    end
    c
end
