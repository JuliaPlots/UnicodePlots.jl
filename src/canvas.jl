
import Base.show

signs = ['⡀' '⠄' '⠂' '⠁';
         '⢀' '⠠' '⠐' '⠈']

type Canvas
  grid::Array{Char,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
end

function show(io::IO, c::Canvas)
  for y in reverse(1:size(c.grid,2))
    for x in 1:size(c.grid,1)
      print(c.grid[x,y])
    end
    println()
  end
  println("pixelWidth: $(c.pixelWidth)")
  println("pixelHeight: $(c.pixelHeight)")
  println("plotOriginX: $(c.plotOriginX)")
  println("plotOriginY: $(c.plotOriginY)")
  println("plotWidth: $(c.plotWidth)")
  println("plotHeight: $(c.plotHeight)")
end

function Canvas(charWidth::Int, charHeight::Int,
                plotOriginX::Float64, plotOriginY::Float64,
                plotWidth::Float64, plotHeight::Float64)
  charWidth = charWidth < 5 ? 5 : charWidth
  charHeight = charHeight < 5 ? 5 : charHeight
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Width has to be positive"))
  grid = if VERSION < v"0.4-"
    fill(char(0x2800), charWidth, charHeight)
  else
    fill(Char(0x2800), charWidth, charHeight)
  end
  Canvas(grid, charWidth * 2, charHeight * 4, plotOriginX, plotOriginY, plotWidth, plotHeight)
end

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

function setPixel!(c::Canvas, pixelX::Int, pixelY::Int)
  @assert 0 <= pixelX <= c.pixelWidth
  @assert 0 <= pixelY <= c.pixelHeight
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = safeFloor(tmp) + 1
  charXOff = (pixelX % 2) + 1
  if charX < safeRound(tmp) + 1 && charXOff == 1
    charX = charX +1
  end
  charY = safeFloor(pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % 4) + 1
  if VERSION < v"0.4-"
    c.grid[charX,charY] = c.grid[charX,charY] | signs[charXOff, charYOff]
  else
    c.grid[charX,charY] = Char(Uint64(c.grid[charX,charY]) | Uint64(signs[charXOff, charYOff]))
  end
end

function setPoint!(c::Canvas, plotX::Float64, plotY::Float64)
  @assert c.plotOriginX <= plotX < c.plotOriginX + c.plotWidth
  @assert c.plotOriginY <= plotY < c.plotOriginY + c.plotHeight
  plotXOffset = plotX - c.plotOriginX
  pixelX = plotXOffset / c.plotWidth * c.pixelWidth
  plotYOffset = plotY - c.plotOriginY
  pixelY = plotYOffset / c.plotHeight * c.pixelHeight
  setPixel!(c, safeFloor(pixelX), safeFloor(pixelY))
end

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
  c = Canvas(width, height, plotOriginX, plotOriginY, plotWidth, plotHeight)
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
  if labels
    minXString=string(minX); minLen = length(minXString)
    maxXString=string(maxX); maxLen = length(maxXString)
    print(io, borderPadding, minXString)
    cnt = borderWidth - maxLen - minLen + 1
    pad = cnt > 0 ? repeat(" ", cnt) : ""
    print(io, pad, maxXString, "\n")
  end
end

function lineplot{F<:Real,R<:Real}(io::IO, X::Vector{F},Y::Vector{R};
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
