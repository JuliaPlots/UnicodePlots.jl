const DOT_SIGNS = [0b10; 0b01]

const N_DOT = 4
const DOT_DECODE = Array{Char}(undef, typemax(UInt16))
DOT_DECODE[1] = ' '
DOT_DECODE[2] = '.'
DOT_DECODE[3] = '\''
DOT_DECODE[4] = ':'
DOT_DECODE[(N_DOT + 1):typemax(UInt16)] = UNICODE_TABLE[1:(typemax(UInt16) - N_DOT)]

"""
Similar to the `AsciiCanvas`, the `DotCanvas` only uses ASCII characters to draw it's content.
Naturally, it doesn't look quite as nice as the Unicode-based ones.
However, in some situations it might yield better results.
Printing plots to a file is one of those situations.

The DotCanvas is best utilized in combination with `scatterplot`.
For `lineplot` we suggest to use the `AsciiCanvas` instead.
"""
struct DotCanvas{YS<:Function,XS<:Function} <: LookupCanvas
    grid::Transpose{UInt16,Matrix{UInt16}}
    colors::Transpose{ColorType,Matrix{ColorType}}
    min_max::NTuple{2,UInt64}
    blend::Bool
    visible::Bool
    pixel_height::Int
    pixel_width::Int
    origin_y::Float64
    origin_x::Float64
    height::Float64
    width::Float64
    xscale::XS
    yscale::YS
end

@inline x_pixel_per_char(::Type{<:DotCanvas}) = 1
@inline y_pixel_per_char(::Type{<:DotCanvas}) = 2

@inline lookup_encode(::DotCanvas) = DOT_SIGNS
@inline lookup_decode(::DotCanvas) = DOT_DECODE
@inline lookup_offset(::DotCanvas) = N_DOT

DotCanvas(args...; kw...) = CreateLookupCanvas(DotCanvas, (0b00, 0b11), args...; kw...)
