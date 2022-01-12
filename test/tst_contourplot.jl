gaussian_2d() = begin
    x = -3:.01:3
    y = -7:.01:3

    X = repeat(x', length(y), 1)
    Y = repeat(y, 1, length(x))

    g(x, y, x₀=0, y₀=-2, σx=1, σy=2) = exp(-((x - x₀) / 2σx)^2 - ((y - y₀) / 2σy)^2)

    x, y, map(g, X, Y)
end

@testset "colormap" begin
    colormap = :cividis
    p = @inferred contourplot(gaussian_2d()...; colormap = colormap)
    test_ref("references/contourplot/gauss_$colormap.txt", @show_col(p, :displaysize=>T_SZ))
end

@testset "levels" begin
    levels = 3
    p = @inferred contourplot(gaussian_2d()...; levels = levels)
    test_ref("references/contourplot/gauss_$(levels)levels.txt", @show_col(p, :displaysize=>T_SZ))
end
