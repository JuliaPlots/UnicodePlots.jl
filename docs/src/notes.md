# Notes

## Saving figures

Saving plots as `png` or `txt` files using the `savefig` command is supported (saving as `png` is experimental and requires `import FreeType, FileIO` before loading `UnicodePlots`).

To recover the plot as a string with ansi color codes use `string(p; color=true)`.

## Color mode

When the `COLORTERM` environment variable is set to either `24bit` or `truecolor`, `UnicodePlots` will use [24bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit) as opposed to [8bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) or even [4bit colors](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit) for named colors.

One can force a specific colormode using either `UnicodePlots.truecolors!()` or `UnicodePlots.colors256!()`.

Named colors such as `:red` or `:light_red` will use `256` color values (rendering will be terminal dependent). In order to force named colors to use true colors instead, use `UnicodePlots.USE_LUT[]=true`.

The default color cycle can be changed to bright (high intensity) colors using `UnicodePlots.brightcolors!()` instead of the default `UnicodePlots.faintcolors!()`.

## 3D plots
3D plots use a so-called "Model-View-Projection" transformation matrix `MVP` on input data to project 3D plots to a 2D screen.

Use keywords`elevation`, `azimuth`, `up` or `zoom` to control the view matrix, a.k.a. camera.

The `projection` type for `MVP` can be set to either `:persp(ective)` or `:ortho(graphic)`.

Displaying the `x`, `y`, and `z` axes can be controlled using the `axes3d` keyword.

For enhanced resolution, use a wider and/or taller `Plot` (this can be achieved using `default_size!(width=60)` for all future plots).

## Layout
`UnicodePlots` is integrated in [`Plots`](https://github.com/JuliaPlots/Plots.jl) as a backend, with support for [basic layout](https://docs.juliaplots.org/stable/gallery/unicodeplots/generated/unicodeplots-ref17).

For a more complex layout, use the `gridplot` function (requires loading [`Term`](https://github.com/FedeClaudi/Term.jl) as extension).
```@example gridplot
using UnicodePlots, Term

(
  UnicodePlots.panel(lineplot(1:2)) *
  UnicodePlots.panel(scatterplot(rand(100)))
) / (
  UnicodePlots.panel(lineplot(2:-1:1)) * 
  UnicodePlots.panel(densityplot(randn(1_000), randn(1_000)))
)
```

```@example gridplot
gridplot(map(i -> lineplot(-i:i), 1:5); show_placeholder=true)
```
```@example gridplot
gridplot(map(i -> lineplot(-i:i), 1:3); layout=(2, nothing))
```
```@example gridplot
gridplot(map(i -> lineplot(-i:i), 1:3); layout=(nothing, 1))
```

## Known issues
Using a non `true monospace font` can lead to visual problems on a `BrailleCanvas` (border versus canvas).

Either change the font to e.g. [JuliaMono](https://juliamono.netlify.app/) or use `border=:dotted` keyword argument in the plots.

For a `Jupyter` notebook with the `IJulia` kernel see [here](https://juliamono.netlify.app/faq/#can_i_use_this_font_in_a_jupyter_notebook_and_how_do_i_do_it).

(Experimental) Terminals seem to respect a standard aspect ratio of `4:3`, hence a square matrix does not often look square in the terminal.

You can pass the experimental keyword `fix_ar=true` to `spy` or `heatmap` in order to recover a unit aspect ratio.
