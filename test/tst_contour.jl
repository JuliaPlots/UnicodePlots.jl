contour_data() = begin
    δ = .025
    x = range(-3, 3; step=δ)
    y = range(-2, 3; step=δ)

    X = repeat(reshape(x, 1, :), length(y), 1)
    Y = repeat(y, 1, length(x))

    z = 2((exp.(-X.^2 - Y.^2)) - (exp.(-(X .- 1).^2 - (Y .- 1).^2)))
    x, y, z
end

@testset "colormap" begin
    contour(contour_data()...; colormap = :cividis)
end

@testset "levels" begin
    contour(contour_data()...; levels = 3)
end
