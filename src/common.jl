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

const _lut_8bit = UInt32[
    0x000000
    0x800000
    0x008000
    0x808000
    0x000080
    0x800080
    0x008080
    0xc0c0c0
    0x808080
    0xff0000
    0x00ff00
    0xffff00
    0x0000ff
    0xff00ff
    0x00ffff
    0xffffff
    0x000000
    0x00005f
    0x000087
    0x0000af
    0x0000d7
    0x0000ff
    0x005f00
    0x005f5f
    0x005f87
    0x005faf
    0x005fd7
    0x005fff
    0x008700
    0x00875f
    0x008787
    0x0087af
    0x0087d7
    0x0087ff
    0x00af00
    0x00af5f
    0x00af87
    0x00afaf
    0x00afd7
    0x00afff
    0x00d700
    0x00d75f
    0x00d787
    0x00d7af
    0x00d7d7
    0x00d7ff
    0x00ff00
    0x00ff5f
    0x00ff87
    0x00ffaf
    0x00ffd7
    0x00ffff
    0x5f0000
    0x5f005f
    0x5f0087
    0x5f00af
    0x5f00d7
    0x5f00ff
    0x5f5f00
    0x5f5f5f
    0x5f5f87
    0x5f5faf
    0x5f5fd7
    0x5f5fff
    0x5f8700
    0x5f875f
    0x5f8787
    0x5f87af
    0x5f87d7
    0x5f87ff
    0x5faf00
    0x5faf5f
    0x5faf87
    0x5fafaf
    0x5fafd7
    0x5fafff
    0x5fd700
    0x5fd75f
    0x5fd787
    0x5fd7af
    0x5fd7d7
    0x5fd7ff
    0x5fff00
    0x5fff5f
    0x5fff87
    0x5fffaf
    0x5fffd7
    0x5fffff
    0x870000
    0x87005f
    0x870087
    0x8700af
    0x8700d7
    0x8700ff
    0x875f00
    0x875f5f
    0x875f87
    0x875faf
    0x875fd7
    0x875fff
    0x878700
    0x87875f
    0x878787
    0x8787af
    0x8787d7
    0x8787ff
    0x87af00
    0x87af5f
    0x87af87
    0x87afaf
    0x87afd7
    0x87afff
    0x87d700
    0x87d75f
    0x87d787
    0x87d7af
    0x87d7d7
    0x87d7ff
    0x87ff00
    0x87ff5f
    0x87ff87
    0x87ffaf
    0x87ffd7
    0x87ffff
    0xaf0000
    0xaf005f
    0xaf0087
    0xaf00af
    0xaf00d7
    0xaf00ff
    0xaf5f00
    0xaf5f5f
    0xaf5f87
    0xaf5faf
    0xaf5fd7
    0xaf5fff
    0xaf8700
    0xaf875f
    0xaf8787
    0xaf87af
    0xaf87d7
    0xaf87ff
    0xafaf00
    0xafaf5f
    0xafaf87
    0xafafaf
    0xafafd7
    0xafafff
    0xafd700
    0xafd75f
    0xafd787
    0xafd7af
    0xafd7d7
    0xafd7ff
    0xafff00
    0xafff5f
    0xafff87
    0xafffaf
    0xafffd7
    0xafffff
    0xd70000
    0xd7005f
    0xd70087
    0xd700af
    0xd700d7
    0xd700ff
    0xd75f00
    0xd75f5f
    0xd75f87
    0xd75faf
    0xd75fd7
    0xd75fff
    0xd78700
    0xd7875f
    0xd78787
    0xd787af
    0xd787d7
    0xd787ff
    0xd7af00
    0xd7af5f
    0xd7af87
    0xd7afaf
    0xd7afd7
    0xd7afff
    0xd7d700
    0xd7d75f
    0xd7d787
    0xd7d7af
    0xd7d7d7
    0xd7d7ff
    0xd7ff00
    0xd7ff5f
    0xd7ff87
    0xd7ffaf
    0xd7ffd7
    0xd7ffff
    0xff0000
    0xff005f
    0xff0087
    0xff00af
    0xff00d7
    0xff00ff
    0xff5f00
    0xff5f5f
    0xff5f87
    0xff5faf
    0xff5fd7
    0xff5fff
    0xff8700
    0xff875f
    0xff8787
    0xff87af
    0xff87d7
    0xff87ff
    0xffaf00
    0xffaf5f
    0xffaf87
    0xffafaf
    0xffafd7
    0xffafff
    0xffd700
    0xffd75f
    0xffd787
    0xffd7af
    0xffd7d7
    0xffd7ff
    0xffff00
    0xffff5f
    0xffff87
    0xffffaf
    0xffffd7
    0xffffff
    0x080808
    0x121212
    0x1c1c1c
    0x262626
    0x303030
    0x3a3a3a
    0x444444
    0x4e4e4e
    0x585858
    0x626262
    0x6c6c6c
    0x767676
    0x808080
    0x8a8a8a
    0x949494
    0x9e9e9e
    0xa8a8a8
    0xb2b2b2
    0xbcbcbc
    0xc6c6c6
    0xd0d0d0
    0xdadada
    0xe4e4e4
    0xeeeeee
]

const UserColorType = Union{Integer,Symbol,NTuple{3,Integer},Nothing}  # allowed color type
const BaseColorType = Union{Symbol,Int}  # color type for printstyled (defined in base/util.jl), used for annotations, ...
const ColorType = UInt32  # internal UnicodePlots color type (canvas)
const THRESHOLD = UInt32(256^3)

const color_cycle = [:green, :blue, :red, :magenta, :yellow, :cyan]

r32(r::Integer)::UInt32 = (r & 0xffffff) << 16
g32(g::Integer)::UInt32 = (g & 0xffffff) << 8
b32(b::Integer)::UInt32 = (b & 0xffffff)

red(c::UInt32)::UInt8 = (c >> 16) & 0xff
grn(c::UInt32)::UInt8 = (c >> 8) & 0xff
blu(c::UInt32)::UInt8 = c & 0xff

function blend(a::UInt32, b::UInt32)::UInt32
    if a < THRESHOLD && b < THRESHOLD 
        return (
            r32(floor(UInt32, √(red(a)^2 + red(b)^2))) +
            g32(floor(UInt32, √(grn(a)^2 + grn(b)^2))) +
            b32(floor(UInt32, √(blu(a)^2 + blu(b)^2)))
        )
    else
        return THRESHOLD + (UInt8(a - THRESHOLD) | UInt8(b - THRESHOLD))
    end
end

print_color(color::BaseColorType, io::IO, args...) = printstyled(io, args...; color = color)
# print_color(color::Nothing, io::IO, args...) = print(io, args...)

validate_base(color::ColorType) = color == typemax(ColorType) ? :normal : Int(color - THRESHOLD)
validate_crayon(color::ColorType) = color == typemax(ColorType) ? ColorType(0) : color - THRESHOLD

function print_color(color::ColorType, io::IO, args...; bgcol = nothing)
    if color >= THRESHOLD  # ansi - 4bit or 8bit
        if bgcol === nothing
            printstyled(io, args...; color = validate_base(color))
        else
            print_color(validate_crayon(color), io, args...; bgcol = validate_crayon(bgcol))
        end
    else  # true color - 24bit
        fgcol = Crayons.ANSIColor(Crayons._torgb(color)..., COLORMODE[])
        bgcol = bgcol === nothing ? Crayons.ANSIColor() : Crayons.ANSIColor(Crayons._torgb(bgcol)..., COLORMODE[])
        # @show fgcol bgcol
        c = Crayon(fgcol, bgcol, (Crayons.ANSIStyle() for _ in 1:9)...)
        if true
            print(io, Crayons.CSI)
            Crayons._print(io, c)
            print(io, Crayons.END_ANSI, args...)  # , Crayons.CSI, '0', Crayons.END_ANSI
        else
            print(io, c, args...)  # Crayon(reset=true)
        end
    end
    return
end

function ansi_8bit_color(color::UserColorType)::UInt32
    color === nothing && return typemax(UInt32)
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

function ansi_24bit_color(color::UserColorType)::UInt32
    color === nothing && return typemax(UInt32)
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
    if colors[x, y] === typemax(ColorType) || force
        colors[x, y] = color
    else
        colors[x, y] = blend(colors[x, y], color)
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
