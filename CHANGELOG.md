# Changelog

## [3.3] - 2022-11-17
### Added
- Group digits on integer values (thousands) for readability (configured using `thousands_separator`).

### Changed
- Consistent left and right padding (avoids duplicate label & cbar paddings, symmetry).
- Colorbar limits labels moved to top and bottom, to save right space.
- Change `imageplot` borders to default `:corners`.
- Fix `sixel` encoding in `imageplot`.
- Simplify floating point repr.

## [3.2] - 2022-11-04
### Changed
- Removed labels in `3d` plots by default.
- Fix default `contourplot` colorbar limits.
- Change `surfaceplot` default aspect.

## [3.1] - 2022-09-02
### Added
- Add `imageplot` (`ansi` or `sixel`).
- Sixel support in `ImageGraphics`.

## [3.0] - 2022-06-24
### Added
- Support multiple series (`Matrix` columns) on `lineplot` and `scatterplot` (and mutating versions).
- Support `width = :auto` and `height = :auto` for creating a plot based on the current terminal size.
- Add `array` keyword to heatmap for matrix display in array convention.
- Add `dscale` support for `densityplot` (e.g. peak damping).
- Add `ColorSchemes.jl` dependency following colormaps removal.
- Add `xflip` and `yflip` for reversing/flipping the axes.
- Add `head_tail_frac` for `lineplot` using `head_tail`.
- Support `vline!` and `hline!`.
- Buffering `i/o` (performance).
- Add `CHANGELOG.md` file.

### Changed
- Swap `width` and `height` of internal `grid` and `colors` buffer.
- Rename `printrow` to `print_row`.
- Change `spy` default title.

### Removed
- Reduce number of exported symbols (canvas related).
- Marked deprecated functions, keywords and tests.
- Hard-coded colormap tables (replaced by `ColorSchemes`).
- Functor `scale` support.

## [2.12] - 2022-05-24
### Changed
- Lazily load `FreeTypeAbstraction`.

## [2.11] - 2022-04-26
### Added
- `polarplot`.
- Support vertical histogram through `vertical` argument.

## [2.10] - 2022-03-23
### Added
- `savefig` supports exporting to `png` files through `FreeTypeAbstraction`.
- Add support for `24bit` (true colors).

## [2.9] - 2022-02-22
### Added
- Add `Unitful` support for `lineplot` and `scatterplot`.
- Add `xticks` and `yticks` to disable drawing ticks.

## [2.8] - 2022-02-07
### Added
- Add `head_tail` in order to mimic an arrow using colors.
- Add `surfaceplot` and `isosurface` (3D plots).

### Changed
- Support vector of colors `barplot`, `boxplot`.
- Enhance `surfaceplot` interpolation & performance.

## [2.7] - 2022-01-23
### Changed
- Crayons `4.1`.

### Removed
- Support for julia `1.0`.

## [2.6] - 2022-01-19
### Added
- Add `contourplot`.

### Changed
- Rework documentation, automate generation of docstrings and `README.md`.
- Fix `heatmap` and `spy` aspect ratios.

## [2.5] - 2021-11-28
### Add
- Allow showing zero pattern in `spy`.

### Changed
- Defaults to unicode exponent on non-identity scales.
- Rename `xyscale` to `xyfact`.

## [2.4] - 2021-09-14
- Add support for text annotations on an existing plot.
- Add `compact` for saving plot space.
- Add marker support.

## [2.3] - 2021-09-07
### Changed
- Fix incorrect braille canvas spacing.

## [2.2] - 2021-09-06
### Added
- Support `x` and `y` axes scaling (e.g. `log-log` plots).

### Changed
- Enhance resolution of histogram.

## [2.1] - 2021-09-03
### Changed
- Move `UnicodePlots` to the `JuliaPlots` organization.

## [2.0] - 2021-08-19
### Added
- `Dates` support.
- Basic `savefig` for `.txt` files.

### Changed
- Bring back CI and support julia `1.6`.
- Avoid drawing pixels out of canvas bounds.
- Switch to `compact` repr for floats.
- Support `coo` in `spy`.

### Removed
- Travis CI.
