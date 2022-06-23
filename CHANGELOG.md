# Changelog

## [3.0.0] - 2022-06-24
### Added
- Add `CHANGELOG.md` file.
- Add `dscale` support for `densityplot` (e.g. peak damping).
- Support multiple series (`Matrix` columns) on `lineplot` and `scatterplot` (and mutating versions).
- Add `array` keyword to heatmap for matrix display in array convention.
- Support `width = :auto` and `height = :auto` for creating a plot based on the current terminal size.
- Add `head_tail_frac` for `lineplot` using `head_tail`.
- Add `ColorSchemes.jl` dependency following colormaps removal.
- Add `xflip` and `yflip` for reversing/flipping the axes.
- Buffering `i/o` (performance).

### Changed
- Swap `width` and `height` of internal `grid` and `colors` buffer.
- Rename `printrow` to `print_row`.
- `spy` default title.

### Removed
- All marked deprecated functions, keywords and tests.
- Functor `scale` support.
- All hard-coded colormap tables (replaced by `ColorSchemes`).

## [2.12.0] - 2022-05-24
### Changed
- lazily load `FreeTypeAbstraction`.

## [2.11.0] - 2022-04-26
### Added
- `polarplot`.
- support vertical histogram through `vertical` argument.

## [2.10.0] - 2022-03-23
### Added
- `savefig` supports exporting to `png` files through `FreeTypeAbstraction`.
- Add support for `24bit` (true colors).

## [2.9.0] - 2022-02-22
### Added
- Add `Unitful` support for `lineplot` and `scatterplot`.
- Add `xticks` and `yticks` to disable drawing ticks.

## [2.8.0] - 2022-02-07
### Added
- Add `surfaceplot` and `isosurface` (3D plots).
- Add `head_tail` in order to mimic an arrow using colors.

### Changed
- `heatmap` and `spy` aspect ratios.

## [2.6.0] - 2022-01-19
### Added
- Add `contourplot`.

## [2.5.0] - 2021-11-28
### Changed
- Defaults to unicode exponent on non-identity scales.

## [2.4.0] - 2021-09-14
- Add support for text annotation on an existing plot.

## [2.2.0] - 2021-09-06
### Added
- Support `x` and `y` axes scaling (e.g. log-log plots).

## [2.0.0] - 2021-08-19
### Changed
- Bring back CI and support julia `1.6`.