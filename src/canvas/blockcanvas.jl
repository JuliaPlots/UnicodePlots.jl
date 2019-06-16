const block_signs = [0b1000 0b0010;
                     0b0100 0b0001]

const block_decode = Vector{Char}(undef, 16)
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

"""
The `BlockCanvas` is also Unicode-based.
It has half the resolution of the `BrailleCanvas`.
In contrast to BrailleCanvas, the pixels don't
have visible spacing between them.
This canvas effectively turns every character
into 4 pixels that can individually be manipulated
using binary operations.
"""
struct BlockCanvas <: LookupCanvas
    grid::Array{UInt8,2}
    colors::Array{UInt8,2}
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
end

@inline x_pixel_per_char(::Type{BlockCanvas}) = 2
@inline y_pixel_per_char(::Type{BlockCanvas}) = 2

@inline lookup_encode(c::BlockCanvas) = block_signs
@inline lookup_decode(c::BlockCanvas) = block_decode

function BlockCanvas(args...; nargs...)
    CreateLookupCanvas(BlockCanvas, args...; nargs...)
end
