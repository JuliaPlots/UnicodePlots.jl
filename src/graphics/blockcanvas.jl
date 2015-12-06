const block_signs = [0b1000 0b0010;
                     0b0100 0b0001]

const block_decode = Array(Char, 16)
block_decode[0b0000 + 1] = ' '
block_decode[0b0001 + 1] = '▗'
block_decode[0b0010 + 1] = '▖'
block_decode[0b0011 + 1] = '▄'
block_decode[0b0100 + 1] = '▝'
block_decode[0b0101 + 1] = '▐'
block_decode[0b0110 + 1] = '▞'
block_decode[0b0111 + 1] = '▟'
block_decode[0b1000 + 1] = '▘'
block_decode[0b1001 + 1] = '▚'
block_decode[0b1010 + 1] = '▌'
block_decode[0b1011 + 1] = '▙'
block_decode[0b1100 + 1] = '▀'
block_decode[0b1101 + 1] = '▜'
block_decode[0b1110 + 1] = '▛'
block_decode[0b1111 + 1] = '█'

type BlockCanvas <: Canvas
  grid::Array{UInt8,2}
  colors::Array{UInt8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
end

pixel_width(c::BlockCanvas) = c.pixelWidth
pixel_height(c::BlockCanvas) = c.pixelHeight
width(c::BlockCanvas) = c.plotWidth
height(c::BlockCanvas) = c.plotHeight
origin_x(c::BlockCanvas) = c.plotOriginX
origin_y(c::BlockCanvas) = c.plotOriginY

x_pixel_per_char(::Type{BlockCanvas}) = 2
y_pixel_per_char(::Type{BlockCanvas}) = 2

nrows(c::BlockCanvas) = size(c.grid, 2)
ncols(c::BlockCanvas) = size(c.grid, 1)

function BlockCanvas(charWidth::Int, charHeight::Int;
                     plotOriginX::Float64 = 0.,
                     plotOriginY::Float64 = 0.,
                     plotWidth::Float64 = 1.,
                     plotHeight::Float64 = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 2)
  pixelWidth = charWidth * x_pixel_per_char(BlockCanvas)
  pixelHeight = charHeight * y_pixel_per_char(BlockCanvas)
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(0x00, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  BlockCanvas(grid, colors,
              pixelWidth, pixelHeight,
              plotOriginX, plotOriginY,
              plotWidth, plotHeight)
end

function pixel!(c::BlockCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = floor(Int, tmp) + 1
  charXOff = (pixelX % x_pixel_per_char(BlockCanvas)) + 1
  if charX < round(Int, tmp, RoundNearestTiesUp) + 1 && charXOff == 1
    charX = charX + 1
  end
  charY = floor(Int, pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % y_pixel_per_char(BlockCanvas)) + 1
  c.grid[charX,charY] = c.grid[charX,charY] | block_signs[charXOff, charYOff]
  c.colors[charX,charY] = c.colors[charX,charY] | color_encode[color]
  c
end

function printrow(io::IO, c::BlockCanvas, row::Int)
    nunrows = nrows(c)
    0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_color(c.colors[x,y], io, block_decode[c.grid[x,y] + 1])
    end
end
