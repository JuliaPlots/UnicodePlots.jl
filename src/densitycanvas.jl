denSigns = [" ", "░", "▒", "▓", "█"]

type DensityCanvas <: Canvas
  grid::Array{Uint,2}
  colors::Array{Uint8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::FloatingPoint
  plotOriginY::FloatingPoint
  plotWidth::FloatingPoint
  plotHeight::FloatingPoint
  maxDensity::FloatingPoint
end

function DensityCanvas(charWidth::Int, charHeight::Int;
                       plotOriginX::FloatingPoint = 0.,
                       plotOriginY::FloatingPoint = 0.,
                       plotWidth::FloatingPoint = 1.,
                       plotHeight::FloatingPoint = 1.)
  charWidth = charWidth < 5 ? 5 : charWidth
  charHeight = charHeight < 5 ? 5 : charHeight
  pixelWidth = charWidth
  pixelHeight = charHeight * 2
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(0, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  DensityCanvas(grid, colors,
                pixelWidth, pixelHeight,
                plotOriginX, plotOriginY,
                plotWidth, plotHeight,
                1)
end

function printRow(io::IO, c::DensityCanvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = row
  denSignCount = length(denSigns)
  valScale = (denSignCount - 1) / c.maxDensity
  for x in 1:ncols(c)
    #if c.grid[x,y] == 0
    #  printColor(c.colors[x,y], io, " ")
    #else
      denIndex = safeRound(c.grid[x,y] * valScale) + 1
      printColor(c.colors[x,y], io, denSigns[denIndex])
    #end
  end
end

function setPixel!(c::DensityCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = safeFloor(tmp) + 1
  charY = safeFloor(pixelY / c.pixelHeight * ch) + 1
  c.grid[charX,charY] += 1
  c.maxDensity = max(c.maxDensity, c.grid[charX,charY])
  c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  c
end
