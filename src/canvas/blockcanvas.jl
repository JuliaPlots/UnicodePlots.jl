"""
The `BlockCanvas` is also Unicode-based.
It has half the resolution of the `BrailleCanvas`.
In contrast to BrailleCanvas, the pixels don't have visible spacing between them.
This canvas effectively turns every character into 4 pixels that can individually be manipulated using binary operations.
"""
struct BlockCanvas{YS<:Function,XS<:Function} <: LookupCanvas
    grid::Transpose{UInt16,Matrix{UInt16}}
    colors::Transpose{ColorType,Matrix{ColorType}}
    min_max::NTuple{2,UInt32}
    blend::Bool
    visible::Bool
    pixel_height::Int
    pixel_width::Int
    origin_y::Float64
    origin_x::Float64
    height::Float64
    width::Float64
    yscale::YS
    xscale::XS
end

const BLOCK_SIGNS = [
    0b1000 0b0100
    0b0010 0b0001
]

const N_BLOCK = grid_type(BlockCanvas)(16)
const BLOCK_DECODE = Vector{Char}(undef, typemax(N_BLOCK))

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
BLOCK_DECODE[(N_BLOCK + 1):typemax(N_BLOCK)] = UNICODE_TABLE[1:(typemax(N_BLOCK) - N_BLOCK)]

@inline x_pixel_per_char(::Type{<:BlockCanvas}) = 2
@inline y_pixel_per_char(::Type{<:BlockCanvas}) = 2

@inline lookup_encode(::BlockCanvas) = BLOCK_SIGNS
@inline lookup_decode(::BlockCanvas) = BLOCK_DECODE
@inline lookup_offset(::BlockCanvas) = N_BLOCK

BlockCanvas(args...; kw...) =
    CreateLookupCanvas(BlockCanvas, (0b0000, 0b1111), args...; kw...)
