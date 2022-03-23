const den_signs = Ref([' ', '░', '▒', '▓', '█'])

"""
Unlike the `BrailleCanvas`, the density canvas
does not simply mark a "pixel" as set.
Instead it increments a counter per character
that keeps track of the frequency of pixels
drawn in that character. Together with a variable
that keeps track of the maximum frequency,
the canvas can thus draw the density of datapoints.
"""
mutable struct DensityCanvas{XS<:Function,YS<:Function} <: Canvas
    grid::Matrix{UInt}
    colors::Matrix{ColorType}
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
    max_density::Float64
end

@inline pixel_width(c::DensityCanvas) = c.pixel_width
@inline pixel_height(c::DensityCanvas) = c.pixel_height
@inline origin_x(c::DensityCanvas) = c.origin_x
@inline origin_y(c::DensityCanvas) = c.origin_y
@inline width(c::DensityCanvas) = c.width
@inline height(c::DensityCanvas) = c.height
@inline nrows(c::DensityCanvas) = size(c.grid, 2)
@inline ncols(c::DensityCanvas) = size(c.grid, 1)

@inline x_pixel_per_char(::Type{C}) where {C<:DensityCanvas} = 1
@inline y_pixel_per_char(::Type{C}) where {C<:DensityCanvas} = 2

function DensityCanvas(
    char_width::Int,
    char_height::Int;
    blend::Bool = true,
    visible::Bool = true,
    origin_x::Number = 0.0,
    origin_y::Number = 0.0,
    width::Number = 1.0,
    height::Number = 1.0,
    xscale::Function = identity,
    yscale::Function = identity,
)
    width > 0 || throw(ArgumentError("width has to be positive"))
    height > 0 || throw(ArgumentError("height has to be positive"))
    char_width   = max(char_width, 5)
    char_height  = max(char_height, 5)
    pixel_width  = char_width * x_pixel_per_char(DensityCanvas)
    pixel_height = char_height * y_pixel_per_char(DensityCanvas)
    grid         = fill(UInt(0), char_width, char_height)
    colors       = fill(INVALID_COLOR, char_width, char_height)
    DensityCanvas(
        grid,
        colors,
        blend,
        visible,
        pixel_width,
        pixel_height,
        Float64(origin_x),
        Float64(origin_y),
        Float64(width),
        Float64(height),
        xscale,
        yscale,
        1.0,
    )
end

function pixel_to_char_point(c::DensityCanvas, pixel_x::Number, pixel_y::Number)
    pixel_x = pixel_x < c.pixel_width ? pixel_x : pixel_x - 1
    pixel_y = pixel_y < c.pixel_height ? pixel_y : pixel_y - 1
    cw, ch = size(c.grid)
    char_x = floor(Int, pixel_x / c.pixel_width * cw) + 1
    char_y = floor(Int, pixel_y / c.pixel_height * ch) + 1
    char_x, char_y
end

function pixel!(c::DensityCanvas, pixel_x::Int, pixel_y::Int, color::UserColorType)
    0 <= pixel_x <= c.pixel_width || return c
    0 <= pixel_y <= c.pixel_height || return c
    char_x, char_y = pixel_to_char_point(c, pixel_x, pixel_y)
    c.grid[char_x, char_y] += 1
    c.max_density = max(c.max_density, c.grid[char_x, char_y])
    set_color!(c.colors, char_x, char_y, ansi_color(color), c.blend)
    c
end

function printrow(io::IO, print_nc, print_col, c::DensityCanvas, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    signs = den_signs[]
    y = row
    den_sign_count = length(signs)
    val_scale = (den_sign_count - 1) / c.max_density
    for x in 1:ncols(c)
        den_index = round(Int, c.grid[x, y] * val_scale, RoundNearestTiesUp) + 1
        print_col(io, c.colors[x, y], signs[den_index])
    end
    nothing
end
