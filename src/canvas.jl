
import Base.show

const spce = if VERSION < v"0.4-"
  char(0x2800)
else
  Char(0x2800)
end
const spceStr = string(spce)

signs = ['⡀' '⠄' '⠂' '⠁';
         '⢀' '⠠' '⠐' '⠈']

abstract Canvas

type BrailleCanvas <: Canvas
  grid::Array{Char,2}
  colors::Array{Uint8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::FloatingPoint
  plotOriginY::FloatingPoint
  plotWidth::FloatingPoint
  plotHeight::FloatingPoint
end

function BrailleCanvas(charWidth::Int, charHeight::Int;
                plotOriginX::FloatingPoint = 0., plotOriginY::FloatingPoint = 0.,
                plotWidth::FloatingPoint = 1., plotHeight::FloatingPoint = 1.)
  charWidth = charWidth < 5 ? 5 : charWidth
  charHeight = charHeight < 5 ? 5 : charHeight
  pixelWidth = charWidth * 2
  pixelHeight = charHeight * 4
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(spce, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  BrailleCanvas(grid, colors, pixelWidth, pixelHeight, plotOriginX, plotOriginY, plotWidth, plotHeight)
end

nrows(c::BrailleCanvas) = size(c.grid,2)
ncols(c::BrailleCanvas) = size(c.grid,1)

function drawRow(io::IO, c::BrailleCanvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = nunrows - row + 1
  for x in 1:ncols(c)
    printColor(c.colors[x,y], io, c.grid[x,y])
  end
end

function show(io::IO, c::BrailleCanvas)
  b = borderDashed
  borderLength = ncols(c)
  drawBorderTop(io, "", borderLength, :solid)
  print(io, "\n")
  for row in 1:nrows(c)
    print(io, b[:l])
    drawRow(io, c, row)
    print(io, b[:r], "\n")
  end
  drawBorderBottom(io, "", borderLength, :solid)
  print(io, "\n")
end

function setPixel!(c::BrailleCanvas, pixelX::Int, pixelY::Int, color::Symbol=:white)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = safeFloor(tmp) + 1
  charXOff = (pixelX % 2) + 1
  if charX < safeRound(tmp) + 1 && charXOff == 1
    charX = charX + 1
  end
  charY = safeFloor(pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % 4) + 1
  if VERSION < v"0.4-"
    c.grid[charX,charY] = c.grid[charX,charY] | signs[charXOff, charYOff]
    c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  else
    c.grid[charX,charY] = Char(Uint64(c.grid[charX,charY]) | Uint64(signs[charXOff, charYOff]))
    c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  end
  c
end

function setPoint!(c::BrailleCanvas, plotX::FloatingPoint, plotY::FloatingPoint, color::Symbol=:white)
  c.plotOriginX <= plotX < c.plotOriginX + c.plotWidth || return nothing
  c.plotOriginY <= plotY < c.plotOriginY + c.plotHeight || return nothing
  plotXOffset = plotX - c.plotOriginX
  pixelX = plotXOffset / c.plotWidth * c.pixelWidth
  plotYOffset = plotY - c.plotOriginY
  pixelY = plotYOffset / c.plotHeight * c.pixelHeight
  setPixel!(c, safeFloor(pixelX), safeFloor(pixelY), color)
end

function setPoint!{F<:Real,R<:Real}(c::BrailleCanvas, X::Vector{F}, Y::Vector{R}, color::Symbol=:white)
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  for i in 1:length(X)
    setPoint!(c, X[i], Y[i], color)
  end
end

# Implementation of the digital differential analyser (DDA)
function drawLine!{F<:FloatingPoint}(c::BrailleCanvas, x1::F, y1::F, x2::F, y2::F, color::Symbol=:white)
  toff = x1 - c.plotOriginX
  px1 = toff / c.plotWidth * c.pixelWidth
  toff = x2 - c.plotOriginX
  px2 = toff / c.plotWidth * c.pixelWidth
  toff = y1 - c.plotOriginY
  py1 = toff / c.plotHeight * c.pixelHeight
  toff = y2 - c.plotOriginY
  py2 = toff / c.plotHeight * c.pixelHeight
  dx = px2 - px1
  dy = py2 - py1
  nsteps = abs(dx) > abs(dy) ? abs(dx): abs(dy)
  incX = dx / nsteps
  incY = dy / nsteps
  curX = px1
  curY = py1
  fpw = convert(FloatingPoint, c.pixelWidth)
  fph = convert(FloatingPoint, c.pixelHeight)
  setPixel!(c, safeRound(curX), safeRound(curY), color)
  for i = 1:nsteps
    curX += incX
    curY += incY
    setPixel!(c, safeRound(curX), safeRound(curY), color)
  end
  c
end



