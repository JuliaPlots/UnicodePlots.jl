#! format: off
const BLANK = 0x0020
const BLANK_BRAILLE = 0x2800
const FULL_BRAILLE = 0x28ff

const FULL_BLOCK = '█'
const HALF_BLOCK = '▄'

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
    'e' => 'ᵉ',
)
const COLOR_CYCLE_FAINT = :green, :blue, :red, :magenta, :yellow, :cyan
const COLOR_CYCLE_BRIGHT = Tuple(Symbol("light_", s) for s in COLOR_CYCLE_FAINT)
const COLOR_CYCLE = Ref(COLOR_CYCLE_FAINT)

const BORDER_COLOR = Ref(:dark_gray)

# standard terminals seem to respect a 4:3 aspect ratio
# unix.stackexchange.com/questions/148569/standard-terminal-font-aspect-ratio
# retrocomputing.stackexchange.com/questions/5629/why-did-80x25-become-the-text-monitor-standard
const ASPECT_RATIO = Ref(4 / 3)

# default display size for the default BrailleCanvas (which has aspect ratio = 2) ==> (40, 15)
const DEFAULT_HEIGHT = Ref(15)
const DEFAULT_WIDTH = Ref(round(Int, DEFAULT_HEIGHT[] * 2ASPECT_RATIO[]))

const MarkerType = Union{Symbol,Char,AbstractString}
const CrayonColorType = Union{Integer,Symbol,NTuple{3,Integer},Nothing}
const UserColorType = Union{Crayon,CrayonColorType}  # allowed color type
const ColorType = UInt32  # internal UnicodePlots color type (on canvas)

const THRESHOLD = UInt32(256^3)
const COLORMODE = Ref(Crayons.COLORS_256)
const INVALID_COLOR = typemax(ColorType)
const USE_LUT = Ref(false)

const FSCALES = (identity = identity, ln = log, log2 = log2, log10 = log10)  # forward
const ISCALES = (identity = identity, ln = exp, log2 = exp2, log10 = exp10)  # inverse
const BASES = (identity = nothing, ln = "ℯ", log2 = "2", log10 = "10")

const CRAYONS_FAST = Ref(true)
const CRAYONS_EMPTY_STYLES = Tuple(Crayons.ANSIStyle() for _ in 1:9)
const CRAYONS_RESET = Crayons.CSI * "0" * Crayons.END_ANSI

#! format: on

colormode() =
    if (cm = COLORMODE[]) == Crayons.COLORS_256
        8
    elseif cm == Crayons.COLORS_24BIT
        24
    else
        error("Unsupported color mode=$cm.")
    end

colors256!() = (COLORMODE[] = Crayons.COLORS_256; nothing)
truecolors!() = (COLORMODE[] = Crayons.COLORS_24BIT; nothing)

function colormode!(mode)
    if mode == 8
        colors256!()
    elseif mode == 24
        truecolors!()
    else
        error("Unsupported color mode=$mode, choose 8 or 24.")
    end
    nothing
end

brightcolors!() = (COLOR_CYCLE[] = COLOR_CYCLE_BRIGHT; nothing)
faintcolors!() = (COLOR_CYCLE[] = COLOR_CYCLE_FAINT; nothing)

# see gist.github.com/XVilka/8346728#checking-for-colorterm
terminal_24bit() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

# specific to UnicodePlots
forced_24bit() = lowercase(get(ENV, "UP_COLORMODE", "")) in ("24", "24bit", "truecolor")
forced_8bit() = lowercase(get(ENV, "UP_COLORMODE", "")) in ("8", "8bit")

function __init__()
    if (terminal_24bit() || forced_24bit()) && !forced_8bit()
        truecolors!()
        USE_LUT[] ? brightcolors!() : faintcolors!()
    else
        colors256!()
        faintcolors!()
    end
    nothing
end

"""
    default_size!(;
        height::Union{Integer,Nothing} = nothing,
        width::Union{Integer,Nothing} = nothing,
    )

# Change and return the default plot size (height, width).
"""
function default_size!(;
    height::Union{Integer,Nothing} = nothing,
    width::Union{Integer,Nothing} = nothing,
)
    @assert height ≡ nothing || width ≡ nothing
    if height ≢ nothing
        DEFAULT_HEIGHT[] = height
        DEFAULT_WIDTH[] = round(Int, height * 2ASPECT_RATIO[])
    elseif width ≢ nothing
        DEFAULT_WIDTH[] = width
        DEFAULT_HEIGHT[] = round(Int, width / 2ASPECT_RATIO[])
    else
        default_size!(height = 15)
    end
    DEFAULT_HEIGHT[], DEFAULT_WIDTH[]  # `displaysize` order convention
end

function char_marker(marker::MarkerType)::Char
    if marker isa Symbol
        get(MARKERS, marker, MARKERS[:circle])
    else
        length(marker) == 1 ||
            throw(ArgumentError("`marker` keyword has a non unit length"))
        first(marker)
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

as_float(x::AbstractVector{<:AbstractFloat}) = x
as_float(x) = float.(x)

roundable(x::Number) = isinteger(x) && (typemin(Int) ≤ x ≤ typemax(Int))
compact_repr(x::Number) = repr(x, context = :compact => true)

lims_repr(x::Number) = nice_repr(roundable(x) ? x : float_round_log10(x))

nice_repr(x::AbstractFloat) =
    compact_repr(roundable(x) ? round(Int, x, RoundNearestTiesUp) : x)
nice_repr(x::Integer) = string(x)

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

sort_by_keys(dict::Dict) = sort!(collect(dict), by = x -> first(x))

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

crayon_color(::Union{Missing,Nothing}) = Crayons.ANSIColor()
crayon_color(color::ColorType) =
    if color < THRESHOLD  # 24bit
        Crayons.ANSIColor(red(color), grn(color), blu(color), Crayons.COLORS_24BIT)
    else  # 8bit
        Crayons.ANSIColor(color - THRESHOLD, Crayons.COLORS_256)
    end

function print_crayons(io, c, args...)
    if CRAYONS_FAST[]
        if Crayons.anyactive(c)  # bypass crayons checks (_have_color, _force_color)
            print(io, Crayons.CSI)
            Crayons._print(io, c)
            print(io, Crayons.END_ANSI, args..., CRAYONS_RESET)
        else
            print(io, args...)
        end
    else
        print(io, c, args..., CRAYONS_RESET)
    end
end

print_color(io::IO, color::Crayon, args...) = print_crayons(io, color, args...)
print_color(io::IO, color::UserColorType, args...) =
    print_color(io, ansi_color(color), args...)
function print_color(io::IO, color::ColorType, args...; bgcol = missing)
    if color == INVALID_COLOR || !get(io, :color, false)
        print(io, args...)
    else
        print_crayons(
            io,
            Crayon(crayon_color(color), crayon_color(bgcol), CRAYONS_EMPTY_STYLES...),
            args...,
        )
    end
    nothing
end

@inline r32(r::Integer)::UInt32 = (r & 0xffffff) << 16
@inline g32(g::Integer)::UInt32 = (g & 0xffffff) << 8
@inline b32(b::Integer)::UInt32 = (b & 0xffffff)

@inline red(c::UInt32)::UInt8 = (c >> 16) & 0xff
@inline grn(c::UInt32)::UInt8 = (c >> 8) & 0xff
@inline blu(c::UInt32)::UInt8 = c & 0xff

@inline blend_colors(a::UInt32, b::UInt32)::UInt32 =
    if a == b
        a  # fastpath
    elseif a < THRESHOLD && b < THRESHOLD  # 24bit
        # physical average (UInt32 to prevent UInt8 overflow)
        r32(floor(UInt32, √((UInt32(red(a))^2 + UInt32(red(b))^2) / 2))) +
        g32(floor(UInt32, √((UInt32(grn(a))^2 + UInt32(grn(b))^2) / 2))) +
        b32(floor(UInt32, √((UInt32(blu(a))^2 + UInt32(blu(b))^2) / 2)))
        # binary or
        # r32(red(a) | red(b)) + g32(grn(a) | grn(b)) + b32(blu(a) | blu(b))
    elseif THRESHOLD ≤ a < INVALID_COLOR && THRESHOLD ≤ b < INVALID_COLOR  # 8bit
        THRESHOLD + (UInt8(a - THRESHOLD) | UInt8(b - THRESHOLD))
    elseif a != INVALID_COLOR && b != INVALID_COLOR
        max(a, b)
    else
        INVALID_COLOR
    end

ignored_color(color::Symbol) = color ≡ :normal || color ≡ :default || color ≡ :nothing
ignored_color(::Nothing) = true
ignored_color(::Any) = false

no_ansi_escape(str::AbstractString) = replace(str, r"\e\[[0-9;]*[a-zA-Z]" => "")

function ansi_4bit_to_8bit(c::UInt8)::UInt8
    q, r = divrem(c, UInt8(60))
    r + (q > 0x0 ? 0x8 : 0x0)
end

ansi_color(color::ColorType)::ColorType = color  # no-op
ansi_color(crayon::Crayon) = ansi_color(crayon.fg)  # ignore bg & styles
function ansi_color(color::CrayonColorType)::ColorType
    ignored_color(color) && return INVALID_COLOR
    ansi_color(Crayons._parse_color(color))
end
function ansi_color(c::Crayons.ANSIColor)::ColorType
    col = if COLORMODE[] == Crayons.COLORS_24BIT
        if c.style == Crayons.COLORS_24BIT
            r32(c.r) + g32(c.g) + b32(c.b)
        elseif c.style == Crayons.COLORS_256
            USE_LUT[] ? LUT_8BIT[c.r + 1] : THRESHOLD + c.r
        elseif c.style == Crayons.COLORS_16
            c8 = ansi_4bit_to_8bit(c.r)
            USE_LUT[] ? LUT_8BIT[c8 + 1] : THRESHOLD + c8
        end
    else  # 0-255 ansi stored in a UInt32
        if c.style == Crayons.COLORS_24BIT
            THRESHOLD + Crayons.to_256_colors(c).r
        elseif c.style == Crayons.COLORS_256
            THRESHOLD + c.r
        elseif c.style == Crayons.COLORS_16
            THRESHOLD + ansi_4bit_to_8bit(c.r)
        end
    end
    ColorType(col)
end

complement(color::UserColorType)::ColorType = complement(ansi_color(color))
complement(color::ColorType)::ColorType =
    if color == INVALID_COLOR
        INVALID_COLOR
    elseif color < THRESHOLD
        r32(~red(color)) + g32(~grn(color)) + b32(~blu(color))
    elseif color != INVALID_COLOR
        THRESHOLD + ~UInt8(color - THRESHOLD)
    end

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

out_stream_size(out_stream::Union{Nothing,IO} = nothing) =
    out_stream ≡ nothing ? displaysize() : displaysize(out_stream)
out_stream_height(out_stream::Union{Nothing,IO} = nothing) =
    out_stream |> out_stream_size |> first
out_stream_width(out_stream::Union{Nothing,IO} = nothing) =
    out_stream |> out_stream_size |> last

function _handle_deprecated_symb(symb, symbols)
    if symb ≡ nothing
        symbols
    else
        Base.depwarn(
            "The keyword `symb` is deprecated in favor of `symbols`",
            :BarplotGraphics,
        )
        [symb]
    end
end
