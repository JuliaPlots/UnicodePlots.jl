"""
The `HeatmapCanvas` is also Unicode-based.
It has a half the resolution of the `BlockCanvas`.
This canvas effectively turns every character
into two pixels (top and bottom).
"""
struct HeatmapCanvas <: LookupCanvas
    grid::Array{UInt8,2}
    colors::Array{ColorType,2}
    blend::Bool
    visible::Bool
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
    xscale::Union{Symbol,Function}
    yscale::Union{Symbol,Function}
end

const HALF_BLOCK = '▄'
@inline x_pixel_per_char(::Type{HeatmapCanvas}) = 1
@inline y_pixel_per_char(::Type{HeatmapCanvas}) = 2

@inline lookup_encode(c::HeatmapCanvas) = [0 0; 1 1]
@inline lookup_decode(c::HeatmapCanvas) = [HALF_BLOCK; HALF_BLOCK]

@inline nrows(c::HeatmapCanvas) = div(size(grid(c), 2) + 1, 2)

HeatmapCanvas(args...; kwargs...) = CreateLookupCanvas(
    HeatmapCanvas,
    args...;
    min_char_width = 1,
    min_char_height = 1,
    kwargs...,
)

_toCrayon(c) = c === nothing ? 0 : (c isa Unsigned ? Int(c) : c)

function printrow(io::IO, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2row

    # extend the plot upwards by half a row
    isodd(size(grid(c), 2)) && (y -= 1)

    iscolor = get(io, :color, false)
    for x in 1:ncols(c)
        if iscolor
            fgcol = _toCrayon(c.colors[x, y])
            if y > 1
                bgcol = _toCrayon(c.colors[x, y - 1])
                print(io, Crayon(foreground = fgcol, background = bgcol), HALF_BLOCK)
                # for odd numbers of rows, only print the foreground for the top row
            else
                print(io, Crayon(foreground = fgcol), HALF_BLOCK)
            end
        else
            print(io, HALF_BLOCK)
        end
    end
    iscolor && print(io, Crayon(reset = true))

    nothing
end
