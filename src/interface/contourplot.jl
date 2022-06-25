"""
    contourplot(x, y, A; kw...)
    contourplot!(p, args...; kw...)

Draws a contour plot on a new canvas.

# Usage

    contourplot(x, y, A; $(keywords(; add = (Z_DESCRIPTION..., :canvas), remove = (:blend, :grid))))

# Arguments

$(arguments(
    (
        A = "`Matrix` of interest for which contours are extracted, or `Function` evaluated as `f(x, y)`",
        levels = "the number of contour levels",
    ); add = (Z_DESCRIPTION..., :x, :y, :canvas), remove = (:blend, :grid)
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> contourplot(-1:.1:1, -1:.1:1, (x, y) -> √(x^2 + y^2))
      ┌────────────────────────────────────────┐  ⠀⠀⠀⠀  
    1 │⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⠒⠊⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠒⠢⣄⡀⠀⠀⠀⠀⠀⠀⠀│  ┌──┐ 1
      │⠀⠀⠀⠀⠀⡠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠱⠤⡀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⡰⠊⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⠔⠒⠒⠉⠉⠉⠉⠓⠒⠒⠤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠘⠢⡀⠀⠀│  │▄▄│  
      │⠀⡰⠉⠀⠀⠀⠀⠀⠀⢀⡠⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠢⡀⠀⠀⠀⠀⠀⠀⠑⢆⠀│  │▄▄│  
      │⡜⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠈⠢⡄⠀⠀⠀⠀⠀⠀⢣│  │▄▄│  
      │⠀⠀⠀⠀⠀⠀⢠⠃⠀⠀⠀⠀⠀⠀⢀⠔⠊⠁⠀⠀⠀⠀⠈⠙⠢⢄⠀⠀⠀⠀⠀⠀⠑⡄⠀⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢣⠀⠀⠀⠀⠀⠀⢘⡄⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠠⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⠄⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀⠀⠣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀⢠⠃⠀⠀⠀⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⠀⠱⡀⠀⠀⠀⠀⠀⠀⠉⠒⣄⣀⠀⠀⠀⠀⢀⣀⠔⠉⠀⠀⠀⠀⠀⠀⢀⠎⠀⠀⠀⠀⠀⠀│  │▄▄│  
      │⢇⠀⠀⠀⠀⠀⠀⠘⠦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⡠⠃⠀⠀⠀⠀⠀⠀⡰│  │▄▄│  
      │⠈⠢⡀⠀⠀⠀⠀⠀⠀⠈⠒⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠔⠋⠀⠀⠀⠀⠀⠀⢀⠖⠁│  │▄▄│  
      │⠀⠀⠈⠱⣀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠒⠢⠤⢤⣀⣀⣀⣀⡠⠤⠤⠒⠊⠁⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀│  │▄▄│  
      │⠀⠀⠀⠀⠀⠑⠦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠒⠁⠀⠀⠀⠀│  │▄▄│  
   -1 │⠀⠀⠀⠀⠀⠀⠀⠀⠙⠒⠤⢄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠤⠔⠊⠁⠀⠀⠀⠀⠀⠀⠀│  └──┘ 0
      └────────────────────────────────────────┘  ⠀⠀⠀⠀  
      ⠀-1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀1⠀  ⠀⠀⠀⠀  
```

# See also

`Plot`, `lineplot`, `BrailleCanvas`
"""
function contourplot(
    x::AbstractVector,
    y::AbstractVector,
    A::Union{Function,AbstractMatrix};
    canvas::Type = KEYWORDS.canvas,
    colormap = KEYWORDS.colormap,
    kw...,
)
    pkw, okw = split_plot_kw(; kw...)
    plot = Plot(
        extrema(x) |> collect,
        extrema(y) |> collect,
        nothing,
        canvas;
        colormap = colormap,
        colorbar = true,
        blend = false,
        grid = false,
        pkw...,
    )
    A isa Function && (A = A.(x', y))
    contourplot!(plot, x, y, A; colormap = colormap, okw...)
end

@doc (@doc contourplot) function contourplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector,
    y::AbstractVector,
    A::AbstractMatrix;
    name::AbstractString = KEYWORDS.name,
    colormap = KEYWORDS.colormap,
    levels::Integer = 3,
)
    isempty(name) || label!(plot, :r, string(name))

    plot.cmap.callback = callback = colormap_callback(colormap)
    mA, MA = NaNMath.extrema(as_float(A))

    for cl ∈ Contour.levels(Contour.contours(y, x, A, levels))
        color = callback(Contour.level(cl), mA, MA)
        for line ∈ Contour.lines(cl)
            yi, xi = Contour.coordinates(line)
            lineplot!(plot, xi, yi, color = color)
        end
    end
    plot
end

"""
    contourplot(A; kw...)

# Usage

Draws a contour plot of matrix `A` along axis `x` and `y` on a new canvas.

The `y` axis is flipped by default:

```
Julia matrices (images) │ UnicodePlots
                        │
           axes(A, 2)   │
           o───────→    │   ↑
           │            │   │
axes(A, 1) │            │ y │
           │            │   │
           ↓            │   o───────→
                        │       x
```
"""
contourplot(A::AbstractMatrix; kw...) =
    contourplot(axes(A, 2) |> collect, axes(A, 1) |> reverse |> collect, A; kw...)
