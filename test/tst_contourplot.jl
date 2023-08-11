@testset "padding" begin
    x = y = -1:0.1:1
    for padding ∈ 0:3
        p = contourplot(
            x,
            y,
            (x, y) -> 1e4 * √(x^2 + y^2);
            labels = false,
            margin = 0,
            padding,
        )
        test_ref("contourplot/padding_$padding.txt", @show_col(p))
    end
end

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

@testset "custom levels" begin
    p = @binf contourplot(gaussian_2d()...; levels = [0.2, 0.5, 0.6, 0.8])
    test_ref("contourplot/gauss_customlevels.txt", @show_col(p))
end

@testset "update contourplot" begin
    p = @binf contourplot(gaussian_2d()...; levels = 2)
    # mutate the colormap & number of levels
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

@testset "consistency with `surfaceplot`" begin
    x = -2:0.2:2
    y = -3:0.2:1
    z = (x, y) -> 10x * exp(-x^2 - y^2)
    p = contourplot(x, y, z; levels = 10)
    test_ref("contourplot/consistency.txt", @show_col(p))
end

@testset "filled `contourplot`" begin
    himmelblau(x, y) = (x^2 + y - 11)^2 + (x + y^2 - 7)^2
    x = y = range(-5, 5; length = 25)
    p = contourplot(x, y, himmelblau; levels = [30, 80, 150, 400], canvas = FilledCanvas)
    test_ref("contourplot/filled_himmelblau.txt", @show_col(p))
end
