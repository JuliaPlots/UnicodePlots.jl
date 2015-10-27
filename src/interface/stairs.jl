function computeStairLines{F<:Real,R<:Real}(X::AbstractVector{F}, Y::AbstractVector{R}, style::Symbol)
  if style == :post
    xVec = zeros(length(X) * 2 - 1)
    yVec = zeros(length(X) * 2 - 1)
    xVec[1] = X[1]
    yVec[1] = Y[1]
    o = 0
    for i = 2:(length(X))
      xVec[i + o] = X[i]
      xVec[i + o + 1] = X[i]
      yVec[i + o] = Y[i-1]
      yVec[i + o + 1] = Y[i]
      o += 1
    end
    xVec, yVec
  elseif style == :pre
    xVec = zeros(length(X) * 2 - 1)
    yVec = zeros(length(X) * 2 - 1)
    xVec[1] = X[1]
    yVec[1] = Y[1]
    o = 0
    for i = 2:(length(X))
      xVec[i + o] = X[i-1]
      xVec[i + o + 1] = X[i]
      yVec[i + o] = Y[i]
      yVec[i + o + 1] = Y[i]
      o += 1
    end
    xVec, yVec
  end
end

function stairs{F<:Real,R<:Real}(
    X::Vector{F}, Y::Vector{R};
    style::Symbol = :post,
    args...)
  xVec, yVec = computeStairLines(X, Y, style)
  lineplot(xVec, yVec; args...)
end

function stairs!{T<:Canvas,F<:Real,R<:Real}(
    plot::Plot{T}, X::AbstractVector{F}, Y::AbstractVector{R};
    style::Symbol = :post,
    args...)
  xVec, yVec = computeStairLines(X, Y, style)
  lineplot!(plot, xVec, yVec; args...)
end
