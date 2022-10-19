"""
    heatmap(A; kw...)

# Description

Draws a heatmap for the given points.
It uses the `Matrix` `A` as the values of the heatmap, with the column and row indices
of the matrix as `x` and `y` coordinates respectively.

# Usage

    heatmap(A::AbstractMatrix; $(keywords((height = 0, width = 0, yfact = nothing, xfact = nothing, array = false); add = (Z_DESCRIPTION..., :fix_ar))))

# Arguments

$(arguments(
    (
        A = "input matrix (color values)",
        yfact = "scale for the `y` coordinate labels (defaults to 0 - i.e. each row in `A` maps to one unit, `y` origin starting at 1). If set to anything else, the y origin will start at 0",
        xfact = "scale for the `x` coordinate (defaults to 0 - i.e. each column in `A` maps to one unit, `x` origin starting at 1). If set to anything else, the x origin will start at 0",
        yoffset = "plotting offset for the `y` coordinate (after scaling)",
        xoffset = "plotting offset for the `x` coordinate (after scaling)",
        array = "use array display convention (origin at the North-West corner of the plot, hence flipping `y` versus regular plots)"
    ); add = (Z_DESCRIPTION..., :fix_ar)
))

# Author(s)

- Rowan Katekar (github.com/rjkat)

# Examples

```julia-repl
julia> heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
      ┌───────────┐         
   11 │▄▄▄▄▄▄▄▄▄▄▄│  ┌──┐ 10
      │▄▄▄▄▄▄▄▄▄▄▄│  │▄▄│   
      │▄▄▄▄▄▄▄▄▄▄▄│  │▄▄│   
      │▄▄▄▄▄▄▄▄▄▄▄│  │▄▄│ z 
      │▄▄▄▄▄▄▄▄▄▄▄│  │▄▄│   
    1 │▄▄▄▄▄▄▄▄▄▄▄│  └──┘ 0 
      └───────────┘         
       1        11          
```

# See also

`Plot`, `HeatmapCanvas`
"""
function heatmap(
    A::AbstractMatrix{T};
    xlim = KEYWORDS.xlim,
    ylim = KEYWORDS.ylim,
    zlim = KEYWORDS.zlim,
    yoffset::Number = 0.0,
    xoffset::Number = 0.0,
    out_stream::Union{Nothing,IO} = nothing,
    height::Union{Nothing,Integer} = nothing,
    width::Union{Nothing,Integer} = nothing,
    margin::Integer = KEYWORDS.margin,
    padding::Integer = KEYWORDS.padding,
    colormap = KEYWORDS.colormap,
    yfact::Union{Nothing,Number} = nothing,
    xfact::Union{Nothing,Number} = nothing,
    fix_ar::Bool = KEYWORDS.fix_ar,
    labels::Bool = KEYWORDS.labels,
    array::Bool = false,
    kw...,
) where {T}
    pkw, okw = split_plot_kw(; kw...)
    warn_on_lost_kw(; okw...)

    nrows, ncols = size(A)

    # if scale is auto, use the matrix indices as axis labels
    # otherwise, start axis labels at zero
    Y = if yfact ≡ nothing
        collect(1:nrows)
    else
        collect(0:(nrows - 1)) .* yfact
    end .+ yoffset
    X = if xfact ≡ nothing
        collect(1:ncols)
    else
        collect(0:(ncols - 1)) .* xfact
    end .+ xoffset

    # set the axis limits automatically
    autolims(lims, vec) = is_auto(lims) && length(vec) > 0 ? extrema(vec) : lims

    ylim = autolims(ylim, Y)
    xlim = autolims(xlim, X)

    # select a subset of A based on the supplied limits
    subset(lims, vec) = begin
        first = findfirst(x -> x ≥ lims[1], vec)
        last = findlast(x -> x ≤ lims[2], vec)
        (first ≡ nothing || last ≡ nothing) ? (1:0) : (first:last)
    end

    yrange = subset(ylim, Y)
    xrange = subset(xlim, X)
    Y = Y[yrange]
    X = X[xrange]
    A = A[yrange, xrange]

    nrows = ceil(Int, (ylim[2] - ylim[1]) / something(yfact, 1)) + 1
    ncols = ceil(Int, (xlim[2] - xlim[1]) / something(xfact, 1)) + 1

    # allow A to be an array over which min and max is not defined,
    # e.g. an array of RGB color values
    minz, maxz = (0, 0)
    has_extrema = false
    try
        minz, maxz = extrema(A)
        has_extrema = true
    catch
    end
    if !is_auto(zlim)
        has_extrema ||
            throw(ArgumentError("`zlim` cannot be set when the element type is $T"))
        minz, maxz = zlim
    end

    # if A is an rgb image, translate the colors directly to the terminal
    callback =
        if length(A) > 0 && isconcretetype(T) && all(x -> x ∈ fieldnames(T), (:r, :g, :b))
            (A, minz, maxz) -> ansi_color(c256.((A.r, A.g, A.b)))
        else
            colormap_callback(colormap)
        end

    data_ar = ncols / nrows  # data aspect ratio

    max_width = if width ≡ nothing
        height ≡ nothing ? 0 : ceil(Int, height * data_ar)
    else
        width
    end
    max_height = if height ≡ nothing
        width ≡ nothing ? 0 : ceil(Int, width / data_ar)
    else
        height
    end

    # `2nrows`: compensate nrows(c::HeatmapCanvas) = div(size(c.grid, 1) + 1, 2)
    height, width, max_height, max_width = get_canvas_dimensions_for_matrix(
        HeatmapCanvas,
        2nrows,
        ncols,
        max_height,
        max_width,
        height,
        width,
        margin,
        padding,
        out_stream,
        fix_ar,
    )

    colorbar = has_extrema && if height < 7
        # for small plots, don't show colorbar by default
        get(kw, :colorbar, false)
    else
        # show colorbar by default, unless set to false, or labels == false
        get(kw, :colorbar, labels)
    end

    xs = length(X) > 0 ? [first(X), last(X)] : zeros(2)
    ys = length(Y) > 0 ? [first(Y), last(Y)] : zeros(2)

    plot = Plot(
        xs,
        ys,
        nothing,
        HeatmapCanvas;
        grid = false,
        colormap = callback,
        colorbar = colorbar,
        colorbar_lim = (minz, maxz),
        ylim = ylim,
        xlim = xlim,
        labels = labels,
        height = height,
        width = width,
        min_height = 1,
        min_width = 1,
        yflip = array,
        filter(x -> x.first ≢ :colorbar, pairs(pkw))...,
    )

    for row ∈ eachindex(Y)
        points!(
            plot,
            X,
            fill(Y[row], length(X)),
            UserColorType[callback(v, minz, maxz) for v ∈ A[row, :]],
        )
    end
    plot
end
