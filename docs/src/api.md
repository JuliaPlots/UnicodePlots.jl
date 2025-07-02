# API

## Methods
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
desc_ex(k, d, n=2) = (
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
)
# FIXME: examples are failing here ...
"All plots support the set (or a subset) of the following named parameters:\n" * join(
  (
    "- `$(UnicodePlots.default_with_type(k))`: $(desc_ex(k, d * '.'))"
    for (k, d) ∈ pairs(UnicodePlots.DESCRIPTION) if k ∈ keys(UnicodePlots.KEYWORDS)
  ), '\n'
) |> Markdown.parse
```

Note: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).

## Docstrings
```@autodocs
Modules = [UnicodePlots]
```
