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

Accepts two numerical vectors and draws the line in the order of the elements

![Lineplot Screenshot](doc/img/line.png)

#### Barplot

Accepts either two vectors or a dictionary

![Barplot Screenshot](doc/img/barplot.png)

## Options

All plots support a common set of options

* **border** The style of the bounding box of the plot. Supports `:solid`, `:bold`, `:dashed`, and `:none` 

## Acknowledgement

Inspired by [TextPlots.jl](https://github.com/sunetos/TextPlots.jl), which in turn was inspired by [Drawille](https://github.com/asciimoo/drawille)
