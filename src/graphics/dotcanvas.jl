const dot_signs = [0b10 0b01]

@inline function init_dot_canvas()
  global const dot_decode = Array(Char, 5)
  dot_decode[0b00 + 1] = ' '
  dot_decode[0b01 + 1] = '.'
  dot_decode[0b10 + 1] = '\''
  dot_decode[0b11 + 1] = ':'
end

type DotCanvas <: Canvas
  grid::Array{UInt8,2}
  colors::Array{UInt8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
end

x_pixel_per_char(::Type{DotCanvas}) = 1
y_pixel_per_char(::Type{DotCanvas}) = 2

nrows(c::DotCanvas) = size(c.grid, 2)
ncols(c::DotCanvas) = size(c.grid, 1)

function DotCanvas(charWidth::Int, charHeight::Int;
                     plotOriginX::Float64 = 0.,
                     plotOriginY::Float64 = 0.,
                     plotWidth::Float64 = 1.,
                     plotHeight::Float64 = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 2)
  pixelWidth = charWidth * x_pixel_per_char(DotCanvas)
  pixelHeight = charHeight * y_pixel_per_char(DotCanvas)
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(0x00, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  DotCanvas(grid, colors,
              pixelWidth, pixelHeight,
              plotOriginX, plotOriginY,
              plotWidth, plotHeight)
end

function pixel!(c::DotCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = floor(Int, tmp) + 1
  charXOff = (pixelX % x_pixel_per_char(DotCanvas)) + 1
  if charX < round(Int, tmp, RoundNearestTiesUp) + 1 && charXOff == 1
    charX = charX + 1
  end
  charY = floor(Int, pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % y_pixel_per_char(DotCanvas)) + 1
  c.grid[charX,charY] = c.grid[charX,charY] | dot_signs[charXOff, charYOff]
  c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  c
end

function printrow(io::IO, c::DotCanvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = row
  for x in 1:ncols(c)
    printColor(c.colors[x,y], io, dot_decode[c.grid[x,y] + 1])
  end
end
