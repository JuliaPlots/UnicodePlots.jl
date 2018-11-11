mutable struct BarplotGraphics{R<:Number} <: GraphicsArea
    bars::Vector{R}
    color::Symbol
    char_width::Int
    max_freq::R
    max_len::Int
    symb::String

    function BarplotGraphics{R}(
            bars::AbstractVector{R},
            char_width::Int,
            color::Symbol,
            symb::String) where R
        @assert length(symb) == 1
        char_width = max(char_width, 10)
        max_freq = maximum(bars)
        max_len = length(string(max_freq))
        char_width = max(char_width, max_len + 7)
        new{R}(bars, color, char_width, max_freq, max_len, symb)
    end
end

nrows(g::BarplotGraphics) = length(g.bars)
ncols(g::BarplotGraphics) = g.char_width

function BarplotGraphics(
        bars::AbstractVector{R},
        char_width::Int;
        color::Symbol = :green,
        symb::String = "■") where {R <: Number}
    BarplotGraphics{R}(bars, char_width, color, symb)
end

function addrow!(g::BarplotGraphics{R}, bars::AbstractVector{R}) where {R <: Number}
    append!(g.bars, bars)
    g.max_freq = maximum(g.bars)
    g.max_len = length(string(g.max_freq))
    g
end

function addrow!(g::BarplotGraphics{R}, bar::Number) where {R <: Number}
    push!(g.bars, R(bar))
    g.max_freq = max(g.max_freq, R(bar))
    g.max_len = length(string(g.max_freq))
    g
end

function printrow(io::IO, g::BarplotGraphics, row::Int)
    0 < row <= nrows(g) || throw(ArgumentError("Argument \"row\" out of bounds: $row"))
    bar = g.bars[row]
    max_bar_width = max(g.char_width - 2 - g.max_len, 1)
    bar_len = g.max_freq > 0 ? round(Int, bar/g.max_freq * max_bar_width, RoundNearestTiesUp) : 0
    bar_str = g.max_freq > 0 ? repeat(g.symb, bar_len) : ""
    bar_lbl = string(bar)
    printstyled(io, bar_str; color = g.color)
    printstyled(io, " ", bar_lbl; color = :white)
    pan_len = max(max_bar_width + 1 + g.max_len - bar_len - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
end
