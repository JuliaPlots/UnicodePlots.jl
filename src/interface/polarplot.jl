"""
    polarplot(θ, 𝓇; kw...)

Draws angles and radii on a polar plot.

# Usage

    polarplot(θ, 𝓇)

# Arguments

$(arguments(
    (
        θ = "angles values (radians)",
        𝓇 = "radii, or `Function` evaluated as `𝓇(θ)`",
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

"""
function polarplot(θ::AbstractVector, 𝓇::Union{Function,AbstractVector}; kw...)
    𝓇 = 𝓇 isa Function ? 𝓇.(θ) : 𝓇

    mr, Mr = extrema(𝓇)
    x = y = [-Mr, +Mr]
    lims = -Mr, +Mr
    plot = Plot(
        x,
        y;
        xlim = lims,
        ylim = lims,
        grid = false,
        border = :none,
        xticks = false,
        yticks = false,
        blend = false,
    )
    polarplot!(plot, θ, 𝓇; kw...)
end

function polarplot!(
    plot::Plot{<:Canvas},
    θ::AbstractVector,
    𝓇::AbstractVector;
    degrees = true,
    num_rad_lab = 3,
    ang_rad_lab = π / 4,
    scatter = false,
    kw...,
)
    mr, Mr = extrema(𝓇)

    # grid
    theta = range(0, 2π, length = 360)
    grid_color = BORDER_COLOR[]
    lineplot!(plot, Mr * cos.(theta), Mr * sin.(theta), color = grid_color)

    for theta in 0:(π / 4):(2π)
        lineplot!(plot, [mr, Mr] .* cos(theta), [mr, Mr] .* sin(theta); color = grid_color)
    end

    # user data
    (scatter ? scatterplot! : lineplot!)(plot, 𝓇 .* cos.(θ), 𝓇 .* sin.(θ); kw...)

    # labels
    row = round(Int, nrows(plot.graphics) / 2)
    label!(plot, :r, row, degrees ? "0°" : "0", color = grid_color)
    label!(plot, :t, degrees ? "90°" : "π / 2", color = grid_color)
    label!(plot, :l, row, degrees ? "180°" : "π", color = grid_color)
    label!(plot, :b, degrees ? "270°" : "3π / 4", color = grid_color)

    for r in range(mr, Mr, length = num_rad_lab)
        annotate!(
            plot,
            r * cos(ang_rad_lab),
            r * sin(ang_rad_lab),
            isinteger(r) ? string(round(Int, r)) : @sprintf("%.1f", r);
            color = grid_color,
        )
    end
    plot
end
