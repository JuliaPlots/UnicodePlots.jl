# UnicodePlots

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![Build Status](https://travis-ci.org/Evizero/UnicodePlots.jl.svg?branch=master)](https://travis-ci.org/Evizero/UnicodePlots.jl)
[![Coverage Status](https://coveralls.io/repos/Evizero/UnicodePlots.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/Evizero/UnicodePlots.jl?branch=master)

Advanced Unicode plotting library designed for use in Julia's REPL.

## High-level Interface

There are a couple of ways to generate typical plots without much
verbosity. Here is a list of the main high-level functions for
common scenarios:

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

```Julia
using UnicodePlots
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title = "Example Plot", name = "my line", xlabel = "x", ylabel = "y")
```

![Basic Canvas](https://user-images.githubusercontent.com/10854026/50774451-c0769480-1293-11e9-9f0f-82a6085900ff.png)

There are other types of `Canvas` available (see section
"Low-level Interface"). In some situations, such as printing to
a file, using `AsciiCanvas`, `DotCanvas` or `BlockCanvas` might
lead to better results.

```Julia
lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title = "Example Plot", name = "my line", xlabel = "x", ylabel = "y", canvas = DotCanvas, border = :ascii)
```

![Basic Canvas](https://user-images.githubusercontent.com/10854026/50768477-e5add780-1280-11e9-9541-55d937d7d605.png)

Every plot has a mutating variant that ends with a exclamation mark.

```Julia
lineplot!(plt, [0, 4, 8], [10, 1, 10], color = :blue, name = "other line")
```

![Basic Canvas](https://user-images.githubusercontent.com/10854026/50768478-e5add780-1280-11e9-93e3-a7fa35a79a6d.png)

#### Scatterplot

```Julia
scatterplot(randn(50), randn(50), title = "My Scatterplot")
```
![Scatterplot Screenshot](https://user-images.githubusercontent.com/10854026/50768727-c19ec600-1281-11e9-81de-5710083fe814.png)

#### Lineplot

```Julia
lineplot([1, 2, 7], [9, -6, 8], title = "My Lineplot")
```
![Lineplot Screenshot1](https://user-images.githubusercontent.com/10854026/50768724-c1062f80-1281-11e9-9fd0-fdf994be6db4.png)

It's also possible to specify a function and a range.

```Julia
plt = lineplot([cos, sin], -π/2, 2π)
```
![Lineplot Screenshot2](https://user-images.githubusercontent.com/10854026/50768725-c1062f80-1281-11e9-8a30-ded2671d3781.png)

You can also plot lines by specifying an intercept and slope

```Julia
lineplot!(plt, -0.5, .2, name = "line")
```
![Lineplot Screenshot3](https://user-images.githubusercontent.com/10854026/50768726-c1062f80-1281-11e9-8784-f2d3d4183547.png)

#### Staircase plot

```Julia
# supported style are :pre and :post
stairs([1, 2, 4, 7, 8], [1, 3, 4, 2, 7], color = :red, style = :post, title = "My Staircase Plot")
```
![Staircase Screenshot](https://user-images.githubusercontent.com/10854026/50768787-0fb3c980-1282-11e9-9b3c-8b66aae57a37.png)

#### Barplot

Accepts either two vectors or a dictionary

```Julia
barplot(["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Population")
```
![Barplot Screenshot](https://user-images.githubusercontent.com/10854026/50764892-74682780-1274-11e9-9861-cdcd31fa3cf0.png)

_Note_: You can use the keyword argument `symb` to specify the character that should
be used to plot the bars. For example `symb = "#"`

#### Histogram

```Julia
histogram(randn(1000) .* 0.1, nbins = 15, closed = :left)
```
![Histogram Screenshot 1](https://user-images.githubusercontent.com/10854026/50764895-7500be00-1274-11e9-9b99-aac93afa1247.png)

The `histogram` function also supports axis scaling using the
parameter `xscale`.

```Julia
histogram(randn(1000) .* 0.1, nbins = 15, closed = :right, xscale=log10)
```
![Histogram Screenshot 2](https://user-images.githubusercontent.com/10854026/50764896-7500be00-1274-11e9-9326-7f76091099f2.png)

#### Boxplot

```Julia
boxplot([1,3,3,4,6,10])
```
![Boxplot Screenshot 1](https://user-images.githubusercontent.com/10854026/50764893-74682780-1274-11e9-9f45-0ce5ac95f129.png)

```Julia
boxplot(["one", "two"], [[1,2,3,4,5], [2,3,4,5,6,7,8,9]], title="Grouped Boxplot", xlabel="x")
```
![Boxplot Screenshot 2](https://user-images.githubusercontent.com/10854026/50764894-7500be00-1274-11e9-8608-5dc9517730cc.png)

#### Sparsity Pattern

```Julia
using SparseArrays
spy(sprandn(50, 120, .05))
```
![Spy Screenshot](https://user-images.githubusercontent.com/10854026/50768479-e5add780-1280-11e9-8304-d90661465cfa.png)

#### Density Plot

```Julia
plt = densityplot(randn(1000), randn(1000))
densityplot!(plt, randn(1000) .+ 2, randn(1000) .+ 2)
```
![Density Screenshot](https://user-images.githubusercontent.com/10854026/50768809-28bc7a80-1282-11e9-917a-0ee22d1b274a.png)

#### Heatmap Plot

```Julia
heatmap(repeat(collect(0:10)', outer=(11, 1)), zlabel="z")
```
![Heatmap Screenshot](https://user-images.githubusercontent.com/1258076/59729642-9a154600-9282-11e9-8f55-db586bc4a749.png)

The `heatmap` function also supports axis scaling using the
parameters `xscale`, `yscale` and axis offsets after scaling using `xoffset` and `yoffset`.

The `colormap` parameter may be used to specify a named or custom colormap. See the `heatmap` function documentation for more details.

In addition, the `colorbar` and `colorbar_border` options may be used to enable/disable
the colorbar and configure its border. The `zlabel` option and `zlabel!` method
may be used to set the z axis (colorbar) label.

```Julia
heatmap(collect(0:30) * collect(0:30)', xscale=0.1, yscale=0.1, xoffset=-1.5, colormap=:inferno)
```

![Heatmap Screenshot 2](https://user-images.githubusercontent.com/1258076/59735239-21b97f80-9298-11e9-9aef-ad4da8ff3d92.png)

### Options

All plots support the set (or a subset) of the following named
parameters.

- `title::String = ""`:

    Text to display on the top of the plot.

- `name::String = ""`:

    Annotation of the current drawing to displayed on the right

- `xlabel::String = ""`:

    Description on the x-axis

- `ylabel::String = ""`:

    Description on the y-axis

- `width::Int = 40`:

    Number of characters per row that should be used for plotting.

    ```Julia
    lineplot(sin, 1:.5:20, width = 80)
    ```
    ![Width Screenshot](doc/img/width.png)

- `height::Int = 20`:

    Number of rows that should be used for plotting. Not applicable to `barplot`.

    ```Julia
    lineplot(sin, 1:.5:20, height = 18)
    ```
    ![Height Screenshot](doc/img/height.png)

- `xlim::Vector = [0, 1]`:

    Plotting range for the x coordinate

- `ylim::Vector = [0, 1]`:

    Plotting range for the y coordinate

- `margin::Int = 3`:

    Number of empty characters to the left of the whole plot.

- `border::Symbol = :solid`:

    The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:corners`, and `:none`.

  ```Julia
  lineplot([-1.,2, 3, 7], [1.,2, 9, 4], border=:bold)
  lineplot([-1.,2, 3, 7], [1.,2, 9, 4], border=:dashed)
  lineplot([-1.,2, 3, 7], [1.,2, 9, 4], border=:dotted)
  lineplot([-1.,2, 3, 7], [1.,2, 9, 4], border=:none)
  ```
    ![Border Screenshot](doc/img/border.png)

- `padding::Int = 1`:

    Space of the left and right of the plot between the labels and the canvas.

- `labels::Bool = true`:

    Can be used to hide the labels by setting `labels=false`.

  ```Julia
  lineplot(sin, 1:.5:20, labels=false)
  ```
    ![Labels Screenshot](doc/img/labels.png)

- `grid::Bool = true`:

    Can be used to hide the gridlines at the origin

- `color::Symbol = :auto`:

    Color of the drawing. Can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`.

- `canvas::Type = BrailleCanvas`:

    The type of canvas that should be used for drawing (see section "Low-level Interface")

- `symb::AbstractString = "▪"`:

    Barplot only. Specifies the character that should be used to render the bars

_Note_: If you want to print the plot into a file but have monospace issues with your font, you should probably try `border = :ascii` and `canvas = AsciiCanvas` (or `canvas = DotCanvas` for scatterplots).

### Methods

- `title!(plot::Plot, title::String)`

    - `title` the string to write in the top center of the plot window. If the title is empty the whole line of the title will not be drawn

- `xlabel!(plot::Plot, xlabel::String)`

    - `xlabel` the string to display on the bottom of the plot window. If the title is empty the whole line of the label will not be drawn

- `ylabel!(plot::Plot, xlabel::String)`

    - `ylabel` the string to display on the far left of the plot window.

The method `annotate!` is responsible for the setting all the textual decorations of a plot. It has two functions:

- `annotate!(plot::Plot, where::Symbol, value::String)`

    - `where` can be any of: `:tl` (top-left), `:t` (top-center), `:tr` (top-right), `:bl` (bottom-left), `:b` (bottom-center), `:br` (bottom-right), `:l` (left), `:r` (right)

- `annotate!(plot::Plot, where::Symbol, row::Int, value::String)`

    - `where` can be any of: `:l` (left), `:r` (right)

    - `row` can be between 1 and the number of character rows of the canvas

![Annotate Screenshot](doc/img/annotate.png)

## Low-level Interface

The primary structures that do all the heavy lifting behind the curtain are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. Basically it uses Unicode characters to represent pixel.

Here is a simple example:

```Julia
canvas = BrailleCanvas(40, 10, # number of columns and rows (characters)
                       origin_x = 0., origin_y = 0., # position in virtual space
                       width = 1., height = 1.)    # size of the virtual space
lines!(canvas, 0., 0., 1., 1., :blue)     # virtual space
points!(canvas, rand(50), rand(50), :red) # virtual space
lines!(canvas, 0., 1., .5, 0., :yellow)   # virtual space
pixel!(canvas, 5, 8, :red)                # pixel space
```

![Basic Canvas](doc/img/canvas.png)

You can access the height and width of the canvas (in characters) with `nrows(canvas)` and `ncols(canvas)` respectively. You can use those functions in combination with `printrow` to embed the canvas anywhere you wish. For example, `printrow(STDOUT, canvas, 3)` writes the third character row of the canvas to the standard output.

As you can see, one issue that arises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the "pixel" of a character could belong to a different color group (each character can only have a single color). This package deals with this using a color-blend for the whole group.

![Blending Colors](doc/img/braille.png)

At the moment there are the following types of Canvas implemented:

  - **BrailleCanvas**:
    This type of canvas is probably the one with the highest resolution for Unicode plotting. It essentially uses the Unicode characters of the [Braille](https://en.wikipedia.org/wiki/Braille) symbols as pixel. This effectively turns every character into 8 pixels that can individually be manipulated using binary operations.

  - **BlockCanvas**:
    This canvas is also Unicode-based. It has half the resolution of the BrailleCanvas. In contrast to BrailleCanvas, the pixels don't have visible spacing between them. This canvas effectively turns every character into 4 pixels that can individually be manipulated using binary operations.

  - **HeatmapCanvas**:
    This canvas is also Unicode-based. It has half the resolution of the BlockCanvas. This canvas effectively turns every character into 2 color pixels, using the foreground and background terminal colors. As such, the number of rows of the canvas is half the number of y coordinates being displayed.

  - **AsciiCanvas** and **DotCanvas**:
    These two canvas utilizes only standard ASCII character for drawing. Naturally, it doesn't look quite as nice as the Unicode-based ones. However, in some situations it might yield better results. Printing plots to a file is one of those situations.

  - **DensityCanvas**:
    Unlike the BrailleCanvas, the density canvas does not simply mark a "pixel" as set. Instead it increments a counter per character that keeps track of the frequency of pixels drawn in that character. Together with a variable that keeps track of the maximum frequency, the canvas can thus draw the density of datapoints.

  - **BarplotGraphics**:
    This graphics area is special in that it does not support any pixel manipulation. It is essentially the barplot without decorations but the numbers. It does only support one method `addrow!` which allows the user to add additional bars to the graphics object

## Installation

To install UnicodePlots, start up Julia and type the following
code-snipped into the REPL. It makes use of the native Julia
package manger.

```Julia
using Pkg
Pkg.add("UnicodePlots")
```

## License

This code is free to use under the terms of the MIT license.

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille)
