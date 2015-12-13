type Plot{T<:GraphicsArea}
  graphics::T
  title::UTF8String
  xlabel::UTF8String
  ylabel::UTF8String
  margin::Int
  padding::Int
  border::Symbol
  leftLabels::Dict{Int,UTF8String}
  leftColors::Dict{Int,Symbol}
  rightLabels::Dict{Int,UTF8String}
  rightColors::Dict{Int,Symbol}
  decorations::Dict{Symbol,UTF8String}
  decoColors::Dict{Symbol,Symbol}
  showLabels::Bool
  autocolor::Int
end

function Plot{T<:GraphicsArea}(
    graphics::T;
    title::AbstractString = "",
    xlabel::AbstractString = "",
    ylabel::AbstractString = "",
    margin::Int = 3,
    padding::Int = 1,
    border::Symbol = :solid,
    showLabels = true)
  rows = nrows(graphics)
  cols = ncols(graphics)
  leftLabels = Dict{Int,UTF8String}()
  leftColors = Dict{Int,Symbol}()
  rightLabels = Dict{Int,UTF8String}()
  rightColors = Dict{Int,Symbol}()
  decorations = Dict{Symbol,UTF8String}()
  decoColors = Dict{Symbol,Symbol}()
  Plot{T}(graphics, title, xlabel, ylabel,
          margin, padding, border,
          leftLabels, leftColors, rightLabels, rightColors,
          decorations, decoColors, showLabels, 0)
end

function Plot{C<:Canvas, F<:AbstractFloat}(
    X::Vector{F}, Y::Vector{F}, ::Type{C} = BrailleCanvas;
    width::Int = 40,
    height::Int = 15,
    margin::Int = 3,
    padding::Int = 1,
    grid::Bool = true,
    title::AbstractString = "",
    border::Symbol = :solid,
    labels::Bool = true,
    xlim::Vector = [0.,0.],
    ylim::Vector = [0.,0.])
  length(xlim) == length(ylim) == 2 || throw(ArgumentError("xlim and ylim must only be vectors of length 2"))
  margin >= 0 || throw(ArgumentError("Margin must be greater than or equal to 0"))
  length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
  width = max(width, 5)
  height = max(height, 2)

  minX, maxX = extend_limits(X, xlim)
  minY, maxY = extend_limits(Y, ylim)
  origin_x = minX
  origin_y = minY
  p_width = maxX - origin_x
  p_height = maxY - origin_y

  canvas = C(width, height,
             origin_x = origin_x, origin_y = origin_y,
             width = p_width, height = p_height)
  newPlot = Plot(canvas, title = title, margin = margin,
                 padding = padding, border = border, showLabels = labels)

  minXString = string(isinteger(minX) ? round(Int, minX, RoundNearestTiesUp) : minX)
  maxXString = string(isinteger(maxX) ? round(Int, maxX, RoundNearestTiesUp) : maxX)
  minYString = string(isinteger(minY) ? round(Int, minY, RoundNearestTiesUp) : minY)
  maxYString = string(isinteger(maxY) ? round(Int, maxY, RoundNearestTiesUp) : maxY)
  annotate!(newPlot, :l, 1, maxYString)
  annotate!(newPlot, :l, height, minYString)
  annotate!(newPlot, :bl, minXString)
  annotate!(newPlot, :br, maxXString)
  if grid
    if minY < 0 < maxY
      for i in linspace(minX, maxX, width * x_pixel_per_char(typeof(canvas)))
        points!(newPlot, i, 0., :white)
      end
    end
    if minX < 0 < maxX
      for i in linspace(minY, maxY, height * y_pixel_per_char(typeof(canvas)))
        points!(newPlot, 0., i, :white)
      end
    end
  end
  newPlot
end

function next_color!{T<:GraphicsArea}(plot::Plot{T})
  curColor = color_cycle[plot.autocolor + 1]
  plot.autocolor = ((plot.autocolor + 1) % length(color_cycle))
  curColor
end

function title{T<:GraphicsArea}(plot::Plot{T})
  plot.title
end

function title!{T<:GraphicsArea}(plot::Plot{T}, title::AbstractString)
  plot.title = title
  plot
end

function xlabel{T<:GraphicsArea}(plot::Plot{T})
  plot.xlabel
end

function xlabel!{T<:GraphicsArea}(plot::Plot{T}, xlabel::AbstractString)
  plot.xlabel = xlabel
  plot
end

function ylabel{T<:GraphicsArea}(plot::Plot{T})
  plot.ylabel
end

function ylabel!{T<:GraphicsArea}(plot::Plot{T}, ylabel::AbstractString)
  plot.ylabel = ylabel
  plot
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, value::AbstractString, color::Symbol=:white)
  where == :t || where == :b || where == :l || where == :r || where == :tl || where == :tr || where == :bl || where == :br || throw(ArgumentError("Unknown location: try one of these :tl :t :tr :bl :b :br"))
  if where == :l || where == :r
    for row = 1:nrows(plot.graphics)
      if where == :l
        if(!haskey(plot.leftLabels, row) || plot.leftLabels[row] == "")
          plot.leftLabels[row] = value
          plot.leftColors[row] = color
          return plot
        end
      elseif where == :r
        if(!haskey(plot.rightLabels, row) || plot.rightLabels[row] == "")
          plot.rightLabels[row] = value
          plot.rightColors[row] = color
          return plot
        end
      end
    end
  else
    plot.decorations[where] = value
    plot.decoColors[where] = color
    return plot
  end
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, value::AbstractString; color::Symbol=:white)
  annotate!(plot, where, value, color)
end

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, row::Int, value::AbstractString, color::Symbol=:white)
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

function annotate!{T<:GraphicsArea}(plot::Plot{T}, where::Symbol, row::Int, value::AbstractString; color::Symbol=:white)
  annotate!(plot, where, row, value, color)
end

function lines!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  lines!(plot.graphics, args...; vars...)
  plot
end

function pixel!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  pixel!(plot.graphics, args...; vars...)
  plot
end

function points!{T<:Canvas}(plot::Plot{T}, args...; vars...)
  points!(plot.graphics, args...; vars...)
  plot
end

function print_title(io::IO, padding::AbstractString, title::AbstractString; p_width::Int = 0)
  if title != ""
    offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
    offset = offset > 0 ? offset: 0
    tpad = repeat(" ", offset)
    print_with_color(:white, io, padding, tpad, title, "\n")
  end
end

function print_border_top(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid)
  b = bordermap[border]
  border == :none || print_with_color(:white, io, padding, b[:tl], repeat(b[:t], length), b[:tr])
end

function print_border_bottom(io::IO, padding::AbstractString, length::Int, border::Symbol = :solid)
  b = bordermap[border]
  border == :none || print_with_color(:white, io, padding, b[:bl], repeat(b[:b], length), b[:br])
end

function Base.show(io::IO, p::Plot)
  b = bordermap[p.border]
  c = p.graphics
  borderLength = ncols(c)

  # get length of largest strings to the left and right
  maxLen = p.showLabels && !isempty(p.leftLabels) ? maximum([length(string(l)) for l in values(p.leftLabels)]) : 0
  maxLenR = p.showLabels && !isempty(p.rightLabels) ? maximum([length(string(l)) for l in values(p.rightLabels)]) : 0
  if p.showLabels && p.ylabel != ""
    maxLen += length(p.ylabel) + 1
  end

  # offset where the plot (incl border) begins
  plotOffset = maxLen + p.margin + p.padding

  # padding-string from left to border
  plotPadding = repeat(" ", p.padding)

  # padding-string between labels and border
  borderPadding = repeat(" ", plotOffset)

  # plot the title and the top border
  print_title(io, borderPadding, p.title, p_width = borderLength)
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
      cnt = round(Int, borderLength / 2 - topMidLen / 2 - topLeftLen, RoundNearestTiesUp)
      pad = cnt > 0 ? repeat(" ", cnt) : ""
      print_with_color(topMidCol, io, pad, topMidStr)
      cnt = borderLength - topRightLen - topLeftLen - topMidLen + 2 - cnt
      pad = cnt > 0 ? repeat(" ", cnt) : ""
      print_with_color(topRightCol, io, pad, topRightStr, "\n")
    end
  end
  print_border_top(io, borderPadding, borderLength, p.border)
  print(io, repeat(" ", maxLenR), plotPadding, "\n")

  # compute position of ylabel
  ylabRow = round(nrows(c) / 2, RoundNearestTiesUp)

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
    print(io, repeat(" ", p.margin))
    if p.showLabels
      if row == ylabRow
        # print ylabel
        print_with_color(:white, io, p.ylabel)
        print(io, repeat(" ", maxLen - length(p.ylabel) - tLen))
      else
        # print padding to fill ylabel length
        print(io, repeat(" ", maxLen - tLen))
      end
      # print the left annotation
      print_with_color(tleftCol, io, tleftLabel)
    end
    # print left border
    print_with_color(:white, io, plotPadding, b[:l])
    # print canvas row
    printrow(io, c, row)
    #print right label and padding
    print_with_color(:white, io, b[:r])
    if p.showLabels
      print(io, plotPadding)
      print_with_color(tRightCol, io, tRightLabel)
      print(io, repeat(" ", maxLenR - tLenR))
    end
    print(io, "\n")
  end

  # draw bottom border and bottom labels
  print_border_bottom(io, borderPadding, borderLength, p.border)
  print(io, repeat(" ", maxLenR), plotPadding, "\n")
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
      cnt = round(Int, borderLength / 2 - botMidLen / 2 - botLeftLen, RoundNearestTiesUp)
      pad = cnt > 0 ? repeat(" ", cnt) : ""
      print_with_color(botMidCol, io, pad, botMidStr)
      cnt = borderLength - botRightLen - botLeftLen - botMidLen + 2 - cnt
      pad = cnt > 0 ? repeat(" ", cnt) : ""
      print_with_color(botRightCol, io, pad, botRightStr, "\n")
    end
    # abuse the print_title function to print the xlabel. maybe refactor this
    print_title(io, borderPadding, p.xlabel, p_width = borderLength)
  end
end
