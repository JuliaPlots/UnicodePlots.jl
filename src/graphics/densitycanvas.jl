const den_signs = [" ", "░", "▒", "▓", "█"]

type DensityCanvas <: Canvas
  grid::Array{UInt,2}
  colors::Array{UInt8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
  maxDensity::Float64
end

x_pixel_per_char(::Type{DensityCanvas}) = 1
y_pixel_per_char(::Type{DensityCanvas}) = 2

nrows(c::DensityCanvas) = size(c.grid, 2)
ncols(c::DensityCanvas) = size(c.grid, 1)

function DensityCanvas(charWidth::Int, charHeight::Int;
                       plotOriginX::Float64 = 0.,
                       plotOriginY::Float64 = 0.,
                       plotWidth::Float64 = 1.,
                       plotHeight::Float64 = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 5)
  pixelWidth = charWidth * x_pixel_per_char(DensityCanvas)
  pixelHeight = charHeight * y_pixel_per_char(DensityCanvas)
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

function pixel!(c::DensityCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX : pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY : pixelY - 1
  cw, ch = size(c.grid)
  charX = floor(Int, pixelX / c.pixelWidth * cw) + 1
  charY = floor(Int, pixelY / c.pixelHeight * ch) + 1
  c.grid[charX,charY] += 1
  c.maxDensity = max(c.maxDensity, c.grid[charX,charY])
  c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  c
end

function printrow(io::IO, c::DensityCanvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = row
  denSignCount = length(den_signs)
  valScale = (denSignCount - 1) / c.maxDensity
  for x in 1:ncols(c)
    denIndex = round(Int, c.grid[x,y] * valScale, RoundNearestTiesUp) + 1
    printColor(c.colors[x,y], io, den_signs[denIndex])
  end
end
