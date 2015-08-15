# UnicodePlots

Advanced Unicode plotting library designed for use in Julia's REPL.

[![Build Status](https://travis-ci.org/Evizero/UnicodePlots.jl.svg?branch=master)](https://travis-ci.org/Evizero/UnicodePlots.jl)

## Installation

There are no dependencies on other packages. Developed for Julia v0.3 and v0.4

```
Pkg.clone("https://github.com/Evizero/UnicodePlots.jl")
```

## High-level Interface

There are four main plotting capabilities for now:
  - Scatterplot
  - Lineplot
  - Barplot (horizontal)
  - Staircase Plot

#### Scatterplot

Accepts two numerical vectors

![Scatterplot Screenshot](doc/img/scatter.png)

#### Lineplot

Accepts two numerical vector. The function will draw the line in the order of the given elements

![Lineplot Screenshot1](doc/img/line.png)

It's also possible to specify a function and a range.

![Lineplot Screenshot2](doc/img/sin.png)

Granted, the labels could be better :-)

#### Barplot

Accepts either two vectors or a dictionary

![Barplot Screenshot](doc/img/barplot.png)

#### Staircase plot

Accepts two vectors

![Staircase Screenshot](doc/img/stairs.png)

## Low-level Interface

The primary structures that do all the heavy lifting for plotting are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. underneath it uses Unicode characters to represent pixel.

Here is a simple example:

```Julia
canvas = BrailleCanvas(40, 10, # number of columns and rows (characters)
                       plotOriginX = 0., plotOriginY = 0., # position in virtual space
                       plotWidth = 1., plotHeight = 1.) # size of the virtual space
drawLine!(canvas, 0., 0., 1., 1., :blue)
setPoint!(canvas, rand(50), rand(50), :red)
drawLine!(canvas, 0., 1., .5, 0., :yellow)
```
![Basic Canvas](doc/img/canvas.png)

As you can see, one issue that arrises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the 8 pixel of a character could belong to a different color group (a character can only have a single color). UnicodePlots deals with this using a colorblend for the whole group.

![Blending Colors](doc/img/braille.png)

At the moment there is one type of Canvas implemented.

### BrailleCanvas

This type of canvas is probably the one with the highest resolution for unicode plotting.
It essentially uses the unicode characters of the [Braille](https://en.wikipedia.org/wiki/Braille) symbols as pixel. This effectively turns every character into 8 pixels than can individually be manipulated using binary operations.

## Options

All plots support a common set of named parameters

* **title**: Text to display on the top of the plot. Defaults to `""`
* **width**: Number of characters per row that should be used for plotting. Defaults to `40`
* **height**: Number of rows that should be used for plotting. Not applicable to `barplot`. Defaults to `10`
* **margin**: Number of empty characters to the left of the whole plot. Defaults to `3`
* **border**: The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, and `:none`. Defaults to`:solid`
* **labels**: Can be used to hide the labels. Defaults to`true`

_Note_: You can also print your plots to another stream than `STDOUT` by passing the IO stream as the first argument. You should probably use `border=:dotted` for external plots.

## Todo

- [ ] Better rounding for labels
- [X] Color support for `lineplot` and `scatterplot`
- [ ] Improve documentation

## License

This code is free to use under the terms of the MIT license.

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille)
