"""
`heatmap(z; nargs...)` → `Plot`

Description
============

Draws a heatmap for the given points.
It uses the parameter `z` (which should be a matrix)
as the z value of the heatmap, with the column and row indices of the matrix
as x and y coordinates respectively.

Usage
======

    heatmap(z::AbstractMatrix; title = "", out_stream::Union{Nothing,IO} = nothing, width = 0, height = 0,
            xlabel = "", ylabel = "", zlabel = "", labels = true,
            border = :solid, colormap = :viridis, colorbar_border = :solid, colorbar = :true,
            xfact = 0, yfact = 0, xlim = (0, 0), ylim = (0, 0), zlim = (0, 0),
            xoffset = 0.0, yoffset = 0.0, margin = 3, padding = 1)

Arguments
==========

- **`z`** : The z value for each point.

- **`title`** : Text to display on the top of the plot.

- **`xlabel`** : x-axis label

- **`ylabel`** : y-axis label

- **`zlabel`** : z-axis (colorbar) label

- **`width`** : Number of characters per row that should be used for plotting.

- **`height`** : Number of rows that should be used for plotting. Not applicable to `barplot`.

- **`border`** : The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`colormap`** : The colormap to use for the heatmap. Supports `:viridis`, `:plasma`, `:magma`, and `:inferno`.
                   Alternatively, supply a function `f: z, zmin, zmax -> terminal color (Int)`,
                   or a vector of RGB vectors in the format shown [here](https://github.com/BIDS/colormap/blob/master/colormaps.py).

- **`colorbar_border`** : The style of the bounding box of the color bar. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`.

- **`xfact`** : Scale for the x coordinate. Defaults to 0 - i.e. each column in `z` corresponds to one unit, x origin starting at 1. If set to anything else, the x origin will start at 0.

- **`yfact`** : Scale for the y coordinate labels. Defaults to 0 - i.e. each row in `z` corresponds to one unit, y origin starting at 1. If set to anything else, the y origin will start at 0.

- **`xlim`** : Plotting range for the x coordinate (after scaling). `(0, 0)` stands for automatic.

- **`ylim`** : Plotting range for the y coordinate (after scaling). `(0, 0)` stands for automatic.

- **`zlim`** : Data range that the colormap is scaled to. `(0, 0)` stands for automatic.

- **`xoffset`** : Plotting offset for the x coordinate (after scaling).

- **`yoffset`** : Plotting offset for the y coordinate (after scaling).

- **`margin`** : Number of empty characters to the left of the whole plot.

- **`padding`** : Space of the left and right of the plot between the labels and the canvas.

- **`labels`** : Can be used to hide the labels by setting `labels=false`.

Returns
========

A plot object of type `Plot{HeatmapCanvas}`

Author(s)
==========

- Rowan Katekar (https://github.com/rjkat)


See also
=========

`Plot`, `scatterplot`, `HeatmapCanvas`
"""
function heatmap(
    A::AbstractMatrix; xlim = (0, 0), ylim = (0, 0), zlim = (0, 0), xoffset = 0., yoffset = 0.,
    out_stream::Union{Nothing,IO} = nothing, width::Int = 0, height::Int = 0, margin::Int = 3,
    padding::Int = 1, colormap = :viridis, xfact = 0, yfact = 0, labels = true, kw...
)
    nr = size(A, 1)
    nc = size(A, 2)

    # if scale is auto, use the matrix indices as axis labels
    # otherwise, start axis labels at zero
    X = xfact == 0 ? collect(1:nc) : collect(0:(nc-1)) .* xfact
    X .+= xoffset
    xfact == 0 && (xfact = 1)
    Y = yfact == 0 ? collect(1:nr) : collect(0:(nr-1)) .* yfact
    Y .+= yoffset
    yfact == 0 && (yfact = 1)

    # set the axis limits automatically
    (xlim == (0, 0) && length(X) > 0) && (xlim = extrema(X))
    (ylim == (0, 0) && length(Y) > 0) && (ylim = extrema(Y))

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
    minz, maxz = 0, 0
    noextrema = true
    try
        minz, maxz = extrema(A)
        noextrema = false
    catch
    end
    if zlim != (0, 0)
        noextrema && throw(ArgumentError("zlim cannot be set when the element type is $(eltype(A))"))
        minz, maxz = zlim
    end

    # if A is an rgb image, translate the colors directly to the terminal
    if length(A) > 0 && all(x -> x in fieldnames(eltype(A)), [:r, :g, :b])
        colormap = (A, minz, maxz) -> rgbimgcolor(A)
    elseif colormap isa Symbol
        cdata = COLOR_MAP_DATA[colormap]
        colormap = (A, minz, maxz) -> heatmapcolor(A, minz, maxz, cdata)
    elseif typeof(colormap) <: AbstractVector
        cdata = colormap
        colormap = (A, minz, maxz) -> heatmapcolor(A, minz, maxz, cdata)
    end

    nr = ceil(Int, (ylim[2] - ylim[1]) / yfact) + 1
    nc = ceil(Int, (xlim[2] - xlim[1]) / xfact) + 1
    aspect_ratio = nc / nr

    max_width = width == 0 ? (height == 0 ? 0 : ceil(Int, height * aspect_ratio)) : width
    max_height = height == 0 ? (width == 0 ? 0 : ceil(Int, width / aspect_ratio)) : height

    width, height, max_width, max_height, data_aspect = get_canvas_dimensions_for_matrix(
        HeatmapCanvas, nr, nc, max_width, max_height, width, height, margin, padding, out_stream
    )

    # ensure plot is big enough
    if data_aspect && aspect_ratio == 1  # square matrix should remain as is
        min_side = min(max_height, max_width)
        height = min(min_side, max(height, nr))
        width = min(min_side, max(width, nc))
    else
        height = min(max_height, max(height, nr))
    end

    colorbar = if height < 7
        # for small plots, don't show colorbar by default
        !noextrema && get(kw, :colorbar, false)
    else
        # show colorbar by default, unless set to false, or labels == false
        !noextrema && get(kw, :colorbar, labels)
    end
    kw = (; kw..., colorbar=colorbar)

    xs = length(X) > 0 ? [X[1], X[end]] : eltype(X)[0, 0]
    ys = length(Y) > 0 ? [Y[1], Y[end]] : eltype(Y)[0, 0]

    plot = Plot(
        xs, ys, HeatmapCanvas;
        grid = false, colormap = colormap, colorbar = colorbar, colorbar_lim = (minz, maxz),
        ylim = ylim, xlim = xlim, labels = labels, width = width, height = height,
        min_width = 1, min_height = 1, kw...
    )
    for row = 1:length(Y)
        Z = Int[colormap(vec, minz, maxz) for vec in A[row, :]]
        Y′ = repeat([Y[row]], length(X))
        points!(plot, X, Y′, Z)
    end
    plot
end
