const ascii_signs = [
    0b100_000_000 0b000_100_000 0b000_000_100
    0b010_000_000 0b000_010_000 0b000_000_010
    0b001_000_000 0b000_001_000 0b000_000_001
]

const ascii_lookup = Dict{UInt16,Char}()
ascii_lookup[0b101_000_000] = '"'
ascii_lookup[0b111_111_111] = '@'
#ascii_lookup[0b011_110_011] = '$'
ascii_lookup[0b010_000_000] = '\''
ascii_lookup[0b010_100_010] = '('
ascii_lookup[0b010_001_010] = ')'
ascii_lookup[0b000_010_000] = '*'
ascii_lookup[0b010_111_010] = '+'
ascii_lookup[0b000_010_010] = ','
ascii_lookup[0b000_100_100] = ','
ascii_lookup[0b000_001_001] = ','
ascii_lookup[0b000_111_000] = '-'
ascii_lookup[0b000_000_010] = '.'
ascii_lookup[0b000_000_100] = '.'
ascii_lookup[0b000_000_001] = '.'
ascii_lookup[0b001_010_100] = '/'
ascii_lookup[0b010_100_000] = '/'
ascii_lookup[0b001_010_110] = '/'
ascii_lookup[0b011_010_010] = '/'
ascii_lookup[0b001_010_010] = '/'
ascii_lookup[0b110_010_111] = '1'
#ascii_lookup[0b111_010_100] = '7'
ascii_lookup[0b010_000_010] = ':'
ascii_lookup[0b111_000_111] = '='
#ascii_lookup[0b010_111_101] = 'A'
#ascii_lookup[0b011_100_011] = 'C'
#ascii_lookup[0b110_101_110] = 'D'
#ascii_lookup[0b111_110_100] = 'F'
#ascii_lookup[0b011_101_011] = 'G'
#ascii_lookup[0b101_111_101] = 'H'
ascii_lookup[0b111_010_111] = 'I'
#ascii_lookup[0b011_001_111] = 'J'
#ascii_lookup[0b101_110_101] = 'K'
ascii_lookup[0b100_100_111] = 'L'
#ascii_lookup[0b111_111_101] = 'M'
#ascii_lookup[0b101_101_101] = 'N'
#ascii_lookup[0b111_101_111] = 'O'
#ascii_lookup[0b111_111_100] = 'P'
ascii_lookup[0b111_010_010] = 'T'
#ascii_lookup[0b101_101_111] = 'U'
ascii_lookup[0b101_101_010] = 'V'
#ascii_lookup[0b101_111_111] = 'W'
ascii_lookup[0b101_010_101] = 'X'
ascii_lookup[0b101_010_010] = 'Y'
ascii_lookup[0b110_100_110] = '['
ascii_lookup[0b010_001_000] = '\\'
ascii_lookup[0b100_010_001] = '\\'
ascii_lookup[0b110_010_010] = '\\'
ascii_lookup[0b100_010_011] = '\\'
ascii_lookup[0b100_010_010] = '\\'
ascii_lookup[0b011_001_011] = ']'
ascii_lookup[0b010_101_000] = '^'
ascii_lookup[0b000_000_111] = '_'
ascii_lookup[0b100_000_000] = '`'
#ascii_lookup[0b000_111_111] = 'a'
#ascii_lookup[0b100_111_111] = 'b'
#ascii_lookup[0b001_111_111] = 'd'
#ascii_lookup[0b001_111_010] = 'f'
#ascii_lookup[0b100_111_101] = 'h'
#ascii_lookup[0b100_101_101] = 'k'
ascii_lookup[0b110_010_011] = 'l'
#ascii_lookup[0b000_111_101] = 'n'
ascii_lookup[0b000_111_100] = 'r'
#ascii_lookup[0b000_101_111] = 'u'
ascii_lookup[0b000_101_010] = 'v'
ascii_lookup[0b011_110_011] = '{'
ascii_lookup[0b010_010_010] = '|'
ascii_lookup[0b100_100_100] = '|'
ascii_lookup[0b001_001_001] = '|'
ascii_lookup[0b110_011_110] = '}'

const n_ascii = 512
const ascii_decode = Vector{Char}(undef, typemax(UInt16))
ascii_decode[1] = ' '
for i in 2:n_ascii
    min_dist = typemax(Int)
    min_char = ' '
    for (k, v) in sort_by_keys(ascii_lookup)
        cur_dist = count_ones(xor(UInt16(i - 1), k))
        if cur_dist < min_dist
            min_dist = cur_dist
            min_char = v
        end
    end
    ascii_decode[i] = min_char
end

ascii_decode[(n_ascii + 1):typemax(UInt16)] = unicode_table[1:(typemax(UInt16) - n_ascii)]

"""
As the name suggests the `AsciiCanvas` only uses
ASCII characters to draw it's content. Naturally,
it doesn't look quite as nice as the Unicode-based
ones. However, in some situations it might yield
better results. Printing plots to a file is one
of those situations.

The AsciiCanvas is best utilized in combination
with `lineplot`.
For `scatterplot` we suggest to use the `DotCanvas`
instead.
"""
struct AsciiCanvas{XS<:Function,YS<:Function} <: LookupCanvas
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

@inline x_pixel_per_char(::Type{C}) where {C<:AsciiCanvas} = 3
@inline y_pixel_per_char(::Type{C}) where {C<:AsciiCanvas} = 3

@inline lookup_encode(::AsciiCanvas) = ascii_signs
@inline lookup_decode(::AsciiCanvas) = ascii_decode

AsciiCanvas(args...; kw...) =
    CreateLookupCanvas(AsciiCanvas, UInt16, (0b000_000_000, 0b111_111_111), args...; kw...)

function char_point!(
    c::AsciiCanvas,
    char_x::Int,
    char_y::Int,
    char::Char,
    color::UserColorType,
)
    if checkbounds(Bool, c.grid, char_x, char_y)
        c.grid[char_x, char_y] = n_ascii + char
        set_color!(c.colors, char_x, char_y, crayon_256_color(color), c.blend)
    end
    c
end
