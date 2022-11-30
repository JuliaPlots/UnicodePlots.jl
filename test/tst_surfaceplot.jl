@testset "zscale" begin
    sombrero(x, y) = 50sinc(√(x^2 + y^2) / π)

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero)
    test_ref("surfaceplot/sombrero_aspect.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero; zscale = :identity)
    test_ref("surfaceplot/sombrero_identity.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero; zscale = h -> h / 2)
    test_ref("surfaceplot/sombrero_zscale.txt", @show_col(p))

    @test_throws ArgumentError surfaceplot([1 2; 3 4]; zscale = :not_supported)
end

@testset "single color - no colormap" begin
    f = (x, y) -> sin(x) + cos(y)
    x, y = 0:0.5:(2π), 0:0.5:(2π)
    p = surfaceplot(x, y, f, color = :cyan, axes3d = false)
    test_ref("surfaceplot/single_color.txt", @show_col(p))

    x, y = 0:π, π:(2π)
    X, Y = UnicodePlots.meshgrid(x, y)
    surfaceplot!(p, X, Y, zero(X), nothing; color = :white, lines = true)
    @test !p.cmap.bar  # since we gave the `color` keyword twice
    test_ref("surfaceplot/mutate.txt", @show_col(p))
end

@testset "matrix" begin
    A = collect(1:10) * collect(0.1:0.1:1)'

    p = surfaceplot(A, axes3d = false)
    test_ref("surfaceplot/matrix.txt", @show_col(p))

    p = surfaceplot(A, padding = 0, margin = 0, axes3d = false)
    test_ref("surfaceplot/matrix_compact.txt", @show_col(p))
end

@testset "masking values using `NaN`s" begin
    x = y = -4:4

    z = 1 ./ sin.(x' .* y)  # produce data with `Inf` values
    z[isinf.(z)] .= NaN  # mask infinite values (quite common scenario)

    p = surfaceplot(x, y, z)
    test_ref("surfaceplot/masked_values_points.txt", @show_col(p))

    p = surfaceplot(x, y, z; lines = true)
    test_ref("surfaceplot/masked_values_lines.txt", @show_col(p))
end

@testset "color interpolation" begin
    p = surfaceplot(
        -2:2,
        -2:2,
        (x, y) -> 15sinc(√(x^2 + y^2) / π),
        colormap = :jet,
        elevation = 60,
        lines = true,
        height = 30,
        width = 80,
    )
    test_ref("surfaceplot/interpolation.txt", @show_col(p))
end

@testset "slice" begin
    data = zeros(40, 20, 20)
    x, y, z = (axes(data, d) for d ∈ 1:ndims(data))
    xc, yc, zc = 30, 8, 8  # centers
    xr, yr, zr = 10, 6, 3  # radii

    for k ∈ z, j ∈ y, i ∈ x  # ellipsoid
        data[i, j, k] = ((i - xc) / xr)^2 + ((j - yc) / yr)^2 + ((k - zc) / zr)^2
    end

    kw = (; zscale = z -> zc, colormap = :jet, azimuth = -90, elevation = 90)

    slice = data[:, :, zc]

    p = surfaceplot(x, y, slice; kw...)
    test_ref("surfaceplot/slice_scatter.txt", @show_col(p))

    p = surfaceplot(x, y, slice; kw..., lines = true)
    test_ref("surfaceplot/slice_lines.txt", @show_col(p))
end

@testset "consistency with `contourplot`" begin
    x = -2:0.2:2
    y = -3:0.2:1
    z = (x, y) -> 10x * exp(-x^2 - y^2)
    p = surfaceplot(x, y, z; azimuth = -60, elevation = 30, axes3d = false)
    test_ref("surfaceplot/consistency.txt", @show_col(p))
end
