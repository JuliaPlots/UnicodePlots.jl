"""
    geoplot(geom; kw...)
    geoplot!(p, geom; kw...)

# Description

Draws geometries implementing the [GeoInterface](https://github.com/JuliaGeo/GeoInterface.jl) specification.

Points are drawn as scatter points, while lines and polygon rings (including holes) are drawn as paths.
Polygon interiors are sprinkled with points, at a density set by `fill`.
Accepts a single geometry, a feature, a feature collection, or a vector of these.

Requires `GeoInterface` to be loaded.

# Usage

    geoplot(geom; $(keywords((; fill = true); add = (:canvas,))))

# Arguments

$(
    arguments(
        (
            fill = "sprinkle points inside polygons: `true` (every other canvas pixel), `false` (outlines only), or an integer pixel stride (`1` fills densely)",
            color = "a color, a `Vector` with one entry per geometry or feature (numbers are mapped through `colormap`), or the name of a feature property as a `String`",
        ); add = (:canvas,)
    )
)

# See also

[`Plot`](@ref), [`lineplot`](@ref), [`scatterplot`](@ref)
"""
function geoplot end

@doc (@doc geoplot) function geoplot! end
