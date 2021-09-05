const DOC_PLOT_PARAMS = """
- **`title`** : Text to display on the top of the plot.

- **`xlabel`** : Text to display on the x axis of the plot

- **`ylabel`** : Text to display on the y axis of the plot

- **`labels`** : Boolean. Can be used to hide the labels by
  setting `labels = false`.

- **`border`** : The style of the bounding box of the plot.
  Supports `:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`,
  `:ascii`, and `:none`.

- **`margin`** : Number of empty characters to the left of the
  whole plot.

- **`padding`** : Space of the left and right of the plot between
  the labels and the canvas.

- **`color`** : Color of the drawing.
  Can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`,
  `:magenta`, `:white`, `:normal`, an integer in the range `0`-`255` for Color256 palette,
  or a tuple of three integers as RGB components.

- **`width`** : Number of characters per row that should be used
  for plotting.
"""

transform_name(::typeof(identity), basename = "") = basename
function transform_name(f, basename = "")
    fname = string(nameof(f))
    fname = occursin("#", fname) ? "custom" : fname
    string(basename, " [", fname, "]")
end

roundable(num::Number) = isinteger(num) & (typemin(Int) <= num < typemax(Int))
compact_repr(num::Number) = repr(num, context=:compact => true)

ceil_neg_log10(x) = roundable(-log10(x)) ? ceil(Integer, -log10(x)) : floor(Integer, -log10(x))
round_neg_log10(x) = roundable(-log10(x)) ? round(Integer, -log10(x), RoundNearestTiesUp) : floor(Integer, -log10(x))
round_up_tick(x,m) = x == 0. ? 0. : (x > 0 ? ceil(x, digits=ceil_neg_log10(m)) : -floor(-x, digits=ceil_neg_log10(m)))
round_down_tick(x,m) = x == 0. ? 0. : (x > 0 ? floor(x, digits=ceil_neg_log10(m)) : -ceil(-x, digits=ceil_neg_log10(m)))
round_up_subtick(x,m) = x == 0. ? 0. : (x > 0 ? ceil(x, digits=ceil_neg_log10(m)+1) : -floor(-x, digits=ceil_neg_log10(m)+1))
round_down_subtick(x,m) = x == 0. ? 0. : (x > 0 ? floor(x, digits=ceil_neg_log10(m)+1) : -ceil(-x, digits=ceil_neg_log10(m)+1))
float_round_log10(x::F,m) where {F<:AbstractFloat} = x == 0. ? F(0) : (x > 0 ? round(x, digits=ceil_neg_log10(m)+1)::F : -round(-x, digits=ceil_neg_log10(m)+1)::F)
float_round_log10(x::Integer,m) = float_round_log10(float(x), m)
float_round_log10(x) = x > 0 ? float_round_log10(x,x) : float_round_log10(x,-x)

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

function extend_limits(vec, limits)
    mi, ma = map(Float64, extrema(limits))
    if mi == 0. && ma == 0.
        mi, ma = map(Float64, extrema(vec))
    end
    diff = ma - mi
    if diff == 0
        ma = mi + 1
        mi = mi - 1
    end
    (limits == (0.,0.) || limits == [0.,0.]) ? plotting_range_narrow(mi, ma) : (mi, ma)
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

const bordermap = Dict{Symbol,Dict{Symbol,String}}()
const border_solid  = Dict{Symbol,String}()
const border_corners = Dict{Symbol,String}()
const border_barplot = Dict{Symbol,String}()
const border_bold   = Dict{Symbol,String}()
const border_none   = Dict{Symbol,String}()
const border_dashed = Dict{Symbol,String}()
const border_dotted = Dict{Symbol,String}()
const border_ascii  = Dict{Symbol,String}()
border_solid[:tl] = "┌"
border_solid[:tr] = "┐"
border_solid[:bl] = "└"
border_solid[:br] = "┘"
border_solid[:t] = "─"
border_solid[:l] = "│"
border_solid[:b] = "─"
border_solid[:r] = "│"
border_corners[:tl] = "┌"
border_corners[:tr] = "┐"
border_corners[:bl] = "└"
border_corners[:br] = "┘"
border_corners[:t] = " "
border_corners[:l] = " "
border_corners[:b] = " "
border_corners[:r] = " "
border_barplot[:tl] = "┌"
border_barplot[:tr] = "┐"
border_barplot[:bl] = "└"
border_barplot[:br] = "┘"
border_barplot[:t] = " "
border_barplot[:l] = "┤"
border_barplot[:b] = " "
border_barplot[:r] = " "
border_bold[:tl] = "┏"
border_bold[:tr] = "┓"
border_bold[:bl] = "┗"
border_bold[:br] = "┛"
border_bold[:t] = "━"
border_bold[:l] = "┃"
border_bold[:b] = "━"
border_bold[:r] = "┃"
border_none[:tl] = " "
border_none[:tr] = " "
border_none[:bl] = " "
border_none[:br] = " "
border_none[:t] = " "
border_none[:l] = " "
border_none[:b] = " "
border_none[:r] = " "
border_dashed[:tl] = "┌"
border_dashed[:tr] = "┐"
border_dashed[:bl] = "└"
border_dashed[:br] = "┘"
border_dashed[:t] = "╌"
border_dashed[:l] = "┊"
border_dashed[:b] = "╌"
border_dashed[:r] = "┊"
border_dotted[:tl] = "⡤"
border_dotted[:tr] = "⢤"
border_dotted[:bl] = "⠓"
border_dotted[:br] = "⠚"
border_dotted[:t] = "⠤"
border_dotted[:l] = "⡇"
border_dotted[:b] = "⠒"
border_dotted[:r] = "⢸"
border_ascii[:tl] = "+"
border_ascii[:tr] = "+"
border_ascii[:bl] = "+"
border_ascii[:br] = "+"
border_ascii[:t] = "-"
border_ascii[:l] = "|"
border_ascii[:b] = "-"
border_ascii[:r] = "|"
bordermap[:solid]  = border_solid
bordermap[:corners] = border_corners
bordermap[:barplot] = border_barplot
bordermap[:bold]   = border_bold
bordermap[:none]   = border_none
bordermap[:dashed] = border_dashed
bordermap[:dotted] = border_dotted
bordermap[:ascii]  = border_ascii

const UserColorType = Union{Integer,Symbol,NTuple{3,Integer},Nothing}  # allowed color type
const JuliaColorType = Union{Symbol,Int}  # color type for printstyled (defined in base/util.jl)
const ColorType = Union{Nothing,UInt8}  # internal UnicodePlots color type

const color_cycle = [:green, :blue, :red, :magenta, :yellow, :cyan]

function print_color(color::UserColorType, io::IO, args...)
    printstyled(io, string(args...); color = julia_color(color))
end

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

function julia_color(color::UserColorType)::JuliaColorType
    if color isa Nothing
        :normal
    elseif color isa Symbol
        color
    elseif color isa Integer
        Int(color)
    else
        julia_color(crayon_256_color(color))
    end
end

@inline function set_color!(colors::Array{ColorType,2}, x::Int, y::Int, color::ColorType; force::Bool=false)
    if color === nothing || colors[x, y] === nothing || force
        colors[x, y] = color
    else
        colors[x, y] |= color
    end
    nothing
end

default_os_size(os::Union{Nothing,IO}) = os === nothing ? (40, 15) : displaysize(os)
default_os_width(os::Union{Nothing,IO})::Int = default_os_size(os)[1]
default_os_height(os::Union{Nothing,IO})::Int = default_os_size(os)[2]

function _handle_deprecated_symb(symb, symbols)
    if symb === nothing
        return symbols
    else
        Base.depwarn("The keyword `symb` is deprecated in favor of `symbols`", :BarplotGraphics)
        return [symb]
    end
end
