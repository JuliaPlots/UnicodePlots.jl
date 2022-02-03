@testset "torus" begin
    torus(x, y, z, r = 0.2, R = 0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
    p = isosurface(
        -1:0.1:1,
        -1:0.1:1,
        -1:0.1:1,
        torus;
        xlim = (-0.5, 0.5),
        ylim = (-0.5, 0.5),
        elevation = 50,
        cull = true,
    )

    test_ref("references/isosurface/torus.txt", @show_col(p))
end

@testset "hyperboloid" begin
    p = isosurface(
        -3:0.6:3,
        -3:0.6:3,
        -3:0.6:3,
        (x, y, z) -> x^2 + y^2 - z^2 - 1;
        xlim = (-1, 1),
        ylim = (-1, 1),
    )
    test_ref("references/isosurface/hyperboloid.txt", @show_col(p))
end
