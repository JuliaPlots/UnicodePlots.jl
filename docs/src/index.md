# UnicodePlots.jl

UnicodePlots is a [unicode-based](https://en.wikipedia.org/wiki/Unicode) scientific plotting library for working in a terminal, using [`Julia`](https://julialang.org)'s [`REPL`](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop).

The source code is hosted on github: [UnicodePlots.jl](https://github.com/JuliaPlots/UnicodePlots.jl).

## Installation

To install UnicodePlots, start up `julia` in a terminal and type the following code snippet into the `REPL` (this makes use of the native `Julia` package manager named `Pkg`):
```julia
julia> using Pkg
julia> Pkg.add("UnicodePlots")
```

## Getting started
Here is a quick hello world example of a typical use-case:

```@example intro
using UnicodePlots
lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example", name="my line", xlabel="x", ylabel="y")
```

There are other types of `Canvas` available (see section [Low-level Interface](https://github.com/JuliaPlots/UnicodePlots.jl#low-level-interface)).

In some situations, such as printing to a file, using `AsciiCanvas`, `DotCanvas`, `BlockCanvas` or `OctantCanvas` might lead to better results:

```@example intro
plt = lineplot([-1, 2, 3, 7], [-1, 2, 9, 4], title="Example", name="my line",
               xlabel="x", ylabel="y", canvas=DotCanvas, border=:ascii)
```

Some plot methods have a mutating variant that ends with an exclamation mark ([bang convention](https://docs.julialang.org/en/v1/manual/style-guide/#bang-convention)):

```@example intro
lineplot!(plt, [0, 4, 8], [10, 1, 10], color=:cyan, name="other line")
```

These mutating methods cannot update the limits of the axes as plots are drawn onto a fixed canvas. The limits must be set beforehand by the plotting function that creates the figure or by creating an empty `Plot`:

```@example intro
p = Plot(; xlim=(-1, 3), ylim=(-1, 3))
lineplot!(p, 1:2)
```

One can adjust the plot `height` and `width` to the current terminal size by using `height=:auto` and/or `width=:auto`.
When using `width=:auto`, it is advised to use the `compact=true` keyword in order to maximize the plot size.

You can reverse/flip the `Plot` axes by setting `xflip=true` and/or `yflip=true` on plot creation.
