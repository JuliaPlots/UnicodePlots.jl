abstract type BarplotGraphicsArea <: GraphicsArea end

mutable struct BarplotGraphics{R<:Number} <: BarplotGraphicsArea
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

mutable struct BarplotTransform{R′<:Number,R<:Number,T<:Function} <: BarplotGraphicsArea
    graphics::BarplotGraphics{R}
    bars′::Vector{R′}
    max_freq′::R′
    transform::T
end

nrows(c::BarplotGraphics) = length(c.bars)
ncols(c::BarplotGraphics) = c.width

nrows(c::BarplotTransform) = length(c.graphics.bars)
ncols(c::BarplotTransform) = c.graphics.width

function BarplotGraphics(
        bars::AbstractVector{R},
        width::Int;
        color::Symbol = :blue,
        symb::String = "▪") where {R <: Number}
    BarplotGraphics{R}(bars, width, color, symb)
end

function BarplotTransform(
        bars::AbstractVector{R},
        width::Int,
        transform::T;
        color::Symbol = :blue,
        symb::String = "▪") where {R <: Number, T <: Function}
    g = BarplotGraphics(bars, width, color=color, symb=symb)
    bars′ = transform.(bars)
    max_freq′ = transform(g.max_freq)
    BarplotTransform{eltype(bars′),R,T}(g, bars′, max_freq′, transform)
end

function barplotgraphics(bars::AbstractVector,
                         width::Int,
                         ::typeof(identity);
                         color::Symbol = :blue,
                         symb::String = "▪")
    BarplotGraphics(bars, width, color=color, symb=symb)
end
function barplotgraphics(bars::AbstractVector,
                         width::Int,
                         transform::Function;
                         color::Symbol = :blue,
                         symb::String = "▪")
    BarplotTransform(bars, width, transform, color=color, symb=symb)
end
function barplotgraphics(bars::AbstractVector,
                         width::Int;
                         transform::Function=identity,
                         color::Symbol = :blue,
                         symb::String = "▪")
    barplotgraphics(bars, width, transform, color=color, symb=symb)
end

function addrow!(c::BarplotGraphics{R}, bars::AbstractVector{R}) where {R <: Number}
    append!(c.bars, bars)
    c.max_freq = maximum(c.bars)
    c.max_len = length(string(c.max_freq))
    c
end
function addrow!(c::BarplotTransform{R′,R}, bars::AbstractVector{R}
                ) where {R′ <: Number, R <: Number}
    addrow!(c.graphics, bars)
    append!(c.bars′, c.transform.(bars))
    c.max_freq′ = maximum(c.bars′)
    c
end

function addrow!(c::BarplotGraphics{R}, bar::Number) where {R <: Number}
    push!(c.bars, R(bar))
    c.max_freq = max(c.max_freq, R(bar))
    c.max_len = length(string(c.max_freq))
    c
end
function addrow!(c::BarplotTransform{R′,R}, bar::Number) where {R′ <: Number, R <: Number}
    addrow!(c.graphics, bar)
    push!(c.bars′, R′(bar))
    c.max_freq′ = max(c.max_freq′, R′(bar))
    c
end

function printrow(io::IO, c::BarplotGraphics, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    bar = c.bars[row]
    max_bar_width = max(c.width - 2 - c.max_len, 1)
    bar_len = c.max_freq > 0 ? round(Int, bar/c.max_freq * max_bar_width, RoundNearestTiesUp) : 0
    bar_str = c.max_freq > 0 ? repeat(c.symb, bar_len) : ""
    bar_lbl = string(bar)
    printstyled(io, bar_str; color = c.color)
    printstyled(io, " ", bar_lbl; color = :white)
    pan_len = max(max_bar_width + 1 + c.max_len - bar_len - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
end
function printrow(io::IO, c::BarplotTransform, row::Int)
    0 < row <= nrows(c) || throw(ArgumentError("Argument row out of bounds: $row"))
    bar′ = c.bars′[row]
    bar = c.graphics.bars[row]
    max_bar_width = max(c.graphics.width - 2 - c.graphics.max_len, 1)
    bar_len = c.max_freq′ > 0 ? round(Int, bar′/c.max_freq′ * max_bar_width, RoundNearestTiesUp) : 0
    bar_str = c.max_freq′ > 0 ? repeat(c.graphics.symb, bar_len) : ""
    bar_lbl = string(bar)
    printstyled(io, bar_str; color = c.graphics.color)
    printstyled(io, " ", bar_lbl; color = :white)
    pan_len = max(max_bar_width + 1 + c.graphics.max_len - bar_len - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
end
