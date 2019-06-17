using Crayons

"""
The `HeatmapCanvas` is also Unicode-based.
It has a half the resolution of the `BlockCanvas`.
This canvas effectively turns every character
into two pixels (top and bottom).
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

const HALF_BLOCK = '▄'
@inline x_pixel_per_char(::Type{HeatmapCanvas}) = 1
@inline y_pixel_per_char(::Type{HeatmapCanvas}) = 2

@inline lookup_encode(c::HeatmapCanvas) = [0 0; 1 1]
@inline lookup_decode(c::HeatmapCanvas) = [HALF_BLOCK; HALF_BLOCK]

@inline nrows(c::HeatmapCanvas) = div(size(grid(c), 2), 2)

function HeatmapCanvas(args...; nargs...)
    CreateLookupCanvas(HeatmapCanvas, args...; nargs...)
end

function printrow(io::IO, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2*row
    iscolor = get(io, :color, false)
    for x in 1:ncols(c)
        if iscolor
            bgcol = Int(colors(c)[x, y-1])
            fgcol = Int(colors(c)[x, y])
            print(io, Crayon(foreground=fgcol, background=bgcol), HALF_BLOCK)
        else
            print(io, HALF_BLOCK)
        end
    end
    if iscolor
        print(io, Crayon(reset=true))
    end
end

function printcolorbarrow(io::IO, c::HeatmapCanvas, row::Int, colormap::Any, border::Symbol, lim, plot_padding, zlabel)
    b = bordermap[border]
    if row == 1
        # print top border and maximum z value
        printstyled(io, b[:tl]; color = :light_black)
        printstyled(io, b[:t]; color = :light_black)
        printstyled(io, b[:t]; color = :light_black)
        printstyled(io, b[:tr]; color = :light_black)
        max_z = lim[2]
        max_z_str = isinteger(max_z) ? max_z : float_round_log10(max_z)
        print(io, plot_padding)
        printstyled(io, max_z_str; color = :light_black)
    elseif row == nrows(c)
        # print bottom border and minimum z value
        printstyled(io, b[:bl]; color = :light_black)
        printstyled(io, b[:b]; color = :light_black)
        printstyled(io, b[:b]; color = :light_black)
        printstyled(io, b[:br]; color = :light_black)
        min_z = lim[1]
        min_z_str = isinteger(min_z) ? min_z : float_round_log10(min_z)
        print(io, plot_padding)
        printstyled(io, min_z_str; color = :light_black)
    else
        # print gradient
        printstyled(io, b[:l]; color = :light_black)
        n = 2*nrows(c)
        bgcol = colormap(n - 2*row + 2, 1, n)
        fgcol = colormap(n - 2*row + 1, 1, n)
        print(io, Crayon(foreground=fgcol, background=bgcol), HALF_BLOCK)
        print(io, HALF_BLOCK)
        print(io, Crayon(reset=true))
        printstyled(io, b[:r]; color = :light_black)

        # print z label
        if row == div(nrows(c), 2) + 1
            print(io, plot_padding)
            print(io, zlabel)
        end
    end
end

