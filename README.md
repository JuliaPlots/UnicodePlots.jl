# UnicodePlots

Advanced Unicode plotting library designed for use in Julia's REPL.

[![Build Status](https://travis-ci.org/Evizero/UnicodePlots.jl.svg?branch=master)](https://travis-ci.org/Evizero/UnicodePlots.jl)

## Installation

There are no dependencies on other packages. Developed for Julia v0.3 and v0.4

```
Pkg.clone("https://github.com/Evizero/UnicodePlots.jl")
```

## Tutorial

There are three main plotting capabilities for now

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

## Options

All plots support a common set of named parameters

* **title**: Text to display on the top of the plot. Defaults to `""`
* **width**: Number of characters per row that should be used for plotting. Defaults to `40`
* **height**: Number of rows that should be used for plotting. Not applicable to `barplot`. Defaults to `10`
* **margin**: Number of empty characters to the left of the whole plot. Defaults to `3`
* **border**: The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, `:dotted`, and `:none`. Defaults to`:solid`
* **labels**: Can be used to hide the labels. Defaults to`true`

## Todo

- [ ] Better rounding for labels
- [ ] Color support for `lineplot` and `scatterplot`
- [ ] Improve documentation

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille)
