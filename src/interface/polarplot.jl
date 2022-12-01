"""
    polarplot(θ, r; kw...)
    polarplot!(p, args...; kw...)

Draws `θ` angles and `r` radii on a polar plot.

# Usage

    polarplot(θ, r; $(keywords(; add = (:canvas,))))

# Arguments

$(arguments(
    (
        θ = "angles values (radians)",
        r = "radii, or `Function` evaluated as `r(θ)`",
        rlim = "plotting range for the `r` axis (`(0, 0)` stands for automatic)",
        degrees = "label angles using degrees",
        num_rad_lab = "number of radius labels",
        ang_rad_lab = "angle where the radius labels are drawn",
        scatter = "use scatter instead of lines",
    )
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> polarplot(range(0, 2π, length = 20), range(0, 2, length = 20))
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀90°⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠤⠒⠒⠉⠉⠉⠉⠉⡏⠉⠉⠉⠉⠓⠒⠦⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⢀⡤⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠒⠤⡀⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⡠⠞⠓⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜2⢄⠀⠀⠀⠀⠀   
        ⠀⠀⠀⣠⠊⠀⠀⠀⠀⠉⠢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠊⠁⠀⠀⠀⠱⣄⠀⠀⠀   
        ⠀⠀⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⠑⠤⡀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀1⠔⠁⠀⠀⠀⠀⠀⠀⠀⠈⢦⠀⠀   
        ⠀⡸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣈⠶⢖⠒⠒⠒⠢⣇⡀⠀⠀⢀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣇⠀   
        ⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠉⠢⣀⠀⡇⢣⡠⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀   
   180° ⠀⡧⠤⠤⠤⠤⠤⠤⠤⠤⢤⠧⠤⠤⠤⠤⠤⠤⠤⠤⡵0⡭⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢼⠀ 0°
        ⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⢀⠔⠊⠀⡇⠈⠒⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢿⠀   
        ⠀⢱⡀⠀⠀⠀⠀⠀⠀⠀⠸⡀⠀⠀⢀⡠⠊⠁⠀⠀⠀⡇⠀⠀⠀⠉⠢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢎⡏⠀   
        ⠀⠀⠳⡀⠀⠀⠀⠀⠀⠀⠀⠱⡠⠔⠁⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠑⠤⡀⠀⠀⠀⠀⠀⢀⠔⢁⠞⠀⠀   
        ⠀⠀⠀⠙⢄⠀⠀⠀⠀⢀⠔⠊⠈⠢⣀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠈⠒⢄⢀⡠⠔⠁⡰⠋⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠑⢦⡠⠊⠁⠀⠀⠀⠀⠀⠉⠒⠢⢄⣀⠀⡇⠀⠀⠀⠀⠀⢀⣀⣀⡠⠔⠊⠉⢢⡤⠊⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⠈⠓⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⡏⠉⠉⠉⠉⠉⠁⠀⠀⠀⣀⠤⠒⠁⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠓⠒⠤⠤⣀⣀⣀⣀⣀⣇⣀⣀⣀⣀⡤⠤⠖⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀270°⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   
```

# See also

`Plot`, `lineplot`, `BrailleCanvas`
"""
function polarplot(
    θ::AbstractVector,
    r::Union{Function,AbstractVector};
    rlim = (0, 0),
    kw...,
)
    pkw, okw = split_plot_kw(kw)
    r, lims = polar_lims(θ, r, rlim)
    plot = Plot(
        lims,
        lims;
        xlim = lims,
        ylim = lims,
        grid = false,
        border = :none,
        xticks = false,
        yticks = false,
        blend = false,
        pkw...,
    )
    polarplot!(plot, θ, r; rlim, okw...)
end

@doc (@doc polarplot) function polarplot!(
    plot::Plot{<:Canvas},
    θ::AbstractVector,
    r::AbstractVector;
    rlim = (0, 0),
    degrees = true,
    num_rad_lab = 3,
    ang_rad_lab = π / 4,
    scatter = false,
    kw...,
)
    mr, Mr = rlim = collect(rlim)

    # grid
    theta = range(0, 2π, length = 360)
    color = BORDER_COLOR[]
    lineplot!(plot, Mr * cos.(theta), Mr * sin.(theta); color)

    for theta ∈ 0:(π / 4):(2π)
        lineplot!(plot, rlim .* cos(theta), rlim .* sin(theta); color)
    end

    # labels
    row = ceil(Int, nrows(plot.graphics) / 2)
    label!(plot, :r, row, degrees ? "0°" : "0"; color)
    label!(plot, :t, degrees ? "90°" : "π / 2"; color)
    label!(plot, :l, row, degrees ? "180°" : "π"; color)
    label!(plot, :b, degrees ? "270°" : "3π / 4"; color)

    for r ∈ range(mr, Mr, length = num_rad_lab)
        annotate!(
            plot,
            r * cos(ang_rad_lab),
            r * sin(ang_rad_lab),
            isinteger(r) ? string(round(Int, r)) : @sprintf("%.1f", r);
            color,
        )
    end

    # user data
    (scatter ? scatterplot! : lineplot!)(plot, r .* cos.(θ), r .* sin.(θ); kw...)

    plot
end

function polar_lims(θ::AbstractVector, r::Union{Function,AbstractVector}, rlim)
    r = r isa Function ? r.(θ) : r
    r_max = last(is_auto(rlim) ? extrema(r) : rlim)
    lims = x = y = [-r_max, +r_max]
    r, lims
end
