const ascii_signs = [0b100_000_000 0b000_100_000 0b000_000_100;
                     0b010_000_000 0b000_010_000 0b000_000_010;
                     0b001_000_000 0b000_001_000 0b000_000_001]

const ascii_lookup = Dict{UInt16,Char}()
ascii_lookup[0b101_000_000] = '"'
ascii_lookup[0b111_111_111] = '@'
ascii_lookup[0b011_110_011] = '$'
ascii_lookup[0b010_000_000] = '\''
ascii_lookup[0b010_100_010] = '('
ascii_lookup[0b010_001_010] = ')'
ascii_lookup[0b000_010_000] = '*'
ascii_lookup[0b010_111_010] = '+'
ascii_lookup[0b000_010_010] = ','
ascii_lookup[0b000_100_100] = ','
ascii_lookup[0b000_001_001] = ','
ascii_lookup[0b000_111_000] = '-'
ascii_lookup[0b000_000_010] = '.'
ascii_lookup[0b000_000_100] = '.'
ascii_lookup[0b000_000_001] = '.'
ascii_lookup[0b001_010_100] = '/'
ascii_lookup[0b010_100_000] = '/'
ascii_lookup[0b001_010_110] = '/'
ascii_lookup[0b011_010_010] = '/'
ascii_lookup[0b001_010_010] = '/'
ascii_lookup[0b110_010_111] = '1'
ascii_lookup[0b111_010_100] = '7'
ascii_lookup[0b010_000_010] = ':'
ascii_lookup[0b111_000_111] = '='
ascii_lookup[0b010_111_101] = 'A'
ascii_lookup[0b011_100_011] = 'C'
ascii_lookup[0b110_101_110] = 'D'
ascii_lookup[0b111_110_100] = 'F'
ascii_lookup[0b011_101_011] = 'G'
ascii_lookup[0b101_111_101] = 'H'
ascii_lookup[0b111_010_111] = 'I'
ascii_lookup[0b011_001_111] = 'J'
ascii_lookup[0b101_110_101] = 'K'
ascii_lookup[0b100_100_111] = 'L'
ascii_lookup[0b111_111_101] = 'M'
ascii_lookup[0b101_101_101] = 'N'
ascii_lookup[0b111_101_111] = 'O'
ascii_lookup[0b111_111_100] = 'P'
ascii_lookup[0b111_010_010] = 'T'
ascii_lookup[0b101_101_111] = 'U'
ascii_lookup[0b101_101_010] = 'V'
ascii_lookup[0b101_111_111] = 'W'
ascii_lookup[0b101_010_101] = 'X'
ascii_lookup[0b101_010_010] = 'Y'
ascii_lookup[0b110_100_110] = '['
ascii_lookup[0b010_001_000] = '\\'
ascii_lookup[0b100_010_001] = '\\'
ascii_lookup[0b110_010_010] = '\\'
ascii_lookup[0b100_010_011] = '\\'
ascii_lookup[0b100_010_010] = '\\'
ascii_lookup[0b011_001_011] = ']'
ascii_lookup[0b010_101_000] = '^'
ascii_lookup[0b000_000_111] = '_'
ascii_lookup[0b100_000_000] = '`'
ascii_lookup[0b000_111_111] = 'a'
ascii_lookup[0b100_111_111] = 'b'
ascii_lookup[0b001_111_111] = 'd'
ascii_lookup[0b001_111_010] = 'f'
ascii_lookup[0b100_111_101] = 'h'
ascii_lookup[0b100_101_101] = 'k'
ascii_lookup[0b110_010_011] = 'l'
ascii_lookup[0b000_111_101] = 'n'
ascii_lookup[0b000_111_100] = 'r'
ascii_lookup[0b000_101_111] = 'u'
ascii_lookup[0b000_101_010] = 'v'
ascii_lookup[0b011_110_011] = '{'
ascii_lookup[0b010_010_010] = '|'
ascii_lookup[0b100_100_100] = '|'
ascii_lookup[0b001_001_001] = '|'
ascii_lookup[0b110_011_110] = '}'

const ascii_decode = Array(Char, 512)
ascii_decode[0b1] = ' '
for i in 1:511
  min_dist = typemax(Int)
  min_char = ' '
  for (k, v) in ascii_lookup
    cur_dist = count_ones(UInt16(i) $ k)
    if cur_dist < min_dist
      min_dist = cur_dist
      min_char = v
    end
  end
  min_char
  ascii_decode[i + 1] = min_char
end

type AsciiCanvas <: Canvas
  grid::Array{UInt16,2}
  colors::Array{UInt8,2}
  pixelWidth::Int
  pixelHeight::Int
  plotOriginX::Float64
  plotOriginY::Float64
  plotWidth::Float64
  plotHeight::Float64
end

x_pixel_per_char(::Type{AsciiCanvas}) = 3
y_pixel_per_char(::Type{AsciiCanvas}) = 3

nrows(c::AsciiCanvas) = size(c.grid, 2)
ncols(c::AsciiCanvas) = size(c.grid, 1)

function AsciiCanvas(charWidth::Int, charHeight::Int;
                     plotOriginX::Float64 = 0.,
                     plotOriginY::Float64 = 0.,
                     plotWidth::Float64 = 1.,
                     plotHeight::Float64 = 1.)
  charWidth = max(charWidth, 5)
  charHeight = max(charHeight, 2)
  pixelWidth = charWidth * x_pixel_per_char(AsciiCanvas)
  pixelHeight = charHeight * y_pixel_per_char(AsciiCanvas)
  plotWidth > 0 || throw(ArgumentError("Width has to be positive"))
  plotHeight > 0 || throw(ArgumentError("Height has to be positive"))
  grid = fill(0x00, charWidth, charHeight)
  colors = fill(0x00, charWidth, charHeight)
  AsciiCanvas(grid, colors,
              pixelWidth, pixelHeight,
              plotOriginX, plotOriginY,
              plotWidth, plotHeight)
end

function pixel!(c::AsciiCanvas, pixelX::Int, pixelY::Int, color::Symbol)
  0 <= pixelX <= c.pixelWidth || return nothing
  0 <= pixelY <= c.pixelHeight || return nothing
  pixelX = pixelX < c.pixelWidth ? pixelX: pixelX - 1
  pixelY = pixelY < c.pixelHeight ? pixelY: pixelY - 1
  cw, ch = size(c.grid)
  tmp = pixelX / c.pixelWidth * cw
  charX = floor(Int, tmp) + 1
  charXOff = (pixelX % x_pixel_per_char(AsciiCanvas)) + 1
  if charX < round(Int, tmp, RoundNearestTiesUp) + 1 && charXOff == 1
    charX = charX + 1
  end
  charY = floor(Int, pixelY / c.pixelHeight * ch) + 1
  charYOff = (pixelY % y_pixel_per_char(AsciiCanvas)) + 1
  c.grid[charX,charY] = c.grid[charX,charY] | ascii_signs[charXOff, charYOff]
  c.colors[charX,charY] = c.colors[charX,charY] | colorEncode[color]
  c
end

function printrow(io::IO, c::AsciiCanvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = row
  for x in 1:ncols(c)
    printColor(c.colors[x,y], io, ascii_decode[c.grid[x,y] + 1])
  end
end
