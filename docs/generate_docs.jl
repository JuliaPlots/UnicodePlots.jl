using UnicodePlots
using Markdown
using Term
import Markdown: MD, Paragraph, plain

main() = begin
  warn = "WARNING: this file has been automatically generated, please update UnicodePlots/docs/generate_docs.jl instead"
  docs_url = "https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs"
  ver = "2.10"

  exs = (
    lineplot1 = ("Basic Canvas", """
      using UnicodePlots
      plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
                     title="Example Plot", name="my line", xlabel="x", ylabel="y")
      """),
    lineplot2 = ("Basic Canvas", """
      lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
               title="Example Plot", name="my line",
               xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii)
      """),
    lineplot3 = ("Basic Canvas", "lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name=\"other line\")"),
    scatterplot1 = ("Scatterplot", "scatterplot(randn(50), randn(50), title=\"My Scatterplot\")"),
    scatterplot2 = ("Scatterplot", "scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln)"),
    scatterplot3 = ("Scatterplot", "scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, unicode_exponent=false)"),
    scatterplot4 = ("Scatterplot", """
      scatterplot([1, 2, 3], [3, 4, 1],
                  marker=[:circle, '', "∫"], color=[:red, nothing, :yellow])
      """),
    lineplot4 = ("Lineplot", "lineplot([1, 2, 7], [9, -6, 8], title=\"My Lineplot\")"),
    lineplot5 = ("Lineplot", "plt = lineplot([cos, sin], -π/2, 2π)"),
    lineplot6 = ("Lineplot", "lineplot!(plt, -.5, .2, name=\"line\")"),
    lineplot7 = ("Lineplot", """
      using Unitful
      a = 1u"m/s^2"
      t = (0:100) * u"s"
      lineplot(a / 2 * t .^ 2, a * t, xlabel = "position", ylabel = "speed")
      """),
    stairs1 = ("Staircase", """
      # supported style are :pre and :post
      stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7],
             color=:red, style=:post, title="My Staircase Plot")
      """),
    barplot1 = ("Barplot", """
      barplot(["Paris", "New York", "Moskau", "Madrid"],
              [2.244, 8.406, 11.92, 3.165],
              title="Population")
      """),
    histogram1 = ("Histogram", "histogram(randn(1_000) .* .1, nbins=15, closed=:left)"),
    histogram2 = ("Histogram", "histogram(randn(1_000) .* .1, nbins=15, closed=:right, xscale=:log10)"),
    histogram3 = ("Histogram", "histogram(randn(100_000) .* .1, nbins=60, vertical=true)"),
    boxplot1 = ("Boxplot", "boxplot([1, 3, 3, 4, 6, 10])"),
    boxplot2 = ("Boxplot", """
      boxplot(["one", "two"],
              [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
              title="Grouped Boxplot", xlabel="x")
      """),
    spy1 = ("Spy", "using SparseArrays\nspy(sprandn(50, 120, .05))"),
    spy2 = ("Spy", "using SparseArrays\nspy(sprandn(50, 120, .9), show_zeros=true)"),
    densityplot1 = ("Densityplot", """
      plt = densityplot(randn(10_000), randn(10_000))
      densityplot!(plt, randn(10_000) .+ 2, randn(10_000) .+ 2)
      """),
    densityplot2 = ("Densityplot", """
      x = randn(10_000); x[1_000:6_000] .= 2
      densityplot(x, randn(10_000); zscale = x -> log(1 + x))
      """),
    contourplot1 = ("Contourplot", "contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2))"),
    polarplot1 = ("Polarplot", "polarplot(range(0, 2π, length = 20), range(0, 2, length = 20))"),
    heatmap1 = ("Heatmap", "heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel=\"z\")"),
    heatmap2 = ("Heatmap", "heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno)"),
    surfaceplot1 = ("Surfaceplot", """
      sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
      surfaceplot(-8:.5:8, -8:.5:8, sombrero, colormap=:jet)
      """),
    surfaceplot2 = ("Surfaceplot", """
      surfaceplot(
        -2:2, -2:2, (x, y) -> 15sinc(√(x^2 + y^2) / π),
        zscale=z -> 0, lines=true, colormap=:jet
      )
      """),
    isosurface = ("Isosurface", """
      torus(x, y, z, r=0.2, R=0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
      isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus, cull=true, zoom=2, elevation=50)
      """),
    width = ("Width", "lineplot(sin, 1:.5:20, width=60)"),
    height = ("Height", "lineplot(sin, 1:.5:20, height=18)"),
    labels = ("Labels", "lineplot(sin, 1:.5:20, labels=false)"),
    border_dashed = ("Border", "lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed)"),
    border_ascii = ("Border", "lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:ascii)"),
    border_bold = ("Border", "lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold)"),
    border_dotted = ("Border", "lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:dotted)"),
    border_none = ("Border", "lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:none)"),
    decorate = ("Decorate", """
      x = y = collect(1:10)
      plt = lineplot(x, y, canvas=DotCanvas, width=30, height=10)
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
      """),
    canvas = ("Canvas", """
      canvas = BrailleCanvas(40, 15,                    # number of columns and rows (characters)
                             origin_x=0., origin_y=0.,  # position in virtual space
                             width=1., height=1.)       # size of the virtual space
      lines!(canvas, 0., 0., 1., 1., :blue)             # virtual space
      points!(canvas, rand(50), rand(50), :red)         # virtual space
      lines!(canvas, 0., 1., .5, 0., :yellow)           # virtual space
      pixel!(canvas, 5, 8, :red)                        # pixel space
      Plot(canvas)
      """),
    blending = ("Blending", """
      canvas = BrailleCanvas(40, 15, origin_x=0., origin_y=0., width=1., height=1.)
      lines!(canvas, 0., 0., 1., 1., :blue)
      lines!(canvas, .25, 1., .5, 0., :yellow)
      lines!(canvas, .2, .8, 1., 0., :red)
      Plot(canvas)
      """),
  )

  plain_md_par(x) = x |> Paragraph |> MD |> plain

  examples = NamedTuple{keys(exs)}(
    (plain_md_par("```julia\n$(rstrip(e[2]))\n```\n<img src=\"$docs_url/$ver/$k.png\" width=\"500\"><br>") for (k, e) in pairs(exs))
  )

  tab = ' '^2

  indent(x, n) = repeat(tab, n) * join(split(x, '\n'), '\n' * repeat(tab, n))
  desc_ex(k, d, n=2) = (
    if k ≡ :border
      join((
        d,
        indent(examples.border_dashed, n),
        indent(examples.border_ascii, n),
        indent(examples.border_bold, n),
        indent(examples.border_dotted, n),
        indent(examples.border_none, n),
      ), '\n')
    elseif k in (:width, :height, :labels)
      join((d, indent(getindex(examples, k), n)), '\n')
    else
      d
    end
  )

  anchor(name) = replace(lowercase(name), ' ' => '-')
  summary(name) = "<summary><a name=$(anchor(name))></a><b>$(name)</b></summary><br>"  # named anchor + formatting

  methods = plain_md_par("""
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
  $(plain_md_par(indent(examples.decorate, 2)))

    - `annotate!(plot::Plot, x::Number, y::Number, text::AbstractString; kw...)`
      - `text` arbitrary annotation at position (x, y)
  """)

  low_level_interface = plain_md_par("""
  The primary structures that do all the heavy lifting behind the curtain are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. Basically, it uses Unicode characters to represent pixel.

  Here is a simple example:

  $(examples.canvas)

  You can access the height and width of the canvas (in characters) with `nrows(canvas)` and `ncols(canvas)` respectively. You can use those functions in combination with `printrow` to embed the canvas anywhere you wish. For example, `printrow(STDOUT, canvas, 3)` writes the third character row of the canvas to the standard output.

  As you can see, one issue that arises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the "pixel" of a character could belong to a different color group (each character can only have a single color). This package deals with this using a color-blend for the whole group. You can disable canvas color blending / mixing by passing `blend=false` to any function.

  $(examples.blending)

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
  """)

  kw_description = plain_md_par("""
  All plots support the set (or a subset) of the following named parameters:

  $(join(
    (
      "$tab- `$(UnicodePlots.default_with_type(k))`: $(desc_ex(k, d * '.'))"
      for (k, d) in pairs(UnicodePlots.DESCRIPTION) if k in keys(UnicodePlots.KEYWORDS)
    ), '\n'
  ))

  _Note_: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).
  """)

  installation = plain_md_par("""
  To install UnicodePlots, start up `Julia` and type the following code snippet into the `REPL` (makes use of the native `Julia` package manager `Pkg`):
  ```julia
  julia> using Pkg
  julia> Pkg.add("UnicodePlots")
  ```
  """)

  doc_update = plain_md_par("""
  The following snippet:
  ```bash
  \$ cd docs
  \$ julia generate_docs.jl
  \$ (cd imgs; julia gen_imgs.jl)
  ```
  will regenerate `README.md` and the example images with root (prefix) url $(docs_url).
  """)

  readme = plain_md_par("""
# UnicodePlots

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.named.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.html)
[![CI](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml)
[![Coverage Status](https://codecov.io/gh/JuliaPlots/UnicodePlots.jl/branch/master/graphs/badge.svg?branch=master)](https://app.codecov.io/gh/JuliaPlots/UnicodePlots.jl)
[![JuliaHub deps](https://juliahub.com/docs/UnicodePlots/deps.svg)](https://juliahub.com/ui/Packages/UnicodePlots/Ctj9q?t=2)
[![UnicodePlots Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/UnicodePlots)](https://pkgs.genieframework.com?packages=UnicodePlots)

Advanced [`Unicode`](https://en.wikipedia.org/wiki/Unicode) plotting library designed for use in `Julia`'s `REPL`.

<img src="$docs_url/$ver/banner.png" width="800">

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
  $(summary("Introduction"))

  Here is a quick hello world example of a typical use-case:

  $(examples.lineplot1)

  There are other types of `Canvas` available (see section [Low-level Interface](https://github.com/JuliaPlots/UnicodePlots.jl#low-level-interface)).

  In some situations, such as printing to a file, using `AsciiCanvas`, `DotCanvas` or `BlockCanvas` might lead to better results:

  $(examples.lineplot2)

  Some plot methods have a mutating variant that ends with a exclamation mark:

  $(examples.lineplot3)

  Physical quantities of [`Unitful.jl`](https://github.com/PainterQubits/Unitful.jl) are supported on a subset of plotting methods.

</details>

<details open>
  $(summary("Scatterplot"))

  $(examples.scatterplot1)

  Axis scaling (`xscale` and/or `yscale`) is supported: choose from (`:identity`, `:ln`, `:log2`, `:log10`) or use an arbitrary scale function:

  $(examples.scatterplot2)

  For the axis scale exponent, one can revert to using `ASCII` characters instead of `Unicode` ones using the keyword `unicode_exponent=false`:

  $(examples.scatterplot3)

  Using a `marker` is supported, choose a `Char`, a unit length `String` or a symbol name such as `:circle` (more from `keys(UnicodePlots.MARKERS)`).
  One can also provide a vector of `marker`s and/or `color`s as in the following example:

  $(examples.scatterplot4)

  As with `lineplot`, `scatterplot` supports plotting physical `Unitful` quantities.
</details>

<details open>
  $(summary("Lineplot"))

  $(examples.lineplot4)

  It's also possible to specify a function and a range:

  $(examples.lineplot5)

  You can also plot lines by specifying an intercept and slope:

  $(examples.lineplot6)

  Physical units are supported through `Unitful`:

  $(examples.lineplot7)
</details>

<details open>
  $(summary("Staircase plot"))

  $(examples.stairs1)
</details>

<details open>
  $(summary("Barplot"))

  $(examples.barplot1)

  _Note_: You can use the keyword argument `symbols` to specify the characters that should be used to plot the bars (e.g. `symbols=['#']`).
</details>

<details open>
  $(summary("Histogram"))

  $(examples.histogram1)

  The `histogram` function also supports axis scaling using the parameter `xscale`:

  $(examples.histogram2)

  Vertical histograms are supported:

  $(examples.histogram3)
</details>

<details open>
  $(summary("Boxplot"))

  $(examples.boxplot1)

  $(examples.boxplot2)
</details>

<details open>
  $(summary("Sparsity Pattern"))

  $(examples.spy1)

  Plotting the zeros pattern is also possible using `show_zeros=true`:

  $(examples.spy2)
</details>

<details open>
  $(summary("Density Plot"))

  $(examples.densityplot1)

  Using a monotonically increasing scale for damping peaks is supported using the `zscale` keyword:

  $(examples.densityplot2)
</details>

<details open>
  $(summary("Contour Plot"))

  $(examples.contourplot1)

  The keyword `levels` controls the number of contour levels. One can also choose a `colormap` as with `heatmap`, and disable the colorbar using `colorbar=false`.
</details>

<details open>
  $(summary("Heatmap Plot"))

  $(examples.heatmap1)

  The `heatmap` function also supports axis scaling using the parameters `xfact`, `yfact` and axis offsets after scaling using `xoffset` and `yoffset`.

  The `colormap` parameter may be used to specify a named or custom colormap. See the `heatmap` function documentation for more details.

  In addition, the `colorbar` and `colorbar_border` options may be used to toggle the colorbar and configure its border.

  The `zlabel` option and `zlabel!` method may be used to set the `z` axis (colorbar) label.

  $(examples.heatmap2)
</details>

<details open>
  $(summary("Polar Plot"))

  Plots data in polar coordinates with `θ` the angles in radians.

  $(examples.polarplot1)

</details>

<details open>
  $(summary("Surface Plot"))

  Plots a colored surface using height values `z` above a `x-y` plane, in three dimensions (masking values using `NaN`s is supported).

  $(examples.surfaceplot1)

  Use `lines=true` to increase the density (underlying call to `lineplot` instead of `scatterplot`, with color interpolation).
  To plot a slice in 3D, use an anonymous function which maps to a constant value: `zscale=z -> a_constant`:

  $(examples.surfaceplot2)
</details>

<details open>
  $(summary("Isosurface Plot"))

  Uses [`MarchingCubes.jl`](https://github.com/JuliaGeometry/MarchingCubes.jl) to extract an isosurface, where `isovalue` controls the surface isovalue.
  Using `centroid` enables plotting the triangulation centroids instead of the triangle vertices (better for small plots).
  Back face culling (hide not visible facets) can be activated using `cull=true`.
  One can use the legacy 'Marching Cubes' algorithm using `legacy=true`.

  $(examples.isosurface)
</details>

## Documentation

<details>
  $(summary("Installation"))

  $(installation)
</details>

<details>
  $(summary("Saving figures"))

  Saving plots as `png` or `txt` files using the `savefig` command is supported (saving as `png` is experimental and resulting images might slightly change without warnings).

  To recover the plot as a string with ansi color codes use `string(p; color=true)`.
</details>

<details>
  $(summary("Color mode"))

  When the `COLORTERM` environment variable is set to either `24bit` or `truecolor`, `UnicodePlots` will use [24bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit) as opposed to [8bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) or even [4bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit) for named colors.

  One can force a specific colormode using either `UnicodePlots.truecolors!()` or `UnicodePlots.colors256!()`.

  Named colors such as `:red` or `:light_red` will use `256` color values (rendering will be terminal dependent). In order to force named colors to use true colors instead, use `UnicodePlots.USE_LUT[]=true`.

  The default color cycle can be changed to bright (high intensity) colors using `UnicodePlots.brightcolors!()` instead of the default `UnicodePlots.faintcolors!()`.
</details>

<details>
  $(summary("3D plots"))

  3d plots use a so-called "Model-View-Projection" transformation matrix `MVP` on input data to project 3D plots to a 2D screen.

  Use keywords`elevation`, `azimuth`, `up` or `zoom` to control the "View" matrix, a.k.a., camera.

  The `projection` type for `MVP` can be set to either `:perspective` or `:orthographic`.

  Displaying the `x`, `y`, and `z` axes can be controlled using the `axes3d` keyword.

  For enhanced resolution, use a wider and/or taller `Plot` (this can be achieved using `default_size!(width=60)` for all future plots).
</details>

<details>
  $(summary("Layout"))

  `UnicodePlots` is integrated in [`Plots`](https://github.com/JuliaPlots/Plots.jl) as a backend, with support for [basic layout](https://docs.juliaplots.org/stable/gallery/unicodeplots/generated/unicodeplots-ref17).

  For a more complex layout, use the [`grid`](https://fedeclaudi.github.io/Term.jl/dev/layout/grid) function from [`Term`](https://github.com/FedeClaudi/Term.jl).
</details>

<details>
  $(summary("Know Issues"))

  Using a non `true monospace font` can lead to visual problems on a `BrailleCanvas` (border versus canvas).

  Either change the font to e.g. [JuliaMono](https://juliamono.netlify.app/) or use `border=:dotted` keyword argument in the plots.

  For a `Jupyter` notebook with the `IJulia` kernel see [here](https://juliamono.netlify.app/faq/#can_i_use_this_font_in_a_jupyter_notebook_and_how_do_i_do_it).

  (Experimental) Terminals seem to respect a standard aspect ratio of `4:3`, hence a square matrix does not often look square in the terminal.

  You can pass the experimental keyword `fix_ar=true` to `spy` or `heatmap` in order to recover a unit aspect ratio.
</details>

<details>
  $(summary("Methods (API)"))

  $(methods)
</details>

<details>
  $(summary("Keywords description (API)"))

  $(kw_description)
</details>

<details>
  $(summary("Low-level Interface"))

  $(low_level_interface)
</details>

<details>
  $(summary("Documentation update"))

  $(doc_update)
</details>

## License

This code is free to use under the terms of the MIT license.

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille).
""")

  mkpath("imgs/$ver")

  fix_rand(c) = replace(c, r"\bsprandn\b\(" => "_stable_sprand(rng, ", r"\brandn\b\(" => "randn(rng, ", r"\brand\b\(" => "rand(rng, ")

  open("imgs/gen_imgs.jl", "w") do io
    banner = """
    banner() = begin
      rng = StableRNG(1337)
      default_size!(height=10)

      panel(plt; kw...) = Panel(string(plt, color=true); fit=true, kw...)

      panels = (
        line = panel(lineplot(t -> exp(-.15t) * sinpi(.5t), xlabel="t", ylabel="y(t)", name = "decay"); title="lineplot", style="orange1"),
        scat = panel(scatterplot(1:6, 1:6, xscale=:log10, yscale=:ln); title="scatterplot", style="yellow1"),
        cont = panel(contourplot(-3:.01:3, -7:.01:3, (x, y) -> exp(-(x / 2)^2 - ((y + 2) / 4)^2)); title="contourplot", style="red1"),
        surf = panel(surfaceplot(-8:.5:8, -8:.5:8, (x, y) -> 15sinc(√(x^2 + y^2) / π)); title="surfaceplot", style="royal_blue1"),
        iso = panel(isosurface(-1:.1:1, -1:.1:1, -1:.1:1, (x, y, z) -> (√(x^2 + y^2) - 0.5)^2 + z^2 - 0.2^2, cull=true, zoom=2, elevation=50); title="isosurface", style="cornsilk1"),
        vhist = panel(histogram(randn(100_000), nbins=60, vertical=true); title="vertical histogram", style="green1"),
        hhist = panel(histogram(randn(1_000) .* 0.1, nbins=15); title="horizontal histogram", style="dodger_blue2"),
        dens = panel(densityplot(randn(1_000), randn(1_000)); title="densityplot", style="cyan1"),
        hmap = panel(heatmap(collect(0:20) * collect(0:20)', xfact=.1, yfact=.1); title="heatmap", style="magenta1"),
        bar = panel(barplot(["Paris", "New York", "Madrid"], [2.244, 8.406, 3.165]); title="barplot", style="gold1"),
        polar = panel(polarplot(range(0, 2π, length = 20), range(0, 2, length = 20)); title="polarplot", style="chartreuse1"),
        box = panel(boxplot(["one", "two"], [collect(1:5), collect(4:9)]); title="boxplot", style="grey11"),
        stair = panel(stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 2]); title="stair", style="aquamarine1"),
        spy = panel(spy([1 -1 0; -1 2 1; 0 -1 1]); title="spy", style="salmon1"),
      )
      g = grid(panels, layout=:((line * scat * polar * stair) / (dens * cont * surf * iso) / (hhist * vhist * (bar / (box * spy)))))

      if true
        cursor_hide(stdout)
        run(`clear`)
        print(stdout, g)
        win = if "WINDOWID" in keys(ENV)
          ENV["WINDOWID"]
        else
          readchomp(`xdotool getactivewindow`)
        end
        run(`import -window \$win $ver/banner.png`)
        cursor_show(stdout)
      else
        print(stdout, g)
        open("$ver/banner.txt", "w") do io
          print(io, g)
        end
      end
    end
    """

    println(io, """
      # $warn
      using UnicodePlots, StableRNGs, SparseArrays, Unitful, Term

      # UnicodePlots.brightcolors!()

      include(joinpath(dirname(pathof(UnicodePlots)), "..", "test", "fixes.jl"))

      cursor_hide(io::IO) = print(io, "\e[?25l")
      cursor_show(io::IO) = print(io, "\e[?25h")

      $(fix_rand(banner))

      main() = begin
        rng = StableRNG(1337)

        bb = parse(Bool, get(ENV, "BB", "false")) ? 9 : nothing
        bb_glyph = parse(Bool, get(ENV, "BB_GL", "false")) ? 8 : nothing

        banner()
      """
    )
    for (i, (k, e)) in enumerate(pairs(exs))
      println(io, "  # $k")
      code = fix_rand.(filter(x -> length(x) != 0 && !startswith(lstrip(x), r"using|import"), [lstrip(c) for c in split(e[2], '\n')]))
      println(io, """
          println("ex n°$i - $k")
          default_size!()
          _func_$i(rng) = begin
          $(indent(join(code, '\n'), 1))
          end
          plt = _func_$i(rng)
          display(plt)
          savefig(plt, "$ver/$k.png"; transparent=false, bounding_box=bb, bounding_box_glyph=bb_glyph, pixelsize=32)
          # savefig(plt, "$ver/$k.txt"; color=true)
        """
      )
    end
    println(io, "  return\nend\nmain()")
  end

  write(stdout, readme)
  open("../README.md", "w") do io
    write(io, "<!-- $warn, and run \$ julia generate_docs.jl to render README.md !! -->\n")
    write(io, readme)
  end
  return
end

main()

#=
open("imgs/gen_all.sh", "w") do io
  write(io, """
    #!/usr/bin/env bash
    # $warn

    echo '== julia =='
    \${JULIA-julia} gen_imgs.jl

    txt2png() {
      html=\${1%.txt}.html
      cat \$1 | \${ANSI2HTML-ansi2html} --input-encoding=utf-8 --output-encoding=utf-8 >\$html
      sed -i "s,background-color: #000000,background-color: #282828," \$html
      \${WKHTMLTOIMAGE-wkhtmltoimage} --quiet --quality 85 \$html \${html%.html}.png
    }
    echo '== txt2png =='
    for f in $ver/*.txt; do
      txt2png \$f & pids+=(\$!)
    done
    wait \${pids[@]}
    rm $ver/*.txt
    rm $ver/*.html
    """
  )
end
=#