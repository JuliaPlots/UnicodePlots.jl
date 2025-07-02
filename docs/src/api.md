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
display(plt)
```

- `annotate!(plot::Plot, x::Number, y::Number, text::AbstractString; kw...)`
  - `text` arbitrary annotation at position (x, y)

## Keywords
All plots support the set (or a subset) of the following named parameters:

```@eval
using UnicodePlots
join(
  (
    "- `$(UnicodePlots.default_with_type(k))`: $(desc_ex(k, d * '.'))"
    for (k, d) ∈ pairs(UnicodePlots.DESCRIPTION) if k ∈ keys(UnicodePlots.KEYWORDS)
  ), '\n'
)
```

Note: If you want to print the plot into a file but have monospace issues with your font, you should probably try setting `border=:ascii` and `canvas=AsciiCanvas` (or `canvas=DotCanvas` for scatterplots).

## Docstrings
```@autodocs
Modules = [UnicodePlots]
```
