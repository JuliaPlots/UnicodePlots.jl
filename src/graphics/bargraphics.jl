mutable struct BarplotGraphics{R<:Number} <: GraphicsArea
    bars::Vector{R}
    color::Symbol
    width::Int
    max_freq::R
    max_len::Int
    symb::String

    function BarplotGraphics{R}(
            bars::AbstractVector{R},
            width::Int,
            color::Symbol,
            symb::String) where R
        width = max(width, 5)
        max_freq = maximum(bars)
        max_len = length(string(max_freq))
        new{R}(bars, color, width, max_freq, max_len, symb)
    end
end

nrows(c::BarplotGraphics) = length(c.bars)
ncols(c::BarplotGraphics) = c.width

function BarplotGraphics(
        bars::AbstractVector{R},
        width::Int;
        color::Symbol = :blue,
        symb::String = "▪") where {R <: Number}
    BarplotGraphics{R}(bars, width, color, symb)
end

function addrow!(c::BarplotGraphics{R}, bars::AbstractVector{R}) where {R <: Number}
    append!(c.bars, bars)
    c.max_freq = maximum(c.bars)
    c.max_len = length(string(c.max_freq))
    c
end

function addrow!(c::BarplotGraphics{R}, bar::Number) where {R <: Number}
    push!(c.bars, R(bar))
    c.max_freq = max(c.max_freq, R(bar))
    c.max_len = length(string(c.max_freq))
    c
end

function printrow(io::IO, c::BarplotGraphics, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    bar = c.bars[row]
    max_bar_width = max(c.width - 2 - c.max_len, 1)
    bar_len = c.max_freq > 0 ? round(Int, bar/c.max_freq * max_bar_width, RoundNearestTiesUp) : 0
    bar_str = c.max_freq > 0 ? repeat(c.symb, bar_len) : ""
    bar_lbl = string(bar)
    print_with_color(c.color, io, bar_str)
    print_with_color(:white, io, " ", bar_lbl)
    pan_len = max(max_bar_width + 1 + c.max_len - bar_len - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
end
