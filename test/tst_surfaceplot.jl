@testset "zscale" begin
    sombrero(x, y) = 30sinc(√(x^2 + y^2) / π)

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero)
    test_ref("references/surfaceplot/sombrero.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero, zscale = :aspect)
    test_ref("references/surfaceplot/sombrero_aspect.txt", @show_col(p))

    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero, zscale = h -> h / 2)
    test_ref("references/surfaceplot/sombrero_zscale.txt", @show_col(p))
end

@testset "single color - no colormap" begin
    p = surfaceplot(0:0.5:(2π), 0:0.5:(2π), (x, y) -> sin(x) + cos(y), color = :yellow)
    test_ref("references/surfaceplot/single_color.txt", @show_col(p))
end

@testset "matrix" begin
    p = surfaceplot(collect(1:10) * collect(.1:.1:1)')
    test_ref("references/surfaceplot/matrix.txt", @show_col(p))
end
