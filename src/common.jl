roundable{T<:Number}(num::T) = isinteger(num) & (typemin(Int) <= num < typemax(Int))

ceil_neg_log10{F<:AbstractFloat}(x::F) = roundable(-log10(x)) ? ceil(Integer, -log10(x)) : floor(Integer, -log10(x))
round_neg_log10{F<:AbstractFloat}(x::F) = roundable(-log10(x)) ? round(Integer, -log10(x), RoundNearestTiesUp) : floor(Integer, -log10(x))
round_up_tick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? ceil(x, ceil_neg_log10(m)) : -floor(-x, ceil_neg_log10(m)))
round_down_tick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? floor(x, ceil_neg_log10(m)) : -ceil(-x, ceil_neg_log10(m)))
round_up_subtick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? ceil(x, ceil_neg_log10(m)+1) : -floor(-x, ceil_neg_log10(m)+1))
round_down_subtick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? floor(x, ceil_neg_log10(m)+1) : -ceil(-x, ceil_neg_log10(m)+1))
float_round_log10{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? round(x, ceil_neg_log10(m)+1)::Float64 : -round(-x, ceil_neg_log10(m)+1)::Float64)
float_round_log10{F<:AbstractFloat}(x::F) = x > 0 ? float_round_log10(x,x) : float_round_log10(x,-x)

function plotting_range{F<:AbstractFloat,R<:AbstractFloat}(xmin::F, xmax::R)
    diffX = xmax - xmin
    xmax = round_up_tick(xmax, diffX)
    xmin = round_down_tick(xmin, diffX)
    xmin, xmax
end

function plotting_range_narrow{F<:AbstractFloat,R<:AbstractFloat}(xmin::F, xmax::R)
    diffX = xmax - xmin
    xmax = round_up_subtick(xmax, diffX)
    xmin = round_down_subtick(xmin, diffX)
    xmin, xmax
end

function extend_limits(vec, limits)
    mi = float(minimum(limits))
    ma = float(maximum(limits))
    if mi == 0. && ma == 0.
        mi = minimum(vec)
        ma = maximum(vec)
    end
    diff = ma - mi
    if diff == 0
        ma = mi + 1
        mi = mi - 1
    end
    (limits == [0.,0.]) ? plotting_range_narrow(mi, ma) : plotting_range_narrow(mi, ma)
end

const bordermap = Dict{Symbol,Dict{Symbol,String}}()
const border_solid  = Dict{Symbol,String}()
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
border_dashed[:l] = "│"
border_dashed[:b] = "╌"
border_dashed[:r] = "│"
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
bordermap[:bold]   = border_bold
bordermap[:none]   = border_none
bordermap[:dashed] = border_dashed
bordermap[:dotted] = border_dotted
bordermap[:ascii]  = border_ascii

const color_cycle = [:blue, :red, :yellow, :magenta, :green, :cyan]
const color_encode = Dict{Symbol,UInt8}()
const color_decode = Dict{UInt8,Symbol}()
color_encode[:white]   = 0b000
color_encode[:blue]    = 0b001
color_encode[:red]     = 0b010
color_encode[:magenta] = 0b011
color_encode[:yellow]  = 0b100
color_encode[:green]   = 0b101
color_encode[:cyan]    = 0b110
for k in keys(color_encode)
    v = color_encode[k]
    color_decode[v] = k
end
color_decode[0b111] = :white

@inline function print_color(color::UInt8, io::IO, args...)
    col = color_decode[color]
    str = string(args...)
    print_with_color(col, io, str)
end
