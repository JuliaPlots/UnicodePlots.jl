struct FiveNumberSummary
    minimum::Float64
    lower_quartile::Float64
    median::Float64
    upper_quartile::Float64
    maximum::Float64
end

struct BoxplotGraphics{R<:Number} <: GraphicsArea
    data::Vector{FiveNumberSummary}
    colors::Vector{ColorType}
    char_width::Int
    visible::Bool
    min_x::RefValue{R}
    max_x::RefValue{R}

    function BoxplotGraphics{R}(
        data::AbstractVector{R},
        char_width::Int,
        visible::Bool,
        color::Union{UserColorType,AbstractVector},
        min_x::R,
        max_x::R,
    ) where {R}
        char_width = max(char_width, 10)
        if min_x == max_x
            min_x -= 1
            max_x += 1
        end
        colors = if color isa AbstractVector
            ansi_color.(color)
        else
            [ansi_color(color)]
        end
        summary = FiveNumberSummary(
            minimum(data),
            percentile(data, 25),
            percentile(data, 50),
            percentile(data, 75),
            maximum(data),
        )
        new{R}([summary], colors, char_width, visible, Ref(min_x), Ref(max_x))
    end
end

@inline nrows(c::BoxplotGraphics) = 3length(c.data)
@inline ncols(c::BoxplotGraphics) = c.char_width

BoxplotGraphics(
    data::AbstractVector{R},
    char_width::Int;
    visible::Bool = true,
    color::Union{UserColorType,AbstractVector} = :green,
    min_x::Number = minimum(data),
    max_x::Number = maximum(data),
) where {R<:Number} =
    BoxplotGraphics{R}(data, char_width, visible, color, R(min_x), R(max_x))

function addseries!(
    c::BoxplotGraphics,
    data::AbstractVector{R},
    color::UserColorType = nothing,
) where {R<:Number}
    mi, ma = extrema(data)
    push!(
        c.data,
        FiveNumberSummary(
            mi,
            percentile(data, 25),
            percentile(data, 50),
            percentile(data, 75),
            ma,
        ),
    )
    push!(c.colors, suitable_color(c, color))
    c.min_x[] = min(mi, c.min_x[])
    c.max_x[] = max(ma, c.max_x[])
    c
end

transform(c::BoxplotGraphics, value) = clamp(
    round(Int, (value - c.min_x[]) / (c.max_x[] - c.min_x[]) * c.char_width),
    1,
    c.char_width,
)

function print_row(io::IO, _, print_color, c::BoxplotGraphics, row::Int)
    0 < row ≤ nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    idx = ceil(Int, row / 3)
    series = c.data[idx]

    series_row = Int((row - 1) % 3) + 1

    min_char = ('╷', '├', '╵')[series_row]
    line_char = (' ', '─', ' ')[series_row]
    left_box_char = ('┌', '┤', '└')[series_row]
    line_box_char = ('─', ' ', '─')[series_row]
    median_char = ('┬', '│', '┴')[series_row]
    right_box_char = ('┐', '├', '┘')[series_row]
    max_char = ('╷', '┤', '╵')[series_row]

    chars = fill(' ', c.char_width)

    # Draw shapes first - this is most important,
    # so they'll always be drawn even if there's not enough space
    chars[transform(c, series.minimum)] = min_char
    chars[transform(c, series.lower_quartile)] = left_box_char
    chars[transform(c, series.median)] = median_char
    chars[transform(c, series.upper_quartile)] = right_box_char
    chars[transform(c, series.maximum)] = max_char

    # Fill in gaps with lines
    for i in (transform(c, series.minimum) + 1):(transform(c, series.lower_quartile) - 1)
        chars[i] = line_char
    end
    for i in (transform(c, series.lower_quartile) + 1):(transform(c, series.median) - 1)
        chars[i] = line_box_char
    end
    for i in (transform(c, series.median) + 1):(transform(c, series.upper_quartile) - 1)
        chars[i] = line_box_char
    end
    for i in (transform(c, series.upper_quartile) + 1):(transform(c, series.maximum) - 1)
        chars[i] = line_char
    end

    print_color(io, c.colors[idx], String(chars))
    nothing
end
