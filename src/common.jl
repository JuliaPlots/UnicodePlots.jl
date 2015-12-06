ceil_neg_log10{F<:AbstractFloat}(x::F) = ceil(Integer, -log10(x))
round_neg_log10{F<:AbstractFloat}(x::F) = round(Integer, -log10(x), RoundNearestTiesUp)
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

const borderMap = Dict{Symbol,Dict{Symbol,UTF8String}}()
const borderSolid = Dict{Symbol,UTF8String}()
const borderBold = Dict{Symbol,UTF8String}()
const borderNone = Dict{Symbol,UTF8String}()
const borderDashed = Dict{Symbol,UTF8String}()
const borderDotted = Dict{Symbol,UTF8String}()
const borderAscii = Dict{Symbol,UTF8String}()
borderSolid[:tl]="┌"
borderSolid[:tr]="┐"
borderSolid[:bl]="└"
borderSolid[:br]="┘"
borderSolid[:t]="─"
borderSolid[:l]="│"
borderSolid[:b]="─"
borderSolid[:r]="│"
borderBold[:tl]="┏"
borderBold[:tr]="┓"
borderBold[:bl]="┗"
borderBold[:br]="┛"
borderBold[:t]="━"
borderBold[:l]="┃"
borderBold[:b]="━"
borderBold[:r]="┃"
borderNone[:tl]=" "
borderNone[:tr]=" "
borderNone[:bl]=" "
borderNone[:br]=" "
borderNone[:t]=" "
borderNone[:l]=" "
borderNone[:b]=" "
borderNone[:r]=" "
borderDashed[:tl]="┌"
borderDashed[:tr]="┐"
borderDashed[:bl]="└"
borderDashed[:br]="┘"
borderDashed[:t]="╌"
borderDashed[:l]="│"
borderDashed[:b]="╌"
borderDashed[:r]="│"
borderDotted[:tl]="⡤"
borderDotted[:tr]="⢤"
borderDotted[:bl]="⠓"
borderDotted[:br]="⠚"
borderDotted[:t]="⠤"
borderDotted[:l]="⡇"
borderDotted[:b]="⠒"
borderDotted[:r]="⢸"
borderAscii[:tl]="+"
borderAscii[:tr]="+"
borderAscii[:bl]="+"
borderAscii[:br]="+"
borderAscii[:t]="-"
borderAscii[:l]="|"
borderAscii[:b]="-"
borderAscii[:r]="|"
borderMap[:solid]=borderSolid
borderMap[:bold]=borderBold
borderMap[:none]=borderNone
borderMap[:dashed]=borderDashed
borderMap[:dotted]=borderDotted
borderMap[:ascii]=borderAscii

const autoColors = [:blue, :red, :yellow, :magenta, :green, :cyan]
const colorEncode = Dict{Symbol,UInt8}()
const colorDecode = Dict{UInt8,Symbol}()
colorEncode[:white]=0b000
colorEncode[:blue]=0b001
colorEncode[:red]=0b010
colorEncode[:magenta]=0b011
colorEncode[:yellow]=0b100
colorEncode[:green]=0b101
colorEncode[:cyan]=0b110
for k in keys(colorEncode)
    v = colorEncode[k]
    colorDecode[v]=k
end
colorDecode[0b111]=:white

function printColor(color::UInt8, io::IO, args...)
    col = colorDecode[color]
    str = string(args...)
    print_with_color(col, io, str)
end

# ▁▂▃▄▅▆▇█
# ⬛
