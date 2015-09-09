
function createPlotWindow{F<:FloatingPoint}(X::Vector{F}, Y::Vector{F};
                                            width::Int = 40,
                                            height::Int = 10,
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
  height = max(height, 2)
  minX = float(minimum(xlim))
  maxX = float(maximum(xlim))
  if minX == 0. && maxX == 0.
    minX = minimum(X)
    maxX = maximum(X)
    diffX = maxX - minX
    if diffX == 0
      t = minX
      minX = t / 2
      maxX = t + t / 2
    end
    minX, maxX = plottingRange(minX, maxX)
  end
  minY = float(minimum(ylim))
  maxY = float(maximum(ylim))
  if minY == 0. && maxY == 0.
    minY = minimum(Y)
    maxY = maximum(Y)
    diffY = maxY - minY
    if diffY == 0
      t = minY
      minY = t / 2
      maxY = t + t / 2
    end
    minY, maxY = plottingRange(minY, maxY)
  end
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

function scatterplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::AbstractVector{F}, Y::AbstractVector{R};
                                                 color::Symbol = :auto,
                                                 name::String = "",
                                                 args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  color = color == :auto ? nextColor!(plot) : color
  name == "" || autoAnnotate!(plot, :r, name, color)
  setPoint!(plot, X, Y, color)
end

function scatterplot{F<:Real,R<:Real}(X::AbstractVector{F}, Y::AbstractVector{R};
                                      color::Symbol=:auto,
                                      name::String = "",
                                      args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  newPlot = createPlotWindow(X, Y; args...)
  color = color == :auto ? nextColor!(newPlot) : color
  name == "" || autoAnnotate!(newPlot, :r, name, color)
  setPoint!(newPlot, X, Y, color)
end

function lineplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::AbstractVector{F}, Y::AbstractVector{R};
                                              color::Symbol=:auto,
                                              name::String = "",
                                              args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  color = color == :auto ? nextColor!(plot) : color
  name == "" || autoAnnotate!(plot, :r, name, color)
  drawLine!(plot, X, Y, color)
end

function lineplot{F<:Real,R<:Real}(X::AbstractVector{F}, Y::AbstractVector{R};
                                   color::Symbol=:auto,
                                   name::String = "",
                                   args...)
  X = convert(Vector{FloatingPoint},X)
  Y = convert(Vector{FloatingPoint},Y)
  newPlot = createPlotWindow(X, Y; args...)
  color = color == :auto ? nextColor!(newPlot) : color
  name == "" || autoAnnotate!(newPlot, :r, name, color)
  drawLine!(newPlot, X, Y, color)
end

function lineplot!{T<:Canvas}(plot::Plot{T}, Y::Function, x::Range; args...)
  X = collect(x)
  lineplot!(plot, Y, X; args...)
end

function lineplot(Y::Function, x::Range; args...)
  X = collect(x)
  lineplot(Y, X; args...)
end

function lineplot!{T<:Canvas,R<:Real}(plot::Plot{T}, Y::Function, X::AbstractVector{R};
                                      name::String = "",
                                      args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  name = name == "" ? string(Y, "(x)") : name
  lineplot!(plot, X, y; name = name, args...)
end

function lineplot{R<:Real}(Y::Function, X::Vector{R};
                           name::String = "",
                           args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  name = name == "" ? string(Y, "(x)") : name
  newPlot = lineplot(X, y; name = name, args...)
  xlabel!(newPlot, "x")
  ylabel!(newPlot, "f(x)")
end

function lineplot!{T<:Canvas}(plot::Plot{T}, Y::Function, startx::Real, endx::Real; args...)
  diff = abs(endx - startx)
  X = collect(startx:(diff/(3*ncols(plot.graphics))):endx)
  lineplot!(plot, Y, X; args...)
end

function lineplot(Y::Function, startx::Real, endx::Real; width::Int = 40, args...)
  diff = abs(endx - startx)
  X = collect(startx:(diff/(3*width)):endx)
  lineplot(Y, X; width = width, args...)
end

function lineplot(Y::AbstractVector{Function}, startx::Real, endx::Real; args...)
  n = length(Y)
  @assert n > 0
  newPlot = lineplot(Y[1], startx, endx; args...)
  for i = 2:n
    lineplot!(newPlot, Y[i], startx, endx; args...)
  end
  newPlot
end

function lineplot{F<:Real,R<:Real}(X::Range{F}, Y::Range{R}; args...)
  lineplot(collect(X), collect(Y); args...)
end

function lineplot{F<:Real}(X::Range, Y::AbstractVector{F}; args...)
  lineplot(collect(X), Y; args...)
end

function lineplot{F<:Real}(X::AbstractVector{F}, Y::Range; args...)
  lineplot(X, collect(Y); args...)
end

function lineplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::Range{F}, Y::Range{R}; args...)
  lineplot!(plot, collect(X), collect(Y); args...)
end

function lineplot!{T<:Canvas,F<:Real}(plot::Plot{T}, X::Range, Y::AbstractVector{F}; args...)
  lineplot!(plot, collect(X), Y; args...)
end

function lineplot!{T<:Canvas,F<:Real}(plot::Plot{T}, X::AbstractVector{F}, Y::Range; args...)
  lineplot!(plot, X, collect(Y); args...)
end

function computeStairLines{F<:Real,R<:Real}(X::AbstractVector{F}, Y::AbstractVector{R}, style::Symbol)
  if style == :post
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
    xVec, yVec
  elseif style == :pre
    xVec = zeros(length(X) * 2 - 1)
    yVec = zeros(length(X) * 2 - 1)
    xVec[1] = X[1]
    yVec[1] = Y[1]
    o = 0
    for i = 2:(length(X))
      xVec[i + o] = X[i-1]
      xVec[i + o + 1] = X[i]
      yVec[i + o] = Y[i]
      yVec[i + o + 1] = Y[i]
      o += 1
    end
    xVec, yVec
  end
end

function stairs!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::AbstractVector{F}, Y::AbstractVector{R};
                                            style::Symbol = :post,
                                            args...)
  xVec, yVec = computeStairLines(X, Y, style)
  lineplot!(plot, xVec, yVec; args...)
end

function stairs{F<:Real,R<:Real}(X::Vector{F}, Y::Vector{R};
                                 style::Symbol = :post,
                                 args...)
  xVec, yVec = computeStairLines(X, Y, style)
  lineplot(xVec, yVec; args...)
end
