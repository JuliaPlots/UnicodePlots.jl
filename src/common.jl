ceilNegLog10{F<:AbstractFloat}(x::F) = ceil(Integer, -log10(x))
roundNegLog10{F<:AbstractFloat}(x::F) = round(Integer, -log10(x), RoundNearestTiesUp)
roundUpToTick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? ceil(x, ceilNegLog10(m)) : -floor(-x, ceilNegLog10(m)))
roundDownToTick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? floor(x, ceilNegLog10(m)) : -ceil(-x, ceilNegLog10(m)))
roundUpToSubTick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? ceil(x, ceilNegLog10(m)+1) : -floor(-x, ceilNegLog10(m)+1))
roundDownToSubTick{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? floor(x, ceilNegLog10(m)+1) : -ceil(-x, ceilNegLog10(m)+1))
floatRoundLog10{F<:AbstractFloat,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? round(x, ceilNegLog10(m)+1) : -round(-x, ceilNegLog10(m)+1))
floatRoundLog10{F<:AbstractFloat}(x::F) = x > 0 ? floatRoundLog10(x,x): floatRoundLog10(x,-x)

function plottingRange{F<:AbstractFloat,R<:AbstractFloat}(xmin::F, xmax::R)
  diffX = xmax - xmin
  xmax = roundUpToTick(xmax, diffX)
  xmin = roundDownToTick(xmin, diffX)
  xmin, xmax
end

function plottingRangeNarrow{F<:AbstractFloat,R<:AbstractFloat}(xmin::F, xmax::R)
  diffX = xmax - xmin
  xmax = roundUpToSubTick(xmax, diffX)
  xmin = roundDownToSubTick(xmin, diffX)
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
    ma = mi + mi / 2
    mi = mi / 2
  end
  (limits == [0.,0.]) ? plottingRangeNarrow(mi, ma) : plottingRangeNarrow(mi, ma)
end

const borderMap = Dict{Symbol,Dict{Symbol,UTF8String}}()
const borderSolid = Dict{Symbol,UTF8String}()
borderSolid[:tl]="┌"
borderSolid[:tr]="┐"
borderSolid[:bl]="└"
borderSolid[:br]="┘"
borderSolid[:t]="─"
borderSolid[:l]="│"
borderSolid[:b]="─"
borderSolid[:r]="│"
const borderBold = Dict{Symbol,UTF8String}()
borderBold[:tl]="┏"
borderBold[:tr]="┓"
borderBold[:bl]="┗"
borderBold[:br]="┛"
borderBold[:t]="━"
borderBold[:l]="┃"
borderBold[:b]="━"
borderBold[:r]="┃"
const borderNone = Dict{Symbol,UTF8String}()
borderNone[:tl]=" "
borderNone[:tr]=" "
borderNone[:bl]=" "
borderNone[:br]=" "
borderNone[:t]=" "
borderNone[:l]=" "
borderNone[:b]=" "
borderNone[:r]=" "
const borderDashed = Dict{Symbol,UTF8String}()
borderDashed[:tl]="┌"
borderDashed[:tr]="┐"
borderDashed[:bl]="└"
borderDashed[:br]="┘"
borderDashed[:t]="╌"
borderDashed[:l]="│"
borderDashed[:b]="╌"
borderDashed[:r]="│"
const borderDotted = Dict{Symbol,UTF8String}()
borderDotted[:tl]="⡤"
borderDotted[:tr]="⢤"
borderDotted[:bl]="⠓"
borderDotted[:br]="⠚"
borderDotted[:t]="⠤"
borderDotted[:l]="⡇"
borderDotted[:b]="⠒"
borderDotted[:r]="⢸"
const borderAscii = Dict{Symbol,UTF8String}()
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
colorEncode[:white]=0b000
colorEncode[:blue]=0b001
colorEncode[:red]=0b010
colorEncode[:magenta]=0b011
colorEncode[:yellow]=0b100
colorEncode[:green]=0b101
colorEncode[:cyan]=0b110
const colorDecode = Dict{UInt8,Symbol}()
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

# ▖▗▘▙▚▛▜▝▞▟
# ▁▂▃▄▅▆▇█
# ░▒▓█
# ⬛
