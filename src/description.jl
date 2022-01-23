const KEYWORDS = (
    canvas = BrailleCanvas,
    symbols = ['■'],
    title = "",
    name = "",
    xlabel = "",
    ylabel = "",
    zlabel = "",
    xscale = :identity,
    yscale = :identity,
    labels = true,
    border = :solid,
    width = DEFAULT_WIDTH[],
    height = DEFAULT_HEIGHT[],
    xlim = (0, 0),
    ylim = (0, 0),
    zlim = (0, 0),
    margin = 3,
    padding = 1,
    color = :auto,
    colorbar_lim = (0, 1),
    colorbar_border = :solid,
    colormap = :viridis,
    colorbar = false,
    unicode_exponent = true,
    compact = false,
    blend = true,
    grid = true,
    # internals
    visible = true,
    fix_ar = false,
)

default(k) = "[`$(getfield(KEYWORDS, k) |> repr)`]"

const DESCRIPTION = (
    # NOTE: this named tuple has to stay ordered
    x = "horizontal position for each point",
    y = "vertical position for each point",
    symbols = "specifies the characters that should be used to render the bars $(default(:symbols))",
    title = "text to display on the top of the plot $(default(:title))",
    name = "annotation of the current drawing to be displayed on the right $(default(:name))",
    xlabel = "text to display on the `x` axis of the plot $(default(:xlabel))",
    ylabel = "text to display on the `y` axis of the plot $(default(:ylabel))",
    zlabel = "text to display on the `z` axis (colorbar) of the plot $(default(:zlabel))",
    xscale = "`x`-axis scale (`:identity`, `:ln`, `:log2`, `:log10`), or scale function e.g. `x -> log10(x)` $(default(:xscale))",
    yscale = "`y`-axis scale $(default(:yscale))",
    labels = "show plot labels $(default(:labels))",
    border = "plot bounding box style, choose from `:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none` $(default(:border))",
    margin = "number of empty characters to the left of the whole plot $(default(:margin))",
    padding = "space of the left and right of the plot between the labels and the canvas $(default(:padding))",
    color = "can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`, `:white`, `:normal`, an integer in the range `0`-`255`, or a tuple of `3` integers as `RGB` components $(default(:color))",
    width = "number of characters per row that should be used for plotting $(default(:width))",
    height = "number of character rows that should be used for plotting $(default(:height))",
    xlim = "plotting range for the `x` axis (`(0, 0)` means automatic) $(default(:xlim))",
    ylim = "plotting range for the `y` axis (`(0, 0)` means automatic) $(default(:ylim))",
    zlim = "colormap scaled data range $(default(:zlim))",
    colorbar = "toggle the colorbar $(default(:colorbar))",
    colormap = "choose from `:viridis`, `:plasma`, `:magma`, `:inferno`, `:cividis`, `:jet`, `:gray` (more from `keys(UnicodePlots.COLOR_MAP_DATA)`), or supply a function `f: (z, zmin, zmax) -> Int(0-255)`, or a vector of RGB tuples $(default(:colormap))",
    colorbar_lim = "colorbar limit $(default(:colorbar_lim))",
    colorbar_border = "style of the bounding box of the color bar (supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`) $(default(:colorbar_border))",
    canvas = "type of canvas that should be used for drawing $(default(:canvas))",
    grid = "draws grid-lines at the origin $(default(:grid))",
    compact = "compact plot labels $(default(:compact))",
    unicode_exponent = "use `Unicode` symbols for exponents: e.g. `10²⸱¹` instead of `10^2.1` $(default(:unicode_exponent))",
    blend = "blend colors on the underlying canvas [`$(KEYWORDS.blend)`]",
    fix_ar = "fix terminal aspect ratio (experimental) $(default(:fix_ar))",
    visible = "visible canvas $(default(:visible))",
)

const Z_DESCRIPTION =
    (:zlabel, :zlim, :colorbar, :colormap, :colorbar_lim, :colorbar_border)

const DEFAULT_KWARGS = (
    # does not have to stay ordered
    :name,
    :title,
    :xlabel,
    :ylabel,
    :zlabel,
    :xscale,
    :yscale,
    :labels,
    :border,
    :width,
    :height,
    :xlim,
    :ylim,
    :zlim,
    :unicode_exponent,
    :compact,
    :blend,
    :grid,
    :padding,
    :margin,
)

const DEFAULT_EXCLUDED = (
    :visible,  # internals
    :fix_ar,  # experimental
    Z_DESCRIPTION...,  # by default for 2D data
)

"""
    keywords([extra]; default = DEFAULT_KWARGS, add = (), exclude = DEFAULT_EXCLUDED, remove = ())

Adds default keywords to a function signature, in a docstring.

# Arguments

- `extra::NamedTuple`: add extra keywords in the form `keyword=value`.
- `default::Tuple`: default `UnicodePlots` keywords.
- `add::Tuple`: add extra symbols, not listed in `default` but present in `KEYWORDS`.
- `remove::Tuple`: remove symbols from `default`.
"""
function keywords(
    extra::NamedTuple = NamedTuple();
    default::Tuple = DEFAULT_KWARGS,
    add::Tuple = (),
    exclude::Tuple = DEFAULT_EXCLUDED,
    remove::Tuple = (),
)
    all_kw = (; KEYWORDS..., extra...)
    candidates = keys(extra) ∪ filter(x -> x ∈ add ∪ default, DEFAULT_KWARGS)
    kw = filter(x -> x ∉ setdiff(exclude ∪ remove, add), candidates)
    @assert allunique(kw)  # extra check
    join((k isa Symbol ? "$k = $(all_kw[k] |> repr)" : k for k in kw), ", ")
end

"""
    arguments([desc]; default = DEFAULT_KWARGS, add = (), exclude = DEFAULT_EXCLUDED, remove = ())

Defines arguments for docstring genreration.

# Arguments

- `desc::NamedTuple`: add argument description in the form `arg=desc`.
- `default::Tuple`: default `UnicodePlots` keywords.
- `add::Tuple`: add extra symbols, not listed in `default` but present in `DESCRIPTION`.
- `remove::Tuple`: remove symbols from `default`.
"""
function arguments(
    desc::NamedTuple = NamedTuple();
    default::Tuple = DEFAULT_KWARGS,
    add::Tuple = (),
    exclude::Tuple = DEFAULT_EXCLUDED,
    remove::Tuple = (),
)
    get_description(n, d) = begin
        str = d[n]
        @assert str[1] === '`' || islowercase(str[1])  # description starts with a lowercase string, or `something`
        @assert str[end] !== '.'  # trailing dot will be added later
        str
    end
    all_desc = (; DESCRIPTION..., desc...)  # desc preempts defaults !
    candidates = keys(desc) ∪ filter(x -> x ∈ add ∪ default, keys(DESCRIPTION))  # desc goes first !
    kw = filter(x -> x ∉ setdiff(exclude ∪ remove, add), candidates)
    @assert allunique(kw)  # extra check
    join(("- **`$k`** : $(get_description(k, all_desc))." for k in kw), '\n')
end
