@testset "isosurface" begin
    torus(x, y, z, r = 0.2, R = 0.5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
    p = isosurface(
        -1:0.1:1,
        -1:0.1:1,
        -1:0.1:1,
        torus;
        xlim = (-0.5, 0.5),
        ylim = (-0.5, 0.5),
        elevation = 50,
    )

    test_ref("references/isosurface/torus.txt", @show_col(p))
end
