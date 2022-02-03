"""
    heatmap(A; kw...)

# Description

Draws a heatmap for the given points.
It uses the `Matrix` `A` as the values of the heatmap, with the column and row indices of the matrix
as x and y coordinates respectively.

# Usage

    heatmap(A::AbstractMatrix; $(keywords((width = 0, height = 0, xfact = 0, yfact = 0); add = (Z_DESCRIPTION..., :fix_ar)))

# Arguments

$(arguments(
    (
        A = "input matrix (color values)",
        xfact = "scale for the `x` coordinate (defaults to 0 - i.e. each column in `A` maps to one unit, `x` origin starting at 1). If set to anything else, the x origin will start at 0",
        yfact = "scale for the `y` coordinate labels (defaults to 0 - i.e. each row in `A` maps to one unit, `y` origin starting at 1). If set to anything else, the y origin will start at 0",
        xoffset = "plotting offset for the `x` coordinate (after scaling)",
        yoffset = "plotting offset for the `y` coordinate (after scaling)",
    ); add = (Z_DESCRIPTION..., :fix_ar)
))

# Returns

A plot object of type `Plot{HeatmapCanvas}`.

# Author(s)

- Rowan Katekar (github.com/rjkat)

# See also

`Plot`, `scatterplot`, `HeatmapCanvas`
"""
function heatmap(
    A::AbstractMatrix;
    xlim = KEYWORDS.xlim,
    ylim = KEYWORDS.ylim,
    zlim = KEYWORDS.zlim,
    xoffset = 0.0,
    yoffset = 0.0,
    out_stream::Union{Nothing,IO} = nothing,
    width::Int = 0,
    height::Int = 0,
    margin::Int = KEYWORDS.margin,
    padding::Int = KEYWORDS.padding,
    colormap = KEYWORDS.colormap,
    xfact = 0,
    yfact = 0,
    labels = true,
    fix_ar::Bool = false,
    kw...,
)
    nrows = size(A, 1)
    ncols = size(A, 2)

    # if scale is auto, use the matrix indices as axis labels
    # otherwise, start axis labels at zero
    X = xfact == 0 ? collect(1:ncols) : collect(0:(ncols - 1)) .* xfact
    X .+= xoffset
    xfact == 0 && (xfact = 1)
    Y = yfact == 0 ? collect(1:nrows) : collect(0:(nrows - 1)) .* yfact
    Y .+= yoffset
    yfact == 0 && (yfact = 1)

    # set the axis limits automatically
    if xlim == (0, 0) && length(X) > 0
        xlim = extrema(X)
    end
    if ylim == (0, 0) && length(Y) > 0
        ylim = extrema(Y)
    end

    # select a subset of A based on the supplied limits
    firstx = findfirst(x -> x >= xlim[1], X)
    lastx = findlast(x -> x <= xlim[2], X)
    xrange = (firstx == nothing || lastx == nothing) ? (1:0) : (firstx:lastx)
    firsty = findfirst(y -> y >= ylim[1], Y)
    lasty = findlast(y -> y <= ylim[2], Y)
    yrange = (firsty == nothing || lasty == nothing) ? (1:0) : (firsty:lasty)
    A = A[yrange, xrange]
    X = X[xrange]
    Y = Y[yrange]

    # allow A to be an array over which min and max is not defined,
    # e.g. an array of RGB color values
    minz, maxz = (0, 0)
    noextrema = true
    try
        minz, maxz = extrema(A)
        noextrema = false
    catch
    end
    if zlim != (0, 0)
        noextrema &&
            throw(ArgumentError("zlim cannot be set when the element type is $(eltype(A))"))
        minz, maxz = zlim
    end

    # if A is an rgb image, translate the colors directly to the terminal
    callback = if length(A) > 0 && all(x -> x in fieldnames(eltype(A)), [:r, :g, :b])
        (A, minz, maxz) -> rgbimgcolor(A)
    else
        colormap_callback(colormap)
    end

    nrows = ceil(Int, (ylim[2] - ylim[1]) / yfact) + 1
    ncols = ceil(Int, (xlim[2] - xlim[1]) / xfact) + 1
    data_ar = ncols / nrows  # data aspect ratio

    max_width = width == 0 ? (height == 0 ? 0 : ceil(Int, height * data_ar)) : width
    max_height = height == 0 ? (width == 0 ? 0 : ceil(Int, width / data_ar)) : height

    # 2nrows: compensate nrows(c::HeatmapCanvas) = div(size(grid(c), 2) + 1, 2)
    width, height, max_width, max_height = get_canvas_dimensions_for_matrix(
        HeatmapCanvas,
        2nrows,
        ncols,
        max_width,
        max_height,
        width,
        height,
        margin,
        padding,
        out_stream,
        fix_ar,
    )

    colorbar = if height < 7
        # for small plots, don't show colorbar by default
        !noextrema && get(kw, :colorbar, false)
    else
        # show colorbar by default, unless set to false, or labels == false
        !noextrema && get(kw, :colorbar, labels)
    end
    kw = (; kw..., colorbar = colorbar)

    xs = length(X) > 0 ? [X[1], X[end]] : Float64[0, 0]
    ys = length(Y) > 0 ? [Y[1], Y[end]] : Float64[0, 0]
    plot = Plot(
        xs,
        ys,
        HeatmapCanvas;
        grid = false,
        colormap = callback,
        colorbar = colorbar,
        colorbar_lim = (minz, maxz),
        ylim = ylim,
        xlim = xlim,
        labels = labels,
        width = width,
        height = height,
        min_width = 1,
        min_height = 1,
        kw...,
    )

    for row in 1:length(Y)
        points!(
            plot,
            X,
            fill(Y[row], length(X)),
            UserColorType[callback(v, minz, maxz) for v in A[row, :]],
        )
    end
    plot
end
