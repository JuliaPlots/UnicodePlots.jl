function scatterplot{F<:Real,R<:Real}(
    x::AbstractVector{F}, y::AbstractVector{R};
    color::Symbol = :auto,
    name::AbstractString = "",
    canvas::Type = BrailleCanvas,
    args...)
  X = convert(Vector{Float64}, x)
  Y = convert(Vector{Float64}, y)
  newPlot = Plot(X, Y, canvas; args...)
  color = (color == :auto) ? nextColor!(newPlot) : color
  name == "" || annotate!(newPlot, :r, name, color)
  setPoint!(newPlot, X, Y, color)
end

function scatterplot!{T<:Canvas,F<:Real,R<:Real}(
    plot::Plot{T}, x::AbstractVector{F}, y::AbstractVector{R};
    color::Symbol = :auto,
    name::AbstractString = "",
    args...)
  X = convert(Vector{Float64}, x)
  Y = convert(Vector{Float64}, y)
  color = (color == :auto) ? nextColor!(plot) : color
  name == "" || annotate!(plot, :r, name, color)
  setPoint!(plot, X, Y, color)
end
