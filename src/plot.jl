
type Plot{T<:Canvas}
  canvas::T
  title::String
  margin::Int
  padding::Int
  border::Symbol
  leftLabels::Vector{String}
  rightLabels::Vector{String}
  decorations::Dict{Symbol,String}
  showLabels::Bool
end

function Plot{T<:Canvas}(canvas::T;
                         title::String="",
                         margin::Int=3,
                         padding::Int=1,
                         border::Symbol=:solid,
                         showLabels=true)
  rows = nrows(canvas)
  cols = ncols(canvas)
  leftLabels = fill("", rows)
  rightLabels = fill("", rows)
  decorations = Dict{Symbol,String}()
  Plot{T}(canvas, title, margin, padding, border, leftLabels, rightLabels, decorations, showLabels)
end

function setTitle!{T<:Canvas}(plot::Plot{T}, title::String)
  plot.title = title
  plot
end

function annotate!{T<:Canvas}(plot::Plot{T}, where::Symbol, value::String)
  where == :tl || where == :tr || where == :bl || where == :br || throw(ArgumentError("Unknown location: try one of these :tl :tr :bl :br"))
  plot.decorations[where] = value
  plot
end

function annotate!{T<:Canvas}(plot::Plot{T}, where::Symbol, row::Int, value::String)
  0 < row <= nrows(plot.canvas)
  if where == :l
    plot.leftLabels[row] = value
  elseif where == :r
    plot.rightLabels[row] = value
  else
    throw(ArgumentError("Unknown location: try one of these :l :r"))
  end
  plot
end

function drawLine!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  drawLine!(plot.canvas, args...; vars...)
  plot
end

function setPixel!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  setPixel!(plot.canvas, args...; vars...)
  plot
end

function setPoint!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  setPoint!(plot.canvas, args...; vars...)
  plot
end

function show(io::IO, p::Plot)
  b = borderMap[p.border]
  c = p.canvas
  borderLength = ncols(c)

  # get length of largest strings to the left and right
  maxLen = p.showLabels ? maximum([length(string(l)) for l in p.leftLabels]) : 0
  maxLenR = p.showLabels ? maximum([length(string(l)) for l in p.rightLabels]) : 0

  # offset where the plot (incl border) begins
  plotOffset = maxLen + p.margin + p.padding

  # padding-string from left to border
  plotPadding = repeat(spceStr, p.padding)

  # padding-string between labels and border
  borderPadding = repeat(spceStr, plotOffset)

  # plot the title and the top border
  drawTitle(io, borderPadding, p.title, plotWidth = borderLength)
  if p.showLabels
    topLeftStr = haskey(p.decorations, :tl) ? p.decorations[:tl] : ""
    topRightStr = haskey(p.decorations, :tr) ? p.decorations[:tr] : ""
    if topLeftStr != "" || topRightStr != ""
      topLeftLen = length(topLeftStr)
      topRightLen = length(topRightStr)
      print(io, borderPadding, topLeftStr)
      cnt = borderLength - topRightLen - topLeftLen + p.padding + 1
      pad = cnt > 0 ? repeat(spceStr, cnt) : ""
      print(io, pad, topRightStr, "\n")
    end
  end
  drawBorderTop(io, borderPadding, borderLength, p.border)
  print(io, repeat(spceStr, maxLenR), plotPadding, "\n")

  # plot all rows
  for row in 1:nrows(c)
    # Current labels to left and right of the row and their length
    tleftLabel = p.leftLabels[row]
    tRightLabel = p.rightLabels[row]
    tLen = length(tleftLabel)
    tLenR = length(tRightLabel)
    # print left label
    print(io, repeat(spceStr, p.margin))
    p.showLabels && print(io, repeat(spceStr, maxLen - tLen), tleftLabel)
    # print left border
    print(io, plotPadding, b[:l])
    # print canvas row
    printRow(io, c, row)
    #print right label and padding
    print(io, b[:r])
    p.showLabels && print(io, plotPadding, tRightLabel, repeat(spceStr, maxLenR - tLenR))
    print("\n")
  end

  # draw bottom border and bottom labels
  drawBorderBottom(io, borderPadding, borderLength, p.border)
  print(io, repeat(spceStr, maxLenR), plotPadding, "\n")
  if p.showLabels
    botLeftStr = haskey(p.decorations, :bl) ? p.decorations[:bl] : ""
    botRightStr = haskey(p.decorations, :br) ? p.decorations[:br] : ""
    if botLeftStr != "" || botRightStr != ""
      botLeftLen = length(botLeftStr)
      botRightLen = length(botRightStr)
      print(io, borderPadding, botLeftStr)
      cnt = borderLength - botRightLen - botLeftLen + p.padding + 1
      pad = cnt > 0 ? repeat(spceStr, cnt) : ""
      print(io, pad, botRightStr, "\n")
    end
  end
end


