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
    )
))

# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

```julia-repl
julia> polarplot(range(0, 2π, length = 20), range(0, 2, length = 20))
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
    2 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠤⠒⠒⠉⠉⠉⠉⠉⡏⠉⠉⠉⠉⠓⠒⠦⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
      ⠀⠀⠀⠀⠀⠀⠀⢀⡤⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠒⠤⡀⠀⠀⠀⠀⠀⠀⠀ 
      ⠀⠀⠀⠀⠀⡠⠞⠓⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⠓⢄⠀⠀⠀⠀⠀ 
      ⠀⠀⠀⣠⠊⠀⠀⠀⠀⠉⠢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠊⠁⠀⠀⠀⠱⣄⠀⠀⠀ 
      ⠀⠀⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⠑⠤⡀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡠⠔⠁⠀⠀⠀⠀⠀⠀⠀⠈⢦⠀⠀ 
      ⠀⡸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣈⠶⢖⠒⠒⠒⠢⣇⡀⠀⠀⢀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣇⠀ 
      ⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠉⠢⣀⠀⡇⢣⡠⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀ 
      ⠀⡧⠤⠤⠤⠤⠤⠤⠤⠤⢤⠧⠤⠤⠤⠤⠤⠤⠤⠤⡵⡷⡭⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⢼⠀ 
      ⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⢀⠔⠊⠀⡇⠈⠒⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢿⠀ 
      ⠀⢱⡀⠀⠀⠀⠀⠀⠀⠀⠸⡀⠀⠀⢀⡠⠊⠁⠀⠀⠀⡇⠀⠀⠀⠉⠢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢎⡏⠀ 
      ⠀⠀⠳⡀⠀⠀⠀⠀⠀⠀⠀⠱⡠⠔⠁⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠑⠤⡀⠀⠀⠀⠀⠀⢀⠔⢁⠞⠀⠀ 
      ⠀⠀⠀⠙⢄⠀⠀⠀⠀⢀⠔⠊⠈⠢⣀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠈⠒⢄⢀⡠⠔⠁⡰⠋⠀⠀⠀ 
      ⠀⠀⠀⠀⠀⠑⢦⡠⠊⠁⠀⠀⠀⠀⠀⠉⠒⠢⢄⣀⠀⡇⠀⠀⠀⠀⠀⢀⣀⣀⡠⠔⠊⠉⢢⡤⠊⠀⠀⠀⠀⠀ 
      ⠀⠀⠀⠀⠀⠀⠀⠈⠓⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⡏⠉⠉⠉⠉⠉⠁⠀⠀⠀⣀⠤⠒⠁⠀⠀⠀⠀⠀⠀⠀ 
   -2 ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠓⠒⠤⠤⣀⣀⣀⣀⣀⣇⣀⣀⣀⣀⡤⠤⠖⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
      ⠀-2⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀2⠀ 

"""
function polarplot(θ::AbstractVector, 𝓇::Union{Function,AbstractVector})
    𝓇 = 𝓇 isa Function ? 𝓇.(θ) : 𝓇

    mr, Mr = extrema(𝓇)
    x = y = [-Mr, +Mr]
    lims = -Mr, +Mr
    plot = Plot(x, y; xlim = lims, ylim = lims, grid = false, border = :none)
    polarplot!(plot, θ, 𝓇)
end

function polarplot!(plot::Plot{<:Canvas}, θ::AbstractVector, 𝓇::AbstractVector)
    mr, Mr = extrema(𝓇)

    # drawing grid
    theta = range(0, 2π, length = 360)
    grid_color = BORDER_COLOR[]
    lineplot!(plot, Mr * cos.(theta), Mr * sin.(theta), color = grid_color)

    for theta in 0:(π / 4):(2π)
        lineplot!(plot, [mr, Mr] .* cos(theta), [mr, Mr] .* sin(theta), color = grid_color)
    end

    # drawing user data
    lineplot!(plot, 𝓇 .* cos.(θ), 𝓇 .* sin.(θ))
    plot
end
