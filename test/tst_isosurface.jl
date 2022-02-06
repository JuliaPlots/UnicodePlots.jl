@testset "sphere" begin
    p = isosurface(
        -3:0.2:3,
        -3:0.2:3,
        -3:0.2:3,
        (x, y, z) -> x^2 + y^2 + z^2 - 2;
        centroid = false,
        axes3d = false,
        cull = true,
        zoom = 2,
    )
    test_ref("references/isosurface/sphere.txt", @show_col(p))
end

@testset "torus" begin
    torus(x, y, z, r = 0.2, R = 0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
    p = isosurface(
        -1:0.1:1,
        -1:0.1:1,
        -1:0.1:1,
        torus;
        elevation = 50,
        cull = true,
        zoom = 2,
    )
    test_ref("references/isosurface/torus.txt", @show_col(p))
end

@testset "hyperboloid" begin
    p = isosurface(-3:0.6:3, -3:0.6:3, -3:0.6:3, (x, y, z) -> x^2 + y^2 - z^2 - 1;)
    test_ref("references/isosurface/hyperboloid.txt", @show_col(p))
end
