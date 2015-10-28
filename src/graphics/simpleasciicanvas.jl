const simple_ascii_signs = [0b100 0b010 0b001]

const simple_ascii_decode = Array(Char, 8)
simple_ascii_decode[0b000 + 1] = ' '
simple_ascii_decode[0b001 + 1] = '.'
simple_ascii_decode[0b010 + 1] = '-'
simple_ascii_decode[0b011 + 1] = ','
simple_ascii_decode[0b100 + 1] = '`'
simple_ascii_decode[0b101 + 1] = ':'
simple_ascii_decode[0b110 + 1] = '\''
simple_ascii_decode[0b111 + 1] = '|'

type SimpleAsciiCanvas <: Canvas
  grid::Array{UInt8,2}
  colors::Array{UInt8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
end

x_pixel_per_char(::Type{SimpleAsciiCanvas}) = 1
y_pixel_per_char(::Type{SimpleAsciiCanvas}) = 3

nrows(c::SimpleAsciiCanvas) = size(c.grid, 2)
ncols(c::SimpleAsciiCanvas) = size(c.grid, 1)

function SimpleAsciiCanvas(charWidth::Int, charHeight::Int;
                     plotOriginX::Float64 = 0.,
                     plotOriginY::Float64 = 0.,
                     plotWidth::Float64 = 1.,
                     plotHeight::Float64 = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 2)
  pixelWidth = charWidth * x_pixel_per_char(SimpleAsciiCanvas)
  pixelHeight = charHeight * y_pixel_per_char(SimpleAsciiCanvas)
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(0x00, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  SimpleAsciiCanvas(grid, colors,
              pixelWidth, pixelHeight,
              plotOriginX, plotOriginY,
              plotWidth, plotHeight)
end

function pixel!(c::SimpleAsciiCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = floor(Int, tmp) + 1
  charXOff = (pixelX % x_pixel_per_char(SimpleAsciiCanvas)) + 1
  if charX < round(Int, tmp, RoundNearestTiesUp) + 1 && charXOff == 1
    charX = charX + 1
  end
  charY = floor(Int, pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % y_pixel_per_char(SimpleAsciiCanvas)) + 1
  c.grid[charX,charY] = c.grid[charX,charY] | simple_ascii_signs[charXOff, charYOff]
  c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  c
end

function printrow(io::IO, c::SimpleAsciiCanvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = row
  for x in 1:ncols(c)
    printColor(c.colors[x,y], io, simple_ascii_decode[c.grid[x,y] + 1])
  end
end
