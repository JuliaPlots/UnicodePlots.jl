"""
Similar to the `AsciiCanvas`, the `DotCanvas` only uses ASCII characters to draw its content.
Naturally, it doesn't look quite as nice as the Unicode-based ones.
However, in some situations it might yield better results.
Printing plots to a file is one of those situations.

The DotCanvas is best used in combination with `scatterplot`.
For `lineplot` we suggest to use the `AsciiCanvas` instead.
"""
struct DotCanvas{YS<:Function,XS<:Function} <: LookupCanvas
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
    xscale::XS
    yscale::YS
end

const N_DOT = grid_type(DotCanvas)(4)
const DOT_SIGNS = [0b10; 0b01]
const DOT_DECODE = Array{Char}(undef, typemax(N_DOT))
DOT_DECODE[1] = ' '
DOT_DECODE[2] = '.'
DOT_DECODE[3] = '\''
DOT_DECODE[4] = ':'
DOT_DECODE[(N_DOT + 1):typemax(N_DOT)] = UNICODE_TABLE[1:(typemax(N_DOT) - N_DOT)]

@inline y_pixel_per_char(::Type{<:DotCanvas}) = 2
@inline x_pixel_per_char(::Type{<:DotCanvas}) = 1

@inline lookup_encode(::DotCanvas) = DOT_SIGNS
@inline lookup_decode(::DotCanvas) = DOT_DECODE
@inline lookup_offset(::DotCanvas) = N_DOT

DotCanvas(args...; kw...) = CreateLookupCanvas(DotCanvas, (0b00, 0b11), args...; kw...)
