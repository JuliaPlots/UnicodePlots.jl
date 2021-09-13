const block_signs = [0b1000 0b0010;
                     0b0100 0b0001]

const n_block_canvas = 16
const block_decode = Vector{Char}(undef, n_block_canvas + n_ascii)
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
block_decode[n_block_canvas+1:n_block_canvas+n_ascii] = ascii_table[1:n_ascii]

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
    colors::Array{ColorType,2}
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
    xscale::Union{Symbol,Function}
    yscale::Union{Symbol,Function}
end

@inline x_pixel_per_char(::Type{BlockCanvas}) = 2
@inline y_pixel_per_char(::Type{BlockCanvas}) = 2

@inline lookup_encode(c::BlockCanvas) = block_signs
@inline lookup_decode(c::BlockCanvas) = block_decode

function BlockCanvas(args...; nargs...)
    CreateLookupCanvas(BlockCanvas, args...; nargs...)
end

function char_point!(c::BlockCanvas, char_x::Int, char_y::Int, char::Char, color::UserColorType)
  if checkbounds(Bool, c.grid, char_x, char_y) && isascii(char)  # NOTE: limit to ASCII (fits UInt8)
    c.grid[char_x,char_y] = n_block_canvas + char
    set_color!(c.colors, char_x, char_y, crayon_256_color(color))
  end
  c
end
