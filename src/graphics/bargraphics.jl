mutable struct BarplotGraphics{R<:Number} <: GraphicsArea
    bars::Vector{R}
    color::Symbol
    char_width::Int
    max_freq::Number
    max_len::Int
    symb::String
    transform

    function BarplotGraphics(
            bars::AbstractVector{R},
            char_width::Int,
            color::Symbol,
            symb::Union{Char,String},
            transform) where {R}
        length(symb) == 1 || throw(ArgumentError("The symbol to print has to be a single character, got: \"" * symb * "\""))
        char_width = max(char_width, 10)
        max_freq, i = findmax(transform.(bars))
        max_len = length(string(bars[i]))
        char_width = max(char_width, max_len + 7)
        new{R}(bars, color, char_width, max_freq, max_len, string(symb), transform)
    end
end

nrows(g::BarplotGraphics) = length(g.bars)
ncols(g::BarplotGraphics) = g.char_width

function BarplotGraphics(
        bars::AbstractVector{R},
        char_width::Int,
        transform = identity;
        color::Symbol = :green,
        symb = "■") where {R <: Number}
    BarplotGraphics(bars, char_width, color, symb, transform)
end

function addrow!(g::BarplotGraphics{R}, bars::AbstractVector{R}) where {R <: Number}
    append!(g.bars, bars)
    g.max_freq, i = findmax(g.transform.(g.bars))
    g.max_len = length(string(g.bars[i]))
    g
end

function addrow!(g::BarplotGraphics{R}, bar::Number) where {R <: Number}
    push!(g.bars, R(bar))
    g.max_freq, i = findmax(g.transform.(g.bars))
    g.max_len = length(string(g.bars[i]))
    g
end

function printrow(io::IO, g::BarplotGraphics, row::Int)
    0 < row <= nrows(g) || throw(ArgumentError("Argument \"row\" out of bounds: $row"))
    bar = g.bars[row]
    max_freq = g.max_freq
    max_bar_width = max(g.char_width - 2 - g.max_len, 1)
    val = g.transform(bar)
    bar_len = max_freq > 0 ? round(Int, max(val, zero(val))/max_freq * max_bar_width, RoundNearestTiesUp) : 0
    bar_str = max_freq > 0 ? repeat(g.symb, bar_len) : ""
    bar_lbl = string(bar)
    printstyled(io, bar_str; color = g.color)
    printstyled(io, " ", bar_lbl; color = :normal)
    pan_len = max(max_bar_width + 1 + g.max_len - bar_len - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
end
