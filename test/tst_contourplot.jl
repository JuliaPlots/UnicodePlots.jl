gaussian_2d(x = -3:0.01:3, y = -7:0.01:3; x₀ = 0, y₀ = -2, σx = 1, σy = 2) = begin
    g = (x, y) -> exp(-((x - x₀) / 2σx)^2 - ((y - y₀) / 2σy)^2)
    x, y, g.(x', y)
end

@testset "arbitrary colormap" begin
    colormap = :cividis
    p = @binf contourplot(gaussian_2d()...; colormap = colormap)
    test_ref("contourplot/gauss_$colormap.txt", @show_col(p))
end

@testset "number of levels" begin
    levels = 5
    p = @binf contourplot(gaussian_2d()...; levels = levels)
    test_ref("contourplot/gauss_$(levels)levels.txt", @show_col(p))
end

@testset "update contourplot" begin
    p = @binf contourplot(gaussian_2d()...; levels = 2)
    contourplot!(p, gaussian_2d(; σx = 0.5, σy = 0.25)...; levels = 1, colormap = :magma)
    test_ref("contourplot/gauss_nested.txt", @show_col(p))
end

@testset "function" begin
    p = @binf contourplot(
        -3:0.01:3,
        -3:0.01:4,
        (x, y) -> (exp(-x^2 - y^2) + exp(-(x - 1)^2 - 2(y - 2)^2))^2,
    )
    test_ref("contourplot/function_contour.txt", @show_col(p))
end
