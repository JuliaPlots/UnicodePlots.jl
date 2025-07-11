"""
    BarplotGraphics

Structure to hold bar based graphics.
"""
struct BarplotGraphics{R <: Number, F <: Function, XS <: Function} <: GraphicsArea
    bars::Vector{R}
    colors::Vector{ColorType}
    char_width::Int
    visible::Bool
    maximum::Float64
    max_val::RefValue{Float64}
    max_len::RefValue{Int}
    symbols::Vector{Char}
    formatter::F
    xscale::XS

    function BarplotGraphics(
            bars::AbstractVector{R},
            char_width::Int;
            symbols::Union{AbstractVector, Tuple} = KEYWORDS.symbols,
            color::Union{UserColorType, AbstractVector} = :green,
            maximum::Union{Number, Nothing} = nothing,
            formatter::Function = default_formatter((;)),
            visible::Bool = KEYWORDS.visible,
            xscale = KEYWORDS.xscale,
        ) where {R <: Number}
        for s in symbols
            length(s) == 1 ||
                throw(ArgumentError("symbol has to be a single character, got \"$s\""))
        end
        xscale = scale_callback(xscale)
        char_width = max(10, char_width, length(string(bars[argmax(xscale.(bars))])) + 7)
        colors = if color isa AbstractVector
            ansi_color.(color)
        else
            fill(ansi_color(color), length(bars))
        end
        return new{R, typeof(formatter), typeof(xscale)}(
            bars,
            colors,
            char_width,
            visible,
            Float64(something(maximum, -Inf)),
            Ref(-Inf),
            Ref(0),
            collect(map(s -> first(s), symbols)),
            formatter,
            xscale,
        )
    end
end

@inline nrows(c::BarplotGraphics) = length(c.bars)
@inline ncols(c::BarplotGraphics) = c.char_width

function addrow!(
        c::BarplotGraphics{R},
        bars::AbstractVector{R},
        color::Union{UserColorType, AbstractVector} = nothing,
    ) where {R <: Number}
    append!(c.bars, bars)
    colors = if color isa AbstractVector
        ansi_color.(color)
    else
        fill(suitable_color(c, color), length(bars))
    end
    append!(c.colors, colors)
    return c
end

function addrow!(
        c::BarplotGraphics{R},
        bar::Number,
        color::UserColorType = nothing,
    ) where {R <: Number}
    push!(c.bars, R(bar))
    push!(c.colors, suitable_color(c, color))
    return c
end

function preprocess!(::IO, c::BarplotGraphics)
    max_val, i = findmax(c.xscale.(c.bars))
    c.max_val[] = max(max_val, c.maximum)
    c.max_len[] = length(c.formatter(c.bars[i]))
    return c -> (c.max_val[] = -Inf; c.max_len[] = 0)
end

function print_row(io::IO, print_nocol, print_color, c::BarplotGraphics, row::Integer)
    1 ≤ row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    val = (bar = c.bars[row]) |> c.xscale
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
    len = if bar ≥ 0
        bar_lbl = c.formatter(bar)
        print_color(io, nothing, ' ', bar_lbl)
        length(bar_lbl)
    else
        -1
    end
    pad_len = max(max_bar_width + 1 + c.max_len[] - bar_head - len, 0)
    print_nocol(io, ' '^round(Int, pad_len))
    return nothing
end
