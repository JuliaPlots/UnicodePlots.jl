const DOC_PLOT_PARAMS = """
- **`title`** : Text to display on the top of the plot.

- **`xlabel`** : Text to display on the x axis of the plot

- **`ylabel`** : Text to display on the y axis of the plot

- **`xscale`** : X-axis scale (:identity, :ln, :log2, :log10),
  or scale function e.g. `x -> log10(x)`

- **`yscale`** : Y-axis scale

- **`labels`** : Boolean. Can be used to hide the labels by setting `labels = false`.

- **`border`** : The style of the bounding box of the plot.
  Supports `:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`compact`** : Compact plot (labels), defaults to `false`.

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`color`** : Color of the drawing.
  Can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`, `:white`,
  `:normal`, an integer in the range `0`-`255` for Color256 palette,
  or a tuple of three integers as RGB components.

- **`width`** : Number of characters per row that should be used for plotting.
"""

const MarkerType = Union{Symbol,Char,AbstractString}
const MARKERS = (
    circle = '⚬',
    rect = '▫',
    diamond = '◇',
    hexagon = '⬡',
    cross = '✚',
    xcross = '✖',
    utriangle = '△',
    dtriangle = '▽',
    rtriangle = '▷',
    ltriangle = '◁',
    pentagon = '⬠',
    star4 = '✦',
    star5 = '★',
    star6 = '✶',
    star8 = '✴',
    vline = '|',
    hline = '―',
    (+) = '+',
    (x) = '⨯',
)

function char_marker(marker::MarkerType)::Char
    if marker isa Symbol
        get(MARKERS, marker, MARKERS[:circle])
    else
        length(marker) == 1 || throw(error("`marker` keyword has a non unit length"))
        marker[1]
    end
end

iterable(obj::AbstractVector) = obj
iterable(obj) = Iterators.repeated(obj)

const FSCALES = (identity=identity, ln=log, log2=log2, log10=log10)  # forward
const ISCALES = (identity=identity, ln=exp, log2=exp2, log10=exp10)  # inverse
const BASES = (identity=nothing, ln="ℯ", log2="2", log10="10")

fscale(x, s::Symbol) = FSCALES[s](x)
iscale(x, s::Symbol) = ISCALES[s](x)

# support arbitrary scale functions
fscale(x, f::Function) = f(x)
iscale(x, f::Function) = f(x)

function transform_name(tr, basename = "")
    name = string(tr isa Union{Symbol,Function} ? tr : typeof(tr))  # typeof(...) for functors
    name == "identity" && return basename
    name = occursin("#", name) ? "custom" : name
    string(basename, " [", name, "]")
end

roundable(num::Number) = isinteger(num) & (typemin(Int) <= num < typemax(Int))
compact_repr(num::Number) = repr(num, context=:compact => true)

ceil_neg_log10(x) = roundable(-log10(x)) ? ceil(Integer, -log10(x)) : floor(Integer, -log10(x))
round_up_tick(x, m) = (
    x == 0 ? 0 : (x > 0 ? ceil(x, digits=ceil_neg_log10(m)) : -floor(-x, digits=ceil_neg_log10(m)))
)
round_down_tick(x, m) = (
    x == 0 ? 0 : (x > 0 ? floor(x, digits=ceil_neg_log10(m)) : -ceil(-x, digits=ceil_neg_log10(m)))
)
round_up_subtick(x, m) = (
    x == 0 ? 0 : (x > 0 ? ceil(x, digits=ceil_neg_log10(m)+1) : -floor(-x, digits=ceil_neg_log10(m)+1))
)
round_down_subtick(x, m) = (
    x == 0 ? 0 : (x > 0 ? floor(x, digits=ceil_neg_log10(m)+1) : -ceil(-x, digits=ceil_neg_log10(m)+1))
)
float_round_log10(x::F,m) where {F<:AbstractFloat} = (
    x == 0 ? F(0) : (x  > 0 ? round(x, digits=ceil_neg_log10(m)+1)::F : -round(-x, digits=ceil_neg_log10(m)+1)::F)
)
float_round_log10(x::Integer, m) = float_round_log10(float(x), m)
float_round_log10(x) = x > 0 ? float_round_log10(x,x) : float_round_log10(x,-x)

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
    Float64(xmin), Float64(xmax)
end

function plotting_range_narrow(xmin, xmax)
    diff = xmax - xmin
    xmax = round_up_subtick(xmax, diff)
    xmin = round_down_subtick(xmin, diff)
    Float64(xmin), Float64(xmax)
end

extend_limits(vec, limits) = extend_limits(vec, limits, :identity)

function extend_limits(vec, limits, scale::Union{Symbol,Function})
    mi, ma = map(Float64, extrema(limits))
    if mi == 0 && ma == 0
        mi, ma = map(Float64, extrema(vec))
    end
    diff = ma - mi
    if diff == 0
        ma = mi + 1
        mi = mi - 1
    end
    if string(scale) != "identity"
        return fscale(mi, scale), fscale(ma, scale)
    else
        return all(iszero.(limits)) ? plotting_range_narrow(mi, ma) : (mi, ma)
    end
end

sort_by_keys(dict::Dict) = sort!(collect(dict), by=x->x[1])

function sorted_keys_values(dict::Dict; k2s=true)
    if k2s  # check and force key type to be of AbstractString type if necessary
        kt, vt = eltype(dict).types
        if !(kt <: AbstractString)
            dict = Dict(string(k) => v  for (k, v) in pairs(dict))
        end
    end
    keys_vals = sort_by_keys(dict)
    first.(keys_vals), last.(keys_vals)
end

const border_solid = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = '─',
    l = '│',
    b = '─',
    r = '│',
)
const border_corners = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = ' ',
    l = ' ',
    b = ' ',
    r = ' ',
)
const border_barplot = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = ' ',
    l = '┤',
    b = ' ',
    r = ' ',
)
const border_bold = (
    tl = '┏',
    tr = '┓',
    bl = '┗',
    br = '┛',
    t = '━',
    l = '┃',
    b = '━',
    r = '┃',
)
const border_none = (
    tl = ' ',
    tr = ' ',
    bl = ' ',
    br = ' ',
    t = ' ',
    l = ' ',
    b = ' ',
    r = ' ',
)
const border_bnone = (
    tl = Char(0x2800),
    tr = Char(0x2800),
    bl = Char(0x2800),
    br = Char(0x2800),
    t = Char(0x2800),
    l = Char(0x2800),
    b = Char(0x2800),
    r = Char(0x2800),
)
const border_dashed = (
    tl = '┌',
    tr = '┐',
    bl = '└',
    br = '┘',
    t = '╌',
    l = '┊',
    b = '╌',
    r = '┊',
)
const border_dotted = (
    tl = '⡤',
    tr = '⢤',
    bl = '⠓',
    br = '⠚',
    t = '⠤',
    l = '⡇',
    b = '⠒',
    r = '⢸',
)
const border_ascii = (
    tl = '+',
    tr = '+',
    bl = '+',
    br = '+',
    t = '-',
    l = '|',
    b = '-',
    r = '|',
)
const bordermap = (
    solid   = border_solid,
    corners = border_corners,
    barplot = border_barplot,
    bold    = border_bold,
    none    = border_none,
    bnone   = border_bnone,
    dashed  = border_dashed,
    dotted  = border_dotted,
    ascii   = border_ascii,
)

const BORDER_COLOR = Ref(:light_black)

const UserColorType = Union{Integer,Symbol,NTuple{3,Integer},Nothing}  # allowed color type
const BaseColorType = Union{Symbol,Int}  # color type for printstyled (defined in base/util.jl), used for annotations, ...
const ColorType = Union{Nothing,UInt32}  # internal UnicodePlots color type (canvas)
const THRESHOLD = UInt32(256^3)

const color_cycle = [:green, :blue, :red, :magenta, :yellow, :cyan]

@inline r32(r::Integer)::UInt32 = (r & 0xffffff) << 16
@inline g32(g::Integer)::UInt32 = (g & 0xffffff) << 8
@inline b32(b::Integer)::UInt32 = (b & 0xffffff)

@inline red(c::UInt32)::UInt8 = (c >> 16) & 0xff
@inline grn(c::UInt32)::UInt8 = (c >> 8) & 0xff
@inline blu(c::UInt32)::UInt8 = c & 0xff

@inline blend_colors(a::UInt32, b::UInt32)::UInt32 = (
    if a < THRESHOLD && b < THRESHOLD 
        r32(floor(UInt32, √(red(a)^2 + red(b)^2))) +
        g32(floor(UInt32, √(grn(a)^2 + grn(b)^2))) +
        b32(floor(UInt32, √(blu(a)^2 + blu(b)^2)))
    else
        THRESHOLD + (UInt8(a - THRESHOLD) | UInt8(b - THRESHOLD))
    end
)

print_color(color::BaseColorType, io::IO, args...) = printstyled(io, args...; color = color)
print_color(color::Nothing, io::IO, args...) = printstyled(io, args...; color = :normal)

@inline validate_base(color::ColorType)::BaseColorType =
    color === nothing ? :normal : Int(color >= THRESHOLD ? color - THRESHOLD : color)

@inline validate_crayon(color::ColorType)::ColorType =
    color === nothing ? UInt32(0) : color >= THRESHOLD ? color - THRESHOLD : color

@inline crayon_ansi(color::ColorType) = (
    if (cm = COLORMODE[]) == Crayons.COLORS_24BIT
        Crayons.ANSIColor(Crayons._torgb(validate_crayon(color))..., cm)
    else
        Crayons.ANSIColor(validate_crayon(color), cm)
    end
)

function print_color(color::ColorType, io::IO, args...; bgcol = missing)
    if color !== nothing && color >= THRESHOLD  # ansi - 4bit or 8bit
        if bgcol === missing
            printstyled(io, args...; color = validate_base(color))
        else
            print_color(validate_crayon(color), io, args...; bgcol = validate_crayon(bgcol))
        end
    else  # true color - 24bit
        fgcol = crayon_ansi(color)
        bgcol = bgcol === missing ? Crayons.ANSIColor() : crayon_ansi(bgcol)
        c = Crayon(fgcol, bgcol, (Crayons.ANSIStyle() for _ in 1:9)...)
        if false
            print(io, Crayons.CSI)
            Crayons._print(io, c)
            print(io, Crayons.END_ANSI, args...)
        else
            print(io, c, args...)
        end
    end
    return
end

@inline ignored_color(color::UserColorType) =
    color === nothing || color === :normal || color === :default || color === :nothing

function ansi_8bit_color(color::UserColorType)::ColorType
    ignored_color(color) && return nothing
    c = Crayons._parse_color(color)
    if c.style == Crayons.COLORS_24BIT
        col = Crayons.to_256_colors(c).r
    elseif c.style == Crayons.COLORS_256
        col = c.r
    elseif c.style == Crayons.COLORS_16
        col = c.r % 60
    else
        throw(error("unsupported"))
    end
    THRESHOLD + col  # 0-255 ansi stored in a UInt32
end

function ansi_24bit_color(color::UserColorType)::ColorType
    ignored_color(color) && return nothing
    c = Crayons._parse_color(color)
    if c.style == Crayons.COLORS_24BIT
        col = r32(c.r) + g32(c.g) + b32(c.b)
    elseif c.style == Crayons.COLORS_256
        col = _lut_8bit[c.r + 1]
    elseif c.style == Crayons.COLORS_16
        col = THRESHOLD + c.r % 60
    else
        throw(error("unsupported"))
    end
    UInt32(col)
end

const COLORMODE = Ref(Crayons.COLORS_256)

is_24bit_supported() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

colormode_8bit() = COLORMODE[] = Crayons.COLORS_256
colormode_24bit() = COLORMODE[] = Crayons.COLORS_24BIT

__init__() = is_24bit_supported() && colormode_24bit()

ansi_color(color::UserColorType) = COLORMODE[] == Crayons.COLORS_24BIT ? ansi_24bit_color(color) : ansi_8bit_color(color)

base_color(color::Integer)::BaseColorType = (@assert 0 <= color <= 255; Int(color))
base_color(color::Nothing)::BaseColorType = :normal
base_color(color::Symbol)::BaseColorType = color

@inline function set_color!(colors::Array{ColorType,2}, x::Int, y::Int, color::ColorType; force::Bool=false)
    if (c = colors[x, y]) === nothing || color === nothing || force
        colors[x, y] = color
    else
        colors[x, y] = blend_colors(c, color)
    end
    nothing
end

out_stream_size(out_stream::Union{Nothing,IO}) = out_stream === nothing ? (40, 15) : displaysize(out_stream)
out_stream_width(out_stream::Union{Nothing,IO})::Int = out_stream_size(out_stream)[1]
out_stream_height(out_stream::Union{Nothing,IO})::Int = out_stream_size(out_stream)[2]

function _handle_deprecated_symb(symb, symbols)
    if symb === nothing
        symbols
    else
        Base.depwarn("The keyword `symb` is deprecated in favor of `symbols`", :BarplotGraphics)
        [symb]
    end
end
