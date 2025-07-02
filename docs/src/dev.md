# Development

## Low-level interface

The primary structures that do all the heavy lifting behind the curtain are subtypes of `Canvas`. A canvas is a graphics object for rasterized plotting. Basically, it uses Unicode characters to represent pixel.
  
Here is a simple example:
```@example 
import UnicodePlots: Plot, BrailleCanvas, lines!, points!, pixel!
canvas = BrailleCanvas(15, 40,                    # number of rows and columns (characters)
                       origin_y=0., origin_x=0.,  # position in virtual space
                       height=1., width=1.)       # size of the virtual space
lines!(canvas, 0., 0., 1., 1.; color=:cyan)       # virtual space
points!(canvas, rand(50), rand(50); color=:red)   # virtual space
lines!(canvas, 0., 1., .5, 0.; color=:yellow)     # virtual space
pixel!(canvas, 5, 8; color=:red)                  # pixel space
Plot(canvas)
```

You can access the height and width of the canvas (in characters) with `nrows(canvas)` and `ncols(canvas)` respectively. You can use those functions in combination with `print_row` to embed the canvas anywhere you wish. For example, `print_row(STDOUT, canvas, 3)` writes the third character row of the canvas to the standard output.

As you can see, one issue that arises when multiple pixel are represented by one character is that it is hard to assign color. That is because each of the "pixel" of a character could belong to a different color group (each character can only have a single color). This package deals with this using a color-blend for the whole group. You can disable canvas color blending / mixing by passing `blend=false` to any function.

```@example 
import UnicodePlots: Plot, BrailleCanvas, lines!
canvas = BrailleCanvas(15, 40; origin_y=0., origin_x=0., height=1., width=1.)
lines!(canvas, 0., 0., 1., 1.; color=:cyan)
lines!(canvas, .25, 1., .5, 0.; color=:yellow)
lines!(canvas, .2, .8, 1., 0.; color=:red)
Plot(canvas)
```

The following types of `Canvas` are implemented:

- **BrailleCanvas**:
  This type of canvas is probably the one with the highest resolution for `Unicode` plotting. It essentially uses the Unicode characters of the [Braille](https://en.wikipedia.org/wiki/Braille) symbols as pixels. This effectively turns every character into eight pixels that can individually be manipulated using binary operations.

- **BlockCanvas**:
  This canvas is also `Unicode` based. It has half the resolution of the BrailleCanvas. In contrast to `BrailleCanvas`, the pixels don't have visible spacing between them. This canvas effectively turns every character into four pixels that can individually be manipulated using binary operations.

- **HeatmapCanvas**:
  This canvas is also `Unicode` based. It has half the resolution of the `BlockCanvas`. This canvas effectively turns every character into two color pixels, using the foreground and background terminal colors. As such, the number of rows of the canvas is half the number of `y` coordinates being displayed.

- **AsciiCanvas** and **DotCanvas**:
  These two canvas utilizes only standard `ASCII` character for drawing. Naturally, it doesn't look quite as nice as the Unicode-based ones. However, in some situations it might yield better results. Printing plots to a file is one of those situations.

- **DensityCanvas**:
  Unlike the `BrailleCanvas`, the density canvas does not simply mark a "pixel" as set. Instead it increments a counter per character that keeps track of the frequency of pixels drawn in that character. Together with a variable that keeps track of the maximum frequency, the canvas can thus draw the density of data-points.

- **BarplotGraphics**:
  This graphics area is special in that it does not support any pixel manipulation. It is essentially the barplot without decorations but the numbers. It does only support one method `addrow!` which allows the user to add additional bars to the graphics object.
    
## Developer notes

Because Julia uses column-major indexing order for an array type, and because displaying data on a terminal is row based, we need an internal buffer compatible with efficient columns based iteration. We solve this by using the transpose of a (`width`, `height`) array for indexing into an internal buffer like `buf[row, col]` or `buf[y, x]`.
Common users of UnicodePlots don't need to be aware of this axis difference if sticking to public interface.

```@example
using UnicodePlots  # hide
p = Plot([NaN], [NaN]; xlim=(1, 10), ylim=(1, 10), title="internal buffer conventions")

# plot axes
vline!(p, 1, head_tail=:head, color=:green, name="y-axis (rows)")
hline!(p, 1, head_tail=:head, color=:red, name="x-axis (cols)")

# square
vline!(p, 2, [2, 9], color=:cyan, name="buf[y, x] - buf[row, col]")
vline!(p, [2, 9], [2, 9], color=:cyan)
hline!(p, [2, 9], [2, 9], color=:cyan)

# internal axes
vline!(p, 3, range(3, 8; length=20), head_tail=:tail, color=:light_green, name="y-buffer (rows)")
hline!(p, 8, range(3, 8; length=20), head_tail=:head, color=:light_red, name="x-buffer (cols)")

# mem layout
vline!(p, 4, [4, 7]; color=:yellow, name="memory layout")
vline!(p, 7, [4, 7]; color=:yellow)
hline!(p, [4, 7], [4, 7]; color=:yellow)
hline!(p, [4.5, 5, 5.5, 6], [4.5, 6.5]; color=:yellow)
```
