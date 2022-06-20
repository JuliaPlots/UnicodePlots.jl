"""
    stairs(x, y; kw...)

# Description

Draws a staircase plot on a new canvas.

The first (optional) vector `x` should contain the horizontal positions for all the points.
The second vector `y` should then contain the corresponding vertical positions respectively.
This means that the two vectors must be of the same length and ordering.

# Usage

    stairs(x, y; $(keywords((style = :post,); add = (:canvas,))))

# Arguments

$(arguments(
    (; style = "specifies where the transition of the stair takes place (can be either `:pre` or `:post`)");
    add = (:x, :y, :canvas)
))

# Author(s)

- Christof Stocker (github.com/Evizero)
- Dominique (github.com/dpo)

# Examples

```julia-repl
julia> stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], style = :post, title = "My Staircase Plot")
                 My Staircase Plot
     ┌────────────────────────────────────────┐
   7 │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⡄⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⢸⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢸│
     │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠧⠤⠤⠤⠤⠼│
     │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
   1 │⣀⣀⣀⣀⣀⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
     └────────────────────────────────────────┘
     1                                        8
```

# See also

[`Plot`](@ref), [`scatterplot`](@ref), [`lineplot`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function stairs(X::AbstractVector, Y::AbstractVector; style::Symbol = :post, kw...)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot(x_vex, y_vex; kw...)
end

function stairs!(
    plot::Plot{<:Canvas},
    X::AbstractVector,
    Y::AbstractVector;
    style::Symbol = :post,
    kw...,
)
    x_vex, y_vex = compute_stair_lines(X, Y, style)
    lineplot!(plot, x_vex, y_vex; kw...)
end

function compute_stair_lines(X::AbstractVector, Y::AbstractVector, style::Symbol)
    if style ≡ :post
        x_vex = similar(X, 2length(X) - 1)
        y_vex = similar(Y, 2length(X) - 1)
        x_vex[1] = X[1]
        y_vex[1] = Y[1]
        o = 0
        for i in 2:(length(X))
            x_vex[i + o] = X[i]
            x_vex[i + o + 1] = X[i]
            y_vex[i + o] = Y[i - 1]
            y_vex[i + o + 1] = Y[i]
            o += 1
        end
        return x_vex, y_vex
    elseif style ≡ :pre
        x_vex = zeros(2length(X) - 1)
        y_vex = zeros(2length(X) - 1)
        x_vex[1] = X[1]
        y_vex[1] = Y[1]
        o = 0
        for i in 2:(length(X))
            x_vex[i + o] = X[i - 1]
            x_vex[i + o + 1] = X[i]
            y_vex[i + o] = Y[i]
            y_vex[i + o + 1] = Y[i]
            o += 1
        end
        return x_vex, y_vex
    end
end
