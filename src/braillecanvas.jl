
const spce = if VERSION < v"0.4-"
  char(0x2800)
else
  Char(0x2800)
end

signs = ['⠁' '⠂' '⠄' '⡀';
         '⠈' '⠐' '⠠' '⢀']

type BrailleCanvas <: Canvas
  grid::Array{Char,2}
  colors::Array{(@compat UInt8),2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::(@compat AbstractFloat)
  plotOriginY::(@compat AbstractFloat)
  plotWidth::(@compat AbstractFloat)
  plotHeight::(@compat AbstractFloat)
end

function BrailleCanvas(charWidth::Int, charHeight::Int;
                       plotOriginX::(@compat AbstractFloat) = 0.,
                       plotOriginY::(@compat AbstractFloat) = 0.,
                       plotWidth::(@compat AbstractFloat) = 1.,
                       plotHeight::(@compat AbstractFloat) = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 2)
  pixelWidth = charWidth * 2
  pixelHeight = charHeight * 4
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(spce, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  BrailleCanvas(grid, colors,
                pixelWidth, pixelHeight,
                plotOriginX, plotOriginY,
                plotWidth, plotHeight)
end

function setPixel!(c::BrailleCanvas, pixelX::Int, pixelY::Int, color::Symbol)
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
  else
    c.grid[charX,charY] = Char((@compat UInt64)(c.grid[charX,charY]) | (@compat UInt64)(signs[charXOff, charYOff]))
  end
  c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  c
end

function setPixel!(c::Canvas, pixelX::Int, pixelY::Int; color::Symbol=:white)
  setPixel!(c, pixelX, pixelY, color)
end

function setPoint!(c::Canvas, plotX::(@compat AbstractFloat), plotY::(@compat AbstractFloat), color::Symbol)
  c.plotOriginX <= plotX < c.plotOriginX + c.plotWidth || return nothing
  c.plotOriginY <= plotY < c.plotOriginY + c.plotHeight || return nothing
  plotXOffset = plotX - c.plotOriginX
  pixelX = plotXOffset / c.plotWidth * c.pixelWidth
  plotYOffset = plotY - c.plotOriginY
  pixelY = c.pixelHeight - plotYOffset / c.plotHeight * c.pixelHeight
  setPixel!(c, safeFloor(pixelX), safeFloor(pixelY), color)
end

function setPoint!(c::Canvas, plotX::(@compat AbstractFloat), plotY::(@compat AbstractFloat); color::Symbol=:white)
  setPoint!(c, plotX, plotY, color)
end

function setPoint!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}, color::Symbol)
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  for i in 1:length(X)
    setPoint!(c, X[i], Y[i], color)
  end
  c
end

function setPoint!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}; color::Symbol=:white)
  setPoint!(c, X, Y, color)
end

# Implementation of the digital differential analyser (DDA)
function drawLine!{F<:(@compat AbstractFloat)}(c::Canvas, x1::F, y1::F, x2::F, y2::F, color::Symbol)
  toff = x1 - c.plotOriginX
  px1 = toff / c.plotWidth * c.pixelWidth
  toff = x2 - c.plotOriginX
  px2 = toff / c.plotWidth * c.pixelWidth
  toff = y1 - c.plotOriginY
  py1 = c.pixelHeight - toff / c.plotHeight * c.pixelHeight
  toff = y2 - c.plotOriginY
  py2 = c.pixelHeight - toff / c.plotHeight * c.pixelHeight
  dx = px2 - px1
  dy = py2 - py1
  nsteps = abs(dx) > abs(dy) ? abs(dx): abs(dy)
  incX = dx / nsteps
  incY = dy / nsteps
  curX = px1
  curY = py1
  fpw = convert((@compat AbstractFloat), c.pixelWidth)
  fph = convert((@compat AbstractFloat), c.pixelHeight)
  setPixel!(c, safeFloor(curX), safeFloor(curY), color)
  for i = 1:nsteps
    curX += incX
    curY += incY
    setPixel!(c, safeFloor(curX), safeFloor(curY), color)
  end
  c
end

function drawLine!{F<:(@compat AbstractFloat)}(c::Canvas, x1::F, y1::F, x2::F, y2::F; color::Symbol=:white)
  drawLine!(c, x1, y1, x2, y2, color)
end

function drawLine!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}, color::Symbol)
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  for i in 1:(length(X)-1)
    drawLine!(c, X[i], Y[i], X[i+1], Y[i+1], color)
  end
  c
end

function drawLine!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}; color::Symbol=:white)
  drawLine!(c, X, Y, color)
end
