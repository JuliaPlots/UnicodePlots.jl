mutable struct BarplotGraphics{R<:Number} <: GraphicsArea
    bars::Vector{R}
    colors::Vector{ColorType}
    char_width::Int
    visible::Bool
    maximum::Union{Nothing,Number}
    max_val::Number
    max_len::Int
    symbols::AbstractVector{String}
    xscale  # Union{Symbol,Function} ==> no, we support functors which are <: Any

    function BarplotGraphics(
        bars::AbstractVector{R},
        char_width::Int,
        visible::Bool,
        color::Union{UserColorType,AbstractVector},
        maximum::Union{Nothing,Number},
        symbols::AbstractVector{S},
        xscale,
    ) where {R,S<:Union{Char,String}}
        for s in symbols
            length(s) == 1 || throw(
                ArgumentError("Symbol has to be a single character, got: \"" * s * "\""),
            )
        end
        xscale = scale_callback(xscale)
        char_width = max(char_width, 10)
        max_val, i = findmax(xscale.(bars))
        max_len = length(string(bars[i]))
        char_width = max(char_width, max_len + 7)
        colors = if color isa AbstractVector
            ansi_color.(color)
        else
            fill(ansi_color(color), length(bars))
        end
        new{R}(
            bars,
            colors,
            char_width,
            visible,
            maximum,
            max_val,
            max_len,
            map(string, symbols),
            xscale,
        )
    end
end

nrows(c::BarplotGraphics) = length(c.bars)
ncols(c::BarplotGraphics) = c.char_width

BarplotGraphics(
    bars::AbstractVector{R},
    char_width::Int,
    xscale = :identity;
    visible::Bool = true,
    color::Union{UserColorType,AbstractVector} = :green,
    maximum::Union{Nothing,Number} = nothing,
    symbols = KEYWORDS.symbols,
) where {R<:Number} =
    BarplotGraphics(bars, char_width, visible, color, maximum, symbols, xscale)

function addrow!(
    c::BarplotGraphics{R},
    bars::AbstractVector{R},
    color::Union{UserColorType,AbstractVector} = nothing,
) where {R<:Number}
    append!(c.bars, bars)
    colors = if color isa AbstractVector
        ansi_color.(color)
    else
        fill(suitable_color(c, color), length(bars))
    end
    append!(c.colors, colors)
    c.max_val, i = findmax(c.xscale.(c.bars))
    c.max_len = length(string(c.bars[i]))
    c
end

function addrow!(
    c::BarplotGraphics{R},
    bar::Number,
    color::UserColorType = nothing,
) where {R<:Number}
    push!(c.bars, R(bar))
    push!(c.colors, suitable_color(c, color))
    c.max_val, i = findmax(c.xscale.(c.bars))
    c.max_len = length(string(c.bars[i]))
    c
end

function printrow(io::IO, print_nc, print_col, c::BarplotGraphics, row::Int)
    0 < row ≤ nrows(c) || throw(ArgumentError("Argument \"row\" out of bounds: $row"))
    bar = c.bars[row]
    max_val = c.maximum === nothing ? c.max_val : max(c.max_val, c.maximum)
    max_bar_width = max(c.char_width - 2 - c.max_len, 1)
    val = c.xscale(bar)
    nsyms = length(c.symbols)
    frac = float(max_val > 0 ? max(val, zero(val)) / max_val : 0)
    bar_head = round(Int, frac * max_bar_width, nsyms > 1 ? RoundDown : RoundNearestTiesUp)
    print_col(io, c.colors[row], max_val > 0 ? repeat(c.symbols[nsyms], bar_head) : "")
    if nsyms > 1
        rem = (frac * max_bar_width - bar_head) * (nsyms - 2)
        print_col(io, c.colors[row], rem > 0 ? c.symbols[1 + round(Int, rem)] : " ")
        bar_head += 1  # padding, we printed one more char
    end
    bar_lbl = string(bar)
    if bar ≥ 0
        print_col(io, :normal, " ", bar_lbl)
        len = length(bar_lbl)
    else
        len = -1
    end
    pad_len = max(max_bar_width + 1 + c.max_len - bar_head - len, 0)
    print_nc(io, ' '^round(Int, pad_len))
    nothing
end
