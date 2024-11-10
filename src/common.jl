const BLANK = 0x0020
const BLANK_BRAILLE = 0x2800
const FULL_BRAILLE = 0x28ff

#! format: off
const BORDER_SOLID = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t  = '─',
    l  = '│',
    b  = '─',
    r  = '│',
)
const BORDER_CORNERS = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t  = ' ',
    l  = ' ',
    b  = ' ',
    r  = ' ',
)
const BORDER_BARPLOT = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t  = ' ',
    l  = '┤',
    b  = ' ',
    r  = ' ',
)
const BORDER_BOLD = (
    tl = '┏',
    tr = '┓',
    bl = '┗',
    br = '┛',
    t  = '━',
    l  = '┃',
    b  = '━',
    r  = '┃',
)
const BORDER_NONE = (
    tl = ' ',
    tr = ' ',
    bl = ' ',
    br = ' ',
    t  = ' ',
    l  = ' ',
    b  = ' ',
    r  = ' ',
)
const BORDER_BNONE = (
    tl = Char(BLANK_BRAILLE),
    tr = Char(BLANK_BRAILLE),
    bl = Char(BLANK_BRAILLE),
    br = Char(BLANK_BRAILLE),
    t  = Char(BLANK_BRAILLE),
    l  = Char(BLANK_BRAILLE),
    b  = Char(BLANK_BRAILLE),
    r  = Char(BLANK_BRAILLE),
)
const BORDER_DASHED = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t  = '╌',
    l  = '┊',
    b  = '╌',
    r  = '┊',
)
const BORDER_DOTTED = (
    tl = '⡤',
    tr = '⢤',
    bl = '⠓',
    br = '⠚',
    t  = '⠤',
    l  = '⡇',
    b  = '⠒',
    r  = '⢸',
)
const BORDER_ASCII = (
    tl = '+',
    tr = '+',
    bl = '+',
    br = '+',
    t  = '-',
    l  = '|',
    b  = '-',
    r  = '|',
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
#! format: on

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

############################################################################################
# define types
const MarkerType = Union{Symbol,AbstractChar,AbstractString}
const StyledStringsColorType = Union{Symbol,StyledStrings.RGBTuple,NTuple{3,Integer},UInt32}  # from StyledStrings/src/faces.jl
const UserColorType = Union{StyledStrings.Face,StyledStringsColorType,Nothing}  # allowed color type
const ColorType = UInt32  # internal UnicodePlots color type (on canvas), 8bit or 24bit

############################################################################################
# unicode table
# en.wikipedia.org/wiki/Plane_(Unicode)
const PLANE0_START = 0x00000
const PLANE0_STOP = 0x0ffff
const PLANE1_START = 0x10000
const PLANE1_STOP = 0x1ffff
const PLANE2_START = 0x20000
const PLANE2_STOP = 0x2ffff

# TODO: maybe later support plane 1 (SMP) and plane 2 (CJK) (needs UInt16 -> UInt32 grid change)
const UNICODE_TABLE = Array{Char}(undef, (PLANE0_STOP - PLANE0_START + 1) + length(MARKERS))
for i ∈ PLANE0_START:PLANE0_STOP
    UNICODE_TABLE[i + 1] = Char(i)
end
for (j, i) ∈ enumerate(PLANE1_START:(PLANE1_START + (length(MARKERS) - 1)))
    UNICODE_TABLE[i + 1] = MARKERS[j]
end

# `UInt32` is enough to hold all values of `UNICODE_TABLE`:
# common supertype for `DotCanvas`, `AsciiCanvas`, `BlockCanvas` `HeatmapCanvas` and `BrailleCanvas`.
const UnicodeType = UInt32

############################################################################################
# colors
@enum Colormode COLORMODE_24BIT COLORMODE_8BIT
const THRESHOLD = UInt32(256^3)  # 8bit - 24bit threshold
const COLORMODE = Ref(COLORMODE_24BIT)
const INVALID_COLOR = typemax(ColorType)
const USE_LUT = Ref(false)

const COLOR_CYCLE_FAINT = :green, :blue, :red, :magenta, :yellow, :cyan
const COLOR_CYCLE_BRIGHT = map(s -> Symbol("bright_", s), COLOR_CYCLE_FAINT)  # COV_EXCL_LINE
const COLOR_CYCLE = Ref(COLOR_CYCLE_FAINT)

const BORDER_COLOR = Ref(:gray)

############################################################################################

const FSCALES = (identity = identity, ln = log, log2 = log2, log10 = log10)  # forward
const ISCALES = (identity = identity, ln = exp, log2 = exp2, log10 = exp10)  # inverse
const BASES = (identity = nothing, ln = "ℯ", log2 = "2", log10 = "10")

const FULL_BLOCK = '█'
const HALF_BLOCK = '▄'

# standard terminals seem to respect a 4:3 aspect ratio
# unix.stackexchange.com/questions/148569/standard-terminal-font-aspect-ratio
# retrocomputing.stackexchange.com/questions/5629/why-did-80x25-become-the-text-monitor-standard
const ASPECT_RATIO = Ref(4 / 3)

# default display size for the default BrailleCanvas (which has aspect ratio = 2) ==> (40, 15)
const DEFAULT_HEIGHT = Ref(15)
const DEFAULT_WIDTH = Ref(round(Int, DEFAULT_HEIGHT[] * 2ASPECT_RATIO[]))

brightcolors!() = COLOR_CYCLE[] = COLOR_CYCLE_BRIGHT
faintcolors!() = COLOR_CYCLE[] = COLOR_CYCLE_FAINT

colors256!() = COLORMODE[] = COLORMODE_8BIT
truecolors!() = COLORMODE[] = COLORMODE_24BIT

function init_24bit()
    truecolors!()
    USE_LUT[] ? brightcolors!() : faintcolors!()
    nothing
end

function init_8bit()
    colors256!()
    faintcolors!()
    nothing
end

colormode() =
    if (cm = COLORMODE[]) ≡ COLORMODE_8BIT
        8
    elseif cm ≡ COLORMODE_24BIT
        24
    else
        throw(ArgumentError("color mode $cm is unsupported"))
    end

function colormode!(mode)
    if mode ≡ 8
        colors256!()
    elseif mode ≡ 24
        truecolors!()
    else
        throw(ArgumentError("color mode $mode is unsupported, choose 8 or 24"))
    end
    nothing
end

# specific to UnicodePlots
forced_24bit() = lowercase(get(ENV, "UP_COLORMODE", "")) ∈ ("24", "24bit", "truecolor")
forced_8bit() = lowercase(get(ENV, "UP_COLORMODE", "")) ∈ ("8", "8bit")

"""
    default_size!(;
        height::Union{Integer,Nothing} = nothing,
        width::Union{Integer,Nothing} = nothing,
    )

Change and return the default plot size (height, width).
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
        length(marker) ≡ 1 || throw(ArgumentError("`marker` keyword has a non unit length"))
        first(marker)
    end
end

iterable(obj::AbstractVecOrMat) = obj
iterable(obj) = Iterators.repeated(obj)

function transform_name(tr, basename = "")
    name = string(tr isa Union{Symbol,Function} ? tr : typeof(tr))
    name == "identity" && return basename
    name = occursin('#', name) ? "custom" : name
    string(basename, " [", name, "]")
end

meshgrid(x, y) = repeat(x, 1, length(y)), repeat(y', length(x), 1)

as_float(x::AbstractVector{<:AbstractFloat}) = x
as_float(x) = float.(x)

roundable(x::Number) = isinteger(x) && (typemin(Int32) ≤ x ≤ typemax(Int32))
compact_repr(x::Number) = repr(x; context = :compact => true)

nice_repr(x::Number, plot) =
    nice_repr(x, plot.unicode_exponent[], plot.thousands_separator[])
nice_repr(x::Number, _::Nothing) =
    nice_repr(x, PLOT_KEYWORDS.unicode_exponent, PLOT_KEYWORDS.thousands_separator)

function nice_repr(x::Integer, ::Bool, thousands_separator::Char)::String
    thousands_separator == '\0' && return string(x)
    xs = collect(reverse(string(abs(x))))
    n = length(xs)
    v = sizehint!(Char[], n + 10)
    for (i, c) ∈ enumerate(xs)
        push!(v, c)
        (i < n && mod1(i, 3) == 3) && push!(v, thousands_separator)
    end
    reverse!(v)
    (sign(x) ≥ 0 ? "" : "-") * String(v)
end

function nice_repr(
    x::AbstractFloat,
    unicode_exponent::Bool,
    thousands_separator::Char,
)::String
    xr = (pseudo_int = roundable(x)) ? round(Int, x, RoundNearestTiesUp) : x
    iszero(xr) && return "0"
    str = compact_repr(xr)
    if (parts = split(str, 'e')) |> length == 2  # e.g. 1.0e-17 => 1e⁻¹⁷
        left, right = parts
        str = *(
            replace(left, r"\.0$" => ""),
            'e',
            unicode_exponent ? superscript(right) : String(right),
        )
    elseif pseudo_int
        str = nice_repr(xr, unicode_exponent, thousands_separator)
    end
    str
end

function_name(f::Function, default) = isempty(default) ? string(nameof(f), "(x)") : default

function default_formatter(kw)
    unicode_exponent = get(kw, :unicode_exponent, PLOT_KEYWORDS.unicode_exponent)
    thousands_separator = get(kw, :thousands_separator, PLOT_KEYWORDS.thousands_separator)
    x -> nice_repr(x, unicode_exponent, thousands_separator)
end

# workaround for github.com/JuliaMath/NaNMath.jl/issues/26
nanless_extrema(x) = any(isnan, x) ? NaNMath.extrema(x) : extrema(x)

function ceil_neg_log10(x)
    val = -log10(x)
    isfinite(val) || return typemin(Int)
    roundable(val) ? ceil(Int, val) : floor(Int, val)
end

round_up_subtick(x::T, m) where {T} = T(iszero(x) ? x : if x > 0
    +ceil(+x; digits = ceil_neg_log10(m) + 1)
else
    -floor(-x; digits = ceil_neg_log10(m) + 1)
end)

round_down_subtick(x::T, m) where {T} = T(iszero(x) ? x : if x > 0
    floor(+x; digits = ceil_neg_log10(m) + 1)
else
    -ceil(-x; digits = ceil_neg_log10(m) + 1)
end)

float_round_log10(x::Integer, m) = float_round_log10(float(x), m)
float_round_log10(x) = x > 0 ? float_round_log10(x, x) : float_round_log10(x, -x)
float_round_log10(x::T, m) where {T<:AbstractFloat} = T(iszero(x) ? x : if x > 0
    +round(+x; digits = ceil_neg_log10(m) + 1)
else
    -round(-x; digits = ceil_neg_log10(m) + 1)
end)

floor_base(x, b) = round_base(x, b, RoundDown)
ceil_base(x, b) = round_base(x, b, RoundUp)

round_base(x::T, b, ::RoundingMode{:Down}) where {T} = T(b^floor(log(b, x)))
round_base(x::T, b, ::RoundingMode{:Up}) where {T} = T(b^ceil(log(b, x)))

function superscript(s::AbstractString)::String
    v = collect(s)
    for (i, k) ∈ enumerate(v)
        v[i] = get(SUPERSCRIPT, k, k)
    end
    String(v)
end

function plotting_range_narrow(xmin, xmax)
    Δ = xmax - xmin
    if iszero(Δ) || !isfinite(Δ)
        Δ = Float64(xmax) - Float64(xmin)  # NOTE: support e.g. xmin == -Inf32 | xmax == Inf32
        if iszero(Δ) || !isfinite(Δ)
            @warn "Invalid plotting range" xmin xmax
            return -Inf, +Inf
        end
    end
    float(round_down_subtick(xmin, Δ)), float(round_up_subtick(xmax, Δ))
end

is_auto(lims) = all(iszero, lims)

# NOTE: we need `SVector{2}(v)` for compiler inferrability, not `Svector(v)` !
autolims(lims) = is_auto(lims) ? SVector(-1.0, 1.0) : SVector{2}(as_float(lims))
autolims(lims, vec::AbstractVector) =
    is_auto(lims) && length(vec) > 0 ? SVector{2}(extrema(vec)) : SVector{2}(as_float(lims))

scale_callback(scale::Symbol) = FSCALES[scale]
scale_callback(scale::Function) = scale

extend_limits(vec, lims) = extend_limits(vec, lims, :identity)

unitless(x) = x  # noop when Unitful is not loaded

function extend_limits(vec::AbstractVector, lims, scale::Union{Symbol,Function})
    scale = scale_callback(scale)
    mi, ma = as_float(extrema(lims))
    if iszero(mi) && iszero(ma)
        isempty(vec) && return is_auto(lims) ? autolims(lims) : lims
        mi, ma = as_float(extrema(vec))
    end
    if mi == ma
        mi -= 1
        ma += 1
    end
    if scale ≡ identity
        is_auto(lims) ? plotting_range_narrow(mi, ma) : (mi, ma)
    else
        scale(mi), scale(ma)
    end
end

sort_by_keys(dict::Dict) = sort!(collect(dict), by = first)

function sorted_keys_values(dict::Dict; k2s = true)
    # check and force key type to <: AbstractString if necessary
    if k2s && !(first(eltype(dict).types) <: AbstractString)
        dict = Dict(string(k) => v for (k, v) ∈ pairs(dict))
    end
    keys_vals = sort_by_keys(dict)
    first.(keys_vals), last.(keys_vals)
end

styledstrings_color(::Union{Missing,Nothing}) = nothing
styledstrings_color(color::ColorType) =
    if color ≡ INVALID_COLOR
        nothing
    elseif color < THRESHOLD  # 24bit
        StyledStrings.SimpleColor(red(color), grn(color), blu(color))
    else  # 8bit
        StyledStrings.Legacy.legacy_color(Int(color - THRESHOLD))
    end

print_color(io::IO, face::StyledStrings.Face, args...) = print(io, StyledStrings.face!(Base.annotatedstring(args...), face))
print_color(io::IO, color::UserColorType, args...) =
    print_color(io, ansi_color(color), args...)

function print_color(io::IO, color::ColorType, args...; bgcol = missing)
    if get(io, :color, false)
        face = StyledStrings.Face(foreground = styledstrings_color(color), background = styledstrings_color(bgcol))
        print_color(io, face, args...)
    else
        print(io, args...)
    end
    nothing
end

@inline r32(r::Integer)::UInt32 = (r & 0xffffff) << 16
@inline g32(g::Integer)::UInt32 = (g & 0xffffff) << 8
@inline b32(b::Integer)::UInt32 = (b & 0xffffff)

@inline red(c::UInt32)::UInt8 = (c >> 16) & 0xff
@inline grn(c::UInt32)::UInt8 = (c >> 8) & 0xff
@inline blu(c::UInt32)::UInt8 = c & 0xff

@inline blend_colors(a::UInt32, b::UInt32)::UInt32 = if a ≡ b
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
elseif a ≢ INVALID_COLOR && b ≢ INVALID_COLOR
    max(a, b)
else
    INVALID_COLOR
end::UInt32

ignored_color(color::Symbol) = color ≡ :normal || color ≡ :default || color ≡ :nothing
ignored_color(::Nothing) = true
ignored_color(::Any) = false

no_ansi_escape(str::AbstractString) = replace(str, r"\e\[[0-9;]*[a-zA-Z]" => "")

ansi_4bit_to_8bit(c::UInt8) =
    let (q, r) = divrem(c, 0x3c)  # UInt8(60)
        UInt8(r + (q > 0x0 ? 0x8 : 0x0))
    end

c256(c::AbstractFloat) = round(UInt32, 255c)
c256(c::Integer) = c

# `ColorType` conversion - colormaps
ansi_color(rgb::AbstractRGB) = ansi_color((c256(rgb.r), c256(rgb.g), c256(rgb.b)))
ansi_color(rgb::NTuple{3,AbstractFloat}) = ansi_color(c256.(rgb))
ansi_color(color::NTuple{3,Integer})::ColorType = r32(color[1]) + g32(color[2]) + b32(color[3])

ansi_color(color::ColorType)::ColorType = color  # no-op
ansi_color(face::StyledStrings.Face) = ansi_color(face.foreground)  # ignore bg & styles
ansi_color(::Union{Nothing,Missing}) = INVALID_COLOR  # not a StyledStringsColorType

function ansi_color(color::StyledStringsColorType)::ColorType
    ignored_color(color) && return INVALID_COLOR
    ansi_color(StyledStrings.SimpleColor(color))
end

function to_256_colors(color)
    r, g, b = rgb = color.r, color.g, color.b
    ansi = if r == g == b && r % 10 == 8
        232 + min((r - 8) ÷ 10, 23)  # gray level
    elseif all(map(c -> (c & 0x1) == 0 && (c > 0 ? c == 128 || c == 192 : true), rgb))
        (r >> 7) + 2(g >> 7) + 4(b >> 7)  # primary color
    else
        r6, g6, b6 = map(c -> c < 48 ? 0 : (c < 114 ? 1 : trunc(Int, (c - 35) / 40)), rgb)
        16 + 36r6 + 6g6 + b6  # cube 6x6x6
    end
    return UInt8(ansi)
end

ansi_color(col::StyledStrings.SimpleColor) = let c = col.value
    if COLORMODE[] ≡ COLORMODE_24BIT
        if c isa Symbol
            c4 = get(StyledStrings.ANSI_4BIT_COLORS, c, nothing)
            c8 = ansi_4bit_to_8bit(UInt8(c4))
            return USE_LUT[] ? LUT_8BIT[c8 + 1] : THRESHOLD + c8
        elseif c isa StyledStrings.RGBTuple
            return r32(c.r) + g32(c.g) + b32(c.b)
        end::ColorType
    else  # 0-255 ansi stored in a UInt32
        return THRESHOLD + if c isa Symbol
            c4 = get(StyledStrings.ANSI_4BIT_COLORS, c, nothing)
            ansi_4bit_to_8bit(UInt8(c4))
        elseif c isa StyledStrings.RGBTuple
            to_256_colors(c)
        end::UInt8
    end::ColorType
end

complement(color::UserColorType)::ColorType = complement(ansi_color(color))
complement(color::ColorType)::ColorType = if color ≡ INVALID_COLOR
    INVALID_COLOR
elseif color < THRESHOLD
    r32(~red(color)) + g32(~grn(color)) + b32(~blu(color))
elseif color ≢ INVALID_COLOR
    THRESHOLD + ~UInt8(color - THRESHOLD)
end::ColorType

out_stream_size(out_stream::Nothing) = displaysize()
out_stream_size(out_stream::IO) = displaysize(out_stream)

out_stream_height(out_stream::Union{Nothing,IO} = nothing) =
    out_stream |> out_stream_size |> first
out_stream_width(out_stream::Union{Nothing,IO} = nothing) =
    out_stream |> out_stream_size |> last

multiple_series_defaults(y::AbstractMatrix, kw, start) = map(
    iterable,
    (
        get(kw, :name, map(i -> "y$i", start:(start + size(y, 2)))),
        get(kw, :color, :auto),
        get(kw, :marker, :pixel),
    ),
)

function colormap_callback(cmap::Symbol)
    cdata = ColorSchemes.colorschemes[cmap]
    (z, minz, maxz) -> begin
        isfinite(z) || return INVALID_COLOR
        z01 =
            minz == maxz ? zero(z) :
            (max(minz, min(z, maxz)) - minz) / (maxz - minz)
        isfinite(z01) || return INVALID_COLOR
        ansi_color(get(cdata, z01))
    end::ColorType
end

function colormap_callback(cmap::AbstractVector)
    (z, minz, maxz) -> begin
        isfinite(z) || return INVALID_COLOR
        i = if minz == maxz || z < minz
            1
        elseif z > maxz
            length(cmap)
        else
            1 + round(Int, ((z - minz) / (maxz - minz)) * (length(cmap) - 1))
        end::Int
        ansi_color(cmap[i])
    end::ColorType
end

colormap_callback(cmap::Nothing) = x -> nothing
colormap_callback(cmap::Function) = cmap

mutable struct ColorMap
    border::Symbol
    bar::Bool
    lim::NTuple{2,Number}
    callback::Function
end

split_plot_kw(kw) =
    if isempty(kw)
        pairs((;)), pairs((;))  # avoids `filter` allocations
    else
        filter(p -> p.first ∈ PLOT_KEYS, kw), filter(p -> p.first ∉ PLOT_KEYS, kw)
    end

warn_on_lost_kw(kw) = (isempty(kw) || @warn "keyword(s) `$kw` will be lost"; nothing)

# TermExt
function panel end
function gridplot end
