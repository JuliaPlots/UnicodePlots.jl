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

    heatmap(z::AbstractMatrix; title = "", width = 0, height = 0,
            xlabel = "", ylabel = "", zlabel = "", labels = true,
            border = :solid, colormap = :viridis, colorbar_border = :solid, show_colorbar = :true,
            xscale = 0.0, yscale = 0.0, xlim = [0, 0], ylim = [0, 0],
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

- **`xscale`** : Scale for the x coordinate. Defaults to 0 - i.e. each column in `z` corresponds to one unit, x origin starting at 1. If set to anything else, the x origin will start at 0.

- **`yscale`** : Scale for the y coordinate labels. Defaults to 0 - i.e. each row in `z` corresponds to one unit, y origin starting at 1. If set to anything else, the y origin will start at 0.

- **`xlim`** : Plotting range for the x coordinate (after scaling). `[0, 0]` stands for automatic.

- **`ylim`** : Plotting range for the y coordinate (after scaling). `[0, 0]` stands for automatic.

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
function heatmap(z::AbstractMatrix; xlim = (0., 0.), ylim = (0., 0.), xoffset = 0., yoffset = 0., width::Int = 0, height::Int = 0, margin::Int = 3, padding::Int = 1, colormap=:viridis, xscale=0.0, yscale=0.0, labels = true, kw...)
    nrows = size(z, 1)
    ncols = size(z, 2)

    # if scale is auto, use the matrix indices as axis labels
    # otherwise, start axis labels at zero
    X = xscale == 0.0 ? collect(1:ncols) : collect(0:(ncols-1)) .* xscale
    X .+= xoffset
    xscale = xscale == 0.0 ? 1 : xscale
    Y = yscale == 0.0 ? collect(1:nrows) : collect(0:(nrows-1)) .* yscale
    Y .+= yoffset
    yscale = yscale == 0.0 ? 1 : yscale

    # set the axis limits automatically
    if xlim == (0, 0) && length(X) > 0
        xlim = extrema(X)
    end
    if ylim == (0, 0) && length(Y) > 0
        ylim = extrema(Y)
    end

    # select a subset of z based on the supplied limits
    firstx = findfirst(x -> x >= xlim[1], X)
    lastx = findlast(x -> x <= xlim[2], X)
    xrange = (firstx == nothing || lastx == nothing) ? (1:0) : (firstx:lastx)
    firsty = findfirst(y -> y >= ylim[1], Y)
    lasty = findlast(y -> y <= ylim[2], Y)
    yrange = (firsty == nothing || lasty == nothing) ? (1:0) : (firsty:lasty)
    z = z[yrange, xrange]
    X = X[xrange]
    Y = Y[yrange]

    # allow z to be an array over which min and max is not defined,
    # e.g. an array of RGB color values
    minz, maxz = (0, 0)
    noextrema = true
    try
        minz, maxz = extrema(z)
        noextrema = false
    catch
    end

    # if z is an rgb image, translate the colors directly to the terminal
    if length(z) > 0 && all(x -> x in fieldnames(eltype(z)), [:r, :g, :b])
        colormap = (z, minz, maxz) -> rgbimgcolor(z)
    elseif colormap isa Symbol
        cdata = COLOR_MAP_DATA[colormap]
        colormap = (z, minz, maxz) -> heatmapcolor(z, minz, maxz, cdata)
    elseif typeof(colormap) <: AbstractVector
        cdata = colormap
        colormap = (z, minz, maxz) -> heatmapcolor(z, minz, maxz, cdata)
    end

    nrows = ceil(Int, (ylim[2] - ylim[1]) / yscale) + 1
    ncols = ceil(Int, (xlim[2] - xlim[1]) / xscale) + 1
    aspect_ratio = ncols / nrows

    max_width = width == 0 ? (height == 0 ? 0 : ceil(Int, height * aspect_ratio)) : width
    max_height = height == 0 ? (width == 0 ? 0 : ceil(Int, width / aspect_ratio)) : height
    width, height, max_width, max_height = get_canvas_dimensions_for_matrix(
        HeatmapCanvas, nrows, ncols, max_width, max_height, width, height, margin, padding
    )

    # ensure plot height is big enough
    height = min(max_height, max(height, nrows))

    # for small plots, don't show colorbar by default
    if height < 7
        show_colorbar = !noextrema && get(kw, :colorbar, false)
    # show colorbar by default, unless set to false, or labels == false
    else
        show_colorbar = !noextrema && get(kw, :colorbar, labels)
    end

    xs = length(X) > 0 ? [X[1], X[end]] : Float64[0., 0.]
    ys = length(Y) > 0 ? [Y[1], Y[end]] : Float64[0., 0.]
    new_plot = Plot(xs, ys, HeatmapCanvas;
                    grid = false, colorbar = show_colorbar,
                    colormap = colormap, colorbar_lim = (minz, maxz),
                    ylim = ylim, xlim = xlim, labels = labels,
                    width = width, height = height, min_width = 1, min_height = 1,
                    kw...)
    for row = 1:length(Y)
        Z = Int[colormap(zi, minz, maxz) for zi in z[row, :]]
        points!(new_plot, X, repeat([Y[row]], length(X)), Z)
    end
    new_plot
end

