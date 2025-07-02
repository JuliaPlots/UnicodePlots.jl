# Interface

## Line plots: `lineplot`
```@example lineplot
using UnicodePlots  # hide
lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot")
```

It's also possible to specify a function and a range:
```@example lineplot
plt = lineplot(-π/2, 2π, [cos, sin])
```

You can also plot lines by specifying an intercept and slope:
```@example lineplot
lineplot!(plt, -.5, .2, name="line")
```

Plotting multiple series is supported by providing a `Matrix` (`<: AbstractMatrix`) for the `y` argument, with the individual series corresponding to its columns. Auto-labeling is by default, but you can also label each series by providing a `Vector` or a `1xn` `Matrix` such as `["series 1" "series2" ...]`:
```@example lineplot
lineplot(1:10, [0:9 3:12 reverse(5:14) fill(4, 10)], color=[:green :red :yellow :cyan])
```

Physical quantities of [`Unitful.jl`](https://github.com/PainterQubits/Unitful.jl) are supported through [package extensions - weak dependencies](https://pkgdocs.julialang.org/dev/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)):
```@example lineplot
using Unitful
a, t = 1u"m/s^2", (0:100) * u"s"
lineplot(a / 2 * t .^ 2, a * t, xlabel="position", ylabel="speed", height=10)
```
Intervals from [`IntervalSets.jl`](https://github.com/JuliaMath/IntervalSets.jl) are supported:

```@example lineplot
using IntervalSets
lineplot(-1..3, x -> x^5 - 5x^4 + 5x^3 + 5x^2 - 6x - 1; name="quintic")
```

Use `head_tail` to mimic plotting arrows (`:head`, `:tail` or `:both`) where the length of the "arrow" head or tail is controlled using `head_tail_frac` where e.g. giving a value of `0.1` means `10%` of the segment length:
```@example lineplot
lineplot(1:10, 1:10, head_tail=:head, head_tail_frac=.1, height=4)
```

`UnicodePlots` exports `hline!` and `vline!` for drawing vertical and horizontal lines on a plot:
```@example lineplot
plt = Plot([NaN], [NaN]; xlim=(0, 8), ylim=(0, 8))
vline!(plt, [2, 6], [2, 6], color=:red)
hline!(plt, [2, 6], [2, 6], color=:white)
hline!(plt, 7, color=:cyan)
vline!(plt, 1, color=:yellow)
```

## Scatter plots: `scatterplot`
```@example scatterplot
using UnicodePlots  # hide
scatterplot(randn(50), randn(50), title="My Scatterplot")
```

Axis scaling (`xscale` and/or `yscale`) is supported: choose from (`:identity`, `:ln`, `:log2`, `:log10`) or use an arbitrary scale function:
```@example scatterplot
scatterplot(1:10, 1:10, xscale=:log10, yscale=:log10)
```

For the axis scale exponent, one can revert to using `ASCII` characters instead of `Unicode` ones using the keyword `unicode_exponent=false`:
```@example scatterplot
scatterplot(1:4, 1:4, xscale=:log10, yscale=:ln, unicode_exponent=false, height=6)
```

Using a `marker` is supported, choose a `Char`, a unit length `String` or a symbol name such as `:circle` (more from `keys(UnicodePlots.MARKERS)`).
  One can also provide a vector of `marker`s and/or `color`s as in the following example:
```@example scatterplot
scatterplot([1, 2, 3], [3, 4, 1], marker=[:circle, '', "∫"],
            color=[:cyan, nothing, :yellow], height=2)
```

As with `lineplot`, `scatterplot` supports plotting physical `Unitful` quantities, or plotting multiple series (`Matrix` argument).

## Staircase plots: `stairs`
```@example
using UnicodePlots  # hide
stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7],
       color=:yellow, style=:post, height=6, title="Staircase")
```

## Bar plots: `barplot`
```@example
using UnicodePlots  # hide
barplot(["Paris", "New York", "Madrid"], [2.244, 8.406, 3.165], title="Population")
```

Note: You can use the keyword argument `symbols` to specify the characters that should be used to plot the bars (e.g. `symbols=['#']`).

## Histogram plots: `histogram`
```@example histogram
using UnicodePlots  # hide
histogram(randn(1_000) .* .1, nbins=15, closed=:left)
```

The `histogram` function also supports axis scaling using the parameter `xscale`:
```@example histogram
histogram(randn(1_000) .* .1, nbins=15, closed=:right, xscale=:log10)
```

Vertical histograms are supported:
```@example histogram
histogram(randn(100_000) .* .1, nbins=60, vertical=true, height=10)
```

## Box plots: `boxplot`
```@example boxplot
using UnicodePlots  # hide
boxplot([1, 3, 3, 4, 6, 10])
```

```@example boxplot
boxplot(["one", "two"],
        [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
        title="Grouped Boxplot", xlabel="x")
```

## Sparsity pattern plots: `spy`
```@example spy
using UnicodePlots  # hide
using SparseArrays
spy(sprandn(50, 120, .05))
```

Plotting the zeros pattern is also possible using `show_zeros=true`:
```@example spy
using SparseArrays
spy(sprandn(50, 120, .9), show_zeros=true)
```

## Density plots: `densityplot`
```@example density
using UnicodePlots  # hide
plt = densityplot(randn(10_000), randn(10_000))
densityplot!(plt, randn(10_000) .+ 2, randn(10_000) .+ 2)
```

Using a scale function (e.g. for damping peaks) is supported using the `dscale` keyword:
```@example density
x = randn(10_000); x[1_000:6_000] .= 2
densityplot(x, randn(10_000); dscale=x -> log(1 + x))
```

## Contour plots: `contourplot`
```@example contour
using UnicodePlots  # hide
contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2))
```

The keyword `levels` controls the number of contour levels. One can also choose a `colormap` as with `heatmap`, and disable the colorbar using `colorbar=false`.

## Polar plots: `polarplot`
Plots data in polar coordinates with `θ` the angles in radians.

```@example polar
using UnicodePlots  # hide
polarplot(range(0, 2π, length=20), range(0, 2, length=20))
```

## Heatmap plots: `heatmap`
```@example heatmap
using UnicodePlots  # hide
heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
```

The `heatmap` function also supports axis scaling using the parameters `xfact`, `yfact` and axis offsets after scaling using `xoffset` and `yoffset`.

The `colormap` parameter may be used to specify a named or custom colormap. See the `heatmap` function documentation for more details.

In addition, the `colorbar` and `colorbar_border` options may be used to toggle the colorbar and configure its border.

The `zlabel` option and `zlabel!` method may be used to set the `z` axis (colorbar) label.

Use the `array` keyword in order to display the matrix in the array convention (as in the repl).

```@example heatmap
heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno)
```

## Image plots: `imageplot`
Draws an image, and surround it with decorations. `Sixel` are supported (experimental) under a compatible terminal through [`ImageInTerminal`](https://github.com/JuliaImages/ImageInTerminal.jl) (which must be imported before `UnicodePlots`).

```@example image
using UnicodePlots  # hide
import ImageInTerminal  # mandatory (triggers extension - weak dependency - loading)
using TestImages
imageplot(testimage("monarch_color_256"), title="monarch")
```

## Surface plots: `surfaceplot`
Plots a colored surface using height values `z` above a `x-y` plane, in three dimensions (masking values using `NaN`s is supported).

```@example surface
using UnicodePlots  # hide
sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
surfaceplot(-8:.5:8, -8:.5:8, sombrero, colormap=:jet)
```

Use `lines=true` to increase the density (underlying call to `lineplot` instead of `scatterplot`, with color interpolation).
By default, `surfaceplot` scales heights to adjust aspect wrt the remaining axes with `zscale=:aspect`.
To plot a slice in 3D, use an anonymous function which maps to a constant value: `zscale=z -> a_constant`:

```@example surface
surfaceplot(
  -2:2, -2:2, (x, y) -> 15sinc(√(x^2 + y^2) / π),
  zscale=z -> 0, lines=true, colormap=:jet
)
```

## Isosurface plots: `isosurface`
Uses [`MarchingCubes.jl`](https://github.com/JuliaGeometry/MarchingCubes.jl) to extract an isosurface, where `isovalue` controls the surface isovalue.
Using `centroid` enables plotting the triangulation centroids instead of the triangle vertices (better for small plots).
Back face culling (hide not visible facets) can be activated using `cull=true`.
One can use the legacy 'Marching Cubes' algorithm using `legacy=true`.

```@example isosurface
using UnicodePlots  # hide
torus(x, y, z, r=0.2, R=0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus, cull=true, zoom=2, elevation=50)
```

# Saving figures
Saving plots as `png` or `txt` files using the `savefig` command is supported (saving as `png` is experimental and requires `import FreeType, FileIO` before loading `UnicodePlots`).

To recover the plot as a string with ansi color codes use `string(p; color=true)`.

# Color mode
When the `COLORTERM` environment variable is set to either `24bit` or `truecolor`, `UnicodePlots` will use [24bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit) as opposed to [8bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) or even [4bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit) for named colors.

One can force a specific colormode using either `UnicodePlots.truecolors!()` or `UnicodePlots.colors256!()`.

Named colors such as `:red` or `:light_red` will use `256` color values (rendering will be terminal dependent). In order to force named colors to use true colors instead, use `UnicodePlots.USE_LUT[]=true`.

The default color cycle can be changed to bright (high intensity) colors using `UnicodePlots.brightcolors!()` instead of the default `UnicodePlots.faintcolors!()`.

# 3D plots
3D plots use a so-called "Model-View-Projection" transformation matrix `MVP` on input data to project 3D plots to a 2D screen.

Use keywords`elevation`, `azimuth`, `up` or `zoom` to control the view matrix, a.k.a. camera.

The `projection` type for `MVP` can be set to either `:persp(ective)` or `:ortho(graphic)`.

Displaying the `x`, `y`, and `z` axes can be controlled using the `axes3d` keyword.

For enhanced resolution, use a wider and/or taller `Plot` (this can be achieved using `default_size!(width=60)` for all future plots).

# Layout
`UnicodePlots` is integrated in [`Plots`](https://github.com/JuliaPlots/Plots.jl) as a backend, with support for [basic layout](https://docs.juliaplots.org/stable/gallery/unicodeplots/generated/unicodeplots-ref17).

For a more complex layout, use the `gridplot` function (requires loading [`Term`](https://github.com/FedeClaudi/Term.jl) as extension).
```@example
using UnicodePlots, Term

(
  UnicodePlots.panel(lineplot(1:2)) *
  UnicodePlots.panel(scatterplot(rand(100)))
) / (
  UnicodePlots.panel(lineplot(2:-1:1)) * 
  UnicodePlots.panel(densityplot(randn(1_000), randn(1_000)))
) |> display

gridplot(map(i -> lineplot(-i:i), 1:5); show_placeholder=true) |> display
gridplot(map(i -> lineplot(-i:i), 1:3); layout=(2, nothing)) |> display
gridplot(map(i -> lineplot(-i:i), 1:3); layout=(nothing, 1)) |> display
```

# Known issues
Using a non `true monospace font` can lead to visual problems on a `BrailleCanvas` (border versus canvas).

Either change the font to e.g. [JuliaMono](https://juliamono.netlify.app/) or use `border=:dotted` keyword argument in the plots.

For a `Jupyter` notebook with the `IJulia` kernel see [here](https://juliamono.netlify.app/faq/#can_i_use_this_font_in_a_jupyter_notebook_and_how_do_i_do_it).

(Experimental) Terminals seem to respect a standard aspect ratio of `4:3`, hence a square matrix does not often look square in the terminal.

You can pass the experimental keyword `fix_ar=true` to `spy` or `heatmap` in order to recover a unit aspect ratio.
