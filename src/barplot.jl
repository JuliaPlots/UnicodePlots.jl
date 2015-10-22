type BarplotGraphics{R<:Real} <: GraphicsArea
  bars::Vector{R}
  color::Symbol
  charWidth::Int
  maxFreq::R
  maxFreqLen::R
  symb::AbstractString

  function BarplotGraphics(bars::Vector{R},
                           charWidth::Int,
                           color::Symbol = :blue,
                           symb = "▪")
    charWidth = max(charWidth, 5)
    maxFreq = maximum(bars)
    maxFreqLen = length(string(maxFreq))
    new(bars, color, charWidth, maxFreq, maxFreqLen, symb)
  end
end

function BarplotGraphics{R<:Real}(bars::Vector{R},
                                  charWidth::Int;
                                  color::Symbol = :blue,
                                  symb = "▪")
  BarplotGraphics{R}(bars, charWidth, color, symb)
end

function addRow!{R<:Real}(c::BarplotGraphics{R}, bars::Vector{R})
  append!(c.bars, bars)
  c.maxFreq = maximum(c.bars)
  c.maxFreqLen = length(string(c.maxFreq))
  c
end

function addRow!{R<:Real}(c::BarplotGraphics{R}, bar::R)
  push!(c.bars, bar)
  c.maxFreq = max(c.maxFreq, bar)
  c.maxFreqLen = length(string(c.maxFreq))
  c
end

nrows(c::BarplotGraphics) = length(c.bars)
ncols(c::BarplotGraphics) = c.charWidth

function printRow(io::IO, c::BarplotGraphics, row::Int)
  numrows = nrows(c)
  0 < row <= numrows || throw(ArgumentError("Argument row out of bounds: $row"))
  bar = c.bars[row]
  maxBarWidth = max(c.charWidth - 2 - c.maxFreqLen, 1)
  barLen = c.maxFreq > 0 ? round(Int, bar / c.maxFreq * maxBarWidth, RoundNearestTiesUp): 0
  barStr = c.maxFreq > 0 ? repeat(c.symb, barLen): ""
  barLbl = string(bar)
  print_with_color(c.color, io, barStr)
  print_with_color(:white, io, spceStr, barLbl)
  panLen = max(maxBarWidth + 1 + c.maxFreqLen - barLen - length(barLbl), 0)
  pad = repeat(spceStr, round(Int, panLen))
  print(io, pad)
end

function barplot{T<:AbstractString,N<:Real}(
    text::Vector{T}, heights::Vector{N};
    border = :solid,
    title::AbstractString = "",
    margin::Int = 3,
    padding::Int = 1,
    color::Symbol = :blue,
    width::Int = 40,
    labels::Bool = true,
    symb = "▪")
  margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
  length(text) == length(heights) || throw(DimensionMismatch("The given vectors must be of the same length"))
  minimum(heights) >= 0 || throw(ArgumentError("All values have to be positive. Negative bars are not supported."))
  width = max(width, 5)

  area = BarplotGraphics(heights, width, color = color, symb = symb)
  newPlot = Plot(area, title=title, margin=margin,
                 padding=padding, border=border, showLabels=labels)
  for i in 1:length(text)
    annotate!(newPlot, :l, i, text[i])
  end
  newPlot
end

function barplot!{C<:BarplotGraphics,T<:AbstractString,N<:Real}(
    plot::Plot{C},
    text::Vector{T},
    heights::Vector{N};
    args...)
  length(text) == length(heights) || throw(DimensionMismatch("The given vectors must be of the same length"))
  !isempty(text)|| throw(ArgumentError("Can't append empty array to barplot"))
  curIdx = nrows(plot.graphics)
  addRow!(plot.graphics, heights)
  for i = 1:length(heights)
    annotate!(plot, :l, curIdx + i, text[i])
  end
  plot
end

function barplot!{C<:BarplotGraphics,T<:AbstractString,N<:Real}(
    plot::Plot{C},
    text::T,
    heights::N;
    args...)
  text == "" && throw(ArgumentError("Can't append empty array to barplot"))
  curIdx = nrows(plot.graphics)
  addRow!(plot.graphics, heights)
  annotate!(plot, :l, curIdx + 1, text)
  plot
end

function barplot{T,N<:Real}(dict::Dict{T,N}; args...)
  barplot(collect(keys(dict)), collect(values(dict)); args...)
end

function barplot{T<:Real,N<:Real}(labels::Vector{T}, heights::Vector{N}; args...)
  labelsStr = map(string, labels)
  barplot(labelsStr, heights; args...)
end

function barplot{T<:Symbol,N<:Real}(labels::Vector{T}, heights::Vector{N}; args...)
  labelsStr = map(string, labels)
  barplot(labelsStr, heights; args...)
end
