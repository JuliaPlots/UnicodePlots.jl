gaussian_2d(x = -3:.01:3, y = -7:.01:3; x₀=0, y₀=-2, σx=1, σy=2) = begin
    X = repeat(x', length(y), 1)
    Y = repeat(y, 1, length(x))
    x, y, map((x, y) -> exp(-((x - x₀) / 2σx)^2 - ((y - y₀) / 2σy)^2), X, Y)
end

@testset "arbitrary colormap" begin
    colormap = :cividis
    p = @inferred contourplot(gaussian_2d()...; colormap = colormap)
    test_ref("references/contourplot/gauss_$colormap.txt", @show_col(p))
end

@testset "number of levels" begin
    levels = 5
    p = @inferred contourplot(gaussian_2d()...; levels = levels)
    test_ref("references/contourplot/gauss_$(levels)levels.txt", @show_col(p))
end

@testset "update contourplot" begin
    p = @inferred contourplot(gaussian_2d()...; levels = 2)
    contourplot!(p, gaussian_2d(; σx = .5, σy = .25)...; levels = 1, colormap = :magma)
    test_ref("references/contourplot/gauss_nested.txt", @show_col(p))
end

@testset "function" begin
    p = @inferred contourplot(-3:.1:3, -3:.1:4, (x, y) -> (exp(-x^2 - y^2) + exp(-(x - 1)^2 - 2(y - 2)^2))^2)
    test_ref("references/contourplot/function_contour.txt", @show_col(p))
end
