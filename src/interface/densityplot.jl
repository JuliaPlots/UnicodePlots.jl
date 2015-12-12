function densityplot{F<:Real,R<:Real}(
        x::Vector{F},
        y::Vector{R};
        color::Symbol = :white,
        args...)
    X = convert(Vector{Float64}, x)
    Y = convert(Vector{Float64}, y)
    new_plot = Plot(X, Y, DensityCanvas; grid = false, args...)
    points!(new_plot, X, Y, color)
end

function densityplot!{T<:Canvas,F<:Real,R<:Real}(
        plot::Plot{T},
        x::Vector{F},
        y::Vector{R};
        color::Symbol = :white,
        args...)
    X = convert(Vector{Float64}, x)
    Y = convert(Vector{Float64}, y)
    points!(plot, X, Y, color)
end
