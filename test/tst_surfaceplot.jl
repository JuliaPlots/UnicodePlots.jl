@testset "hscale" begin
    sombrero(x, y) = 30sinc(√(x^2 + y^2) / π)

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero)
    test_ref("references/surfaceplot/sombrero.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero, hscale = :aspect)
    test_ref("references/surfaceplot/sombrero_aspect.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero, hscale = h -> h / 2)
    test_ref("references/surfaceplot/sombrero_hscale.txt", @show_col(p))

    @test_throws ArgumentError surfaceplot([1 2; 3 4], hscale = :not_supported)
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
    for k in z, j in y, i in x
        data[i, j, k] = ((i - xc) / xr)^2 + ((j - yc) / yr)^2 + ((k - zc) / zr)^2  # ellipsoid
    end
    p = surfaceplot(x, y, data[:, :, zc], hscale = x -> zc, colormap = :jet)
    test_ref("references/surfaceplot/slice.txt", @show_col(p))
end
