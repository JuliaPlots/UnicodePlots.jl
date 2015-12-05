import Base.show
import Base.print

const spceStr = " " #string(spce)

abstract GraphicsArea
abstract Canvas <: GraphicsArea

function print(io::IO, c::GraphicsArea)
  for row in 1:nrows(c)
    printrow(io, c, row)
    print(io, "\n")
  end
end

function show(io::IO, c::GraphicsArea)
  b = borderDashed
  borderLength = ncols(c)
  drawBorderTop(io, "", borderLength, :solid)
  print(io, "\n")
  for row in 1:nrows(c)
    print_with_color(:white, io, b[:l])
    printrow(io, c, row)
    print_with_color(:white, io, b[:r], "\n")
  end
  drawBorderBottom(io, "", borderLength, :solid)
  print(io, "\n")
end

function pixel!(c::Canvas, pixelX::Int, pixelY::Int; color::Symbol = :white)
  pixel!(c, pixelX, pixelY, color)
end

function points!(c::Canvas, plotX::Real, plotY::Real, color::Symbol)
  c.plotOriginX <= plotX < c.plotOriginX + c.plotWidth || return nothing
  c.plotOriginY <= plotY < c.plotOriginY + c.plotHeight || return nothing
  plotXOffset = plotX - c.plotOriginX
  pixelX = plotXOffset / c.plotWidth * c.pixelWidth
  plotYOffset = plotY - c.plotOriginY
  pixelY = c.pixelHeight - plotYOffset / c.plotHeight * c.pixelHeight
  pixel!(c, floor(Int, pixelX), floor(Int, pixelY), color)
end

function points!(c::Canvas, plotX::Real, plotY::Real; color::Symbol = :white)
  points!(c, plotX, plotY, color)
end

function points!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}, color::Symbol)
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  for i in 1:length(X)
    points!(c, X[i], Y[i], color)
  end
  c
end

function points!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}; color::Symbol = :white)
  points!(c, X, Y, color)
end

# Implementation of the digital differential analyser (DDA)
function lines!(c::Canvas, x1::Real, y1::Real, x2::Real, y2::Real, color::Symbol)
  if (x1 < c.plotOriginX && x2 < c.plotOriginX) ||
      (x1 > c.plotOriginX + c.plotWidth && x2 > c.plotOriginX + c.plotWidth)
    return c
  end
  if (y1 < c.plotOriginY && y2 < c.plotOriginY) ||
      (y1 > c.plotOriginY + c.plotHeight && y2 > c.plotOriginY + c.plotHeight)
    return c
  end
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
  fpw = convert(AbstractFloat, c.pixelWidth)
  fph = convert(AbstractFloat, c.pixelHeight)
  pixel!(c, floor(Int, curX), floor(Int, curY), color)
  for i = 1:nsteps
    curX += incX
    curY += incY
    pixel!(c, floor(Int, curX), floor(Int, curY), color)
  end
  c
end

function lines!(c::Canvas, x1::Real, y1::Real, x2::Real, y2::Real; color::Symbol = :white)
  lines!(c, x1, y1, x2, y2, color)
end

function lines!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}, color::Symbol)
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  for i in 1:(length(X)-1)
    lines!(c, X[i], Y[i], X[i+1], Y[i+1], color)
  end
  c
end

function lines!{F<:Real,R<:Real}(c::Canvas, X::Vector{F}, Y::Vector{R}; color::Symbol = :white)
  lines!(c, X, Y, color)
end
