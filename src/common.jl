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
const COLOR_CYCLE = :green, :blue, :red, :magenta, :yellow, :cyan
const BORDER_COLOR = Ref(:light_black)

# standard terminals seem to respect a 4:3 aspect ratio
# unix.stackexchange.com/questions/148569/standard-terminal-font-aspect-ratio
# retrocomputing.stackexchange.com/questions/5629/why-did-80x25-become-the-text-monitor-standard
const ASPECT_RATIO = 4 / 3

# default display size for the default BrailleCanvas (which has aspect ratio = 2) ==> (40, 15)
const DEFAULT_HEIGHT = Ref(15)
const DEFAULT_WIDTH = Ref(round(Int, DEFAULT_HEIGHT[] * 2ASPECT_RATIO))

const MarkerType = Union{Symbol,Char,AbstractString}
const UserColorType = Union{Integer,Symbol,NTuple{3,Integer},Nothing}  # allowed color type
const BaseColorType = Union{Symbol,Int}  # color type for Base.printstyled (defined in base/util.jl)...
const ColorType = UInt32  # internal UnicodePlots color type (canvas)

const THRESHOLD = UInt32(256^3)
const CRAYONS_FAST = Ref(true)
const COLORDEPTH = Ref(Crayons.COLORS_256)
const INVALID_COLOR = typemax(ColorType)

const FSCALES = (identity = identity, ln = log, log2 = log2, log10 = log10)  # forward
const ISCALES = (identity = identity, ln = exp, log2 = exp2, log10 = exp10)  # inverse
const BASES = (identity = nothing, ln = "ℯ", log2 = "2", log10 = "10")

const EMPTY_STYLES = Tuple(Crayons.ANSIStyle() for _ in 1:9)
const RESET = Crayons.CSI * "0" * Crayons.END_ANSI

#! format: on

# see gist.github.com/XVilka/8346728#checking-for-colorterm
is_24bit_supported() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

colordepth() = COLORDEPTH[] == Crayons.COLORS_256 ? 8 : 24

function colordepth!(depth)
    if depth == 8
        COLORDEPTH[] = Crayons.COLORS_256
    elseif depth == 24
        COLORDEPTH[] = Crayons.COLORS_24BIT
    else
        error("Unsupported bit depth=$depth, choose 8 or 24.")
    end
end

__init__() = is_24bit_supported() && colordepth!(24)

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
round_up_tick(x::T, m) where {T} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? ceil(x, digits = ceil_neg_log10(m)) :
            -floor(-x, digits = ceil_neg_log10(m))
        )
    ) |> T
round_down_tick(x::T, m) where {T} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? floor(x, digits = ceil_neg_log10(m)) :
            -ceil(-x, digits = ceil_neg_log10(m))
        )
    ) |> T
round_up_subtick(x::T, m) where {T} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? ceil(x, digits = ceil_neg_log10(m) + 1) :
            -floor(-x, digits = ceil_neg_log10(m) + 1)
        )
    ) |> T
round_down_subtick(x::T, m) where {T} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? floor(x, digits = ceil_neg_log10(m) + 1) :
            -ceil(-x, digits = ceil_neg_log10(m) + 1)
        )
    ) |> T
float_round_log10(x::T, m) where {T<:AbstractFloat} =
    (
        x == 0 ? 0 :
        (
            x > 0 ? round(x, digits = ceil_neg_log10(m) + 1) :
            -round(-x, digits = ceil_neg_log10(m) + 1)
        )
    ) |> T
float_round_log10(x::Integer, m) = float_round_log10(float(x), m)
float_round_log10(x) = x > 0 ? float_round_log10(x, x) : float_round_log10(x, -x)

function unit_str(x, fancy)
    io = IOContext(PipeBuffer(), :fancy_exponent => fancy)
    show(io, unit(x))
    read(io, String)
end
number_unit(x::AbstractVector{<:Quantity}, fancy = true) =
    ustrip.(x), unit_str(first(x), fancy)
number_unit(x::Quantity, fancy = true) = ustrip(x), unit_str(x, fancy)
number_unit(x::AbstractVector, args...) = x, nothing
number_unit(x::Number, args...) = x, nothing

unit_label(label::AbstractString, unit::AbstractString) =
    (lab_strip = rstrip(label)) == "" ? unit : "$lab_strip ($unit)"
unit_label(label::AbstractString, unit::Nothing) = rstrip(label)

function superscript(s::AbstractString)
    v = collect(s)
    for (i, k) in enumerate(v)
        v[i] = get(SUPERSCRIPT, k, k)
    end
    String(v)
end

function plotting_range(xmin, xmax)
    diff = xmax - xmin
    xmax = round_up_tick(xmax, diff)
    xmin = round_down_tick(xmin, diff)
    float(xmin), float(xmax)
end

function plotting_range_narrow(xmin, xmax)
    diff = xmax - xmin
    xmax = round_up_subtick(xmax, diff)
    xmin = round_down_subtick(xmin, diff)
    float(xmin), float(xmax)
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

crayon_color(::Union{Missing,Nothing}, depth) = Crayons.ANSIColor()
crayon_color(color::ColorType, depth) = Crayons.ANSIColor(color |> rgb2ansi, depth)
crayon_color(color::ColorType, ::Nothing) = (
    if (cm = COLORDEPTH[]) == Crayons.COLORS_24BIT
        Crayons.ANSIColor(Crayons._torgb(color |> rgb2ansi)..., cm)
    else
        Crayons.ANSIColor(color |> rgb2ansi, cm)
    end
)

function print_crayon(io, c, args...)
    if CRAYONS_FAST[]
        if Crayons.anyactive(c)  # bypass crayons checks (_have_color, _force_color)
            print(io, Crayons.CSI)
            Crayons._print(io, c)
            print(io, Crayons.END_ANSI, args..., RESET)
        else
            print(io, args)
        end
    else
        print(io, c, args..., RESET)
    end
end

print_color(color::BaseColorType, io::IO, args...) = printstyled(io, args...; color = color)
function print_color(color::ColorType, io::IO, args...; bgcol = missing)
    if color == INVALID_COLOR || !get(io, :color, false)
        print(io, args...)
    else
        depth = color < THRESHOLD ? nothing : Crayons.COLORS_256
        print_crayon(
            io,
            Crayon(crayon_color(color, depth), crayon_color(bgcol, depth), EMPTY_STYLES...),
            args...,
        )
    end
end

@inline r32(r::Integer)::UInt32 = (r & 0xffffff) << 16
@inline g32(g::Integer)::UInt32 = (g & 0xffffff) << 8
@inline b32(b::Integer)::UInt32 = (b & 0xffffff)

@inline red(c::UInt32)::UInt8 = (c >> 16) & 0xff
@inline grn(c::UInt32)::UInt8 = (c >> 8) & 0xff
@inline blu(c::UInt32)::UInt8 = c & 0xff

@inline rgb2ansi(v::Integer) = v ≥ THRESHOLD ? v - THRESHOLD : v

@inline function blend_colors(a::UInt32, b::UInt32)::UInt32
    if a == b
        return a  # fastpath
    else
        if a < THRESHOLD && b < THRESHOLD
            # NOTE: convert to UInt32 to prevent Integer overflow
            return (
                r32(floor(UInt32, √((UInt32(red(a))^2 + UInt32(red(b))^2) / 2))) +
                g32(floor(UInt32, √((UInt32(grn(a))^2 + UInt32(grn(b))^2) / 2))) +
                b32(floor(UInt32, √((UInt32(blu(a))^2 + UInt32(blu(b))^2) / 2)))
            )
        elseif THRESHOLD ≤ a < INVALID_COLOR && THRESHOLD ≤ b < INVALID_COLOR
            return THRESHOLD + (UInt8(a |> rgb2ansi) | UInt8(b |> rgb2ansi))
        elseif a != INVALID_COLOR && b != INVALID_COLOR
            return max(a, b)
        else
            return INVALID_COLOR
        end
    end
end

ignored_color(color::Symbol) = color === :normal || color === :default || color === :nothing
ignored_color(::Nothing) = true
ignored_color(::Any) = false

ansi_color(color::ColorType)::ColorType = color  # no-op
function ansi_color(color::UserColorType)::ColorType
    ignored_color(color) && return INVALID_COLOR
    c = Crayons._parse_color(color)
    if COLORDEPTH[] == Crayons.COLORS_24BIT
        col = if c.style == Crayons.COLORS_24BIT
            r32(c.r) + g32(c.g) + b32(c.b)
        elseif c.style == Crayons.COLORS_256
            LUT_8BIT[c.r + 1]
        elseif c.style == Crayons.COLORS_16
            THRESHOLD + c.r % 60  # 0-255 ansi
        end
        return ColorType(col)
    else
        col = if c.style == Crayons.COLORS_24BIT
            Crayons.to_256_colors(c).r
        elseif c.style == Crayons.COLORS_256
            c.r
        elseif c.style == Crayons.COLORS_16
            c.r % 60
        end
        return ColorType(THRESHOLD + col)  # 0-255 ansi stored in a UInt32
    end
end

complement(color::UserColorType)::ColorType = complement(ansi_color(color))
complement(color::ColorType)::ColorType =
    if color < THRESHOLD
        r32(~red(color)) + g32(~grn(color)) + b32(~blu(color))
    elseif color != INVALID_COLOR
        THRESHOLD + ~UInt8(color |> rgb2ansi)
    else
        INVALID_COLOR
    end

base_color(color::ColorType)::BaseColorType =
    color == INVALID_COLOR ? :normal : Int(rgb2ansi(color))
base_color(color::Integer)::BaseColorType = (@assert 0 ≤ color ≤ 255;
Int(color))
base_color(color::Nothing)::BaseColorType = :normal
base_color(color::Symbol)::BaseColorType = color  # no-op

@inline function set_color!(
    colors::Matrix{ColorType},
    x::Int,
    y::Int,
    color::ColorType,
    blend::Bool,
)
    colors[x, y] = if (c = colors[x, y]) == INVALID_COLOR || !blend
        color
    else
        blend_colors(c, color)
    end
    nothing
end

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
