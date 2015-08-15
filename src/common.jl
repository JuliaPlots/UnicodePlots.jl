
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

borderMap=Dict{Symbol,Dict{Symbol,String}}()
borderSolid=Dict{Symbol,String}()
borderSolid[:ul]="┌"
borderSolid[:ur]="┐"
borderSolid[:dl]="└"
borderSolid[:dr]="┘"
borderSolid[:u]="─"
borderSolid[:l]="│"
borderSolid[:d]="─"
borderSolid[:r]="│"
borderBold=Dict{Symbol,String}()
borderBold[:ul]="┏"
borderBold[:ur]="┓"
borderBold[:dl]="┗"
borderBold[:dr]="┛"
borderBold[:u]="━"
borderBold[:l]="┃"
borderBold[:d]="━"
borderBold[:r]="┃"
borderNone=Dict{Symbol,String}()
borderNone[:ul]=" "
borderNone[:ur]=" "
borderNone[:dl]=" "
borderNone[:dr]=" "
borderNone[:u]=" "
borderNone[:l]=" "
borderNone[:d]=" "
borderNone[:r]=" "
borderDashed=Dict{Symbol,String}()
borderDashed[:ul]="┌"
borderDashed[:ur]="┐"
borderDashed[:dl]="└"
borderDashed[:dr]="┘"
borderDashed[:u]="╌"
borderDashed[:l]="│"
borderDashed[:d]="╌"
borderDashed[:r]="│"
borderDotted=Dict{Symbol,String}()
borderDotted[:ul]="⡤"
borderDotted[:ur]="⢤"
borderDotted[:dl]="⠓"
borderDotted[:dr]="⠚"
borderDotted[:u]="⠤"
borderDotted[:l]="⡇"
borderDotted[:d]="⠒"
borderDotted[:r]="⢸"
borderMap[:solid]=borderSolid
borderMap[:bold]=borderBold
borderMap[:none]=borderNone
borderMap[:dashed]=borderDashed
borderMap[:dotted]=borderDotted

signs = ['⡀' '⠄' '⠂' '⠁';
         '⢀' '⠠' '⠐' '⠈']

function drawTitle(io::IO, padding::String, title::String)
  title == "" || print(io, padding, " ", title, "\n")
end

function drawBorderTop(io::IO, padding::String, length::Int, border = :solid)
  b=borderMap[border]
  border == :none || print(io, padding, b[:ul], repeat(b[:u], length), b[:ur], "\n")
end

function drawBorderBottom(io::IO, padding::String, length::Int, border = :solid)
  b=borderMap[border]
  border == :none || print(io, padding, b[:dl], repeat(b[:d], length), b[:dr], "\n")
end
