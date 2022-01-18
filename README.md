# UnicodePlots

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.named.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnicodePlots.html)
[![CI](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaPlots/UnicodePlots.jl/actions/workflows/ci.yml)
[![Coverage Status](https://codecov.io/gh/JuliaPlots/UnicodePlots.jl/branch/master/graphs/badge.svg?branch=master)](https://app.codecov.io/gh/JuliaPlots/UnicodePlots.jl)
[![UnicodePlots Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/UnicodePlots)](https://pkgs.genieframework.com?packages=UnicodePlots)

Advanced Unicode plotting library designed for use in Julia's `REPL`.

`UnicodePlots` is integrated in [`Plots`](https://github.com/JuliaPlots/Plots.jl) as a backend, with support for [layouts](https://docs.juliaplots.org/stable/generated/unicodeplots/#unicodeplots-ref17).

## High-level Interface

There are a couple of ways to generate typical plots without much verbosity.
Here is a list of the main high-level functions for common scenarios:

  - Scatterplot
  - Lineplot
  - Staircase Plot
  - Barplot (horizontal)
  - Histogram (horizontal)
  - Boxplot (horizontal)
  - Sparsity Pattern
  - Density Plot
  - Heatmap

Here is a quick hello world example of a typical use-case:

```julia
using UnicodePlots
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
               title="Example Plot", name="my line", xlabel="x", ylabel="y", border=:dotted)
```

![Basic Canvas](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/lineplot1.png)

There are other types of `Canvas` available (see section "Low-level Interface").
In some situations, such as printing to a file, using `AsciiCanvas`, `DotCanvas` or `BlockCanvas` might lead to better results:

```julia
lineplot([-1, 2, 3, 7], [-1, 2, 9, 4],
         title="Example Plot", name="my line",
         xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii)
```

![Basic Canvas](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/lineplot2.png)

Some plot methods have a mutating variant that ends with a exclamation mark:

```julia
lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:blue, name="other line")
```

![Basic Canvas](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/lineplot3.png)

#### Scatterplot

```julia
scatterplot(randn(50), randn(50), title="My Scatterplot", border=:dotted)
```
![Scatterplot Screenshot1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/scatterplot1.png)

Axis scaling (`xscale` and/or `yscale`) is supported: choose from (`:identity`, `:ln`, `:log2`, `:log10`) or use an arbitrary scale function:

```julia
scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted)
```
![Scatterplot Screenshot2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/scatterplot2.png)

For the axis scale exponent, one can revert to using `ASCII` characters instead of `Unicode` ones using the keyword `unicode_exponent=false`:

```julia
scatterplot(1:10, 1:10, xscale=:log10, yscale=:ln, border=:dotted, unicode_exponent=false)
```
![Scatterplot Screenshot3](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/scatterplot3.png)

Using a `marker` is supported, choose a `Char`, a unit length `String` or a symbol name such as `:circle` (more from `keys(UnicodePlots.MARKERS)`).
One can also provide a vector of `marker`s and/or `color`s as in the following example:

```julia
scatterplot([1, 2, 3], [3, 4, 1],
            marker=[:circle, '😀', "∫"], color=[:red, nothing, :yellow], border=:dotted)
```
![Scatterplot Screenshot4](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/scatterplot4.png)

#### Lineplot

```julia
lineplot([1, 2, 7], [9, -6, 8], title="My Lineplot", border=:dotted)
```
![Lineplot Screenshot1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/lineplot4.png)

It's also possible to specify a function and a range:

```julia
plt = lineplot([cos, sin], -π/2, 2π, border=:dotted)
```
![Lineplot Screenshot2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/lineplot5.png)

You can also plot lines by specifying an intercept and slope:

```julia
lineplot!(plt, -.5, .2, name="line")
```
![Lineplot Screenshot3](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/lineplot6.png)

#### Staircase plot

```julia
# supported style are :pre and :post
stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7],
       color=:red, style=:post, title="My Staircase Plot", border=:dotted)
```
![Staircase Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/stairs1.png)

#### Barplot

Accepts either two vectors or a dictionary:

```julia
barplot(["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title="Population")
```
![Barplot Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/barplot1.png)

_Note_: You can use the keyword argument `symbols` to specify the characters that should
be used to plot the bars. For example `symbols=["#"]`

#### Histogram

```julia
histogram(randn(1000) .* .1, nbins=15, closed=:left)
```
![Histogram Screenshot 1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/histogram1.png)

The `histogram` function also supports axis scaling using the parameter `xscale`:

```julia
histogram(randn(1000) .* .1, nbins=15, closed=:right, xscale=:log10)
```
![Histogram Screenshot 2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/histogram2.png)

#### Boxplot

```julia
boxplot([1, 3, 3, 4, 6, 10])
```
![Boxplot Screenshot 1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/boxplot1.png)

```julia
boxplot(["one", "two"],
        [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
        title="Grouped Boxplot", xlabel="x")
```
![Boxplot Screenshot 2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/boxplot2.png)

#### Sparsity Pattern

```julia
using SparseArrays
spy(sprandn(50, 120, .05), border=:dotted)
```
![Spy Screenshot 1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/spy1.png)

Plotting the zeros pattern is also possible using `show_zeros=true`:

```julia
using SparseArrays
spy(sprandn(50, 120, .9), show_zeros=true, border=:dotted)
```
![Spy Screenshot 2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/spy2.png)

#### Density Plot

```julia
plt = densityplot(randn(1000), randn(1000))
densityplot!(plt, randn(1000) .+ 2, randn(1000) .+ 2)
```
![Density Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/densityplot1.png)

#### Heatmap Plot

```julia
heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
```
![Heatmap Screenshot 1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/heatmap1.png)

The `heatmap` function also supports axis scaling using the parameters `xfact`, `yfact` and axis offsets after scaling using `xoffset` and `yoffset`.

The `colormap` parameter may be used to specify a named or custom colormap. See the `heatmap` function documentation for more details.

In addition, the `colorbar` and `colorbar_border` options may be used to enable/disable the colorbar and configure its border.
The `zlabel` option and `zlabel!` method may be used to set the z axis (colorbar) label.

```julia
heatmap(collect(0:30) * collect(0:30)', xfact=.1, yfact=.1, xoffset=-1.5, colormap=:inferno)
```

![Heatmap Screenshot 2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/heatmap2.png)

### Options

All plots support the set (or a subset) of the following named parameters:

- `title::String=""`:

    Text to display on the top of the plot.

- `name::String=""`:

    Annotation of the current drawing to displayed on the right

- `xlabel::String=""`:

    Description on the x-axis

- `ylabel::String=""`:

    Description on the y-axis

- `width::Int=40`:

    Number of characters per row that should be used for plotting.

    ```julia
    lineplot(sin, 1:.5:20, width=60)
    ```
    ![Width Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/width.png)

- `height::Int=20`:

    Number of rows that should be used for plotting. Not applicable to `barplot`.

    ```julia
    lineplot(sin, 1:.5:20, height=18)
    ```
    ![Height Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/height.png)

- `xlim::Vector=[0, 1]`:

    Plotting range for the x coordinate.

- `ylim::Vector=[0, 1]`:

    Plotting range for the y coordinate.

- `labels::Bool=true`:

    Can be used to hide the labels by setting `labels=false`.

  ```julia
  lineplot(sin, 1:.5:20, labels=false)
  ```
    ![Labels Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/labels.png)

- `border::Symbol=:solid`:

    The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:corners`, and `:none`.

  ```julia
  lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold)
  ```
  ![Border Screenshot 1](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/border_bold.png)
  ```julia
  lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed)
  ```
  ![Border Screenshot 2](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/border_dashed.png)
  ```julia
  lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:dotted)
  ```
  ![Border Screenshot 3](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/border_dotted.png)
  ```julia
  lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:none)
  ```
  ![Border Screenshot 4](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/border_none.png)

- `compact::Bool=false`:
    
    Compact plot (labels), defaults to `false`.

- `margin::Int=3`:

    Number of empty characters to the left of the whole plot.

- `padding::Int=1`:

    Space of the left and right of the plot between the labels and the canvas.

- `grid::Bool=true`:

    Can be used to hide the gridlines at the origin.

- `color::Symbol=:auto`:

    Color of the drawing. Can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`.

- `canvas::Type=BrailleCanvas`:

    The type of canvas that should be used for drawing (see section "Low-level Interface").

- `symbols::AbstractVector{String}=["▪"]`:

    Barplot only. Specifies the characters that should be used to render the bars.

_Note_: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).

### Methods

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

![Label Screenshot](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/decorate.png)

- `annotate!(plot::Plot, x::Number, y::Number, text::AbstractString; kwargs...)`
    - `text` arbitrary annotation at position (x, y)

## Know Issues

Using a non `true monospace font` can lead to visual problems on a `BrailleCanvas` (border versus canvas).
Either change the font to e.g. [JuliaMono](https://juliamono.netlify.app/) or use `border=:dotted` keyword argument in the plots.
For a `Jupyter` notebook with the `IJulia` kernel see [here](https://juliamono.netlify.app/faq/#can_i_use_this_font_in_a_jupyter_notebook_and_how_do_i_do_it).

Terminals seem to respect a standard aspect ratio of `4:3`, hence a square matrix will often no look square in the terminal.
As a fix, you can pass `correct_aspect_ratio=true` to `spy` or `heatmap` in order to recover a unit aspect ratio.

## Low-level Interface

The primary structures that do all the heavy lifting behind the curtain are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. Basically it uses Unicode characters to represent pixel.

Here is a simple example:

```julia
canvas = BrailleCanvas(40, 10,                    # number of columns and rows (characters)
                       origin_x=0., origin_y=0.,  # position in virtual space
                       width=1., height=1.)       # size of the virtual space
lines!(canvas, 0., 0., 1., 1., :blue)      # virtual space
points!(canvas, rand(50), rand(50), :red)  # virtual space
lines!(canvas, 0., 1., .5, 0., :yellow)    # virtual space
pixel!(canvas, 5, 8, :red)                 # pixel space
```

![Basic Canvas](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/canvas.png)

You can access the height and width of the canvas (in characters) with `nrows(canvas)` and `ncols(canvas)` respectively. You can use those functions in combination with `printrow` to embed the canvas anywhere you wish. For example, `printrow(STDOUT, canvas, 3)` writes the third character row of the canvas to the standard output.

As you can see, one issue that arises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the "pixel" of a character could belong to a different color group (each character can only have a single color). This package deals with this using a color-blend for the whole group.

![Blending Colors](https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs/doc/imgs/2.x/blending.png)

At the moment there are the following types of Canvas implemented:

  - **BrailleCanvas**:
    This type of canvas is probably the one with the highest resolution for `Unicode` plotting. It essentially uses the Unicode characters of the [Braille](https://en.wikipedia.org/wiki/Braille) symbols as pixels. This effectively turns every character into eight pixels that can individually be manipulated using binary operations.

  - **BlockCanvas**:
    This canvas is also `Unicode` based. It has half the resolution of the BrailleCanvas. In contrast to `BrailleCanvas`, the pixels don't have visible spacing between them. This canvas effectively turns every character into four pixels that can individually be manipulated using binary operations.

  - **HeatmapCanvas**:
    This canvas is also `Unicode` based. It has half the resolution of the `BlockCanvas`. This canvas effectively turns every character into two color pixels, using the foreground and background terminal colors. As such, the number of rows of the canvas is half the number of y coordinates being displayed.

  - **AsciiCanvas** and **DotCanvas**:
    These two canvas utilizes only standard `ASCII` character for drawing. Naturally, it doesn't look quite as nice as the Unicode-based ones. However, in some situations it might yield better results. Printing plots to a file is one of those situations.

  - **DensityCanvas**:
    Unlike the `BrailleCanvas`, the density canvas does not simply mark a "pixel" as set. Instead it increments a counter per character that keeps track of the frequency of pixels drawn in that character. Together with a variable that keeps track of the maximum frequency, the canvas can thus draw the density of datapoints.

  - **BarplotGraphics**:
    This graphics area is special in that it does not support any pixel manipulation. It is essentially the barplot without decorations but the numbers. It does only support one method `addrow!` which allows the user to add additional bars to the graphics object.

## Installation

To install UnicodePlots, start up Julia and type the following code snippet into the REPL (makes use of the native Julia package manager `Pkg`):

```julia
using Pkg
Pkg.add("UnicodePlots")
```

## Documentation update
Documentation images for `README.md` is stored in the `unicodeplots-docs` branch of this repository.

The following snippet:
```bash
cd doc
bash gen_imgs.sh
```
will regenerate the images with root (prefix) url https://github.com/JuliaPlots/UnicodePlots.jl/raw/unicodeplots-docs.

## License

This code is free to use under the terms of the MIT license.

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille)
