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

function HeatmapCanvas(args...; kwargs...)
    c = CreateLookupCanvas(HeatmapCanvas, args...; min_char_width=1, min_char_height=1, kwargs...)
    fill!(c.colors, 0)  # black background by default
    c
end

function printrow(io::IO, c::HeatmapCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    y = 2row
    # extend the plot upwards by half a row
    isodd(size(grid(c), 2)) && (y -= 1)
    iscolor = get(io, :color, false)
    for x in 1:ncols(c)
        if iscolor
            if (y - 1) > 0
                print_color(c.colors[x, y], io, HALF_BLOCK; bgcol = c.colors[x, y - 1])
            else  # for odd numbers of rows, only print the foreground for the top row
                print_color(c.colors[x, y], io, HALF_BLOCK)
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
        print_color(BORDER_COLOR[], io, b[:tl], b[:t], b[:t], b[:tr])
        print(io, plot_padding)
        print_color(BORDER_COLOR[], io, label)
    elseif row == nrows(c)
        label = lim_str[1]
        # print bottom border and minimum z value
        print_color(BORDER_COLOR[], io, b[:bl], b[:b], b[:b], b[:br])
        print(io, plot_padding)
        print_color(BORDER_COLOR[], io, label)
    else
        # print gradient
        print_color(BORDER_COLOR[], io, b[:l])
        if min_z == max_z  # if min and max are the same, single color
            bgcol = colormap(1, 1, 1)
            fgcol = bgcol
        else  # otherwise, blend from min to max
            n = 2(nrows(c) - 2)
            r = row - 2
            bgcol = colormap(n - 2r,     1, n)
            fgcol = colormap(n - 2r - 1, 1, n)
        end
        @assert 0 <= fgcol <= 255
        @assert 0 <= bgcol <= 255
        print_color(UInt32(fgcol + THRESHOLD), io, HALF_BLOCK; bgcol = UInt32(bgcol + THRESHOLD))
        print(io, HALF_BLOCK, Crayon(reset=true))
        print_color(BORDER_COLOR[], io, b[:r])
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

