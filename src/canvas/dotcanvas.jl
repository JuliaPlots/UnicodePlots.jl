const dot_signs = [0b10 0b01]

const dot_decode = Array{Char}(undef, 5)
dot_decode[0b00 + 1] = ' '
dot_decode[0b01 + 1] = '.'
dot_decode[0b10 + 1] = '\''
dot_decode[0b11 + 1] = ':'

"""
Similar to the `AsciiCanvas`, the `DotCanvas` only uses
ASCII characters to draw it's content. Naturally,
it doesn't look quite as nice as the Unicode-based
ones. However, in some situations it might yield
better results. Printing plots to a file is one
of those situations.

The DotCanvas is best utilized in combination
with `scatterplot`.
For `lineplot` we suggest to use the `AsciiCanvas`
instead.
"""
struct DotCanvas <: LookupCanvas
    grid::Array{UInt8,2}
    colors::Array{UInt8,2}
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
end

@inline x_pixel_per_char(::Type{DotCanvas}) = 1
@inline y_pixel_per_char(::Type{DotCanvas}) = 2

@inline lookup_encode(c::DotCanvas) = dot_signs
@inline lookup_decode(c::DotCanvas) = dot_decode

function DotCanvas(args...; nargs...)
    CreateLookupCanvas(DotCanvas, args...; nargs...)
end
