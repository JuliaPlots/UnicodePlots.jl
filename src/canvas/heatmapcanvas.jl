using Crayons

"""
The `HeatmapCanvas` is also Unicode-based.
It has a half the resolution of the `BlockCanvas`.
This canvas effectively turns every character
into a single pixel. 
"""
struct HeatmapCanvas <: LookupCanvas
    grid::Array{UInt8,2}
    colors::Array{UInt8,2}
    pixel_width::Int
    pixel_height::Int
    origin_x::Float64
    origin_y::Float64
    width::Float64
    height::Float64
end

@inline x_pixel_per_char(::Type{HeatmapCanvas}) = 1
@inline y_pixel_per_char(::Type{HeatmapCanvas}) = 2

@inline lookup_encode(c::HeatmapCanvas) = [0 0; 1 1]
@inline lookup_decode(c::HeatmapCanvas) = ['▄'; '▄']

@inline nrows(c::HeatmapCanvas) = div(size(grid(c), 2), 2)

function HeatmapCanvas(args...; nargs...)
    CreateLookupCanvas(HeatmapCanvas, args...; nargs...)
end

function printrow(io::IO, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2*row
    iscolor = get(io, :color, false)
    for x in 1:ncols(c)
        bgcol = Int(colors(c)[x, y-1])
        fgcol = Int(colors(c)[x, y])
        if iscolor
            print(io, Crayon(foreground=fgcol, background=bgcol), '▄')
        else
            print(io, '▄')
        end
    end
    if iscolor
        print(io, Crayon(reset=true))
    end
end
