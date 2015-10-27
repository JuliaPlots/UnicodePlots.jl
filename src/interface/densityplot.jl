function densityplot{F<:Real,R<:Real}(
    x::Vector{F}, y::Vector{R};
    color::Symbol = :white,
    args...)
  X = convert(Vector{Float64}, x)
  Y = convert(Vector{Float64}, y)
  minX = minimum(X); minY = minimum(Y)
  maxX = maximum(X); maxY = maximum(Y)
  newPlot = Plot(X, Y, DensityCanvas; grid = false, args...)
  setPoint!(newPlot, X, Y, color)
end

function densityplot!{T<:Canvas,F<:Real,R<:Real}(
    plot::Plot{T}, x::Vector{F}, y::Vector{R};
    color::Symbol = :white,
    args...)
  X = convert(Vector{Float64}, x)
  Y = convert(Vector{Float64}, y)
  setPoint!(plot, X, Y, color)
end
