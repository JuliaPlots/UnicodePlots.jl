const DESCRIPTION = (
    # NOTE: this named tuple has to stay ordered
    x = "horizontal position for each point",
    y = "vertical position for each point",
    symbols = "specifies the characters that should be used to render the bars",
    title = "text to display on the top of the plot",
    name = "annotation of the current drawing to be displayed on the right",
    xlabel = "text to display on the `x` axis of the plot",
    ylabel = "text to display on the `y` axis of the plot",
    zlabel = "text to display on the `z` axis (colorbar) of the plot",
    xscale = "`x`-axis scale `(:identity, :ln, :log2, :log10)`, or scale function e.g. `x -> log10(x)`",
    yscale = "`y`-axis scale",
    labels = "used to hide the labels by setting `labels=false`",
    border = "style of the bounding box of the plot, supports `:corners`, `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`",
    margin = "number of empty characters to the left of the whole plot",
    padding = "space of the left and right of the plot between the labels and the canvas",
    color = "can be any of `:green`, `:blue`, `:red`, `:yellow`, `:cyan`, `:magenta`, `:white`, `:normal`, an integer in the range `0`-`255`, or a tuple of `3` integers as `RGB` components",
    width = "number of characters per row that should be used for plotting",
    height = "number of character rows that should be used for plotting",
    xlim = "plotting range for the `x` axis (`(0, 0)` stands for automatic)",
    ylim = "plotting range for the `y` axis (`(0, 0)` stands for automatic)",
    zlim = "colormap scaled data range (`(0, 0)` stands for automatic)",
    colorbar = "toggle the colorbar",
    colormap = "choose from `:viridis`, `:plasma`, `:magma`, `:inferno`, `:cividis`, `:jet`, `:gray` (more from `keys(UnicodePlots.COLOR_MAP_DATA)`), or supply a function `f: (z, zmin, zmax) -> Int(0-255)`, or a vector of RGB tuples",
    colorbar_lim = "colorbar limit, defaults to `(0, 1)`",
    colorbar_border = "style of the bounding box of the color bar (supports `:solid`, `:bold`, `:dashed`, `:dotted`, `:ascii`, and `:none`)",
    canvas = "type of canvas that should be used for drawing",
    grid = "if `true`, draws grid-lines at the origin",
    compact = "compact plot (labels), defaults to `false`",
    blend = "blend colors on the underlying canvas, defaults to `true`",
    fix_ar = "fix terminal aspect ratio (experimental)",
    visible = "visible canvas (`true` by default)",
)

const Z_DESCRIPTION = (
    :zlabel,
    :zlim,
    :colorbar,
    :colormap,
    :colorbar_lim,
    :colorbar_border,
)

const SIGNATURE = (
    name = "\"\"",
    title = "\"\"",
    xscale = ":identity",
    yscale = ":identity",
    title = "\"\"",
    xlabel = "\"\"",
    ylabel = "\"\"",
    zlabel = "\"\"",
    labels = "true",
    border = ":solid",
    margin = "3",
    padding = "1",
    color = ":green",
    symbols = "['■']",
    width = "$(DEFAULT_WIDTH[])",
    height = "$(DEFAULT_HEIGHT[])",
    xlim = "(0, 0)",
    ylim = "(0, 0)",
    grid = "true",
)

function signature_kwargs(
    ;
    default::Tuple = (
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
        :compact,
        :grid,
        :margin,
        :padding,
        :blend,
    ),
    add::Tuple = (),
    exclude::Tuple = (
        :visible, :fix_ar,  # internals
        Z_DESCRIPTION...,  # by default for 2D data
    ),
    remove::Tuple = (),
)
    sig = (; SIGNATURE..., mod...)
    candidates = keys(desc) ∪ filter(x -> x ∈ add ∪ default, keys(SIGNATURE))
    keywords = filter(x -> x ∉ setdiff(exclude ∪ remove, add), candidates)
    join((k isa Symbol ? "$k = $(sig[k])" : k for k in keywords), ", ")
end

function arguments(
    desc::NamedTuple = NamedTuple();
    default::Tuple = (
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
        :compact,
        :grid,
        :margin,
        :padding,
        :blend,
    ),
    add::Tuple = (),
    exclude::Tuple = (
        :visible, :fix_ar,  # internals
        Z_DESCRIPTION...,  # by default for 2D data
    ),
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
    keywords = filter(x -> x ∉ setdiff(exclude ∪ remove, add), candidates)
    @assert allunique(keywords)  # extra check
    join(("- **`$k`** : $(get_description(k, all_desc))." for k ∈ keywords), '\n')
end
