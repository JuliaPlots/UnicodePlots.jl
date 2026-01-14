const DEN_SIGNS = Ref((' ', '░', '▒', '▓', '█'))

"""
Unlike the `BrailleCanvas`, the density canvas does not simply mark a pixel as set.
Instead it increments a counter per character that keeps track of the frequency of pixels drawn in that character.
Together with a variable that keeps track of the maximum frequency, the canvas can thus draw the density of datapoints.
"""
struct DensityCanvas{YS <: Function, XS <: Function, DS <: Function} <: Canvas
    grid::Transpose{UInt64, Matrix{UInt64}}
    colors::Transpose{ColorType, Matrix{ColorType}}
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
    max_density::RefValue{Float64}
    yscale::YS
    xscale::XS
    dscale::DS
end

@inline y_pixel_per_char(::Type{<:DensityCanvas}) = 2
@inline x_pixel_per_char(::Type{<:DensityCanvas}) = 1

function DensityCanvas(
        char_height::Integer,
        char_width::Integer;
        blend::Bool = KEYWORDS.blend,
        visible::Bool = KEYWORDS.visible,
        origin_y::Number = 0.0,
        origin_x::Number = 0.0,
        height::Number = 1.0,
        width::Number = 1.0,
        yflip::Bool = KEYWORDS.yflip,
        xflip::Bool = KEYWORDS.xflip,
        yscale::Union{Symbol, Function} = KEYWORDS.yscale,
        xscale::Union{Symbol, Function} = KEYWORDS.xscale,
        dscale::Union{Symbol, Function} = :identity,
    )
    height > 0 || throw(ArgumentError("`height` has to be positive"))
    width > 0 || throw(ArgumentError("`width` has to be positive"))
    char_height = max(char_height, 5)
    char_width = max(char_width, 5)
    pixel_height = char_height * y_pixel_per_char(DensityCanvas)
    pixel_width = char_width * x_pixel_per_char(DensityCanvas)
    grid = transpose(fill(grid_type(DensityCanvas)(0), char_width, char_height))
    colors = transpose(fill(INVALID_COLOR, char_width, char_height))
    return DensityCanvas(
        grid,
        colors,
        visible,
        blend,
        yflip,
        xflip,
        pixel_height,
        pixel_width,
        Float64(origin_y),
        Float64(origin_x),
        Float64(height),
        Float64(width),
        Ref(-Inf),
        scale_callback(yscale),
        scale_callback(xscale),
        scale_callback(dscale),
    )
end

function pixel!(
        c::DensityCanvas,
        pixel_x::Integer,
        pixel_y::Integer,
        color::ColorType,
        blend::Bool,
    )
    valid_x_pixel(c, pixel_x) || return c
    valid_y_pixel(c, pixel_y) || return c
    char_x, char_y = pixel_to_char_point(c, pixel_x, pixel_y)
    if checkbounds(Bool, c.grid, char_y, char_x)
        c.grid[char_y, char_x] += 1  # count occurrences
        set_color!(c, char_x, char_y, color, blend)
    end
    return c
end

function preprocess!(::IO, c::DensityCanvas)
    c.max_density[] = max(eps(), maximum(c.dscale, c.grid))
    return c -> c.max_density[] = -Inf
end

function print_row(io::IO, _, print_color, c::DensityCanvas, row::Integer)
    1 ≤ row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    signs = DEN_SIGNS[]
    fact = (length(signs) - 1) / c.max_density[]
    for col in 1:ncols(c)
        val = fact * c.dscale(c.grid[row, col])
        print_color(io, c.colors[row, col], signs[round(Int, val, RoundNearestTiesUp) + 1])
    end
    return nothing
end
