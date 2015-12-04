function compute_stair_lines{F<:Real,R<:Real}(
        X::AbstractVector{F},
        Y::AbstractVector{R},
        style::Symbol)
    if style == :post
        x_vex = zeros(length(X) * 2 - 1)
        y_vex = zeros(length(X) * 2 - 1)
        x_vex[1] = X[1]
        y_vex[1] = Y[1]
        o = 0
        for i = 2:(length(X))
            x_vex[i + o] = X[i]
            x_vex[i + o + 1] = X[i]
            y_vex[i + o] = Y[i-1]
            y_vex[i + o + 1] = Y[i]
            o += 1
        end
        x_vex, y_vex
    elseif style == :pre
        x_vex = zeros(length(X) * 2 - 1)
        y_vex = zeros(length(X) * 2 - 1)
        x_vex[1] = X[1]
        y_vex[1] = Y[1]
        o = 0
        for i = 2:(length(X))
            x_vex[i + o] = X[i-1]
            x_vex[i + o + 1] = X[i]
            y_vex[i + o] = Y[i]
            y_vex[i + o + 1] = Y[i]
            o += 1
        end
        x_vex, y_vex
    end
end

function stairs{F<:Real,R<:Real}(
        X::Vector{F}, Y::Vector{R};
        style::Symbol = :post,
        args...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot(x_vex, y_vex; args...)
end

function stairs!{T<:Canvas,F<:Real,R<:Real}(
        plot::Plot{T}, X::AbstractVector{F}, Y::AbstractVector{R};
        style::Symbol = :post,
        args...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot!(plot, x_vex, y_vex; args...)
end
