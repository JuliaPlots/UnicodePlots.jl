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
    projection = :orthographic,
    elevation = round(atand(1 / √2); digits = 6),
    azimuth = 45.0,
    axes3d = true,
    near = 1.0,
    far = 100.0,
    zoom = 1.0,
    up = :z,
    colorbar = false,
    unicode_exponent = true,
    compact = false,
    blend = true,
    grid = true,
    # internals
    visible = true,
    fix_ar = false,
)

const DESCRIPTION = (
    # NOTE: this named tuple has to stay ordered
    x = "horizontal position for each point",
    y = "vertical position for each point",
    z = "depth position for each point",
    symbols = "characters used to render the bars",
    title = "text displayed on top of the plot",
    name = "current drawing annotation displayed on the right",
    xlabel = "text displayed on the `x` axis of the plot",
    ylabel = "text displayed on the `y` axis of the plot",
    zlabel = "text displayed on the `z` axis (colorbar) of the plot",
    xscale = "`x`-axis scale (`:identity`, `:ln`, `:log2`, `:log10`), or scale function e.g. `x -> log10(x)`",
    yscale = "`y`-axis scale",
    labels = "show plot labels",
    border = "plot bounding box style (`:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:none`)",
    margin = "number of empty characters to the left of the whole plot",
    padding = "left and right space between the labels and the canvas",
    color = "choose from (`:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`, `:white`, `:normal`, `:auto`), use an integer in `[0-255]`, or provide `3` integers as `RGB` components",
    width = "number of characters per canvas row",
    height = "number of canvas rows",
    xlim = "plotting range for the `x` axis (`(0, 0)` stands for automatic)",
    ylim = "plotting range for the `y` axis",
    zlim = "colormap scaled data range",
    colorbar = "toggle the colorbar",
    colormap = "choose from (`:viridis`, `:cividis`, `:plasma`, `:jet`, `:gray`, `keys(UnicodePlots.COLOR_MAP_DATA)`...), or supply a function `f: (z, zmin, zmax) -> Int(0-255)`, or a vector of RGB tuples",
    colorbar_lim = "colorbar limit",
    colorbar_border = "color bar bounding box style (`:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, `:none`)",
    canvas = "type of canvas used for drawing",
    grid = "draws grid-lines at the origin",
    compact = "compact plot labels",
    unicode_exponent = "use `Unicode` symbols for exponents: e.g. `10²⸱¹` instead of `10^2.1`",
    projection = "projection for 3D plots (`:orthographic`, `:perspective`, or `Matrix-View-Projection` (MVP) matrix)",
    axes3d = "draw 3d axes (`x -> :red`, `y -> :green`, `z -> :blue`)",
    elevation = "elevation angle above or below the `floor` plane (`-90 ≤ θ ≤ 90`)",
    azimuth = "azimutal angle around the `up` vector (`-180° ≤ φ ≤ 180°`)",
    zoom = "zooming factor in 3D",
    up = "up vector (`:x`, `:y` or `:z`), prefix with `m -> -` or `p -> +` to change the sign e.g. `:mz` for `-z` axis pointing upwards",
    near = "distance to the near clipping plane (`:perspective` projection only)",
    far = "distance to the far clipping plane (`:perspective` projection only)",
    blend = "blend colors on the underlying canvas",
    fix_ar = "fix terminal aspect ratio (experimental)",
    visible = "visible canvas",
)

const Z_DESCRIPTION =
    (:zlabel, :zlim, :colorbar, :colormap, :colorbar_lim, :colorbar_border)

const PROJ_DESCRIPTION = (:projection, :azimuth, :elevation, :up, :zoom, :axes3d)

const DEFAULT_KW = (
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
    PROJ_DESCRIPTION...,  # 3D plots
)

base_type(x) = replace(string(typeof(x).name.name), "64" => "")

default_with_type(s::Symbol) = (
    if s in keys(KEYWORDS)
        "$s::$(base_type(KEYWORDS[s])) = $(KEYWORDS[s] |> repr)"
    else
        s |> string
    end
)

"""
    keywords([extra]; default = DEFAULT_KW, add = (), exclude = DEFAULT_EXCLUDED, remove = ())

Adds default keywords to a function signature, in a docstring.

# Arguments

- `extra::NamedTuple`: add extra keywords in the form `keyword=value`.
- `default::Tuple`: default `UnicodePlots` keywords.
- `add::Tuple`: add extra symbols, not listed in `default` but present in `KEYWORDS`.
- `remove::Tuple`: remove symbols from `default`.
"""
function keywords(
    extra::NamedTuple = NamedTuple();
    default::Tuple = DEFAULT_KW,
    add::Tuple = (),
    exclude::Tuple = DEFAULT_EXCLUDED,
    remove::Tuple = (),
)
    all_kw = (; KEYWORDS..., extra...)
    candidates = keys(extra) ∪ filter(x -> x ∈ add ∪ default, keys(KEYWORDS))  # extra goes first !
    kw = filter(x -> x ∉ setdiff(exclude ∪ remove, add), candidates)
    @assert allunique(kw)  # extra check
    join((k isa Symbol ? "$k = $(all_kw[k] |> repr)" : k for k in kw), ", ")
end

"""
    arguments([desc]; default = DEFAULT_KW, add = (), exclude = DEFAULT_EXCLUDED, remove = ())

Defines arguments for docstring genreration.

# Arguments

- `desc::NamedTuple`: add argument description in the form `arg=desc`.
- `default::Tuple`: default `UnicodePlots` keywords.
- `add::Tuple`: add extra symbols, not listed in `default` but present in `DESCRIPTION`.
- `remove::Tuple`: remove symbols from `default`.
"""
function arguments(
    desc::NamedTuple = NamedTuple();
    default::Tuple = DEFAULT_KW,
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
    join(
        ("- **`$(default_with_type(k))`** : $(get_description(k, all_desc))." for k in kw),
        '\n',
    )
end
