mutable struct BarplotGraphics{R <: Number} <: GraphicsArea
    bars::Vector{R}
    color::ColorType
    char_width::Int
    max_freq::Number
    max_len::Int
    symbols::AbstractVector{String}
    transform

    function BarplotGraphics(
        bars::AbstractVector{R},
        char_width::Int,
        color::UserColorType,
        symbols::AbstractVector{S},
        transform
    ) where {R, S <: Union{Char,String}}
        for s ∈ symbols
            length(s) == 1 || throw(
                ArgumentError("Symbol has to be a single character, got: \"" * s * "\"")
            )
        end
        transform_func = transform isa Symbol ? getfield(Main, transform) : transform
        char_width = max(char_width, 10)
        max_freq, i = findmax(transform_func.(bars))
        max_len = length(string(bars[i]))
        char_width = max(char_width, max_len + 7)
        new{R}(bars, crayon_256_color(color), char_width, max_freq, max_len, map(string, symbols), transform_func)
    end
end

nrows(g::BarplotGraphics) = length(g.bars)
ncols(g::BarplotGraphics) = g.char_width

BarplotGraphics(
    bars::AbstractVector{R},
    char_width::Int,
    transform = :identity;
    color::UserColorType = :green,
    symbols = ["■"]
) where {R <: Number} = BarplotGraphics(bars, char_width, crayon_256_color(color), symbols, transform)

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
    nsyms = length(g.symbols)
    frac = float(max_freq > 0 ? max(val, zero(val)) / max_freq : 0)
    bar_head = round(Int, frac * max_bar_width, nsyms > 1 ? RoundDown : RoundNearestTiesUp)
    print_color(g.color, io, max_freq > 0 ? repeat(g.symbols[nsyms], bar_head) : "")
    if nsyms > 1
        rem = (frac * max_bar_width - bar_head) * (nsyms - 2)
        print_color(g.color, io, rem > 0 ? g.symbols[1 + round(Int, rem)] : " ")
        bar_head += 1  # padding, we printed one more char
    end
    bar_lbl = string(bar)
    bar > 0 && print_color(:normal, io, " ", bar_lbl)
    pan_len = max(max_bar_width + 1 + g.max_len - bar_head - length(bar_lbl), 0)
    pad = repeat(" ", round(Int, pan_len))
    print(io, pad)
    nothing
end
