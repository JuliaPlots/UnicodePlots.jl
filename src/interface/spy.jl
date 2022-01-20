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

    spy(A; maxwidth = 70, maxheight = 40, title = "Sparsity Pattern", labels = true, border = :solid, margin = 3, padding = 1, color = :auto, out_stream::Union{Nothing,IO} = nothing, width = 0, height = 0, canvas = BrailleCanvas, zeros = false)

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

- **`show_zeros`** : Show zeros pattern instead of default nonzeros.

- **`fix_ar`** : Fix terminal aspect ratio (experimental)

Returns
========

A plot object of type `Plot{T<:Canvas}`

Author(s)
==========

- Dominique Orban (Github: https://github.com/dpo)
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

function spy(A::AbstractMatrix; kwargs...)
    rows, cols, vals = _strict_non_zeros(_findnz(A)...)
    if get(kwargs, :show_zeros, false)
        I = CartesianIndex.(zip(rows, cols))  # non zeros
        mask = trues(size(A)); mask[I] .= false
        Z = CartesianIndices(axes(A))[mask]  # zeros
        rows, cols = getindex.(Z, 1), getindex.(Z, 2)
        vals = zeros(eltype(vals), length(rows))
    end
    spy(size(A)..., rows, cols, vals; kwargs...)
end

function _strict_non_zeros(rows, cols, vals)
    # findnz(A) returns stored zeros, ignore those
    I = findall(!iszero, vals)
    rows[I], cols[I], vals[I]
end

function spy(
    nrow::Int,
    ncol::Int,
    rows::AbstractArray{<:Integer},
    cols::AbstractArray{<:Integer},
    vals::AbstractArray;
    maxwidth::Int  = 0,
    maxheight::Int = 0,
    title = "Sparsity Pattern",
    out_stream::Union{Nothing,IO} = nothing,
    width::Int  = 0,
    height::Int = 0,
    margin::Int  = 3,
    padding::Int = 1,
    color::UserColorType = :auto,
    canvas::Type{T} = BrailleCanvas,
    show_zeros::Bool = false,
    fix_ar::Bool = false,
    kw...
) where {T <: Canvas}
    if color == :automatic
        Base.depwarn("`color = :automatic` is deprecated, use `color = :auto` instead", :spy)
        color = :auto
    end
    width, height = get_canvas_dimensions_for_matrix(
        canvas, nrow, ncol, maxwidth, maxheight,
        width, height, margin, padding, out_stream, fix_ar;
        extra_rows = 9, extra_cols = 6
    )
    can = T(width, height, width  = 1. + ncol, height = 1. + nrow)
    plot = Plot(can; title = title, margin = margin, padding = padding, kw...)

    if color != :auto
        points!(plot, cols, nrow + 1 .- rows, color)
        label!(plot, :r, 1, show_zeros ? "= 0" : "≠ 0", color)
    else
        if show_zeros
            points!(plot, cols, nrow + 1 .- rows, :green)
            label!(plot, :r, 1, "= 0", :green)
        else
            pos_idx = vals .> 0
            neg_idx = (!).(pos_idx)
            pos_cols = cols[pos_idx]
            pos_rows = rows[pos_idx]
            neg_cols = cols[neg_idx]
            neg_rows = rows[neg_idx]
            points!(plot, pos_cols, nrow + 1 .- pos_rows, :red)
            points!(plot, neg_cols, nrow + 1 .- neg_rows, :blue)
            label!(plot, :r, 1, "> 0", :red)
            label!(plot, :r, 2, "< 0", :blue)
        end
    end
    label!(plot, :l, 1, "1", :light_black)
    label!(plot, :l, nrows(plot.graphics), string(nrow), :light_black)
    label!(plot, :bl, "1", :light_black)
    label!(plot, :br, string(ncol), :light_black)
    haskey(kw, :xlabel) || xlabel!(plot, string(length(vals), show_zeros ? " zeros" : " nonzeros"))
    plot
end

function _findnz(A::AbstractMatrix)
    I = findall(!iszero, A)
    getindex.(I, 1), getindex.(I, 2), A[I]
end

_findnz(A::AbstractSparseMatrix) = findnz(A)
