struct BarplotGraphics{R<:Number,XS<:Function} <: GraphicsArea
    bars::Vector{R}
    colors::Vector{ColorType}
    char_width::Int
    visible::Bool
    maximum::Float64
    max_val::RefValue{Float64}
    max_len::RefValue{Int}
    symbols::Vector{Char}
    xscale::XS

    function BarplotGraphics(
        bars::AbstractVector{R},
        char_width::Int,
        visible::Bool,
        color::Union{UserColorType,AbstractVector},
        maximum::Union{Nothing,Number},
        symbols::Union{NTuple{N,S},AbstractVector{S}},
        xscale,
    ) where {R<:Number,N,S<:Union{Char,String}}
        for s in symbols
            length(s) == 1 || throw(
                ArgumentError("Symbol has to be a single character, got: \"" * s * "\""),
            )
        end
        xscale = scale_callback(xscale)
        char_width = max(10, char_width, length(string(bars[argmax(xscale.(bars))])) + 7)
        colors = if color isa AbstractVector
            ansi_color.(color)
        else
            fill(ansi_color(color), length(bars))
        end
        new{R,typeof(xscale)}(
            bars,
            colors,
            char_width,
            visible,
            float(something(maximum, -Inf)),
            Ref(-Inf),
            Ref(0),
            collect(map(s -> first(s), symbols)),
            xscale,
        )
    end
end

@inline nrows(c::BarplotGraphics) = length(c.bars)
@inline ncols(c::BarplotGraphics) = c.char_width

BarplotGraphics(
    bars::AbstractVector{<:Number},
    char_width::Int,
    xscale = :identity;
    visible::Bool = true,
    color::Union{UserColorType,AbstractVector} = :green,
    maximum::Union{Nothing,Number} = nothing,
    symbols = KEYWORDS.symbols,
) = BarplotGraphics(bars, char_width, visible, color, maximum, symbols, xscale)

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
    c
end

function addrow!(
    c::BarplotGraphics{R},
    bar::Number,
    color::UserColorType = nothing,
) where {R<:Number}
    push!(c.bars, R(bar))
    push!(c.colors, suitable_color(c, color))
    c
end

function preprocess!(c::BarplotGraphics)
    max_val, i = findmax(c.xscale.(c.bars))
    c.max_val[] = max(max_val, c.maximum)
    c.max_len[] = length(string(c.bars[i]))
    c -> (c.max_val[] = -Inf; c.max_len[] = 0)
end

function print_row(io::IO, print_nocol, print_color, c::BarplotGraphics, row::Int)
    0 < row ≤ nrows(c) || throw(ArgumentError("Argument \"row\" out of bounds: $row"))
    bar = c.bars[row]
    val = c.xscale(bar)
    nsyms = length(c.symbols)
    frac = c.max_val[] > 0 ? max(val, zero(val)) / c.max_val[] : 0.0
    max_bar_width = max(c.char_width - 2 - c.max_len[], 1)
    bar_head = round(Int, frac * max_bar_width, nsyms > 1 ? RoundDown : RoundNearestTiesUp)
    print_color(io, c.colors[row], c.symbols[nsyms]^bar_head)
    if nsyms > 1
        rem = (frac * max_bar_width - bar_head) * (nsyms - 2)
        print_color(io, c.colors[row], rem > 0 ? c.symbols[1 + round(Int, rem)] : ' ')
        bar_head += 1  # padding, we printed one more char
    end
    bar_lbl = string(bar)
    if bar ≥ 0
        print_color(io, nothing, ' ', bar_lbl)
        len = length(bar_lbl)
    else
        len = -1
    end
    pad_len = max(max_bar_width + 1 + c.max_len[] - bar_head - len, 0)
    print_nocol(io, ' '^round(Int, pad_len))
    nothing
end
