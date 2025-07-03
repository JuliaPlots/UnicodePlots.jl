# NOTE: use `axes3d = false` on stability of \ issues w.r.t azimuth and elevation

@testset "sphere" begin
    x = y = z = -3:0.2:3
    p = isosurface(
        x,
        y,
        z,
        (x, y, z) -> x^2 + y^2 + z^2 - 2;
        centroid = false,
        cull = true,
        zoom = 2,
    )
    test_ref("isosurface/sphere.txt", @show_col(p))
end

@testset "torus" begin
    torus(x, y, z, r = 0.2, R = 0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
    x = y = z = -1:0.1:1
    p = isosurface(x, y, z, torus; cull = true, zoom = 2)
    test_ref("isosurface/torus.txt", @show_col(p))
end

@testset "hyperboloid" begin
    x = y = z = -3:0.8:3
    p = isosurface(x, y, z, (x, y, z) -> x^2 + y^2 - z^2 - 1)
    test_ref("isosurface/hyperboloid.txt", @show_col(p))
end

@testset "legacy" begin
    x = y = z = -3:0.25:3
    p = isosurface(x, y, z, (x, y, z) -> x * exp(-x^2 - y^2 - z^2) - 1.0e-4; legacy = true)
    test_ref("isosurface/legacy.txt", @show_col(p))
end
