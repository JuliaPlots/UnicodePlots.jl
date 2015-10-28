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
  points!(newPlot, X, Y, color)
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
  points!(plot, X, Y, color)
end

function scatterplot{F<:Real,R<:Real}(X::Range{F}, Y::Range{R}; args...)
  scatterplot(collect(X), collect(Y); args...)
end

function scatterplot{F<:Real}(X::Range, Y::AbstractVector{F}; args...)
  scatterplot(collect(X), Y; args...)
end

function scatterplot{F<:Real}(X::AbstractVector{F}, Y::Range; args...)
  scatterplot(X, collect(Y); args...)
end

function scatterplot(X::AbstractVector; args...)
  scatterplot(1:length(X), X; args...)
end

function scatterplot!{T<:Canvas}(plot::Plot{T}, X::AbstractVector; args...)
  scatterplot!(plot, 1:length(X), X; args...)
end

function scatterplot!{T<:Canvas,F<:Real,R<:Real}(plot::Plot{T}, X::Range{F}, Y::Range{R}; args...)
  scatterplot!(plot, collect(X), collect(Y); args...)
end

function scatterplot!{T<:Canvas,F<:Real}(plot::Plot{T}, X::Range, Y::AbstractVector{F}; args...)
  scatterplot!(plot, collect(X), Y; args...)
end

function scatterplot!{T<:Canvas,F<:Real}(plot::Plot{T}, X::AbstractVector{F}, Y::Range; args...)
  scatterplot!(plot, X, collect(Y); args...)
end
