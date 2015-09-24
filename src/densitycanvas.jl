denSigns = [" ", "░", "▒", "▓", "█"]

type DensityCanvas <: Canvas
  grid::Array{(@compat UInt),2}
  colors::Array{(@compat UInt8),2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::(@compat AbstractFloat)
  plotOriginY::(@compat AbstractFloat)
  plotWidth::(@compat AbstractFloat)
  plotHeight::(@compat AbstractFloat)
  maxDensity::(@compat AbstractFloat)
end

function DensityCanvas(charWidth::Int, charHeight::Int;
                       plotOriginX::(@compat AbstractFloat) = 0.,
                       plotOriginY::(@compat AbstractFloat) = 0.,
                       plotWidth::(@compat AbstractFloat) = 1.,
                       plotHeight::(@compat AbstractFloat) = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 5)
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
