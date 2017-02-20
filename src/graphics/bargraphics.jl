type BarplotGraphics{R<:Real} <: GraphicsArea
    bars::Vector{R}
    color::Symbol
    width::Int
    max_freq::R
    max_len::R
    symb::AbstractString

    function (::Type{BarplotGraphics{R}}){R}(
            bars::Vector{R},
            width::Int,
            color::Symbol,
            symb)
        width = max(width, 5)
        max_freq = maximum(bars)
        max_len = length(string(max_freq))
        new{R}(bars, color, width, max_freq, max_len, symb)
    end
end

nrows(c::BarplotGraphics) = length(c.bars)
ncols(c::BarplotGraphics) = c.width

function BarplotGraphics{R<:Real}(
        bars::Vector{R},
        width::Int;
        color::Symbol = :blue,
        symb = "▪")
    BarplotGraphics{R}(bars, width, color, symb)
end

function addrow!{R<:Real}(c::BarplotGraphics{R}, bars::Vector{R})
    append!(c.bars, bars)
    c.max_freq = maximum(c.bars)
    c.max_len = length(string(c.max_freq))
    c
end

function addrow!{R<:Real}(c::BarplotGraphics{R}, bar::R)
    push!(c.bars, bar)
    c.max_freq = max(c.max_freq, bar)
    c.max_len = length(string(c.max_freq))
    c
end

function printrow(io::IO, c::BarplotGraphics, row::Int)
    numrows = nrows(c)
    0 < row <= numrows || throw(ArgumentError("Argument row out of bounds: $row"))
    bar = c.bars[row]
    max_bar_width = max(c.width - 2 - c.max_len, 1)
    bar_len = c.max_freq > 0 ? round(Int, bar/c.max_freq * max_bar_width, RoundNearestTiesUp): 0
    bar_str = c.max_freq > 0 ? repeat(c.symb, bar_len): ""
    bar_lbl = string(bar)
    print_with_color(c.color, io, bar_str)
    print_with_color(:white, io, " ", bar_lbl)
    pan_len = max(max_bar_width + 1 + c.max_len - bar_len - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
end
