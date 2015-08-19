
import Base.show
import Base.print

const spceStr = " " #string(spce)

abstract GraphicsArea
abstract Canvas <: GraphicsArea

function print(io::IO, c::GraphicsArea)
  for row in 1:nrows(c)
    printRow(io, c, row)
    print(io, "\n")
  end
end

function show(io::IO, c::GraphicsArea)
  b = borderDashed
  borderLength = ncols(c)
  drawBorderTop(io, "", borderLength, :solid)
  print(io, "\n")
  for row in 1:nrows(c)
    print(io, b[:l])
    printRow(io, c, row)
    print(io, b[:r], "\n")
  end
  drawBorderBottom(io, "", borderLength, :solid)
  print(io, "\n")
end

nrows(c::Canvas) = size(c.grid,2)
ncols(c::Canvas) = size(c.grid,1)

function printRow(io::IO, c::Canvas, row::Int)
  nunrows = nrows(c)
  0 < row <= nunrows || throw(ArgumentError("Argument row out of bounds: $row"))
  y = row
  for x in 1:ncols(c)
    printColor(c.colors[x,y], io, c.grid[x,y])
  end
end
