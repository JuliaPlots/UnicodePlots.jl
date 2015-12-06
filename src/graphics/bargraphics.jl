type BarplotGraphics{R<:Real} <: GraphicsArea
  bars::Vector{R}
  color::Symbol
  charWidth::Int
  maxFreq::R
  maxFreqLen::R
  symb::AbstractString

  function BarplotGraphics(bars::Vector{R},
                           charWidth::Int,
                           color::Symbol,
                           symb)
    charWidth = max(charWidth, 5)
    maxFreq = maximum(bars)
    maxFreqLen = length(string(maxFreq))
    new(bars, color, charWidth, maxFreq, maxFreqLen, symb)
  end
end

nrows(c::BarplotGraphics) = length(c.bars)
ncols(c::BarplotGraphics) = c.charWidth

function BarplotGraphics{R<:Real}(bars::Vector{R},
                                  charWidth::Int;
                                  color::Symbol = :blue,
                                  symb = "▪")
  BarplotGraphics{R}(bars, charWidth, color, symb)
end

function addrow!{R<:Real}(c::BarplotGraphics{R}, bars::Vector{R})
  append!(c.bars, bars)
  c.maxFreq = maximum(c.bars)
  c.maxFreqLen = length(string(c.maxFreq))
  c
end

function addrow!{R<:Real}(c::BarplotGraphics{R}, bar::R)
  push!(c.bars, bar)
  c.maxFreq = max(c.maxFreq, bar)
  c.maxFreqLen = length(string(c.maxFreq))
  c
end

function printrow(io::IO, c::BarplotGraphics, row::Int)
  numrows = nrows(c)
  0 < row <= numrows || throw(ArgumentError("Argument row out of bounds: $row"))
  bar = c.bars[row]
  maxBarWidth = max(c.charWidth - 2 - c.maxFreqLen, 1)
  barLen = c.maxFreq > 0 ? round(Int, bar / c.maxFreq * maxBarWidth, RoundNearestTiesUp): 0
  barStr = c.maxFreq > 0 ? repeat(c.symb, barLen): ""
  barLbl = string(bar)
  print_with_color(c.color, io, barStr)
  print_with_color(:white, io, " ", barLbl)
  panLen = max(maxBarWidth + 1 + c.maxFreqLen - barLen - length(barLbl), 0)
  pad = repeat(" ", round(Int, panLen))
  print(io, pad)
end
