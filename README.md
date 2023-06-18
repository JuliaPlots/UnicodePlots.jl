<!-- WARNING: this file has been automatically generated, please update UnicodePlots/docs/gen_docs.jl instead, and run $ julia gen_docs.jl to render README.md !! -->
# UnicodePlots

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.named.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.html)
[![CI](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml)
[![Coverage Status](https://codecov.io/gh/JuliaPlots/UnicodePlots.jl/branch/master/graphs/badge.svg?branch=master)](https://app.codecov.io/gh/JuliaPlots/UnicodePlots.jl)
[![JuliaHub deps](https://juliahub.com/docs/UnicodePlots/deps.svg)](https://juliahub.com/ui/Packages/UnicodePlots/Ctj9q?t=2)
[![UnicodePlots Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/UnicodePlots)](https://pkgs.genieframework.com?packages=UnicodePlots)

Advanced [`Unicode`](https://en.wikipedia.org/wiki/Unicode) plotting library designed for use in `Julia`'s `REPL`.

<img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/banner.jpg" width="900">

## High-level Interface

Here is a list of the main high-level functions for common scenarios:

  - [`lineplot`](https://github.com/JuliaPlots/UnicodePlots.jl#lineplot) (Line Plot)
  - [`scatterplot`](https://github.com/JuliaPlots/UnicodePlots.jl#scatterplot) (Scatter Plot)
  - [`stairs`](https://github.com/JuliaPlots/UnicodePlots.jl#staircase-plot) (Staircase Plot)
  - [`barplot`](https://github.com/JuliaPlots/UnicodePlots.jl#barplot) (Bar Plot - horizontal)
  - [`histogram`](https://github.com/JuliaPlots/UnicodePlots.jl#histogram) (Histogram - horizontal / vertical)
  - [`boxplot`](https://github.com/JuliaPlots/UnicodePlots.jl#boxplot) (Box Plot - horizontal)
  - [`spy`](https://github.com/JuliaPlots/UnicodePlots.jl#sparsity-pattern) (Sparsity Pattern)
  - [`densityplot`](https://github.com/JuliaPlots/UnicodePlots.jl#density-plot) (Density Plot)
  - [`contourplot`](https://github.com/JuliaPlots/UnicodePlots.jl#contour-plot) (Contour Plot)
  - [`polarplot`](https://github.com/JuliaPlots/UnicodePlots.jl#polar-plot) (Polar Plot)
  - [`heatmap`](https://github.com/JuliaPlots/UnicodePlots.jl#heatmap-plot) (Heatmap Plot)
  - [`imageplot`](https://github.com/JuliaPlots/UnicodePlots.jl#image-plot) (Image Plot)
  - [`surfaceplot`](https://github.com/JuliaPlots/UnicodePlots.jl#surface-plot) (Surface Plot - 3D)
  - [`isosurface`](https://github.com/JuliaPlots/UnicodePlots.jl#isosurface-plot) (Isosurface Plot - 3D)

<details open>
  <summary><a name=introduction></a><b>Introduction</b></summary><br>

  Here is a quick hello world example of a typical use-case:

  ```julia
  using UnicodePlots
  lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example", name="my line", xlabel="x", ylabel="y")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot1.png" width="450"><br>
  

  There are other types of `Canvas` available (see section [Low-level Interface](https://github.com/JuliaPlots/UnicodePlots.jl#low-level-interface)).

  In some situations, such as printing to a file, using `AsciiCanvas`, `DotCanvas` or `BlockCanvas` might lead to better results:

  ```julia
  plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example", name="my line",
                 xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot2.png" width="450"><br>
  

  Some plot methods have a mutating variant that ends with an exclamation mark:

  ```julia
  lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:cyan, name="other line")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot3.png" width="450"><br>
  

  One can adjust the plot `height` and `width` to the current terminal size by using `height=:auto` and/or `width=:auto`.

  You can reverse/flip the `Plot` axes by setting `xflip=true` and/or `yflip=true` on plot creation.

</details>

<details open>
  <summary><a name=lineplot></a><b>Lineplot</b></summary><br>

  ```julia
  lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot4.png" width="450"><br>
  

  It's also possible to specify a function and a range:

  ```julia
  plt = lineplot(-π/2, 2π, [cos, sin])
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot5.png" width="450"><br>
  

  You can also plot lines by specifying an intercept and slope:

  ```julia
  lineplot!(plt, -.5, .2, name="line")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot6.png" width="450"><br>
  

  Plotting multiple series is supported by providing a `Matrix` (`<: AbstractMatrix`) for the `y` argument, with the individual series corresponding to its columns. Auto-labeling is by default, but you can also label each series by providing a `Vector` or a `1xn` `Matrix` such as `["series 1" "series2" ...]`:

  ```julia
  lineplot(1:10, [0:9 3:12 reverse(5:14) fill(4, 10)], color=[:green :red :yellow :cyan])
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot7.png" width="450"><br>
  

  Physical quantities of [`Unitful.jl`](https://github.com/PainterQubits/Unitful.jl) are supported through [package extensions - weak dependencies](https://pkgdocs.julialang.org/dev/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)):

  ```julia
  using Unitful
  a, t = 1u"m/s^2", (0:100) * u"s"
  lineplot(a / 2 * t .^ 2, a * t, xlabel="position", ylabel="speed", height=10)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot8.png" width="450"><br>
  

  Intervals from [`IntervalSets.jl`](https://github.com/JuliaMath/IntervalSets.jl) are supported:

  ```julia
  using IntervalSets
  lineplot(-1..3, x -> x^5 - 5x^4 + 5x^3 + 5x^2 - 6x - 1; name="quintic")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot9.png" width="450"><br>
  

  Use `head_tail` to mimic plotting arrows (`:head`, `:tail` or `:both`) where the length of the "arrow" head or tail is controlled using `head_tail_frac` where e.g. giving a value of `0.1` means `10%` of the segment length:

  ```julia
  lineplot(1:10, 1:10, head_tail=:head, head_tail_frac=.1, height=4)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot10.png" width="450"><br>
  

  `UnicodePlots` exports `hline!` and `vline!` for drawing vertical and horizontal lines on a plot:

  ```julia
  p = Plot([NaN], [NaN]; xlim=(0, 8), ylim=(0, 8))
  vline!(p, [2, 6], [2, 6], color=:red)
  hline!(p, [2, 6], [2, 6], color=:white)
  hline!(p, 7, color=:cyan)
  vline!(p, 1, color=:yellow)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/lineplot11.png" width="450"><br>
  

</details>

<details open>
  <summary><a name=scatterplot></a><b>Scatterplot</b></summary><br>

  ```julia
  scatterplot(randn(50), randn(50), title="My Scatterplot")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/scatterplot1.png" width="450"><br>
  

  Axis scaling (`xscale` and/or `yscale`) is supported: choose from (`:identity`, `:ln`, `:log2`, `:log10`) or use an arbitrary scale function:

  ```julia
  scatterplot(1:10, 1:10, xscale=:log10, yscale=:log10)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/scatterplot2.png" width="450"><br>
  

  For the axis scale exponent, one can revert to using `ASCII` characters instead of `Unicode` ones using the keyword `unicode_exponent=false`:

  ```julia
  scatterplot(1:4, 1:4, xscale=:log10, yscale=:ln, unicode_exponent=false, height=6)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/scatterplot3.png" width="450"><br>
  

  Using a `marker` is supported, choose a `Char`, a unit length `String` or a symbol name such as `:circle` (more from `keys(UnicodePlots.MARKERS)`).
  One can also provide a vector of `marker`s and/or `color`s as in the following example:

  ```julia
  scatterplot([1, 2, 3], [3, 4, 1], marker=[:circle, '', "∫"],
              color=[:cyan, nothing, :yellow], height=2)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/scatterplot4.png" width="450"><br>
  

  As with `lineplot`, `scatterplot` supports plotting physical `Unitful` quantities, or plotting multiple series (`Matrix` argument).
</details>

<details open>
  <summary><a name=staircase-plot></a><b>Staircase plot</b></summary><br>

  ```julia
  stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7],
         color=:yellow, style=:post, height=6, title="Staircase")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/stairs1.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=barplot></a><b>Barplot</b></summary><br>

  ```julia
  barplot(["Paris", "New York", "Madrid"], [2.244, 8.406, 3.165], title="Population")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/barplot1.png" width="450"><br>
  

  _Note_: You can use the keyword argument `symbols` to specify the characters that should be used to plot the bars (e.g. `symbols=['#']`).
</details>

<details open>
  <summary><a name=histogram></a><b>Histogram</b></summary><br>

  ```julia
  histogram(randn(1_000) .* .1, nbins=15, closed=:left)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/histogram1.png" width="450"><br>
  

  The `histogram` function also supports axis scaling using the parameter `xscale`:

  ```julia
  histogram(randn(1_000) .* .1, nbins=15, closed=:right, xscale=:log10)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/histogram2.png" width="450"><br>
  

  Vertical histograms are supported:

  ```julia
  histogram(randn(100_000) .* .1, nbins=60, vertical=true, height=10)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/histogram3.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=boxplot></a><b>Boxplot</b></summary><br>

  ```julia
  boxplot([1, 3, 3, 4, 6, 10])
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/boxplot1.png" width="450"><br>
  

  ```julia
  boxplot(["one", "two"],
          [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
          title="Grouped Boxplot", xlabel="x")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/boxplot2.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=sparsity-pattern></a><b>Sparsity Pattern</b></summary><br>

  ```julia
  using SparseArrays
  spy(sprandn(50, 120, .05))
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/spy1.png" width="450"><br>
  

  Plotting the zeros pattern is also possible using `show_zeros=true`:

  ```julia
  using SparseArrays
  spy(sprandn(50, 120, .9), show_zeros=true)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/spy2.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=density-plot></a><b>Density Plot</b></summary><br>

  ```julia
  plt = densityplot(randn(10_000), randn(10_000))
  densityplot!(plt, randn(10_000) .+ 2, randn(10_000) .+ 2)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/densityplot1.png" width="450"><br>
  

  Using a scale function (e.g. damping peaks) is supported using the `dscale` keyword:

  ```julia
  x = randn(10_000); x[1_000:6_000] .= 2
  densityplot(x, randn(10_000); dscale=x -> log(1 + x))
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/densityplot2.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=contour-plot></a><b>Contour Plot</b></summary><br>

  ```julia
  contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2))
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/contourplot1.png" width="450"><br>
  

  The keyword `levels` controls the number of contour levels. One can also choose a `colormap` as with `heatmap`, and disable the colorbar using `colorbar=false`.
</details>

<details open>
  <summary><a name=polar-plot></a><b>Polar Plot</b></summary><br>

  Plots data in polar coordinates with `θ` the angles in radians.

  ```julia
  polarplot(range(0, 2π, length=20), range(0, 2, length=20))
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/polarplot1.png" width="450"><br>
  

</details>

<details open>
  <summary><a name=heatmap-plot></a><b>Heatmap Plot</b></summary><br>

  ```julia
  heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/heatmap1.png" width="450"><br>
  

  The `heatmap` function also supports axis scaling using the parameters `xfact`, `yfact` and axis offsets after scaling using `xoffset` and `yoffset`.

  The `colormap` parameter may be used to specify a named or custom colormap. See the `heatmap` function documentation for more details.

  In addition, the `colorbar` and `colorbar_border` options may be used to toggle the colorbar and configure its border.

  The `zlabel` option and `zlabel!` method may be used to set the `z` axis (colorbar) label.

  Use the `array` keyword in order to display the matrix in the array convention (as in the repl).

  ```julia
  heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/heatmap2.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=image-plot></a><b>Image Plot</b></summary><br>

  Draws an image, surround it with decorations. `Sixel` are supported (experimental) under a compatible terminal through [`ImageInTerminal`](https://github.com/JuliaImages/ImageInTerminal.jl) (which must be imported before `UnicodePlots`).

  ```julia
  import ImageInTerminal  # mandatory (triggers glue code loading)
  using TestImages
  imageplot(testimage("monarch_color_256"), title="monarch")
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/imageplot1.png" width="450"><br>
  
</details>

<details open>
  <summary><a name=surface-plot></a><b>Surface Plot</b></summary><br>

  Plots a colored surface using height values `z` above a `x-y` plane, in three dimensions (masking values using `NaN`s is supported).

  ```julia
  sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
  surfaceplot(-8:.5:8, -8:.5:8, sombrero, colormap=:jet)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/surfaceplot1.png" width="450"><br>
  

  Use `lines=true` to increase the density (underlying call to `lineplot` instead of `scatterplot`, with color interpolation).
  By default, `surfaceplot` scales heights to adjust aspect the other axes with `zscale=:aspect`.
  To plot a slice in 3D, use an anonymous function which maps to a constant value: `zscale=z -> a_constant`:

  ```julia
  surfaceplot(
    -2:2, -2:2, (x, y) -> 15sinc(√(x^2 + y^2) / π),
    zscale=z -> 0, lines=true, colormap=:jet
  )
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/surfaceplot2.png" width="450"><br>
  
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
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/isosurface.png" width="450"><br>
  
</details>

## Documentation

##### Installation
<details>
  <summary></a><b>...</b></summary><br>

  To install UnicodePlots, start up `Julia` and type the following code snippet into the `REPL` (makes use of the native `Julia` package manager `Pkg`):
```julia
julia> using Pkg
julia> Pkg.add("UnicodePlots")
```


</details>

##### Saving figures
<details>
  <summary></a><b>...</b></summary><br>

  Saving plots as `png` or `txt` files using the `savefig` command is supported (saving as `png` is experimental and requires `import FreeType, FileIO` before loading `UnicodePlots`).

  To recover the plot as a string with ansi color codes use `string(p; color=true)`.
</details>

##### Color mode
<details>
  <summary></a><b>...</b></summary><br>

  When the `COLORTERM` environment variable is set to either `24bit` or `truecolor`, `UnicodePlots` will use [24bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit) as opposed to [8bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) or even [4bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit) for named colors.

  One can force a specific colormode using either `UnicodePlots.truecolors!()` or `UnicodePlots.colors256!()`.

  Named colors such as `:red` or `:light_red` will use `256` color values (rendering will be terminal dependent). In order to force named colors to use true colors instead, use `UnicodePlots.USE_LUT[]=true`.

  The default color cycle can be changed to bright (high intensity) colors using `UnicodePlots.brightcolors!()` instead of the default `UnicodePlots.faintcolors!()`.
</details>

##### 3D plots
<details>
  <summary></a><b>...</b></summary><br>

  3d plots use a so-called "Model-View-Projection" transformation matrix `MVP` on input data to project 3D plots to a 2D screen.

  Use keywords`elevation`, `azimuth`, `up` or `zoom` to control the view matrix, a.k.a. camera.

  The `projection` type for `MVP` can be set to either `:persp(ective)` or `:ortho(graphic)`.

  Displaying the `x`, `y`, and `z` axes can be controlled using the `axes3d` keyword.

  For enhanced resolution, use a wider and/or taller `Plot` (this can be achieved using `default_size!(width=60)` for all future plots).
</details>

##### Layout
<details>
  <summary></a><b>...</b></summary><br>

  `UnicodePlots` is integrated in [`Plots`](https://github.com/JuliaPlots/Plots.jl) as a backend, with support for [basic layout](https://docs.juliaplots.org/stable/gallery/unicodeplots/generated/unicodeplots-ref17).

  For a more complex layout, use the `gridplot` function (requires loading [`Term`](https://github.com/FedeClaudi/Term.jl)).
  ```julia
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
</details>

##### Known issues
<details>
  <summary></a><b>...</b></summary><br>

  Using a non `true monospace font` can lead to visual problems on a `BrailleCanvas` (border versus canvas).

  Either change the font to e.g. [JuliaMono](https://juliamono.netlify.app/) or use `border=:dotted` keyword argument in the plots.

  For a `Jupyter` notebook with the `IJulia` kernel see [here](https://juliamono.netlify.app/faq/#can_i_use_this_font_in_a_jupyter_notebook_and_how_do_i_do_it).

  (Experimental) Terminals seem to respect a standard aspect ratio of `4:3`, hence a square matrix does not often look square in the terminal.

  You can pass the experimental keyword `fix_ar=true` to `spy` or `heatmap` in order to recover a unit aspect ratio.
</details>

##### Methods (API)
<details>
  <summary></a><b>...</b></summary><br>

Non-exhaustive methods description:

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
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/decorate.png" width="450"><br>
  


  - `annotate!(plot::Plot, x::Number, y::Number, text::AbstractString; kw...)`
    - `text` arbitrary annotation at position (x, y)
  

</details>

##### Keywords description (API)
<details>
  <summary></a><b>...</b></summary><br>

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
      lineplot(1:.5:20, sin, labels=false)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/labels.png" width="450"><br>
      
  - `border::Symbol = :solid`: plot bounding box style (`:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:none`).
      ```julia
      lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/border_dashed.png" width="450"><br>
      
      ```julia
      lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:ascii)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/border_ascii.png" width="450"><br>
      
      ```julia
      lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/border_bold.png" width="450"><br>
      
      ```julia
      lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:dotted)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/border_dotted.png" width="450"><br>
      
      ```julia
      lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:none)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/border_none.png" width="450"><br>
      
  - `margin::Int = 3`: number of empty characters to the left of the whole plot.
  - `padding::Int = 1`: left and right space between the labels and the canvas.
  - `color::Symbol = :auto`: choose from (`:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`, `:white`, `:normal`, `:auto`), use an integer in `[0-255]`, or provide `3` integers as `RGB` components.
  - `height::Int = 15`: number of canvas rows, or `:auto`.
      ```julia
      lineplot(1:.5:20, sin, height=18)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/height.png" width="450"><br>
      
  - `width::Int = 40`: number of characters per canvas row, or `:auto`.
      ```julia
      lineplot(1:.5:20, sin, width=60)
      ```
      <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/width.png" width="450"><br>
      
  - `xlim::Tuple = (0, 0)`: plotting range for the `x` axis (`(0, 0)` stands for automatic).
  - `ylim::Tuple = (0, 0)`: plotting range for the `y` axis.
  - `zlim::Tuple = (0, 0)`: colormap scaled data range.
  - `xticks::Bool = true`: set `false` to disable ticks (labels) on `x`-axis.
  - `yticks::Bool = true`: set `false` to disable ticks (labels) on `y`-axis.
  - `xflip::Bool = false`: set `true` to flip the `x` axis.
  - `yflip::Bool = false`: set `true` to flip the `y` axis.
  - `colorbar::Bool = false`: toggle the colorbar.
  - `colormap::Symbol = :viridis`: choose a symbol from `ColorSchemes.jl` e.g. `:viridis`, or supply a function `f: (z, zmin, zmax) -> Int(0-255)`, or a vector of RGB tuples.
  - `colorbar_lim::Tuple = (0, 1)`: colorbar limit.
  - `colorbar_border::Symbol = :solid`: color bar bounding box style (`:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:none`).
  - `canvas::UnionAll = BrailleCanvas`: type of canvas used for drawing.
  - `grid::Bool = true`: draws grid-lines at the origin.
  - `compact::Bool = false`: compact plot labels.
  - `unicode_exponent::Bool = true`: use `Unicode` symbols for exponents: e.g. `10²⸱¹` instead of `10^2.1`.
  - `thousands_separator::Char = ' '`: thousands separator character (use `Char(0)` to disable grouping digits).
  - `projection::Symbol = :orthographic`: projection for 3D plots (`:ortho(graphic)`, `:persp(ective)`, or `Model-View-Projection` (MVP) matrix).
  - `axes3d::Bool = true`: draw 3d axes (`x -> :red`, `y -> :green`, `z -> :blue`).
  - `elevation::Float = 35.26`: elevation angle above or below the `floor` plane (`-90 ≤ θ ≤ 90`).
  - `azimuth::Float = 45.0`: azimutal angle around the `up` vector (`-180° ≤ φ ≤ 180°`).
  - `zoom::Float = 1.0`: zooming factor in 3D.
  - `up::Symbol = :z`: up vector (`:x`, `:y` or `:z`), prefix with `m -> -` or `p -> +` to change the sign e.g. `:mz` for `-z` axis pointing upwards.
  - `near::Float = 1.0`: distance to the near clipping plane (`:perspective` projection only).
  - `far::Float = 100.0`: distance to the far clipping plane (`:perspective` projection only).
  - `canvas_kw::NamedTuple = NamedTuple()`: extra canvas keywords.
  - `blend::Bool = true`: blend colors on the underlying canvas.
  - `fix_ar::Bool = false`: fix terminal aspect ratio (experimental).
  - `visible::Bool = true`: visible canvas.
  
  _Note_: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).
  
  
</details>

##### Low-level interface
<details>
  <summary></a><b>...</b></summary><br>

  The primary structures that do all the heavy lifting behind the curtain are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. Basically, it uses Unicode characters to represent pixel.
  
  Here is a simple example:
  
  ```julia
  import UnicodePlots: lines!, points!, pixel!
  canvas = BrailleCanvas(15, 40,                    # number of rows and columns (characters)
                         origin_y=0., origin_x=0.,  # position in virtual space
                         height=1., width=1.)       # size of the virtual space
  lines!(canvas, 0., 0., 1., 1.; color=:cyan)       # virtual space
  points!(canvas, rand(50), rand(50); color=:red)   # virtual space
  lines!(canvas, 0., 1., .5, 0.; color=:yellow)     # virtual space
  pixel!(canvas, 5, 8; color=:red)                  # pixel space
  Plot(canvas)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/canvas.png" width="450"><br>
  
  
  You can access the height and width of the canvas (in characters) with `nrows(canvas)` and `ncols(canvas)` respectively. You can use those functions in combination with `print_row` to embed the canvas anywhere you wish. For example, `print_row(STDOUT, canvas, 3)` writes the third character row of the canvas to the standard output.
  
  As you can see, one issue that arises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the "pixel" of a character could belong to a different color group (each character can only have a single color). This package deals with this using a color-blend for the whole group. You can disable canvas color blending / mixing by passing `blend=false` to any function.
  
  ```julia
  import UnicodePlots: lines!
  canvas = BrailleCanvas(15, 40; origin_y=0., origin_x=0., height=1., width=1.)
  lines!(canvas, 0., 0., 1., 1.; color=:cyan)
  lines!(canvas, .25, 1., .5, 0.; color=:yellow)
  lines!(canvas, .2, .8, 1., 0.; color=:red)
  Plot(canvas)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/blending.png" width="450"><br>
  
  
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

##### Developer notes
<details>
  <summary></a><b>...</b></summary><br>

  Because Julia uses column-major indexing order for an array type, and because displaying data on a terminal is row based, we need an internal buffer compatible with efficient columns based iteration. We solve this by using the transpose of a (`width`, `height`) array for indexing into an internal buffer like `buf[row, col]` or `buf[y, x]`.
  Common users of UnicodePlots don't need to be aware of this axis difference if sticking to public interface.

  ```julia
  p = Plot([NaN], [NaN]; xlim=(1, 10), ylim=(1, 10), title="internal buffer conventions")
  
  # plot axes
  vline!(p, 1, head_tail=:head, color=:green, name="y-axis (rows)")
  hline!(p, 1, head_tail=:head, color=:red, name="x-axis (cols)")
  
  # square
  vline!(p, 2, [2, 9], color=:cyan, name="buf[y, x] - buf[row, col]")
  vline!(p, [2, 9], [2, 9], color=:cyan)
  hline!(p, [2, 9], [2, 9], color=:cyan)
  
  # internal axes
  vline!(p, 3, range(3, 8; length=20), head_tail=:tail, color=:light_green, name="y-buffer (rows)")
  hline!(p, 8, range(3, 8; length=20), head_tail=:head, color=:light_red, name="x-buffer (cols)")
  
  # mem layout
  vline!(p, 4, [4, 7]; color=:yellow, name="memory layout")
  vline!(p, 7, [4, 7]; color=:yellow)
  hline!(p, [4, 7], [4, 7]; color=:yellow)
  hline!(p, [4.5, 5, 5.5, 6], [4.5, 6.5]; color=:yellow)
  ```
  <img src="https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/3.x/buffer_convention.png" width="450"><br>
  
</details>

##### Invalidations check
<details>
  <summary></a><b>...</b></summary><br>

  Run the folowing snippet to analyze invalidations:
  ```julia
  using SnoopCompileCore
  
  invalidations = @snoopr using UnicodePlots
  tinf = @snoopi_deep UnicodePlots.precompile_workload()
  
  using SnoopCompile, AbstractTrees, PrettyTables  # must occur after `invalidations`
  
  print_tree(tinf; maxdepth = typemax(Int))
  
  trees = invalidation_trees(invalidations)
  trees = filtermod(UnicodePlots, trees; recursive = true)
  
  @show length(uinvalidated(invalidations))  # all invalidations
  
  # only from `UnicodePlots`
  @show length(staleinstances(tinf))
  @show length(trees)
  
  SnoopCompile.report_invalidations(;
     invalidations,
     process_filename = x -> last(split(x, ".julia/packages/")),
     n_rows = 0,
  )
  ```
  
  
</details>


##### Documentation update
<details>
  <summary></a><b>...</b></summary><br>

  The following snippet:
  ```bash
  $ cd docs
  $ julia gen_docs.jl
  $ (cd imgs; julia gen_imgs.jl)
  ```
  will regenerate `README.md` and the example images with root (prefix) url https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs.
  
  
</details>

## License

This code is free to use under the terms of the MIT license.

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille).

