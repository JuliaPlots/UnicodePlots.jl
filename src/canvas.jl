
import Base.show
import Base.print

const spce = if VERSION < v"0.4-"
  char(0x2800)
else
  Char(0x2800)
end
const spceStr = " " #string(spce)

signs = ['⠁' '⠂' '⠄' '⡀';
         '⠈' '⠐' '⠠' '⢀']

abstract Canvas

function print(io::IO, c::Canvas)
  for row in 1:nrows(c)
    printRow(io, c, row)
    print(io, "\n")
  end
end

function show(io::IO, c::Canvas)
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
