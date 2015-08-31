
type Plot{T<:GraphicsArea}
  graphics::T
  title::String
  xlabel::String
  ylabel::String
  margin::Int
  padding::Int
  border::Symbol
  leftLabels::Dict{Int,String}
  leftColors::Dict{Int,Symbol}
  rightLabels::Dict{Int,String}
  rightColors::Dict{Int,Symbol}
  decorations::Dict{Symbol,String}
  decoColors::Dict{Symbol,Symbol}
  showLabels::Bool
end

function Plot{T<:GraphicsArea}(graphics::T;
                               title::String = "",
                               xlabel::String = "",
                               ylabel::String = "",
                               margin::Int = 3,
                               padding::Int = 1,
                               border::Symbol = :solid,
                               showLabels = true)
  rows = nrows(graphics)
  cols = ncols(graphics)
  leftLabels = Dict{Int,String}()
  leftColors = Dict{Int,Symbol}()
  rightLabels = Dict{Int,String}()
  rightColors = Dict{Int,Symbol}()
  decorations = Dict{Symbol,String}()
  decoColors = Dict{Symbol,Symbol}()
  Plot{T}(graphics, title, xlabel, ylabel,
          margin, padding, border,
          leftLabels, leftColors, rightLabels, rightColors,
          decorations, decoColors, showLabels)
end

function title{T<:GraphicsArea}(plot::Plot{T})
  plot.title
end

function title!{T<:GraphicsArea}(plot::Plot{T}, title::String)
  plot.title = title
  plot
end

function xlabel{T<:GraphicsArea}(plot::Plot{T})
  plot.xlabel
end

function xlabel!{T<:GraphicsArea}(plot::Plot{T}, xlabel::String)
  plot.xlabel = xlabel
  plot
end

function ylabel{T<:GraphicsArea}(plot::Plot{T})
  plot.ylabel
end

function ylabel!{T<:GraphicsArea}(plot::Plot{T}, ylabel::String)
  plot.ylabel = ylabel
  plot
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, value::String, color::Symbol=:white)
  where == :t || where == :b || where == :tl || where == :tr || where == :bl || where == :br || throw(ArgumentError("Unknown location: try one of these :tl :t :tr :bl :b :br"))
  plot.decorations[where] = value
  plot.decoColors[where] = color
  plot
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, value::String; color::Symbol=:white)
  annotate!(plot, where, value, color)
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, row::Int, value::String, color::Symbol=:white)
  if where == :l
    plot.leftLabels[row] = value
    plot.leftColors[row] = color
  elseif where == :r
    plot.rightLabels[row] = value
    plot.rightColors[row] = color
  else
    throw(ArgumentError("Unknown location: try one of these :l :r"))
  end
  plot
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, row::Int, value::String; color::Symbol=:white)
  annotate!(plot, where, row, value, color)
end

function drawLine!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  drawLine!(plot.graphics, args...; vars...)
  plot
end

function setPixel!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  setPixel!(plot.graphics, args...; vars...)
  plot
end

function setPoint!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  setPoint!(plot.graphics, args...; vars...)
  plot
end

function drawTitle(io::IO, padding::String, title::String; plotWidth::Int=0)
  if title != ""
    offset = safeRound(plotWidth / 2 - length(title) / 2)
    offset = offset > 0 ? offset: 0
    tpad = repeat(spceStr, offset)
    print_with_color(:white, io, padding, tpad, title, "\n")
  end
end

function drawBorderTop(io::IO, padding::String, length::Int, border = :solid)
  b = borderMap[border]
  border == :none || print(io, padding, b[:tl], repeat(b[:t], length), b[:tr])
end

function drawBorderBottom(io::IO, padding::String, length::Int, border = :solid)
  b = borderMap[border]
  border == :none || print(io, padding, b[:bl], repeat(b[:b], length), b[:br])
end

function show(io::IO, p::Plot)
  b = borderMap[p.border]
  c = p.graphics
  borderLength = ncols(c)

  # get length of largest strings to the left and right
  maxLen = p.showLabels && !isempty(p.leftLabels) ? maximum([length(string(l)) for l in values(p.leftLabels)]) : 0
  maxLenR = p.showLabels && !isempty(p.rightLabels) ? maximum([length(string(l)) for l in values(p.rightLabels)]) : 0
  if p.ylabel != ""
    maxLen += length(p.ylabel) + p.padding
  end

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
    topLeftCol = haskey(p.decoColors, :tl) ? p.decoColors[:tl] : :white
    topMidStr = haskey(p.decorations, :t) ? p.decorations[:t] : ""
    topMidCol = haskey(p.decoColors, :t) ? p.decoColors[:t] : :white
    topRightStr = haskey(p.decorations, :tr) ? p.decorations[:tr] : ""
    topRightCol = haskey(p.decoColors, :tr) ? p.decoColors[:tr] : :white
    if topLeftStr != "" || topRightStr != "" || topMidStr != ""
      topLeftLen = length(topLeftStr)
      topMidLen = length(topMidStr)
      topRightLen = length(topRightStr)
      print_with_color(topLeftCol, io, borderPadding, topLeftStr)
      cnt = safeRound(borderLength / 2 - topMidLen / 2 - topLeftLen)
      pad = cnt > 0 ? repeat(spceStr, cnt) : ""
      print_with_color(topMidCol, io, pad, topMidStr)
      cnt = borderLength - topRightLen - topLeftLen - topMidLen + 2 - cnt
      pad = cnt > 0 ? repeat(spceStr, cnt) : ""
      print_with_color(topRightCol, io, pad, topRightStr, "\n")
    end
  end
  drawBorderTop(io, borderPadding, borderLength, p.border)
  print(io, repeat(spceStr, maxLenR), plotPadding, "\n")

  # compute position of ylabel
  ylabRow = safeFloor(nrows(c) / 2)

  # plot all rows
  for row in 1:nrows(c)
    # Current labels to left and right of the row and their length
    tleftLabel = haskey(p.leftLabels,row) ? p.leftLabels[row] : ""
    tleftCol = haskey(p.leftColors,row) ? p.leftColors[row] : :white
    tRightLabel = haskey(p.rightLabels,row) ? p.rightLabels[row] : ""
    tRightCol = haskey(p.rightColors,row) ? p.rightColors[row] : :white
    tLen = length(tleftLabel)
    tLenR = length(tRightLabel)
    # print left annotations
    print(io, repeat(spceStr, p.margin))
    if p.showLabels
      if row == ylabRow
        # print ylabel
        print_with_color(:white, io, p.ylabel)
        print(io, repeat(spceStr, maxLen - length(p.ylabel) - tLen))
      else
        # print padding to fill ylabel length
        print(io, repeat(spceStr, maxLen - tLen))
      end
      # print the left annotation
      print_with_color(tleftCol, io, tleftLabel)
    end
    # print left border
    print(io, plotPadding, b[:l])
    # print canvas row
    printRow(io, c, row)
    #print right label and padding
    print(io, b[:r])
    if p.showLabels
      print(io, plotPadding)
      print_with_color(tRightCol, io, tRightLabel)
      print(io, repeat(spceStr, maxLenR - tLenR))
    end
    print(io, "\n")
  end

  # draw bottom border and bottom labels
  drawBorderBottom(io, borderPadding, borderLength, p.border)
  print(io, repeat(spceStr, maxLenR), plotPadding, "\n")
  if p.showLabels
    botLeftStr = haskey(p.decorations, :bl) ? p.decorations[:bl] : ""
    botLeftCol = haskey(p.decoColors, :bl) ? p.decoColors[:bl] : :white
    botMidStr = haskey(p.decorations, :b) ? p.decorations[:b] : ""
    botMidCol = haskey(p.decoColors, :b) ? p.decoColors[:b] : :white
    botRightStr = haskey(p.decorations, :br) ? p.decorations[:br] : ""
    botRightCol = haskey(p.decoColors, :br) ? p.decoColors[:br] : :white
    if botLeftStr != "" || botRightStr != "" || botMidStr != ""
      botLeftLen = length(botLeftStr)
      botMidLen = length(botMidStr)
      botRightLen = length(botRightStr)
      print_with_color(botLeftCol, io, borderPadding, botLeftStr)
      cnt = safeRound(borderLength / 2 - botMidLen / 2 - botLeftLen)
      pad = cnt > 0 ? repeat(spceStr, cnt) : ""
      print_with_color(botMidCol, io, pad, botMidStr)
      cnt = borderLength - botRightLen - botLeftLen - botMidLen + 2 - cnt
      pad = cnt > 0 ? repeat(spceStr, cnt) : ""
      print_with_color(botRightCol, io, pad, botRightStr, "\n")
    end
    # abuse the drawtitle function to print the xlabel. maybe refactor this
    drawTitle(io, borderPadding, p.xlabel, plotWidth = borderLength)
  end
end


