# Notes

## Methods
Non-exhaustive list of methods description:

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
```@example
using UnicodePlots  # hide
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

- `annotate!(plot::Plot, x::Number, y::Number, text::AbstractString; kw...)`
  - `text` arbitrary annotation at position (x, y)

## Keywords
```@eval
using UnicodePlots
using Markdown
indent(x, n=1, tab=' '^2) = tab^n * join(x isa AbstractVector ? x : split(x, '\n'), '\n' * tab^n)
ex(x) = join(("```@example", "using UnicodePlots  # hide", x, "```"), '\n')
desc_ex(k, d, n=2) = begin
  return d  # FIXME: temporarily disable examples (fails to render properly)
  if k ≡ :border
    join((
      d,
      indent(ex("lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:dashed)"), n),
      indent(ex("lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:ascii)"), n),
      indent(ex("lineplot([-1., 2, 3, 7], [1.,2, 9, 4], canvas=DotCanvas, border=:bold)"), n),
      indent(ex("lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:dotted)"), n),
      indent(ex("lineplot([-1., 2, 3, 7], [1.,2, 9, 4], border=:none)"), n),
    ), '\n')
  elseif k ≡ :width
    join((d, indent(ex("lineplot(1:.5:20, sin, width=60)"), n)), '\n')
  elseif k ≡ :height
    join((d, indent(ex("lineplot(1:.5:20, sin, height=18)"), n)), '\n')
  elseif k ≡ :labels
    join((d, indent(ex("lineplot(1:.5:20, sin, labels=false)"), n)), '\n')
  else
    d
  end
end
"All plots support the set (or a subset) of the following named parameters:\n" * join(
  (
    "- `$(UnicodePlots.default_with_type(k))`: $(desc_ex(k, d * '.'))"
    for (k, d) ∈ pairs(UnicodePlots.DESCRIPTION) if k ∈ keys(UnicodePlots.KEYWORDS)
  ), '\n'
) |> Markdown.parse
```

Note: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).

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
