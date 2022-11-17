const HEATMAP_SIGNS = [0 1; 0 1]
const HEATMAP_DECODE = [HALF_BLOCK; HALF_BLOCK]

"""
The `HeatmapCanvas` is also Unicode-based.
It has a half the resolution of the `BlockCanvas`.
This canvas effectively turns every character into two pixels (top and bottom).
"""
struct HeatmapCanvas{YS<:Function,XS<:Function} <: LookupCanvas
    grid::Transpose{UInt8,Matrix{UInt8}}
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

@inline nrows(c::HeatmapCanvas) = div(size(c.grid, 1) + 1, 2)

@inline y_pixel_per_char(::Type{<:HeatmapCanvas}) = 2
@inline x_pixel_per_char(::Type{<:HeatmapCanvas}) = 1

@inline lookup_encode(::HeatmapCanvas) = HEATMAP_SIGNS
@inline lookup_decode(::HeatmapCanvas) = HEATMAP_DECODE

function HeatmapCanvas(args...; kw...)
    c = CreateLookupCanvas(
        HeatmapCanvas,
        (0, 1),
        args...;
        min_char_height = 1,
        min_char_width = 1,
        kw...,
    )
    fill!(c.colors, ansi_color(:black))  # black background by default
    c
end

function print_row(io::IO, _, print_color, c::HeatmapCanvas, row::Integer)
    1 ≤ row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    row *= y_pixel_per_char(HeatmapCanvas)

    # extend the plot upwards by half a row
    isodd(size(c.grid, 1)) && (row -= 1)

    for col ∈ 1:ncols(c)
        # for odd numbers of rows, only print the foreground for the top row
        bgcol = row > 1 ? c.colors[row - 1, col] : missing
        print_color(io, c.colors[row, col], HALF_BLOCK; bgcol = bgcol)
    end

    nothing
end
