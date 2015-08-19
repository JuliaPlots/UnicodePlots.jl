
function createPlotWindow{F<:FloatingPoint}(X::Vector{F}, Y::Vector{F};
                                            width::Int=40, height::Int=10,
                                            margin::Int=3, padding::Int=1,
                                            title::String="", border=:solid,
                                            labels::Bool=true)
  margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  width = max(width, 5)
  height = max(height, 5)
  minX = minimum(X); minY = minimum(Y)
  maxX = maximum(X); maxY = maximum(Y)
  minX, maxX = plottingRange(minX, maxX)
  minY, maxY = plottingRange(minY, maxY)
  plotOriginX = minX; plotWidth = maxX - plotOriginX
  plotOriginY = minY; plotHeight = maxY - plotOriginY

  canvas = BrailleCanvas(width, height,
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
    for i in linspace(minX, maxX, width*2)
      setPoint!(newPlot, i, 0., :white)
    end
  end
  newPlot
end

function scatterplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::Vector{F}, Y::Vector{R}; color::Symbol=:white, args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  setPoint!(plot, X, Y, color)
end

function scatterplot{F<:Real,R<:Real}(X::Vector{F}, Y::Vector{R}; color::Symbol=:white, args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  minX = minimum(X); minY = minimum(Y)
  maxX = maximum(X); maxY = maximum(Y)
  newPlot = createPlotWindow(X, Y; args...)
  setPoint!(newPlot, X, Y, color)
end

function lineplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::Vector{F}, Y::Vector{R}; color::Symbol=:white, args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  drawLine!(plot, X, Y, color)
end

function lineplot{F<:Real,R<:Real}(X::Vector{F}, Y::Vector{R}; color::Symbol=:white, args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  newPlot = createPlotWindow(X, Y; args...)
  drawLine!(newPlot, X, Y, color)
end

function lineplot!{T<:Canvas}(plot::Plot{T}, Y::Function, X::Range; args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot!(plot, collect(X), y; args...)
end

function lineplot(Y::Function, X::Range; args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot(collect(X), y; args...)
end

function lineplot!{T<:Canvas,R<:Real}(plot::Plot{T}, Y::Function, X::Vector{R}; args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot!(plot, X, y; args...)
end

function lineplot{R<:Real}(Y::Function, X::Vector{R}; args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot(X, y; args...)
end

function lineplot!{T<:Canvas,R<:Real,S<:Real}(plot::Plot{T}, Y::Function, startx::R, endx::S, step::Real = 1.; args...)
  X = collect(startx:step:endx)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot!(plot, X, y; args...)
end

function lineplot{R<:Real,S<:Real}(Y::Function, startx::R, endx::S, step::Real = 1.; args...)
  X = collect(startx:step:endx)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot(X, y; args...)
end

function stairs!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::Vector{F}, Y::Vector{R}; args...)
  xVec = zeros(length(X) * 2 - 1)
  yVec = zeros(length(X) * 2 - 1)
  xVec[1] = X[1]
  yVec[1] = Y[1]
  o = 0
  for i = 2:(length(X))
    xVec[i + o] = X[i]
    xVec[i + o + 1] = X[i]
    yVec[i + o] = Y[i-1]
    yVec[i + o + 1] = Y[i]
    o += 1
  end
  lineplot!(plot, xVec, yVec; args...)
end

function stairs{F<:Real,R<:Real}(X::Vector{F},Y::Vector{R}; args...)
  xVec = zeros(length(X) * 2 - 1)
  yVec = zeros(length(X) * 2 - 1)
  xVec[1] = X[1]
  yVec[1] = Y[1]
  o = 0
  for i = 2:(length(X))
    xVec[i + o] = X[i]
    xVec[i + o + 1] = X[i]
    yVec[i + o] = Y[i-1]
    yVec[i + o + 1] = Y[i]
    o += 1
  end
  lineplot(xVec, yVec; args...)
end
