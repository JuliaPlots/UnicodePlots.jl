using StatsBase

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
    width::Int
    left::R
    right::R

    function BoxplotGraphics{R}(
            data::AbstractVector{R},
            width::Int,
            color::Symbol,
            left::R,
            right::R) where R
        width = max(width, 10)
        new{R}(
            [FiveNumberSummary(
                min(data...),
                percentile(data, 25),
                percentile(data, 50),
                percentile(data, 75),
                max(data...)
            )], color, width, left, right)
    end
end

nrows(c::BoxplotGraphics) = 3*length(c.data)
ncols(c::BoxplotGraphics) = c.width

function BoxplotGraphics(
        data::AbstractVector{R},
        width::Int;
        color::Symbol = :blue,
        left::R,
        right::R,
        labels::AbstractVector{<:AbstractString} = []) where {R <: Number}
    BoxplotGraphics{R}(data, width, color, left, right)
end

function addseries!(c::BoxplotGraphics, data::AbstractVector{R}) where {R <: Number}
    append!(c.data, [FiveNumberSummary(
        min(data...),
        percentile(data, 25),
        percentile(data, 50),
        percentile(data, 75),
        max(data...)
    )])
end

function printrow(io::IO, c::BoxplotGraphics, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    series = c.data[Int(ceil(row/3))]

    transform = value -> Int(round((value - c.left)/(c.right - c.left) * c.width))

    seriesRow = Int((row-1) % 3) + 1

    minChar = ['│', '├' , '│'][seriesRow]
    lineChar = [' ', '─' , ' '][seriesRow]
    leftBoxChar = ['┌', '┤' , '└'][seriesRow]
    lineBoxChar = ['─', ' ' , '─'][seriesRow]
    medianChar = ['┬', '│' , '┴'][seriesRow]
    rightBoxChar = ['┐', '├' , '┘'][seriesRow]
    maxChar = ['│', '┤' , '│'][seriesRow]

    line = [' ' for _ in 1:c.width]

    # Draw points first - this is most important, so they'll always be drawn
    # even if there's not enough space
    line[transform(series.minimum)] = minChar
    line[transform(series.lower_quartile)] = leftBoxChar
    line[transform(series.median)] = medianChar
    line[transform(series.upper_quartile)] = rightBoxChar
    line[transform(series.maximum)] = maxChar

    # Fill in gaps with lines
    for i in transform(series.minimum)+1:transform(series.lower_quartile)-1
        line[i] = lineChar
    end
    for i in transform(series.lower_quartile)+1:transform(series.median)-1
        line[i] = lineBoxChar
    end
    for i in transform(series.median)+1:transform(series.upper_quartile)-1
        line[i] = lineBoxChar
    end
    for i in transform(series.upper_quartile)+1:transform(series.maximum)-1
        line[i] = lineChar
    end

    printstyled(io, join(line), color = c.color)
end
