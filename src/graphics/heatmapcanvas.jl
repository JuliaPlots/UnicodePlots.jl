"""
The `HeatmapCanvas` is also Unicode-based.
It has a quarter of the resolution of the `BlockCanvas`.
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
@inline y_pixel_per_char(::Type{HeatmapCanvas}) = 1

@inline lookup_encode(c::HeatmapCanvas) = [0, 1]
@inline lookup_decode(c::HeatmapCanvas) = ['█']

function HeatmapCanvas(args...; nargs...)
    CreateLookupCanvas(HeatmapCanvas, args...; nargs...)
end
