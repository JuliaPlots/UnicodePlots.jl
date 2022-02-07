@testset "zscale" begin
    sombrero(x, y) = 30sinc(√(x^2 + y^2) / π)

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero)
    test_ref("references/surfaceplot/sombrero.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero, zscale = :aspect)
    test_ref("references/surfaceplot/sombrero_aspect.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero, zscale = h -> h / 2)
    test_ref("references/surfaceplot/sombrero_zscale.txt", @show_col(p))

    @test_throws ArgumentError surfaceplot([1 2; 3 4], zscale = :not_supported)
end

@testset "single color - no colormap" begin
    p = surfaceplot(0:0.5:(2π), 0:0.5:(2π), (x, y) -> sin(x) + cos(y), color = :yellow)
    test_ref("references/surfaceplot/single_color.txt", @show_col(p))
end

@testset "matrix" begin
    p = surfaceplot(collect(1:10) * collect(0.1:0.1:1)')
    test_ref("references/surfaceplot/matrix.txt", @show_col(p))
end

@testset "slice" begin
    data = zeros(40, 20, 20)
    x, y, z = (axes(data, d) for d in 1:ndims(data))
    xc, yc, zc = 30, 8, 8  # centers
    xr, yr, zr = 10, 6, 3  # radii

    for k in z, j in y, i in x  # ellipsoid
        data[i, j, k] = ((i - xc) / xr)^2 + ((j - yc) / yr)^2 + ((k - zc) / zr)^2
    end

    # NOTE: projection precision issues, force azimuth and elevation
    kw = (; zscale = z -> zc, colormap = :jet, azimuth = -90, elevation = 90)

    z = data[:, :, zc]

    p = surfaceplot(x, y, z; kw...)
    test_ref("references/surfaceplot/slice_scatter.txt", @show_col(p))

    p = surfaceplot(x, y, z; kw..., lines = true)
    test_ref("references/surfaceplot/slice_lines.txt", @show_col(p))
end
