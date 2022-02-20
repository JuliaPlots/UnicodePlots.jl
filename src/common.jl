#! format: off
const BLANK = 0x0020
const BLANK_BRAILLE = 0x2800
const FULL_BRAILLE = 0x28ff

const BORDER_SOLID = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = '─',
    l = '│',
    b = '─',
    r = '│',
)
const BORDER_CORNERS = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = ' ',
    l = ' ',
    b = ' ',
    r = ' ',
)
const BORDER_BARPLOT = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = ' ',
    l = '┤',
    b = ' ',
    r = ' ',
)
const BORDER_BOLD = (
    tl = '┏',
    tr = '┓',
    bl = '┗',
    br = '┛',
    t = '━',
    l = '┃',
    b = '━',
    r = '┃',
)
const BORDER_NONE = (
    tl = ' ',
    tr = ' ',
    bl = ' ',
    br = ' ',
    t = ' ',
    l = ' ',
    b = ' ',
    r = ' ',
)
const BORDER_BNONE = (
    tl = Char(BLANK_BRAILLE),
    tr = Char(BLANK_BRAILLE),
    bl = Char(BLANK_BRAILLE),
    br = Char(BLANK_BRAILLE),
    t = Char(BLANK_BRAILLE),
    l = Char(BLANK_BRAILLE),
    b = Char(BLANK_BRAILLE),
    r = Char(BLANK_BRAILLE),
)
const BORDER_DASHED = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = '╌',
    l = '┊',
    b = '╌',
    r = '┊',
)
const BORDER_DOTTED = (
    tl = '⡤',
    tr = '⢤',
    bl = '⠓',
    br = '⠚',
    t = '⠤',
    l = '⡇',
    b = '⠒',
    r = '⢸',
)
const BORDER_ASCII = (
    tl = '+',
    tr = '+',
    bl = '+',
    br = '+',
    t = '-',
    l = '|',
    b = '-',
    r = '|',
)
const BORDERMAP = (
    solid   = BORDER_SOLID,
    corners = BORDER_CORNERS,
    barplot = BORDER_BARPLOT,
    bold    = BORDER_BOLD,
    none    = BORDER_NONE,
    bnone   = BORDER_BNONE,
    dashed  = BORDER_DASHED,
    dotted  = BORDER_DOTTED,
    ascii   = BORDER_ASCII,
)
const MARKERS = (
    circle    = '⚬',
    rect      = '▫',
    diamond   = '◇',
    hexagon   = '⬡',
    cross     = '✚',
    xcross    = '✖',
    utriangle = '△',
    dtriangle = '▽',
    rtriangle = '▷',
    ltriangle = '◁',
    pentagon  = '⬠',
    star4     = '✦',
    star5     = '★',
    star6     = '✶',
    star8     = '✴',
    vline     = '|',
    hline     = '―',
    (+)       = '+',
    (x)       = '⨯',
)
const SUPERSCRIPT = Dict(
    # '.' => '‧',  # U+2027: Hyphenation Point
    # '.' => '˙',  # U+02D9: Dot Above
    # '.' => '⸳',  # U+2E33: Raised Dot
    # '.' => '⋅',  # U+22C5: Dot Operator
    # '.' => '·',  # U+00B7: Middle Dot
    '.' => '⸱',  # U+2E31: Word Separator Middle Dot
    '-' => '⁻',
    '+' => '⁺',
    '0' => '⁰',
    '1' => '¹',
    '2' => '²',
    '3' => '³',
    '4' => '⁴',
    '5' => '⁵',
    '6' => '⁶',
    '7' => '⁷',
    '8' => '⁸',
    '9' => '⁹',
)
const COLOR_CYCLE = (:green, :blue, :red, :magenta, :yellow, :cyan)

# standard terminals seem to respect a 4:3 aspect ratio
# unix.stackexchange.com/questions/148569/standard-terminal-font-aspect-ratio
# retrocomputing.stackexchange.com/questions/5629/why-did-80x25-become-the-text-monitor-standard
const ASPECT_RATIO = 4 / 3

# default display size for the default BrailleCanvas (which has aspect ratio = 2) ==> (40, 15)
const DEFAULT_HEIGHT = Ref(15)
const DEFAULT_WIDTH = Ref(round(Int, DEFAULT_HEIGHT[] * 2ASPECT_RATIO))

const MarkerType = Union{Symbol,Char,AbstractString}
const UserColorType = Union{Integer,Symbol,NTuple{3,Integer},Nothing}  # allowed color type
const JuliaColorType = Union{Symbol,Int}  # color type for printstyled (defined in base/util.jl)
const ColorType = Union{Nothing,UInt8}  # internal UnicodePlots color type

const FSCALES = (identity = identity, ln = log, log2 = log2, log10 = log10)  # forward
const ISCALES = (identity = identity, ln = exp, log2 = exp2, log10 = exp10)  # inverse
const BASES = (identity = nothing, ln = "ℯ", log2 = "2", log10 = "10")

#! format: on

function default_size!(;
    width::Union{Integer,Nothing} = nothing,
    height::Union{Integer,Nothing} = nothing,
)
    @assert (width === nothing) ⊻ (height === nothing)
    if width !== nothing
        DEFAULT_WIDTH[] = width
        DEFAULT_HEIGHT[] = round(Int, width / 2ASPECT_RATIO)
    elseif height !== nothing
        DEFAULT_HEIGHT[] = height
        DEFAULT_WIDTH[] = round(Int, height * 2ASPECT_RATIO)
    end
    return
end

function char_marker(marker::MarkerType)::Char
    if marker isa Symbol
        get(MARKERS, marker, MARKERS[:circle])
    else
        length(marker) == 1 ||
            throw(ArgumentError("`marker` keyword has a non unit length"))
        marker[1]
    end
end

iterable(obj::AbstractVector) = obj
iterable(obj) = Iterators.repeated(obj)

function transform_name(tr, basename = "")
    name = string(tr isa Union{Symbol,Function} ? tr : typeof(tr))  # typeof(...) for functors
    name == "identity" && return basename
    name = occursin("#", name) ? "custom" : name
    string(basename, " [", name, "]")
end

as_float(x) = eltype(x) <: AbstractFloat ? x : float.(x)

roundable(num::Number) = isinteger(num) & (typemin(Int) <= num < typemax(Int))
compact_repr(num::Number) = repr(num, context = :compact => true)

ceil_neg_log10(x) =
    roundable(-log10(x)) ? ceil(Integer, -log10(x)) : floor(Integer, -log10(x))
round_up_tick(x::F, m) where {F} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? ceil(x, digits = ceil_neg_log10(m)) :
            -floor(-x, digits = ceil_neg_log10(m))
        )
    ) |> F
round_down_tick(x::F, m) where {F} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? floor(x, digits = ceil_neg_log10(m)) :
            -ceil(-x, digits = ceil_neg_log10(m))
        )
    ) |> F
round_up_subtick(x::F, m) where {F} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? ceil(x, digits = ceil_neg_log10(m) + 1) :
            -floor(-x, digits = ceil_neg_log10(m) + 1)
        )
    ) |> F
round_down_subtick(x::F, m) where {F} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? floor(x, digits = ceil_neg_log10(m) + 1) :
            -ceil(-x, digits = ceil_neg_log10(m) + 1)
        )
    ) |> F
float_round_log10(x::F, m) where {F<:AbstractFloat} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? round(x, digits = ceil_neg_log10(m) + 1) :
            -round(-x, digits = ceil_neg_log10(m) + 1)
        )
    ) |> F
float_round_log10(x::Integer, m) = float_round_log10(float(x), m)
float_round_log10(x) = x > 0 ? float_round_log10(x, x) : float_round_log10(x, -x)

number_unit(x::AbstractVector{<:Quantity}) = ustrip.(x), x |> first |> unit |> string
number_unit(x::Quantity) = ustrip(x), x |> unit |> string
number_unit(x::AbstractVector) = x, nothing
number_unit(x::Number) = x, nothing

unit_label(label::AbstractString, unit::AbstractString) =
    label == "" ? unit : "$label ($unit)"
unit_label(label::AbstractString, unit::Nothing) = label

function superscript(s::AbstractString)
    v = collect(s)
    for (i, k) in enumerate(v)
        v[i] = get(SUPERSCRIPT, k, k)
    end
    String(v)
end

function plotting_range(xmin, xmax)
    xmin, xmax = float(xmin), float(xmax)
    diff = xmax - xmin
    xmax = round_up_tick(xmax, diff)
    xmin = round_down_tick(xmin, diff)
    xmin, xmax
end

function plotting_range_narrow(xmin, xmax)
    xmin, xmax = float(xmin), float(xmax)
    diff = xmax - xmin
    xmax = round_up_subtick(xmax, diff)
    xmin = round_down_subtick(xmin, diff)
    xmin, xmax
end

scale_callback(scale) = scale isa Symbol ? FSCALES[scale] : scale

extend_limits(vec, limits) = extend_limits(vec, limits, :identity)

function extend_limits(vec, limits, scale::Union{Symbol,Function})
    scale = scale_callback(scale)
    mi, ma = as_float(extrema(limits))
    if mi == 0 && ma == 0
        mi, ma = as_float(extrema(vec))
    end
    if ma - mi == 0
        ma = mi + 1
        mi = mi - 1
    end
    if scale != identity
        scale(mi), scale(ma)
    else
        all(iszero.(limits)) ? plotting_range_narrow(mi, ma) : (mi, ma)
    end
end

sort_by_keys(dict::Dict) = sort!(collect(dict), by = x -> x[1])

function sorted_keys_values(dict::Dict; k2s = true)
    if k2s  # check and force key type to be of AbstractString type if necessary
        kt, vt = eltype(dict).types
        if !(kt <: AbstractString)
            dict = Dict(string(k) => v for (k, v) in pairs(dict))
        end
    end
    keys_vals = sort_by_keys(dict)
    first.(keys_vals), last.(keys_vals)
end

print_color(color::UserColorType, io::IO, args...) =
    printstyled(io, string(args...); color = julia_color(color))

function crayon_256_color(color::UserColorType)::ColorType
    color in (:normal, :default, :nothing, nothing) && return nothing
    ansicolor = Crayons._parse_color(color)
    if ansicolor.style == Crayons.COLORS_16
        return Crayons.val(ansicolor) % 60
    elseif ansicolor.style == Crayons.COLORS_24BIT
        return Crayons.val(Crayons.to_256_colors(ansicolor))
    end
    Crayons.val(ansicolor)
end

complement(color) = (col = crayon_256_color(color)) === nothing ? nothing : ~col

julia_color(color::Integer)::JuliaColorType = Int(color)
julia_color(color::Nothing)::JuliaColorType = :normal
julia_color(color::Symbol)::JuliaColorType = color
julia_color(color)::JuliaColorType = julia_color(crayon_256_color(color))

@inline function set_color!(
    colors::Matrix{ColorType},
    x::Int,
    y::Int,
    color::UInt8,
    blend::Bool,
)
    if colors[x, y] === nothing || !blend
        colors[x, y] = color
    else
        colors[x, y] |= color
    end
    nothing
end

@inline set_color!(colors::Matrix{ColorType}, x::Int, y::Int, color::Nothing, args...) =
    (colors[x, y] = color; nothing)

out_stream_size(out_stream::Union{Nothing,IO}) =
    out_stream === nothing ? (DEFAULT_WIDTH[], DEFAULT_HEIGHT[]) : displaysize(out_stream)
out_stream_width(out_stream::Union{Nothing,IO})::Int = out_stream_size(out_stream)[1]
out_stream_height(out_stream::Union{Nothing,IO})::Int = out_stream_size(out_stream)[2]

function _handle_deprecated_symb(symb, symbols)
    if symb === nothing
        symbols
    else
        Base.depwarn(
            "The keyword `symb` is deprecated in favor of `symbols`",
            :BarplotGraphics,
        )
        [symb]
    end
end
