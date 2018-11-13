struct FiveNumberSummary
    minimum::Float64
    lower_quartile::Float64
    median::Float64
    upper_quartile::Float64
    maximum::Float64
end

mutable struct BoxplotGraphics{R<:Number} <: GraphicsArea
    data::Vector{FiveNumberSummary}
    color::Symbol
    char_width::Int
    min_x::R
    max_x::R

    function BoxplotGraphics{R}(
            data::AbstractVector{R},
            char_width::Int,
            color::Symbol,
            min_x::R,
            max_x::R) where R
        char_width = max(char_width, 10)
        if min_x == max_x
            min_x = min_x - 1
            max_x = max_x + 1
        end
        new{R}(
            [FiveNumberSummary(
                minimum(data),
                percentile(data, 25),
                percentile(data, 50),
                percentile(data, 75),
                maximum(data)
            )],
            color, char_width, min_x, max_x
        )
    end
end

nrows(c::BoxplotGraphics) = 3*length(c.data)
ncols(c::BoxplotGraphics) = c.char_width

function BoxplotGraphics(
        data::AbstractVector{R},
        char_width::Int;
        color::Symbol = :green,
        min_x::Number = minimum(data),
        max_x::Number = maximum(data)) where {R <: Number}
    BoxplotGraphics{R}(data, char_width, color, R(min_x), R(max_x))
end

function addseries!(c::BoxplotGraphics, data::AbstractVector{R}) where {R <: Number}
    mi, ma = extrema(data)
    push!(c.data, FiveNumberSummary(
        mi,
        percentile(data, 25),
        percentile(data, 50),
        percentile(data, 75),
        ma
    ))
    c.min_x = min(mi, c.min_x)
    c.max_x = max(ma, c.max_x)
    c
end

function printrow(io::IO, c::BoxplotGraphics, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    series = c.data[ceil(Int, row/3)]

    function transform(value)
        clamp(round(Int, (value - c.min_x) / (c.max_x - c.min_x) * c.char_width), 1, c.char_width)
    end

    series_row = Int((row-1) % 3) + 1

    min_char = ['╷', '├' , '╵'][series_row]
    line_char = [' ', '─' , ' '][series_row]
    left_box_char = ['┌', '┤' , '└'][series_row]
    line_box_char = ['─', ' ' , '─'][series_row]
    median_char = ['┬', '│' , '┴'][series_row]
    right_box_char = ['┐', '├' , '┘'][series_row]
    max_char = ['╷', '┤' , '╵'][series_row]

    line = [' ' for _ in 1:c.char_width]

    # Draw shapes first - this is most important,
    # so they'll always be drawn even if there's not enough space
    line[transform(series.minimum)] = min_char
    line[transform(series.lower_quartile)] = left_box_char
    line[transform(series.median)] = median_char
    line[transform(series.upper_quartile)] = right_box_char
    line[transform(series.maximum)] = max_char

    # Fill in gaps with lines
    for i in transform(series.minimum)+1:transform(series.lower_quartile)-1
        line[i] = line_char
    end
    for i in transform(series.lower_quartile)+1:transform(series.median)-1
        line[i] = line_box_char
    end
    for i in transform(series.median)+1:transform(series.upper_quartile)-1
        line[i] = line_box_char
    end
    for i in transform(series.upper_quartile)+1:transform(series.maximum)-1
        line[i] = line_char
    end

    printstyled(io, join(line), color = c.color)
end
