
type DensityCanvas <: Canvas
  grid::Array{Char,2}
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
  grid = fill(spce, charWidth, charHeight)
  colors = fill(spce, charWidth, charHeight)
  BrailleCanvas(grid, colors, pixelWidth, pixelHeight, plotOriginX, plotOriginY, plotWidth, plotHeight)
end
