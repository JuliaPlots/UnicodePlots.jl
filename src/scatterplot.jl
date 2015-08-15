
function scatterplot{F<:Real,R<:Real}(io::IO, X::Vector{F},Y::Vector{R};
                                       width::Int=40, height::Int=10, margin::Int=3,
                                       title::String="", border=:solid, labels::Bool=true)
  margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  width = width >= 5 ? width: 5
  height = height >= 5 ? height: 5
  X = convert(Vector{Float64},X)
  Y = convert(Vector{Float64},Y)
  b=borderMap[border]
  minX = minimum(X); minY = minimum(Y)
  maxX = maximum(X); maxY = maximum(Y)
  diffX = maxX - minX; diffY = maxY - minY
  smallDiff = min(diffX, diffY)
  padX = 0.01 * diffX; padY = 0.01 * diffY
  plotOriginX = minX - padX; plotWidth = maxX - plotOriginX + padX
  plotOriginY = minY - padY; plotHeight = maxY - plotOriginY + padY
  c = BrailleCanvas(width, height,
                    plotOriginX = plotOriginX,
                    plotOriginY = plotOriginY,
                    plotWidth = plotWidth,
                    plotHeight = plotHeight)
  if minY < 0 < maxY
    for i in linspace(minX, maxX, width*2)
      setPoint!(c, i, 0.)
    end
  end
  for i in 1:length(X)
    setPoint!(c, X[i], Y[i])
  end

  minYString=string(minY)
  maxYString=string(maxY)
  maxLen = labels ? max(length(minYString), length(maxYString)) : 0
  plotOffset = maxLen + margin
  borderPadding = repeat(" ", plotOffset + 1)
  drawTitle(io, borderPadding, title)

  len = length(maxYString)
  padY1 = labels ? string(repeat(" ", margin), repeat(" ", maxLen - len)): ""
  len = length(minYString)
  padY2 = labels ? string(repeat(" ", margin), repeat(" ", maxLen - len)): ""
  borderWidth = width + 1
  drawBorderTop(io, borderPadding, borderWidth, border)
  print(io, "\n")
  for y in reverse(1:size(c.grid,2))
    if labels && y == height
      print(io, padY1, maxYString, " ", b[:l])
    elseif labels && y == 1
      print(io, padY2, minYString, " ", b[:l])
    else
      print(io, borderPadding, b[:l])
    end
    for x in 1:size(c.grid,1)
      print(io, c.grid[x,y])
    end
    print(io," ", b[:r], "\n")
  end
  drawBorderBottom(io, borderPadding, borderWidth, border)
  print(io, "\n")
  if labels
    minXString=string(minX); minLen = length(minXString)
    maxXString=string(maxX); maxLen = length(maxXString)
    print(io, borderPadding, minXString)
    cnt = borderWidth - maxLen - minLen + 1
    pad = cnt > 0 ? repeat(" ", cnt) : ""
    print(io, pad, maxXString, "\n")
  end
end

function lineplot{F<:Real,R<:Real}(io::IO, X::Vector{F}, Y::Vector{R};
                                    width::Int=40, height::Int=10, margin::Int=3,
                                    title::String="", border=:solid, labels::Bool=true)
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  X = convert(Vector{Float64},X)
  Y = convert(Vector{Float64},Y)
  minX = minimum(X); minY = minimum(Y)
  maxX = maximum(X); maxY = maximum(Y)
  diffX = maxX - minX; diffY = maxY - minY
  smallDiff = min(diffX, diffY)
  xVec =[X[1]]; yVec = [Y[1]]
  for i in 2:(length(X))

    tV = collect(X[i-1]:.002smallDiff:X[i])
    tl = length(tV)
    # if there is a huge Y gap but no X gap, draw vertical line
    tV = if tl > 1
      tV
    else
      np = safeRound(abs(Y[i]-Y[i-1]) / diffY * height * 8.)
      if np > 1
        tl = np
        ones(np) * X[i]
      else
        X[i]
      end
    end
    if tl > 1
      append!(xVec, tV)
      append!(yVec, linspace(Y[i-1],Y[i],tl))
    else
      push!(xVec, tV)
      push!(yVec, Y[i])
    end
    #yVec = [yVec; linspace(Y[i-1],Y[i],tl)]
  end
  scatterplot(io, xVec, yVec; width=width, height=height, margin=margin,
              title=title, border=border, labels=labels)
end

function scatterplot{F<:Real,R<:Real}(X::Vector{F},Y::Vector{R}; args...)
  scatterplot(STDOUT, X, Y; args...)
end

function lineplot{F<:Real,R<:Real}(X::Vector{F},Y::Vector{R}; args...)
  lineplot(STDOUT, X, Y; args...)
end

function lineplot(io::IO, Y::Function, X::Range; args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot(io, collect(X), y; args...)
end

function lineplot(Y::Function, X::Range; args...)
  lineplot(STDOUT, Y, X; args...)
end

function lineplot{R<:Real}(io::IO, Y::Function, X::Vector{R}; args...)
  y = convert(Vector{Float64}, [Y(i) for i in X])
  lineplot(io, X, y; args...)
end

function lineplot{R<:Real}(Y::Function, X::Vector{R}; args...)
  lineplot(STDOUT, Y, X; args...)
end

function lineplot{R<:Real,S<:Real}(io::IO, Y::Function, startx::R, endx::S, step::Real = 1.; args...)
  rnge = startx:endx
  y = convert(Vector{Float64}, [Y(i) for i in startx:step:endx])
  lineplot(io, collect(rnge), y; args...)
end

function stairs{F<:Real,R<:Real}(io::IO, X::Vector{F},Y::Vector{R}; args...)
  xVec = zeros(length(X) * 2- 1)
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
  lineplot(io, xVec, yVec; args...)
end

function stairs{F<:Real,R<:Real}(X::Vector{F},Y::Vector{R}; args...)
  stairs(STDOUT, X, Y; args...)
end
