"""
    spy(A; kw...)

# Description

Plots the sparsity pattern for the given matrix `A`. This means
that a scatterplot that resembles the matrix is drawn, in which
only the pixel for non-zero elements of the matrix are set.

If the parameters `width` and `height` are not explicitly
specified, then the function will attempt to preserve the aspect
ratio of the matrix, while also attempting to fit the resulting
plot withing the bounding box specified by `maxwidth` and `maxheight`.

# Usage

    spy(A; $(keywords((maxwidth = 0, maxheight = 0, zeros = false); add=(:fix_ar, :canvas))))

# Arguments

$(arguments(
    (
        A = "matrix of interest for which non-zero elements should be drawn",
        maxheight = "maximum number of character rows that should be used for plotting",
        maxwidth = "maximum number of characters per row that should be used for plotting",
        height = "exact number of character rows that should be used for plotting (`0` stands for automatic)",
        width = "exact number of characters per row that should be used for plotting (`0` stands for automatic)",
        show_zeros = "show zeros pattern instead of default nonzeros",
    ); add=(:fix_ar, :canvas),
))

# Author(s)

- Dominique Orban (github.com/dpo)
- Christof Stocker (github.com/Evizero)
- Jake Bolewski (github.com/jakebolewski)

# Examples

```julia-repl
julia> using SparseArrays
julia> spy(sprandn(50, 120, .05))
      ┌────────────────────────────────────────────────────────────┐    
    1 │⡀⠨⠂⠀⠠⠀⠠⠀⠀⠀⠂⠀⡀⠂⠀⠀⠰⠈⠈⠂⡀⠀⠀⠀⠀⠐⠀⡀⡀⠀⠀⢄⡀⠀⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢄⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠐⠴⠄│ > 0
      │⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠠⠄⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢀⠀⡀⠀⠄⠘⠀⠀⡀⠀⠀⠀⠂⠠⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀│ < 0
      │⠂⠀⠀⠀⠐⠐⠀⠂⠀⡀⠐⢀⠀⠀⠀⠀⡀⠀⠈⠀⠄⠀⠀⠨⠀⠀⠀⠀⠀⠠⠀⢀⠀⠀⠉⠐⠄⠄⠀⠔⠀⠀⠂⠀⢐⠀⠀⠀⡀⠘⢀⠀⠁⠄⠀⠠⠀⠄⠀⠄│    
      │⠀⢀⠀⠀⠀⠀⠀⠠⠀⠂⠀⠄⠀⠘⠈⠌⢀⠀⠀⠀⠐⠀⠁⠀⠀⠀⢀⠀⠀⠠⠀⠁⠄⠀⠀⠀⠂⢀⠀⠀⠀⠀⢀⡁⠀⠀⠂⠠⠀⠀⠀⠀⠀⠊⠁⠀⠀⠀⠀⠄│    
      │⠀⠅⠀⠀⠀⠀⢄⠈⠄⠠⠈⠀⠀⠀⠀⡀⠀⢀⠠⠀⠀⠀⠁⠀⠀⡀⠃⠀⠀⠈⠈⠁⠀⠁⠠⢀⠀⢁⠀⠀⢀⠀⠀⠀⢀⠀⠠⠂⠀⠁⢁⠀⠂⠀⠀⠆⠌⠀⠀⠀│    
      │⠀⠀⠔⠀⠀⠀⠀⢀⠀⠁⢀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⡀⠀⠀⠀⡀⠀⠈⠀⠀⠀⡁⠁⠀⠀⠀⠠⠀⠀⠀⠄⡀⠀⠀⠀⠊⠀⠀⠄⠀⠀⠀⠀⠀⠀⠠⠀⠀⠄⠀│    
      │⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠅⠄⡀⠀⠀⢂⠂⠄⠑⠀⠀⠀⢄⠀⠀⠠⠂⠁⡀⠀⢠⠈⠀⠂⠀⠀⠄⠀⠀⠀⠄⠀⠀⠃⠂⠀⠄⢀⠀⠀⠀⠀⠀⠀⠀│    
      │⠀⠐⠀⠀⠂⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠌⠀⠂⠀⠀⠀⠀⡀⢁⠁⠨⠀⠀⠀⠂⠀⠀⠨⠀⠁⠀⠀⠀⠀⠀⠊⠀⠄⠀⠀⠁⠐⠠⠀⢀⠀⠀⠀⠈⠀⠀⠁⠐⠄⠄│    
      │⢉⠀⢀⠁⠀⠀⠀⠀⠈⠀⠀⠀⠀⠁⠀⠠⠀⠀⠁⠀⠀⠀⡠⠁⠀⠀⠀⠀⠉⠠⡀⠀⠀⠀⢀⡀⠄⠀⠀⠀⠄⠀⠀⠈⠄⠀⠑⠀⠀⠀⠀⠀⠀⠠⠀⡀⡀⠀⠀⠀│    
      │⠅⠈⠈⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⡄⠀⠀⠄⠀⠀⠠⠀⠀⠠⠈⠀⠂⠢⠈⠀⠀⠀⠄⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠠⠀⠀⠀⠀⠀⠀⢀⠤⠀⠀⠀⠀│    
      │⠀⠀⠀⠂⠁⠀⠀⠀⠀⠁⠀⠘⠀⠂⢠⠀⠀⠀⠀⠀⢃⠀⠐⠈⠄⠐⠀⠀⠀⢀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⡀⠀⡀⠀⠀⠁⠀⠁⠀⠁⠠⠔⠀⢁⡀│    
   50 │⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠈⠀⠂⠠⠀⠀⠀⠖⠀⠀⠀⠈⠀⠀⠀⠀⠀⡀⠠⠀⢀⠀⠅⠀⠀⠐⠀⠀⠀⠀⠠⠀⠠⠀⠀⢀⠀│    
      └────────────────────────────────────────────────────────────┘    
      ⠀1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀120⠀    
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀315 ≠ 0⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀    
```

# See also

[`Plot`](@ref), [`scatterplot`](@ref),
[`BrailleCanvas`](@ref), [`BlockCanvas`](@ref),
[`AsciiCanvas`](@ref), [`DotCanvas`](@ref)
"""
function spy(A::AbstractMatrix; kw...)
    rows, cols, vals = _strict_non_zeros(_findnz(A)...)
    if get(kw, :show_zeros, false)
        I = CartesianIndex.(zip(rows, cols))  # non zeros
        mask = trues(size(A))
        mask[I] .= false
        Z = CartesianIndices(axes(A))[mask]  # zeros
        rows, cols = getindex.(Z, 1), getindex.(Z, 2)
        vals = zeros(eltype(vals), length(rows))
    end
    spy(size(A)..., rows, cols, vals; kw...)
end

_strict_non_zeros(rows, cols, vals) =
    let I = findall(!iszero, vals)  # findnz(A) returns stored zeros, ignore those
        rows[I], cols[I], vals[I]
    end

function spy(
    nrow::Integer,
    ncol::Integer,
    rows::AbstractArray{<:Integer},
    cols::AbstractArray{<:Integer},
    vals::AbstractArray;
    maxwidth::Integer = 0,
    maxheight::Integer = 0,
    out_stream::Union{Nothing,IO} = nothing,
    height::Union{Nothing,Integer} = nothing,
    width::Union{Nothing,Integer} = nothing,
    margin::Integer = KEYWORDS.margin,
    padding::Integer = KEYWORDS.padding,
    color::UserColorType = KEYWORDS.color,
    canvas::Type{<:Canvas} = KEYWORDS.canvas,
    fix_ar::Bool = KEYWORDS.fix_ar,
    show_zeros::Bool = false,
    kw...,
)
    pkw, okw = split_plot_kw(; kw...)
    warn_on_lost_kw(; okw...)

    height, width = get_canvas_dimensions_for_matrix(
        canvas,
        nrow,
        ncol,
        maxheight,
        maxwidth,
        height,
        width,
        margin,
        padding,
        out_stream,
        fix_ar;
        extra_rows = 9,
        extra_cols = 6,
    )

    can = canvas(height, width; height = 1.0 + nrow, width = 1.0 + ncol)
    plot = Plot(can; margin, padding, pkw...)

    if color ≢ :auto
        points!(plot, cols, nrow + 1 .- rows, color)
        label!(plot, :r, 1, show_zeros ? "⩵ 0" : "≠ 0", color)
    else
        if show_zeros
            points!(plot, cols, nrow + 1 .- rows, :green)
            label!(plot, :r, 1, "⩵ 0", :green)
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
    bc = BORDER_COLOR[]
    label!(plot, :l, 1, "1", bc)
    label!(plot, :l, nrows(plot.graphics), nice_repr(nrow, plot), bc)
    label!(plot, :bl, "1", bc)
    label!(plot, :br, nice_repr(ncol, plot), bc)
    isempty(xlabel(plot)) &&
        xlabel!(plot, nice_repr(length(vals), plot) * (show_zeros ? " ⩵ 0" : " ≠ 0"))
    plot
end

_findnz(A::AbstractMatrix) =
    let I = findall(!iszero, A)
        getindex.(I, 1), getindex.(I, 2), A[I]
    end

_findnz(A::AbstractSparseMatrix) = findnz(A)
