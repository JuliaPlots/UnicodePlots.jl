
function safeRound(num)
  if VERSION < v"0.4-"
    iround(num)
  else
    round(Integer,num)
  end
end

function safeFloor(num)
  if VERSION < v"0.4-"
    ifloor(num)
  else
    floor(Integer,num)
  end
end

function safeCeil(num)
  if VERSION < v"0.4-"
    iceil(num)
  else
    ceil(Integer,num)
  end
end

ceilNegLog10{F<:FloatingPoint}(x::F) = safeCeil(-log10(x))
roundNegLog10{F<:FloatingPoint}(x::F) = safeRound(-log10(x))
roundUpToTick{F<:FloatingPoint,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? ceil(x, ceilNegLog10(m)) : -floor(-x, ceilNegLog10(m)))
roundDownToTick{F<:FloatingPoint,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? floor(x, ceilNegLog10(m)) : -ceil(-x, ceilNegLog10(m)))
floatRoundLog10{F<:FloatingPoint,R<:Real}(x::F,m::R) = x == 0. ? 0.: (x > 0 ? round(x, ceilNegLog10(m)+1) : -round(-x, ceilNegLog10(m)+1))
floatRoundLog10{F<:FloatingPoint}(x::F) = x > 0 ? floatRoundLog10(x,x): floatRoundLog10(x,-x)

function plottingRange{F<:FloatingPoint,R<:FloatingPoint}(xmin::F, xmax::R)
  diffX = xmax - xmin
  xmax = roundUpToTick(xmax, diffX)
  xmin = roundDownToTick(xmin, diffX)
  xmin, xmax
end

borderMap=Dict{Symbol,Dict{Symbol,String}}()
borderSolid=Dict{Symbol,String}()
borderSolid[:tl]="┌"
borderSolid[:tr]="┐"
borderSolid[:bl]="└"
borderSolid[:br]="┘"
borderSolid[:t]="─"
borderSolid[:l]="│"
borderSolid[:b]="─"
borderSolid[:r]="│"
borderBold=Dict{Symbol,String}()
borderBold[:tl]="┏"
borderBold[:tr]="┓"
borderBold[:bl]="┗"
borderBold[:br]="┛"
borderBold[:t]="━"
borderBold[:l]="┃"
borderBold[:b]="━"
borderBold[:r]="┃"
borderNone=Dict{Symbol,String}()
borderNone[:tl]=" "
borderNone[:tr]=" "
borderNone[:bl]=" "
borderNone[:br]=" "
borderNone[:t]=" "
borderNone[:l]=" "
borderNone[:b]=" "
borderNone[:r]=" "
borderDashed=Dict{Symbol,String}()
borderDashed[:tl]="┌"
borderDashed[:tr]="┐"
borderDashed[:bl]="└"
borderDashed[:br]="┘"
borderDashed[:t]="╌"
borderDashed[:l]="│"
borderDashed[:b]="╌"
borderDashed[:r]="│"
borderDotted=Dict{Symbol,String}()
borderDotted[:tl]="⡤"
borderDotted[:tr]="⢤"
borderDotted[:bl]="⠓"
borderDotted[:br]="⠚"
borderDotted[:t]="⠤"
borderDotted[:l]="⡇"
borderDotted[:b]="⠒"
borderDotted[:r]="⢸"
borderMap[:solid]=borderSolid
borderMap[:bold]=borderBold
borderMap[:none]=borderNone
borderMap[:dashed]=borderDashed
borderMap[:dotted]=borderDotted

colorEncode=Dict{Symbol,Uint8}()
colorEncode[:white]=0b000
colorEncode[:blue]=0b001
colorEncode[:red]=0b010
colorEncode[:magenta]=0b011
colorEncode[:yellow]=0b100
colorEncode[:green]=0b101
colorEncode[:cyan]=0b110
colorDecode=Dict{Uint8,Symbol}()
for k in keys(colorEncode)
  v = colorEncode[k]
  colorDecode[v]=k
end
colorDecode[0b111]=:white

# ▖▗▘▙▚▛▜▝▞▟
# ▁▂▃▄▅▆▇█
# ░▒▓█
# ⬛

function printColor(color::Uint8, io::IO, args...)
  #if isa(io, Base.TTY)
    col = colorDecode[color]
    str = string(args...)
    print_with_color(col, io, str)
  #else
  #  print(io, args...)
  #end
end
