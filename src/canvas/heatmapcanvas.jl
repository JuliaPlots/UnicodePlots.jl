"""
The `HeatmapCanvas` is also Unicode-based.
It has a half the resolution of the `BlockCanvas`.
This canvas effectively turns every character
into two pixels (top and bottom).
"""
struct HeatmapCanvas <: LookupCanvas
    grid::Array{UInt8,2}
    colors::Array{ColorType,2}
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
    HeatmapCanvas, args...; min_char_width=1, min_char_height=1, kwargs...
)

_toCrayon(c) = c === nothing ? 0 : (c isa Unsigned ? Int(c) : c)

function printrow(io::IO, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2*row
    # extend the plot upwards by half a row
    isodd(size(grid(c), 2)) && (y -= 1)

    iscolor = get(io, :color, false)
    for x in 1:ncols(c)
        if iscolor
            fgcol = _toCrayon(c.colors[x, y])
            if y > 1
                bgcol = _toCrayon(c.colors[x, y - 1])
                print(io, Crayon(foreground=fgcol, background=bgcol), HALF_BLOCK)
            else  # for odd numbers of rows, only print the foreground for the top row
                print(io, Crayon(foreground=fgcol), HALF_BLOCK)
            end
        else
            print(io, HALF_BLOCK)
        end
    end
    iscolor && print(io, Crayon(reset=true))
    nothing
end

function printcolorbarrow(
    io::IO, c::HeatmapCanvas, row::Int, colormap::Any, border::Symbol,
    lim, lim_str, plot_padding, zlabel, max_len, blank::Char
)
    b = bordermap[border]
    min_z, max_z = lim
    label = ""
    if row == 1
        label = lim_str[2]
        # print top border and maximum z value
        print_color(:light_black, io, b[:tl], b[:t], b[:t], b[:tr])
        print(io, plot_padding)
        print_color(:light_black, io, label)
    elseif row == nrows(c)
        label = lim_str[1]
        # print bottom border and minimum z value
        print_color(:light_black, io, b[:bl], b[:b], b[:b], b[:br])
        print(io, plot_padding)
        print_color(:light_black, io, label)
    else
        # print gradient
        print_color(:light_black, io, b[:l])
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
        print_color(:light_black, io, b[:r])
        print(io, plot_padding)
        # print z label
        if row == div(nrows(c), 2) + 1
            label = zlabel
            print(io, label)            
        end
    end
    print(io, repeat(blank, max_len - length(label)))
    nothing
end

