"""
The `HeatmapCanvas` is also Unicode-based.
It has a half the resolution of the `BlockCanvas`.
This canvas effectively turns every character
into two pixels (top and bottom).
"""
struct HeatmapCanvas{XS<:Function,YS<:Function} <: LookupCanvas
    grid::Matrix{UInt8}
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

@inline x_pixel_per_char(::Type{C}) where {C<:HeatmapCanvas} = 1
@inline y_pixel_per_char(::Type{C}) where {C<:HeatmapCanvas} = 2

@inline lookup_encode(::HeatmapCanvas) = [0 0; 1 1]
@inline lookup_decode(::HeatmapCanvas) = [HALF_BLOCK; HALF_BLOCK]

@inline nrows(c::HeatmapCanvas) = div(size(grid(c), 2) + 1, 2)

function HeatmapCanvas(args...; kw...)
    c = CreateLookupCanvas(
        HeatmapCanvas,
        UInt8,
        (0, 1),
        args...;
        min_char_width = 1,
        min_char_height = 1,
        kw...,
    )
    fill!(c.colors, ansi_color(:black))  # black background by default
    c
end

function printrow(io::IO, print_nc, print_col, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2row

    # extend the plot upwards by half a row
    isodd(size(grid(c), 2)) && (y -= 1)

    for x in 1:ncols(c)
        # for odd numbers of rows, only print the foreground for the top row
        bgcol = y > 1 ? c.colors[x, y - 1] : missing
        print_col(io, c.colors[x, y], HALF_BLOCK; bgcol = bgcol)
    end

    nothing
end
