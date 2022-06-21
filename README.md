<!-- WARNING: this file has been automatically generated, please update UnicodePlots/docs/generate_docs.jl instead, and run $ julia generate_docs.jl to render README.md !! -->
# UnicodePlots

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.named.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.html)
[![CI](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml)
[![Coverage Status](https://codecov.io/gh/JuliaPlots/UnicodePlots.jl/branch/master/graphs/badge.svg?branch=master)](https://app.codecov.io/gh/JuliaPlots/UnicodePlots.jl)
[![JuliaHub deps](https://juliahub.com/docs/UnicodePlots/deps.svg)](https://juliahub.com/ui/Packages/UnicodePlots/Ctj9q?t=2)
[![UnicodePlots Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/UnicodePlots)](https://pkgs.genieframework.com?packages=UnicodePlots)

Advanced [`Unicode`](https://en.wikipedia.org/wiki/Unicode) plotting library designed for use in `Julia`'s `REPL`.

<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/banner.jpg" width="900">

## High-level Interface

There are a couple of ways to generate typical plots without much verbosity.

Here is a list of the main high-level functions for common scenarios:

  - [`scatterplot`](https://github.com/JuliaPlots/UnicodePlots.jl#scatterplot) (Scatter Plot)
  - [`lineplot`](https://github.com/JuliaPlots/UnicodePlots.jl#lineplot) (Line Plot)
  - [`stairs`](https://github.com/JuliaPlots/UnicodePlots.jl#staircase-plot) (Staircase Plot)
  - [`barplot`](https://github.com/JuliaPlots/UnicodePlots.jl#barplot) (Bar Plot - horizontal)
  - [`histogram`](https://github.com/JuliaPlots/UnicodePlots.jl#histogram) (Histogram - horizontal / vertical)
  - [`boxplot`](https://github.com/JuliaPlots/UnicodePlots.jl#boxplot) (Box Plot - horizontal)
  - [`spy`](https://github.com/JuliaPlots/UnicodePlots.jl#sparsity-pattern) (Sparsity Pattern)
  - [`densityplot`](https://github.com/JuliaPlots/UnicodePlots.jl#density-plot) (Density Plot)
  - [`contourplot`](https://github.com/JuliaPlots/UnicodePlots.jl#contour-plot) (Contour Plot)
  - [`polarplot`](https://github.com/JuliaPlots/UnicodePlots.jl#polar-plot) (Polar Plot)
  - [`heatmap`](https://github.com/JuliaPlots/UnicodePlots.jl#heatmap-plot) (Heatmap Plot)
  - [`surfaceplot`](https://github.com/JuliaPlots/UnicodePlots.jl#surface-plot) (Surface Plot - 3D)
  - [`isosurface`](https://github.com/JuliaPlots/UnicodePlots.jl#isosurface-plot) (Isosurface Plot - 3D)

<details open>
  <summary><a name=introduction></a><b>Introduction</b></summary><br>

  Here is a quick hello world example of a typical use-case:

  ```julia
using UnicodePlots
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
               title="Example Plot", name="my line", xlabel="x", ylabel="y")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot1.png" width="500"><br>


  There are other types of `Canvas` available (see section [Low-level Interface](https://github.com/JuliaPlots/UnicodePlots.jl#low-level-interface)).

  In some situations, such as printing to a file, using `AsciiCanvas`, `DotCanvas` or `BlockCanvas` might lead to better results:

  ```julia
lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
         title="Example Plot", name="my line",
         xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot2.png" width="500"><br>


  Some plot methods have a mutating variant that ends with a exclamation mark:

  ```julia
lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name="other line")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot3.png" width="500"><br>


  Physical quantities of [`Unitful.jl`](https://github.com/PainterQubits/Unitful.jl) are supported on a subset of plotting methods.

</details>

<details open>
  <summary><a name=scatterplot></a><b>Scatterplot</b></summary><br>

  ```julia
scatterplot(randn(50), randn(50), title="My Scatterplot")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/scatterplot1.png" width="500"><br>


  Axis scaling (`xscale` and/or `yscale`) is supported: choose from (`:identity`, `:ln`, `:log2`, `:log10`) or use an arbitrary scale function:

  ```julia
scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/scatterplot2.png" width="500"><br>


  For the axis scale exponent, one can revert to using `ASCII` characters instead of `Unicode` ones using the keyword `unicode_exponent=false`:

  ```julia
scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, unicode_exponent=false)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/scatterplot3.png" width="500"><br>


  Using a `marker` is supported, choose a `Char`, a unit length `String` or a symbol name such as `:circle` (more from `keys(UnicodePlots.MARKERS)`).
  One can also provide a vector of `marker`s and/or `color`s as in the following example:

  ```julia
scatterplot([1, 2, 3], [3, 4, 1],
            marker=[:circle, '', "∫"], color=[:red, nothing, :yellow])
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/scatterplot4.png" width="500"><br>


  As with `lineplot`, `scatterplot` supports plotting physical `Unitful` quantities.
</details>

<details open>
  <summary><a name=lineplot></a><b>Lineplot</b></summary><br>

  ```julia
lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot4.png" width="500"><br>


  It's also possible to specify a function and a range:

  ```julia
plt = lineplot([cos, sin], -π/2, 2π)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot5.png" width="500"><br>


  You can also plot lines by specifying an intercept and slope:

  ```julia
lineplot!(plt, -.5, .2, name="line")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot6.png" width="500"><br>


  Physical units are supported through `Unitful`:

  ```julia
using Unitful
a = 1u"m/s^2"
t = (0:100) * u"s"
lineplot(a / 2 * t .^ 2, a * t, xlabel = "position", ylabel = "speed")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/lineplot7.png" width="500"><br>

</details>

<details open>
  <summary><a name=staircase-plot></a><b>Staircase plot</b></summary><br>

  ```julia
# supported style are :pre and :post
stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7],
       color=:red, style=:post, title="My Staircase Plot")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/stairs1.png" width="500"><br>

</details>

<details open>
  <summary><a name=barplot></a><b>Barplot</b></summary><br>

  ```julia
barplot(["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title="Population")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/barplot1.png" width="500"><br>


  _Note_: You can use the keyword argument `symbols` to specify the characters that should be used to plot the bars (e.g. `symbols=['#']`).
</details>

<details open>
  <summary><a name=histogram></a><b>Histogram</b></summary><br>

  ```julia
histogram(randn(1_000) .* .1, nbins=15, closed=:left)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/histogram1.png" width="500"><br>


  The `histogram` function also supports axis scaling using the parameter `xscale`:

  ```julia
histogram(randn(1_000) .* .1, nbins=15, closed=:right, xscale=:log10)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/histogram2.png" width="500"><br>


  Vertical histograms are supported:

  ```julia
histogram(randn(100_000) .* .1, nbins=60, vertical=true)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/histogram3.png" width="500"><br>

</details>

<details open>
  <summary><a name=boxplot></a><b>Boxplot</b></summary><br>

  ```julia
boxplot([1, 3, 3, 4, 6, 10])
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/boxplot1.png" width="500"><br>


  ```julia
boxplot(["one", "two"],
        [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
        title="Grouped Boxplot", xlabel="x")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/boxplot2.png" width="500"><br>

</details>

<details open>
  <summary><a name=sparsity-pattern></a><b>Sparsity Pattern</b></summary><br>

  ```julia
using SparseArrays
spy(sprandn(50, 120, .05))
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/spy1.png" width="500"><br>


  Plotting the zeros pattern is also possible using `show_zeros=true`:

  ```julia
using SparseArrays
spy(sprandn(50, 120, .9), show_zeros=true)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/spy2.png" width="500"><br>

</details>

<details open>
  <summary><a name=density-plot></a><b>Density Plot</b></summary><br>

  ```julia
plt = densityplot(randn(10_000), randn(10_000))
densityplot!(plt, randn(10_000) .+ 2, randn(10_000) .+ 2)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/densityplot1.png" width="500"><br>


  Using a scale function (e.g. damping peaks) is supported using the `dscale` keyword:

  ```julia
x = randn(10_000); x[1_000:6_000] .= 2
densityplot(x, randn(10_000); dscale = x -> log(1 + x))
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/densityplot2.png" width="500"><br>

</details>

<details open>
  <summary><a name=contour-plot></a><b>Contour Plot</b></summary><br>

  ```julia
contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2))
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/contourplot1.png" width="500"><br>


  The keyword `levels` controls the number of contour levels. One can also choose a `colormap` as with `heatmap`, and disable the colorbar using `colorbar=false`.
</details>

<details open>
  <summary><a name=heatmap-plot></a><b>Heatmap Plot</b></summary><br>

  ```julia
heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/heatmap1.png" width="500"><br>


  The `heatmap` function also supports axis scaling using the parameters `xfact`, `yfact` and axis offsets after scaling using `xoffset` and `yoffset`.

  The `colormap` parameter may be used to specify a named or custom colormap. See the `heatmap` function documentation for more details.

  In addition, the `colorbar` and `colorbar_border` options may be used to toggle the colorbar and configure its border.

  The `zlabel` option and `zlabel!` method may be used to set the `z` axis (colorbar) label.

  ```julia
heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/heatmap2.png" width="500"><br>

</details>

<details open>
  <summary><a name=polar-plot></a><b>Polar Plot</b></summary><br>

  Plots data in polar coordinates with `θ` the angles in radians.

  ```julia
polarplot(range(0, 2π, length = 20), range(0, 2, length = 20))
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/polarplot1.png" width="500"><br>


</details>

<details open>
  <summary><a name=surface-plot></a><b>Surface Plot</b></summary><br>

  Plots a colored surface using height values `z` above a `x-y` plane, in three dimensions (masking values using `NaN`s is supported).

  ```julia
sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
surfaceplot(-8:.5:8, -8:.5:8, sombrero, colormap=:jet)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/surfaceplot1.png" width="500"><br>


  Use `lines=true` to increase the density (underlying call to `lineplot` instead of `scatterplot`, with color interpolation).
  To plot a slice in 3D, use an anonymous function which maps to a constant value: `zscale=z -> a_constant`:

  ```julia
surfaceplot(
  -2:2, -2:2, (x, y) -> 15sinc(√(x^2 + y^2) / π),
  zscale=z -> 0, lines=true, colormap=:jet
)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/surfaceplot2.png" width="500"><br>

</details>

<details open>
  <summary><a name=isosurface-plot></a><b>Isosurface Plot</b></summary><br>

  Uses [`MarchingCubes.jl`](https://github.com/JuliaGeometry/MarchingCubes.jl) to extract an isosurface, where `isovalue` controls the surface isovalue.
  Using `centroid` enables plotting the triangulation centroids instead of the triangle vertices (better for small plots).
  Back face culling (hide not visible facets) can be activated using `cull=true`.
  One can use the legacy 'Marching Cubes' algorithm using `legacy=true`.

  ```julia
torus(x, y, z, r=0.2, R=0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus, cull=true, zoom=2, elevation=50)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/isosurface.png" width="500"><br>

</details>

## Documentation

<details>
  <summary><a name=installation></a><b>Installation</b></summary><br>

  To install UnicodePlots, start up `Julia` and type the following code snippet into the `REPL` (makes use of the native `Julia` package manager `Pkg`):
```julia
julia> using Pkg
julia> Pkg.add("UnicodePlots")
```


</details>

<details>
  <summary><a name=saving-figures></a><b>Saving figures</b></summary><br>

  Saving plots as `png` or `txt` files using the `savefig` command is supported (saving as `png` is experimental and resulting images might slightly change without warnings).

  To recover the plot as a string with ansi color codes use `string(p; color=true)`.
</details>

<details>
  <summary><a name=color-mode></a><b>Color mode</b></summary><br>

  When the `COLORTERM` environment variable is set to either `24bit` or `truecolor`, `UnicodePlots` will use [24bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit) as opposed to [8bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) or even [4bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit) for named colors.

  One can force a specific colormode using either `UnicodePlots.truecolors!()` or `UnicodePlots.colors256!()`.

  Named colors such as `:red` or `:light_red` will use `256` color values (rendering will be terminal dependent). In order to force named colors to use true colors instead, use `UnicodePlots.USE_LUT[]=true`.

  The default color cycle can be changed to bright (high intensity) colors using `UnicodePlots.brightcolors!()` instead of the default `UnicodePlots.faintcolors!()`.
</details>

<details>
  <summary><a name=3d-plots></a><b>3D plots</b></summary><br>

  3d plots use a so-called "Model-View-Projection" transformation matrix `MVP` on input data to project 3D plots to a 2D screen.

  Use keywords`elevation`, `azimuth`, `up` or `zoom` to control the "View" matrix, a.k.a., camera.

  The `projection` type for `MVP` can be set to either `:perspective` or `:orthographic`.

  Displaying the `x`, `y`, and `z` axes can be controlled using the `axes3d` keyword.

  For enhanced resolution, use a wider and/or taller `Plot` (this can be achieved using `default_size!(width=60)` for all future plots).
</details>

<details>
  <summary><a name=layout></a><b>Layout</b></summary><br>

  `UnicodePlots` is integrated in [`Plots`](https://github.com/JuliaPlots/Plots.jl) as a backend, with support for [basic layout](https://docs.juliaplots.org/stable/gallery/unicodeplots/generated/unicodeplots-ref17).

  For a more complex layout, use the [`grid`](https://fedeclaudi.github.io/Term.jl/dev/layout/grid) function from [`Term`](https://github.com/FedeClaudi/Term.jl).
</details>

<details>
  <summary><a name=know-issues></a><b>Know Issues</b></summary><br>

  Using a non `true monospace font` can lead to visual problems on a `BrailleCanvas` (border versus canvas).

  Either change the font to e.g. [JuliaMono](https://juliamono.netlify.app/) or use `border=:dotted` keyword argument in the plots.

  For a `Jupyter` notebook with the `IJulia` kernel see [here](https://juliamono.netlify.app/faq/#can_i_use_this_font_in_a_jupyter_notebook_and_how_do_i_do_it).

  (Experimental) Terminals seem to respect a standard aspect ratio of `4:3`, hence a square matrix does not often look square in the terminal.

  You can pass the experimental keyword `fix_ar=true` to `spy` or `heatmap` in order to recover a unit aspect ratio.
</details>

<details>
  <summary><a name=methods-(api)></a><b>Methods (API)</b></summary><br>

    - `title!(plot::Plot, title::String)`

    - `title` the string to write in the top center of the plot window. If the title is empty the whole line of the title will not be drawn

  - `xlabel!(plot::Plot, xlabel::String)`

    - `xlabel` the string to display on the bottom of the plot window. If the title is empty the whole line of the label will not be drawn

  - `ylabel!(plot::Plot, xlabel::String)`

    - `ylabel` the string to display on the far left of the plot window.

The method `label!` is responsible for the setting all the textual decorations of a plot. It has two functions:

  - `label!(plot::Plot, where::Symbol, value::String)`

    - `where` can be any of: `:tl` (top-left), `:t` (top-center), `:tr` (top-right), `:bl` (bottom-left), `:b` (bottom-center), `:br` (bottom-right), `:l` (left), `:r` (right)

  - `label!(plot::Plot, where::Symbol, row::Int, value::String)`

    - `where` can be any of: `:l` (left), `:r` (right)

    - `row` can be between 1 and the number of character rows of the canvas
    ```julia
    x = y = collect(1:10)
    plt = lineplot(x, y, canvas=DotCanvas, height=10, width=30)
    lineplot!(plt, x, reverse(y))
    title!(plt, "Plot Title")
    for loc in (:tl, :t, :tr, :bl, :b, :br)
      label!(plt, loc, string(':', loc))
    end
    label!(plt, :l, ":l")
    label!(plt, :r, ":r")
    for i in 1:10
      label!(plt, :l, i, string(i))
      label!(plt, :r, i, string(i))
    end
    plt
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/decorate.png" width="500"><br>
    


  - `annotate!(plot::Plot, x::Number, y::Number, text::AbstractString; kw...)`
    - `text` arbitrary annotation at position (x, y)


</details>

<details>
  <summary><a name=keywords-description-(api)></a><b>Keywords description (API)</b></summary><br>

  All plots support the set (or a subset) of the following named parameters:

  - `symbols::Array = ['■']`: collection of characters used to render the bars.
  - `title::String = ""`: text displayed on top of the plot.
  - `name::String = ""`: current drawing annotation displayed on the right.
  - `xlabel::String = ""`: text displayed on the `x` axis of the plot.
  - `ylabel::String = ""`: text displayed on the `y` axis of the plot.
  - `zlabel::String = ""`: text displayed on the `z` axis (colorbar) of the plot.
  - `xscale::Symbol = :identity`: `x`-axis scale (`:identity`, `:ln`, `:log2`, `:log10`), or scale function e.g. `x -> log10(x)`.
  - `yscale::Symbol = :identity`: `y`-axis scale.
  - `labels::Bool = true`: show plot labels.
    ```julia
    lineplot(sin, 1:.5:20, labels=false)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/labels.png" width="500"><br>
    
  - `border::Symbol = :solid`: plot bounding box style (`:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:none`).
    ```julia
    lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/border_dashed.png" width="500"><br>
    
    ```julia
    lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:ascii)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/border_ascii.png" width="500"><br>
    
    ```julia
    lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/border_bold.png" width="500"><br>
    
    ```julia
    lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:dotted)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/border_dotted.png" width="500"><br>
    
    ```julia
    lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:none)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/border_none.png" width="500"><br>
    
  - `margin::Int = 3`: number of empty characters to the left of the whole plot.
  - `padding::Int = 1`: left and right space between the labels and the canvas.
  - `color::Symbol = :auto`: choose from (`:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`, `:white`, `:normal`, `:auto`), use an integer in `[0-255]`, or provide `3` integers as `RGB` components.
  - `height::Int = 15`: number of canvas rows.
    ```julia
    lineplot(sin, 1:.5:20, height=18)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/height.png" width="500"><br>
    
  - `width::Int = 40`: number of characters per canvas row.
    ```julia
    lineplot(sin, 1:.5:20, width=60)
    ```
    <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/width.png" width="500"><br>
    
  - `xlim::Tuple = (0, 0)`: plotting range for the `x` axis (`(0, 0)` stands for automatic).
  - `ylim::Tuple = (0, 0)`: plotting range for the `y` axis.
  - `zlim::Tuple = (0, 0)`: colormap scaled data range.
  - `xticks::Bool = true`: set `false` to disable ticks on `x`-axis.
  - `yticks::Bool = true`: set `false` to disable ticks on `y`-axis.
  - `colorbar::Bool = false`: toggle the colorbar.
  - `colormap::Symbol = :viridis`: choose from (`:viridis`, `:cividis`, `:plasma`, `:jet`, `:gray`, `keys(UnicodePlots.COLOR_MAP_DATA)`...), or supply a function `f: (z, zmin, zmax) -> Int(0-255)`, or a vector of RGB tuples.
  - `colorbar_lim::Tuple = (0, 1)`: colorbar limit.
  - `colorbar_border::Symbol = :solid`: color bar bounding box style (`:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:none`).
  - `canvas::UnionAll = BrailleCanvas`: type of canvas used for drawing.
  - `grid::Bool = true`: draws grid-lines at the origin.
  - `compact::Bool = false`: compact plot labels.
  - `unicode_exponent::Bool = true`: use `Unicode` symbols for exponents: e.g. `10²⸱¹` instead of `10^2.1`.
  - `projection::Symbol = :orthographic`: projection for 3D plots (`:orthographic`, `:perspective`, or `Model-View-Projection` (MVP) matrix).
  - `axes3d::Bool = true`: draw 3d axes (`x -> :red`, `y -> :green`, `z -> :blue`).
  - `elevation::Float = 35.26`: elevation angle above or below the `floor` plane (`-90 ≤ θ ≤ 90`).
  - `azimuth::Float = 45.0`: azimutal angle around the `up` vector (`-180° ≤ φ ≤ 180°`).
  - `zoom::Float = 1.0`: zooming factor in 3D.
  - `up::Symbol = :z`: up vector (`:x`, `:y` or `:z`), prefix with `m -> -` or `p -> +` to change the sign e.g. `:mz` for `-z` axis pointing upwards.
  - `near::Float = 1.0`: distance to the near clipping plane (`:perspective` projection only).
  - `far::Float = 100.0`: distance to the far clipping plane (`:perspective` projection only).
  - `blend::Bool = true`: blend colors on the underlying canvas.
  - `fix_ar::Bool = false`: fix terminal aspect ratio (experimental).
  - `visible::Bool = true`: visible canvas.

_Note_: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).


</details>

<details>
  <summary><a name=low-level-interface></a><b>Low-level Interface</b></summary><br>

  The primary structures that do all the heavy lifting behind the curtain are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. Basically, it uses Unicode characters to represent pixel.

Here is a simple example:

```julia
canvas = BrailleCanvas(15, 40,                    # number of rows and columns (characters)
                       origin_y=0., origin_x=0.,  # position in virtual space
                       height=1., width=1.)       # size of the virtual space
lines!(canvas, 0., 0., 1., 1., :blue)             # virtual space
points!(canvas, rand(50), rand(50), :red)         # virtual space
lines!(canvas, 0., 1., .5, 0., :yellow)           # virtual space
pixel!(canvas, 5, 8, :red)                        # pixel space
Plot(canvas)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/canvas.png" width="500"><br>


You can access the height and width of the canvas (in characters) with `nrows(canvas)` and `ncols(canvas)` respectively. You can use those functions in combination with `print_row` to embed the canvas anywhere you wish. For example, `print_row(STDOUT, canvas, 3)` writes the third character row of the canvas to the standard output.

As you can see, one issue that arises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the "pixel" of a character could belong to a different color group (each character can only have a single color). This package deals with this using a color-blend for the whole group. You can disable canvas color blending / mixing by passing `blend=false` to any function.

```julia
canvas = BrailleCanvas(15, 40; origin_y=0., origin_x=0., height=1., width=1.)
lines!(canvas, 0., 0., 1., 1., :blue)
lines!(canvas, .25, 1., .5, 0., :yellow)
lines!(canvas, .2, .8, 1., 0., :red)
Plot(canvas)
```
<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/2.10/blending.png" width="500"><br>


The following types of `Canvas` are implemented:
  - **BrailleCanvas**:
    This type of canvas is probably the one with the highest resolution for `Unicode` plotting. It essentially uses the Unicode characters of the [Braille](https://en.wikipedia.org/wiki/Braille) symbols as pixels. This effectively turns every character into eight pixels that can individually be manipulated using binary operations.

  - **BlockCanvas**:
    This canvas is also `Unicode` based. It has half the resolution of the BrailleCanvas. In contrast to `BrailleCanvas`, the pixels don't have visible spacing between them. This canvas effectively turns every character into four pixels that can individually be manipulated using binary operations.

  - **HeatmapCanvas**:
    This canvas is also `Unicode` based. It has half the resolution of the `BlockCanvas`. This canvas effectively turns every character into two color pixels, using the foreground and background terminal colors. As such, the number of rows of the canvas is half the number of `y` coordinates being displayed.

  - **AsciiCanvas** and **DotCanvas**:
    These two canvas utilizes only standard `ASCII` character for drawing. Naturally, it doesn't look quite as nice as the Unicode-based ones. However, in some situations it might yield better results. Printing plots to a file is one of those situations.

  - **DensityCanvas**:
    Unlike the `BrailleCanvas`, the density canvas does not simply mark a "pixel" as set. Instead it increments a counter per character that keeps track of the frequency of pixels drawn in that character. Together with a variable that keeps track of the maximum frequency, the canvas can thus draw the density of datapoints.

  - **BarplotGraphics**:
    This graphics area is special in that it does not support any pixel manipulation. It is essentially the barplot without decorations but the numbers. It does only support one method `addrow!` which allows the user to add additional bars to the graphics object.


</details>

<details>
  <summary><a name=documentation-update></a><b>Documentation update</b></summary><br>

  The following snippet:
```bash
$ cd docs
$ julia generate_docs.jl
$ (cd imgs; julia gen_imgs.jl)
```
will regenerate `README.md` and the example images with root (prefix) url https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs.


</details>

## License

This code is free to use under the terms of the MIT license.

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille).

