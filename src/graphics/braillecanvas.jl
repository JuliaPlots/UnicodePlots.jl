const braille_signs = ['⠁' '⠂' '⠄' '⡀';
                       '⠈' '⠐' '⠠' '⢀']

type BrailleCanvas <: Canvas
  grid::Array{Char,2}
  colors::Array{UInt8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
end

pixel_width(c::BrailleCanvas) = c.pixelWidth
pixel_height(c::BrailleCanvas) = c.pixelHeight
width(c::BrailleCanvas) = c.plotWidth
height(c::BrailleCanvas) = c.plotHeight
origin_x(c::BrailleCanvas) = c.plotOriginX
origin_y(c::BrailleCanvas) = c.plotOriginY

x_pixel_per_char(::Type{BrailleCanvas}) = 2
y_pixel_per_char(::Type{BrailleCanvas}) = 4

nrows(c::BrailleCanvas) = size(c.grid, 2)
ncols(c::BrailleCanvas) = size(c.grid, 1)

function BrailleCanvas(charWidth::Int, charHeight::Int;
                       plotOriginX::Float64 = 0.,
                       plotOriginY::Float64 = 0.,
                       plotWidth::Float64 = 1.,
                       plotHeight::Float64 = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 2)
  pixelWidth = charWidth * x_pixel_per_char(BrailleCanvas)
  pixelHeight = charHeight * y_pixel_per_char(BrailleCanvas)
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(Char(0x2800), charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  BrailleCanvas(grid, colors,
                pixelWidth, pixelHeight,
                plotOriginX, plotOriginY,
                plotWidth, plotHeight)
end

function pixel!(c::BrailleCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = floor(Int, tmp) + 1
  charXOff = (pixelX % 2) + 1
  if charX < round(Int, tmp, RoundNearestTiesUp) + 1 && charXOff == 1
    charX = charX + 1
  end
  charY = floor(Int, pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % 4) + 1
  c.grid[charX,charY] = Char(UInt64(c.grid[charX,charY]) | UInt64(braille_signs[charXOff, charYOff]))
  c.colors[charX,charY] = c.colors[charX,charY] | color_encode[color]
  c
end

function printrow(io::IO, c::BrailleCanvas, row::Int)
    nunrows = nrows(c)
    0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
    y = row
    for x in 1:ncols(c)
        print_color(c.colors[x,y], io, c.grid[x,y])
    end
end
