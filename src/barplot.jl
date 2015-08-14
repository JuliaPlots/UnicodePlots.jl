
function barplot{T,N}(io::IO, labels::Vector{T}, heights::Vector{N}; border=:solid, title::String="", marigin::Int=3, color::Symbol=:blue, width::Int=40)
  width > 0 || throw(ArgumentError("the given width has to be positive"))
  b=borderMap[border]
  maxLen = max([length(string(l)) for l in labels]...)
  min(heights...) >= 0 || throw(ArgumentError("All values have to be positive"))
  maxFreq = max(heights...)
  maxFreqLen = length(string(maxFreq))
  plotOffset = maxLen + marigin
  borderPadding = repeat(" ", plotOffset)
  drawTitle(io, borderPadding, title)
  borderWidth = width + maxFreqLen + 2
  drawBorderTop(io, borderPadding, borderWidth, border)
  for (label, height) in zip(labels, heights)
    str = string(label)
    len = length(str)
    pad = string(repeat(" ", marigin),repeat(" ", maxLen - len))
    bar = repeat("▪", safeRound(height / maxFreq * width))
    lbl = "$(pad)$(label)$(b[:l])"
    print(io, lbl)
    if isa(io, Base.TTY)
      print_with_color(color, io, bar)
    else
      print(io, bar)
    end
    txt = " $(height)"
    print(io, txt)
    line = string(lbl, bar, txt)
    lineLen = length(line)
    pad = repeat(" ", maxLen + marigin + width + maxFreqLen + 3 - lineLen)
    print(io,pad, b[:r], "\n")
  end
  drawBorderBottom(io, borderPadding, borderWidth, border)
  nothing
end


function barplot{T,N}(labels::Vector{T},heights::Vector{N}; args...)
  barplot(STDOUT, labels, heights; args...)
end
