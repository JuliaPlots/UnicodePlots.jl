function createDensityWindow{F<:FloatingPoint}(X::Vector{F}, Y::Vector{F};
                                               width::Int = 40,
                                               height::Int = 20,
                                               margin::Int = 3,
                                               padding::Int = 1,
                                               title::String = "",
                                               border::Symbol = :solid,
                                               labels::Bool = true,
                                               xlim::Vector = [0.,0.],
                                               ylim::Vector = [0.,0.])
  length(xlim) == length(ylim) == 2 || throw(ArgumentError("xlim and ylim must only be vectors of length 2"))
  margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  width = max(width, 5)
  height = max(height, 5)
  minX = float(minimum(xlim))
  maxX = float(maximum(xlim))
  if minX == 0. && maxX == 0.
    minX = minimum(X)
    maxX = maximum(X)
    minX, maxX = plottingRange(minX, maxX)
  end
  minY = float(minimum(ylim))
  maxY = float(minimum(ylim))
  if minY == 0. && maxY == 0.
    minY = minimum(Y)
    maxY = maximum(Y)
    minY, maxY = plottingRange(minY, maxY)
  end
  plotOriginX = minX; plotWidth = maxX - plotOriginX
  plotOriginY = minY; plotHeight = maxY - plotOriginY

  canvas = DensityCanvas(width, height,
                         plotOriginX = plotOriginX, plotOriginY = plotOriginY,
                         plotWidth = plotWidth, plotHeight = plotHeight)
  newPlot = Plot(canvas, title=title, margin=margin,
                 padding=padding, border=border, showLabels=labels)

  minXString=string(isinteger(minX) ? safeRound(minX) : minX)
  maxXString=string(isinteger(maxX) ? safeRound(maxX) : maxX)
  minYString=string(isinteger(minY) ? safeRound(minY) : minY)
  maxYString=string(isinteger(maxY) ? safeRound(maxY) : maxY)
  annotate!(newPlot, :l, 1, maxYString)
  annotate!(newPlot, :l, height, minYString)
  annotate!(newPlot, :bl, minXString)
  annotate!(newPlot, :br, maxXString)
  if minY < 0 < maxY
    for i in linspace(minX, maxX, width * 2)
      setPoint!(newPlot, i, 0., :white)
    end
  end
  newPlot
end

function densityplot{F<:Real,R<:Real}(X::Vector{F}, Y::Vector{R};
                                      color::Symbol = :white,
                                      args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  minX = minimum(X); minY = minimum(Y)
  maxX = maximum(X); maxY = maximum(Y)
  newPlot = createDensityWindow(X, Y; args...)
  setPoint!(newPlot, X, Y, color)
end

