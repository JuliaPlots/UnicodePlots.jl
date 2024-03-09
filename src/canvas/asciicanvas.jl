"""
As the name suggests the `AsciiCanvas` only uses ASCII characters to draw it's content.
Naturally, it doesn't look quite as nice as the Unicode-based ones.
However, in some situations it might yield better results.
Printing plots to a file is one of those situations.

The AsciiCanvas is best utilized in combination with `lineplot`.
For `scatterplot` we suggest to use the `DotCanvas` instead.
"""
struct AsciiCanvas{YS<:Function,XS<:Function} <: LookupCanvas
    grid::Transpose{UInt16,Matrix{UInt16}}
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
    min_max::NTuple{2,UnicodeType}
    yscale::YS
    xscale::XS
end

const N_ASCII = grid_type(AsciiCanvas)(512)
const ASCII_ENCODE = [
    0b100_000_000 0b010_000_000 0b001_000_000
    0b000_100_000 0b000_010_000 0b000_001_000
    0b000_000_100 0b000_000_010 0b000_000_001
]

const ASCII_LOOKUP = Dict{UInt16,Char}()
ASCII_LOOKUP[0b101_000_000] = '"'
ASCII_LOOKUP[0b111_111_111] = '@'
# ASCII_LOOKUP[0b011_110_011] = '$'
ASCII_LOOKUP[0b010_000_000] = '\''
ASCII_LOOKUP[0b010_100_010] = '('
ASCII_LOOKUP[0b010_001_010] = ')'
ASCII_LOOKUP[0b000_010_000] = '*'
ASCII_LOOKUP[0b010_111_010] = '+'
ASCII_LOOKUP[0b000_010_010] = ','
ASCII_LOOKUP[0b000_100_100] = ','
ASCII_LOOKUP[0b000_001_001] = ','
ASCII_LOOKUP[0b000_111_000] = '-'
ASCII_LOOKUP[0b000_000_010] = '.'
ASCII_LOOKUP[0b000_000_100] = '.'
ASCII_LOOKUP[0b000_000_001] = '.'
ASCII_LOOKUP[0b001_010_100] = '/'
ASCII_LOOKUP[0b010_100_000] = '/'
ASCII_LOOKUP[0b001_010_110] = '/'
ASCII_LOOKUP[0b011_010_010] = '/'
ASCII_LOOKUP[0b001_010_010] = '/'
ASCII_LOOKUP[0b110_010_111] = '1'
# ASCII_LOOKUP[0b111_010_100] = '7'
ASCII_LOOKUP[0b010_000_010] = ':'
ASCII_LOOKUP[0b111_000_111] = '='
# ASCII_LOOKUP[0b010_111_101] = 'A'
# ASCII_LOOKUP[0b011_100_011] = 'C'
# ASCII_LOOKUP[0b110_101_110] = 'D'
# ASCII_LOOKUP[0b111_110_100] = 'F'
# ASCII_LOOKUP[0b011_101_011] = 'G'
# ASCII_LOOKUP[0b101_111_101] = 'H'
ASCII_LOOKUP[0b111_010_111] = 'I'
# ASCII_LOOKUP[0b011_001_111] = 'J'
# ASCII_LOOKUP[0b101_110_101] = 'K'
ASCII_LOOKUP[0b100_100_111] = 'L'
# ASCII_LOOKUP[0b111_111_101] = 'M'
# ASCII_LOOKUP[0b101_101_101] = 'N'
# ASCII_LOOKUP[0b111_101_111] = 'O'
# ASCII_LOOKUP[0b111_111_100] = 'P'
ASCII_LOOKUP[0b111_010_010] = 'T'
# ASCII_LOOKUP[0b101_101_111] = 'U'
ASCII_LOOKUP[0b101_101_010] = 'V'
# ASCII_LOOKUP[0b101_111_111] = 'W'
ASCII_LOOKUP[0b101_010_101] = 'X'
ASCII_LOOKUP[0b101_010_010] = 'Y'
ASCII_LOOKUP[0b110_100_110] = '['
ASCII_LOOKUP[0b010_001_000] = '\\'
ASCII_LOOKUP[0b100_010_001] = '\\'
ASCII_LOOKUP[0b110_010_010] = '\\'
ASCII_LOOKUP[0b100_010_011] = '\\'
ASCII_LOOKUP[0b100_010_010] = '\\'
ASCII_LOOKUP[0b011_001_011] = ']'
ASCII_LOOKUP[0b010_101_000] = '^'
ASCII_LOOKUP[0b000_000_111] = '_'
ASCII_LOOKUP[0b100_000_000] = '`'
# ASCII_LOOKUP[0b000_111_111] = 'a'
# ASCII_LOOKUP[0b100_111_111] = 'b'
# ASCII_LOOKUP[0b001_111_111] = 'd'
# ASCII_LOOKUP[0b001_111_010] = 'f'
# ASCII_LOOKUP[0b100_111_101] = 'h'
# ASCII_LOOKUP[0b100_101_101] = 'k'
ASCII_LOOKUP[0b110_010_011] = 'l'
# ASCII_LOOKUP[0b000_111_101] = 'n'
ASCII_LOOKUP[0b000_111_100] = 'r'
# ASCII_LOOKUP[0b000_101_111] = 'u'
ASCII_LOOKUP[0b000_101_010] = 'v'
ASCII_LOOKUP[0b011_110_011] = '{'
ASCII_LOOKUP[0b010_010_010] = '|'
ASCII_LOOKUP[0b100_100_100] = '|'
ASCII_LOOKUP[0b001_001_001] = '|'
ASCII_LOOKUP[0b110_011_110] = '}'

const ASCII_DECODE = Vector{Char}(undef, typemax(N_ASCII))
ASCII_DECODE[1] = ' '
for i ∈ 2:N_ASCII
    min_dist = typemax(Int)
    min_char = ' '
    for (k, v) ∈ sort_by_keys(ASCII_LOOKUP)
        if (cur_dist = count_ones(xor(typeof(N_ASCII)(i - 1), k))) < min_dist
            min_dist = cur_dist
            min_char = v
        end
    end
    ASCII_DECODE[i] = min_char
end

ASCII_DECODE[(N_ASCII + 1):typemax(N_ASCII)] = UNICODE_TABLE[1:(typemax(N_ASCII) - N_ASCII)]

@inline y_pixel_per_char(::Type{<:AsciiCanvas}) = 3
@inline x_pixel_per_char(::Type{<:AsciiCanvas}) = 3

@inline lookup_encode(::AsciiCanvas) = ASCII_ENCODE
@inline lookup_decode(::AsciiCanvas) = ASCII_DECODE
@inline lookup_offset(::AsciiCanvas) = N_ASCII

AsciiCanvas(args...; kw...) =
    CreateLookupCanvas(AsciiCanvas, (0b000_000_000, 0b111_111_111), args...; kw...)
