"""
    spy(A; kwargs...)

Description
============

Plots the sparsity pattern for the given matrix `A`. This means
that a scatterplot that resembles the matrix is drawn, in which
only the pixel for non-zero elements of the matrix are set.

If the parameters `width` and `height` are not explicitly
specified, then the function will attempt to preserve the aspect
ratio of the matrix, while also attempting to fit the resulting
plot withing the bounding box specified by `maxwidth` and
`maxheight`

Usage
======

    spy(A; maxwidth = 70, maxheight = 40, title = "Sparsity Pattern", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, width = 0, height = 0, canvas = BrailleCanvas, grid = true)

Arguments
==========

- **`A`** : The matrix of interest for which non-zero elements
  should be drawn

- **`maxwidth`** : Maximum number of characters per row that
  should be used for plotting

- **`maxheight`** : Maximum number of character rows that should
  be used for plotting.

- **`title`** : Text to display on the top of the plot.

- **`labels`** : Boolean. Can be used to hide the labels by
  setting `labels = false`.

- **`border`** : The style of the bounding box of the plot.
  Supports `:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.  
- **`margin`** : Number of empty characters to the left of the
  whole plot.

- **`padding`** : Space of the left and right of the plot between
  the labels and the canvas.

- **`color`** : Color of the drawing.
  Can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`,
  `:magenta`, `:white`, `:normal`.

- **`width`** : Exact number of characters per row that should be
  used for plotting. `0` stands for automatic.

- **`height`** : Exact number of character rows that should be
  used for plotting. `0` stands for automatic.

- **`canvas`** : The type of canvas that should be used for drawing.

Returns
========

A plot object of type `Plot{T<:Canvas}`

Author(s)
==========

- Dominique (Github: https://github.com/dpo)
- Christof Stocker (Github: https://github.com/Evizero)
- Jake Bolewski (Github: https://github.com/jakebolewski)

Examples
=========

```julia-repl
julia> spy(sprandn(50, 120, .05))
                           Sparsity Pattern
      ┌────────────────────────────────────────────────────────────┐
    1 │⢀⠀⠒⠀⢄⠂⠀⡀⠀⠀⠀⠰⠀⠐⠀⠀⠀⠀⠂⠀⠀⠀⠠⠰⠀⠀⠀⡀⠄⠀⠠⠀⠀⠀⠀⠀⡀⠀⠀⠀⡀⠐⠀⠐⠀⠀⡀⠀⠀⠀⠀⠀⠀⠂⡀⠀⡀⠠⠀⠀│ > 0
      │⠀⠀⠀⠀⠀⢀⢀⠀⠀⠀⠀⠐⠄⠀⢀⠂⠀⠠⠀⠉⠀⠀⠀⠀⢐⠀⠀⠀⠀⠀⠠⠐⠄⠄⠀⠀⠀⠐⠐⠈⢁⠀⠀⠀⠀⠀⠀⠀⠠⠀⠐⡐⠀⠄⠀⠀⠈⠀⠀⠠│ < 0
      │⡀⠀⠀⠀⡀⠊⠀⠀⠀⢀⢀⠀⠄⠀⠂⡠⠂⠐⠐⠀⠀⠄⠀⠀⠀⠄⠀⠀⠀⠀⡀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠠⠀⠂⠀⠠⠀⠀⠀⠆⠄⠈⠀⢀⠀⠀⠀⠐⠄⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⢠⠀⢀⠀⠀⠀⢀⠀⠄⠀⠀⠀⠂⠀⠀⠀⠇⠀⢀⠀⠀⠁⠁⠀⠄⠄⠀⠀⠁⠁⠀⡈⠀⠁⠄⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀│
      │⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⢀⠀⠀⠀⠐⠂⠁⢀⠠⠀⠀⠀⠀⠀⠁⠀⠀⠀⠠⠀⠀⠀⠀⢀⠀⢄⠀⠀⠀⠐⠀⠀⠈⠀⠀⠐⠀⠄⠂⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠠⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠠⠈⠀⠀⠀⠀⢀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀│
      │⠐⠀⠉⠐⠀⠀⠁⠀⠀⠀⠀⠀⠀⠌⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠌⠀⠀⠄⠀⠀⡀⠀⠀⠀⠀⠀⢀⠈⠄⠀⡀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀│
      │⠂⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⡨⠀⠠⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠈⡠⠀⡀⠀⠀⠁⠀⠁⠠⠀⠀⠀⠀⠀⠀⠀⠄⡀⠀⠄⡠⠀⠀⠀⠀│
      │⠐⠀⠀⠀⠀⠀⠀⠃⠀⠀⠀⠀⠁⠀⡀⠁⠀⢂⠂⠀⠀⠀⠈⠁⠀⠀⠁⠁⠄⠀⠀⠀⠀⠀⡀⠀⠀⠀⠂⠀⠀⠀⠀⠐⠀⠂⠀⠂⠁⠀⠆⠈⠀⠀⠄⠄⠀⠀⠀⠀│
      │⠀⠀⠀⠠⠀⠁⠀⠀⠀⠀⠂⠀⠠⠀⠀⠌⠀⠀⠂⠄⠀⡀⠂⠀⠀⡀⠠⠁⠄⠀⠀⠀⠀⠀⠄⠈⠀⢂⠐⠀⢀⠀⠠⠀⠄⠁⡀⠀⠀⠐⠀⠀⡐⠀⠀⠀⠁⠀⠀⠔│
      │⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠁⠃⡀⡁⠀⠀⠀⢀⠀⠀⠂⠀⠀⠠⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠬⠀⡀│
      │⠐⠀⠀⠀⠀⠀⠀⠀⠢⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠈⠁⠁⠀⠀⠄⠀⠀⠐⠀⠄⠀⠠⠀⠁⡀⠁⠀⠀⠠⠡⠀⠀⠀⠀⠀⠀⠀⠐⠄⠀⠀⠀⠀⡀│
   50 │⠀⠀⠀⠀⠁⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠂⠀⠀⠀⠀⠀⠀⠐⠀⠈⠂⠀⠀⠀⠀⠀⠀⠀⠀⠠⠈⠀⠀⠀⠀⠀⠀⠂⠀⠄⠀⠀⠀⠂⠁⠀⠀⠀⠂⠀│
      └────────────────────────────────────────────────────────────┘
      1                                                          120
                               nz = 275
```

See also
=========

[`Plot`](@ref), [`scatterplot`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function spy(
        A::AbstractMatrix;
        maxwidth::Int  = 0,
        maxheight::Int = 0,
        title = "Sparsity Pattern",
        width::Int  = 0,
        height::Int = 0,
        margin::Int  = 3,
        padding::Int = 1,
        color::Symbol = :auto,
        canvas::Type{T} = BrailleCanvas,
        kw...) where {T <: Canvas}
    if color == :automatic
        Base.depwarn("`color = :automatic` is deprecated, use `color = :auto` instead", :spy)
        color = :auto
    end
    nrow, ncol = size(A)
    rows, cols, vals = _findnz(A)
    (width, height, _, _) = get_canvas_dimensions_for_matrix(
        canvas, size(A, 1), size(A, 2), maxwidth, maxheight, width, height, margin, padding;
        extra_rows = 9, extra_cols = 6
    )
    can = T(width, height,
            width  = Float64(ncol) + 1,
            height = Float64(nrow) + 1)
    plot = Plot(can;
                title = title, margin = margin,
                padding = padding, kw...)
    height = nrows(plot.graphics)
    width = ncols(plot.graphics)
    plot = if color != :auto
        points!(plot,
                convert(Vector{Float64}, cols),
                nrow + 1 .- convert(Vector{Float64}, rows),
                color)
    else
        pos_idx = vals .> 0
        neg_idx = (!).(pos_idx)
        pos_cols = cols[pos_idx]
        pos_rows = rows[pos_idx]
        neg_cols = cols[neg_idx]
        neg_rows = rows[neg_idx]
        points!(plot,
                convert(Vector{Float64}, pos_cols),
                nrow + 1 .- convert(Vector{Float64}, pos_rows),
                :red)
        points!(plot,
                convert(Vector{AbstractFloat}, neg_cols),
                nrow + 1 .- convert(Vector{Float64}, neg_rows),
                :blue)
        annotate!(plot, :r, 1, "> 0", :red)
        annotate!(plot, :r, 2, "< 0", :blue)
    end
    annotate!(plot, :l, 1, "1", :light_black)
    annotate!(plot, :l, height, string(nrow), :light_black)
    annotate!(plot, :bl, "1", :light_black)
    annotate!(plot, :br, string(ncol), :light_black)
    xlabel!(plot, string("nz = ", length(vals)))
    return plot
end

function _findnz(A::AbstractMatrix)
    I = findall(!iszero, A)
    (getindex.(I, 1), getindex.(I, 2), A[I])
end

_findnz(A::AbstractSparseMatrix) = findnz(A)
