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
  newPlot = Plot(area, title = title, margin = margin,
                 padding = padding, border = border, showLabels = labels)
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
