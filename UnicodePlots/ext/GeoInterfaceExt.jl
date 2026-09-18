module GeoInterfaceExt

import UnicodePlots:
    UnicodePlots,
    KEYWORDS,
    Plot,
    Canvas,
    UserColorType,
    split_plot_kw,
    next_color!,
    label!,
    is_auto,
    nanless_extrema,
    colormap_callback,
    ansi_color,
    blend_colors,
    pixel!,
    pixel_width,
    pixel_height,
    scale_x_to_pixel,
    scale_y_to_pixel
import GeoInterface as GI

function UnicodePlots.geoplot(geom; canvas::Type = KEYWORDS.canvas, kw...)
    pkw, okw = split_plot_kw(kw)
    x, y = Float64[], Float64[]
    foreach_part(geom) do part
        px, py = xy(part)
        append!(x, px)
        append!(y, py)
    end
    return UnicodePlots.geoplot!(Plot(x, y, nothing, canvas; pkw...), geom; okw...)
end

function UnicodePlots.geoplot!(
        plot::Plot{<:Canvas},
        geom;
        color = KEYWORDS.color,
        name::AbstractString = KEYWORDS.name,
        colormap = KEYWORDS.colormap,
        zlim = KEYWORDS.zlim,
        fill::Union{Bool, Integer} = true,
    )
    stride = fill isa Bool ? (fill ? 2 : 0) : Int(fill)
    stride ≥ 0 || throw(ArgumentError("`fill` must be positive"))
    elements = collect(members(geom))
    color isa AbstractString &&
        (color = [GI.properties(f)[Symbol(color)] for f in elements])
    colors = if color isa AbstractVector
        length(color) == length(elements) || throw(
            ArgumentError("`color` must have one entry per feature or geometry"),
        )
        if all(c -> c isa Real, color)  # values mapped through `colormap`
            plot.cmap.bar = true
            plot.cmap.lim = (lo, hi) = is_auto(zlim) ? nanless_extrema(color) : zlim
            plot.cmap.callback = callback = colormap_callback(colormap)
            isempty(name) || label!(plot, :r, string(name))
            map(c -> callback(c, lo, hi), color)
        elseif all(c -> c isa UserColorType, color)
            isempty(name) || label!(plot, :r, string(name), first(color))
            color
        else  # categorical values, one color and label per unique value
            palette = Dict(c => next_color!(plot) for c in unique(color))
            for (c, col) in palette
                label!(plot, :r, string(c), col)
            end
            map(c -> palette[c], color)
        end
    else
        color = color ≡ :auto ? next_color!(plot) : color
        isempty(name) || label!(plot, :r, string(name), color)
        Iterators.repeated(color)
    end
    for (element, color) in zip(elements, colors)
        foreach_part(part -> draw!(plot, GI.trait(part), part, color, stride), element)
    end
    plot.series[] += 1
    return plot
end

draw!(plot, ::GI.AbstractCurveTrait, geom, color, _) =
    UnicodePlots.lines!(plot, xy(geom)...; color)
draw!(plot, _, geom, color, _) = UnicodePlots.points!(plot, xy(geom)...; color)
function draw!(plot, ::GI.AbstractPolygonTrait, geom, color, stride)
    stride > 0 && sprinkle!(plot, geom, color, stride)
    for ring in GI.getgeom(geom)
        UnicodePlots.lines!(plot, xy(ring)...; color)
    end
    return plot
end

"""
Sprinkle points inside a polygon, on every `stride`-th canvas pixel of a scanline
sampling of its rings. Crossings alternate between inside and outside (even-odd
rule), which leaves holes empty.
"""
function sprinkle!(plot::Plot{<:Canvas}, poly, color, stride::Int)
    c = plot.graphics
    col, blend = ansi_color(color), blend_colors(c, color)
    edges = NTuple{4, Float64}[]
    for ring in GI.getgeom(poly)
        x, y = xy(ring)
        px = map(v -> scale_x_to_pixel(c, v), x)
        py = map(v -> scale_y_to_pixel(c, v), y)
        for i in eachindex(px, py)  # cyclic, as a ring may be given unclosed
            j = i == lastindex(px) ? firstindex(px) : i + 1
            push!(edges, (px[i], py[i], px[j], py[j]))
        end
    end
    crossings = Float64[]
    for pixel_y in 0:stride:(pixel_height(c) - 1)
        yc = pixel_y + 0.5
        empty!(crossings)
        for (x1, y1, x2, y2) in edges
            (y1 ≤ yc < y2 || y2 ≤ yc < y1) &&
                push!(crossings, x1 + (yc - y1) * (x2 - x1) / (y2 - y1))
        end
        sort!(crossings)
        for i in 1:2:(length(crossings) - 1)
            lo = max(0, ceil(Int, crossings[i] - 0.5))
            hi = min(pixel_width(c) - 1, floor(Int, crossings[i + 1] - 0.5))
            for pixel_x in lo:hi
                pixel_x % stride == 0 && pixel!(c, pixel_x, pixel_y, col, blend)
            end
        end
    end
    return plot
end

# Top-level features or geometries, which `color` values correspond to.
members(obj) = members(GI.trait(obj), obj)
members(::Nothing, objs::AbstractVector) = skipmissing(objs)
members(::GI.AbstractFeatureCollectionTrait, fc) = GI.getfeature(fc)
members(_, obj) = (obj,)

# Call `f` on every point, multipoint, curve and polygon contained in `obj`.
foreach_part(f, obj) = foreach_part(f, GI.trait(obj), obj)
foreach_part(f, ::Nothing, objs::AbstractVector) =
    foreach(o -> foreach_part(f, o), skipmissing(objs))
foreach_part(
    f,
    ::Union{
        GI.AbstractPointTrait,
        GI.AbstractMultiPointTrait,
        GI.AbstractCurveTrait,
        GI.AbstractPolygonTrait,
    },
    geom,
) = f(geom)
foreach_part(f, ::GI.AbstractGeometryTrait, geom) =
    foreach(g -> foreach_part(f, g), GI.getgeom(geom))
foreach_part(f, ::GI.AbstractFeatureTrait, feature) =
    foreach_part(f, GI.geometry(feature))
foreach_part(f, ::GI.AbstractFeatureCollectionTrait, fc) =
    foreach(g -> foreach_part(f, g), GI.getfeature(fc))

xy(geom) = xy(GI.trait(geom), geom)
xy(::GI.AbstractPointTrait, point) = [GI.x(point)], [GI.y(point)]
xy(_, geom) = [GI.x(p) for p in GI.getpoint(geom)], [GI.y(p) for p in GI.getpoint(geom)]

end  # module
