function lineplot{F<:Real, R<:Real}(
        X::AbstractVector{F},
        Y::AbstractVector{R};
        color::Symbol = :auto,
        name::AbstractString = "",
        canvas::Type = BrailleCanvas,
        args...)
    X = convert(Vector{Float64},X)
    Y = convert(Vector{Float64},Y)
    new_plot = Plot(X, Y, canvas; args...)
    color = color == :auto ? next_color!(new_plot) : color
    name == "" || annotate!(new_plot, :r, name, color)
    lines!(new_plot, X, Y, color)
end

function lineplot!{T<:Canvas, F<:Real, R<:Real}(
        plot::Plot{T},
        X::AbstractVector{F},
        Y::AbstractVector{R};
        color::Symbol = :auto,
        name::AbstractString = "",
        args...)
    X = convert(Vector{Float64},X)
    Y = convert(Vector{Float64},Y)
    color = color == :auto ? next_color!(plot) : color
    name == "" || annotate!(plot, :r, name, color)
    lines!(plot, X, Y, color)
end

function lineplot!{T<:Canvas}(
        plot::Plot{T},
        intercept::Real,
        slope::Real;
        args...)
    xmin = origin_x(plot.graphics)
    xmax = origin_x(plot.graphics) + width(plot.graphics)
    ymin = origin_y(plot.graphics)
    ymax = origin_y(plot.graphics) + height(plot.graphics)
    lineplot!(plot, [xmin, xmax], [intercept + xmin*slope, intercept + xmax*slope]; args...)
end

function lineplot!{T<:Canvas}(
        plot::Plot{T},
        Y::Function,
        x::Range;
        args...)
    X = collect(x)
    lineplot!(plot, Y, X; args...)
end

function lineplot(
        Y::Function,
        x::Range;
        args...)
    X = collect(x)
    lineplot(Y, X; args...)
end

function lineplot!{T<:Canvas, R<:Real}(
        plot::Plot{T},
        Y::Function,
        X::AbstractVector{R};
        name::AbstractString = "",
        args...)
    y = convert(Vector{Float64}, [Y(i) for i in X])
    name = name == "" ? string(Y, "(x)") : name
    lineplot!(plot, X, y; name = name, args...)
end

function lineplot{R<:Real}(
        Y::Function,
        X::Vector{R};
        name::AbstractString = "",
        args...)
    y = convert(Vector{Float64}, [Y(i) for i in X])
    name = name == "" ? string(Y, "(x)") : name
    new_plot = lineplot(X, y; name = name, args...)
    xlabel!(new_plot, "x")
    ylabel!(new_plot, "f(x)")
end

function lineplot!{T<:Canvas}(
        plot::Plot{T},
        Y::Function,
        startx::Real,
        endx::Real;
        args...)
    diff = abs(endx - startx)
    X = collect(startx:(diff/(3*ncols(plot.graphics))):endx)
    lineplot!(plot, Y, X; args...)
end

function lineplot(Y::Function; args...)
    lineplot(Y, -10, 10; args...)
end

function lineplot!{T<:Canvas}(
        plot::Plot{T},
        Y::Function;
        args...)
    lineplot!(plot, Y, origin_x(plot.graphics), origin_x(plot.graphics) + width(plot.graphics); args...)
end

function lineplot(
        Y::Function,
        startx::Real,
        endx::Real;
        width::Int = 40,
        args...)
    diff = abs(endx - startx)
    X = collect(startx:(diff/(3*width)):endx)
    lineplot(Y, X; width = width, args...)
end

function lineplot(Y::AbstractVector{Function}; args...)
    lineplot(Y, -10, 10; args...)
end

function lineplot(
        Y::AbstractVector{Function},
        startx::Real,
        endx::Real;
        args...)
    n = length(Y)
    @assert n > 0
    new_plot = lineplot(Y[1], startx, endx; args...)
    for i = 2:n
        lineplot!(new_plot, Y[i], startx, endx; args...)
    end
    new_plot
end

function lineplot{F<:Real, R<:Real}(
        X::Range{F},
        Y::Range{R};
        args...)
    lineplot(collect(X), collect(Y); args...)
end

function lineplot{F<:Real}(
        X::Range,
        Y::AbstractVector{F};
        args...)
    lineplot(collect(X), Y; args...)
end

function lineplot{F<:Real}(
        X::AbstractVector{F},
        Y::Range;
        args...)
    lineplot(X, collect(Y); args...)
end

function lineplot(X::AbstractVector; args...)
    lineplot(1:length(X), X; args...)
end

function lineplot!{T<:Canvas}(
        plot::Plot{T},
        X::AbstractVector;
        args...)
    lineplot!(plot, 1:length(X), X; args...)
end

function lineplot!{T<:Canvas, F<:Real, R<:Real}(
        plot::Plot{T},
        X::Range{F},
        Y::Range{R};
        args...)
    lineplot!(plot, collect(X), collect(Y); args...)
end

function lineplot!{T<:Canvas, F<:Real}(
        plot::Plot{T},
        X::Range,
        Y::AbstractVector{F};
        args...)
    lineplot!(plot, collect(X), Y; args...)
end

function lineplot!{T<:Canvas, F<:Real}(
        plot::Plot{T},
        X::AbstractVector{F},
        Y::Range;
        args...)
    lineplot!(plot, X, collect(Y); args...)
end

function lineplot{D<:TimeType, R<:Real}(
        X::AbstractVector{D},
        Y::AbstractVector{R};
        args...)
    d = convert(Vector{Float64}, X)
    new_plot = lineplot(d, Y; args...)
    annotate!(new_plot, :bl, string(first(X)))
    annotate!(new_plot, :br, string(last(X)))
end
