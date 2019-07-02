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

@inline nrows(c::HeatmapCanvas) = div(size(grid(c), 2) + 1, 2)

function HeatmapCanvas(args...; kwargs...)
    CreateLookupCanvas(HeatmapCanvas, args...; min_char_width=1, min_char_height=1, kwargs...)
end

function printrow(io::IO, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2*row
    # extend the plot upwards by half a row
    if isodd(size(grid(c), 2))
        y -= 1
    end
    iscolor = get(io, :color, false)
    for x in 1:ncols(c)
        if iscolor
            fgcol = Int(colors(c)[x, y])
            if (y - 1) > 0
                bgcol = Int(colors(c)[x, y - 1])
                print(io, Crayon(foreground=fgcol, background=bgcol), HALF_BLOCK)
            # for odd numbers of rows, only print the foreground for the top row
            else
                print(io, Crayon(foreground=fgcol), HALF_BLOCK)
            end
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
    min_z = lim[1]
    max_z = lim[2]
    if row == 1
        # print top border and maximum z value
        printstyled(io, b[:tl]; color = :light_black)
        printstyled(io, b[:t]; color = :light_black)
        printstyled(io, b[:t]; color = :light_black)
        printstyled(io, b[:tr]; color = :light_black)
        max_z_str = isinteger(max_z) ? max_z : float_round_log10(max_z)
        print(io, plot_padding)
        printstyled(io, max_z_str; color = :light_black)
    elseif row == nrows(c)
        # print bottom border and minimum z value
        printstyled(io, b[:bl]; color = :light_black)
        printstyled(io, b[:b]; color = :light_black)
        printstyled(io, b[:b]; color = :light_black)
        printstyled(io, b[:br]; color = :light_black)
        min_z_str = isinteger(min_z) ? min_z : float_round_log10(min_z)
        print(io, plot_padding)
        printstyled(io, min_z_str; color = :light_black)
    else
        # print gradient
        printstyled(io, b[:l]; color = :light_black)
        # if min and max are the same, single color
        if min_z == max_z
            bgcol = colormap(1, 1, 1)
            fgcol = bgcol
        # otherwise, blend from min to max
        else
            n = 2*(nrows(c) - 2)
            r = row - 2
            bgcol = colormap(n - (2*r),     1, n)
            fgcol = colormap(n - (2*r + 1), 1, n)
        end
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

