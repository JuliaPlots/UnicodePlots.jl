@testset "isosurface" begin
    torus(x, y, z, r = .2, R = .5) = (√(x^2 + y^2) - R)^2 + z^2 - r^2
    p = isosurface(-1:.1:1, -1:.1:1, -1:.1:1, torus; xlim = (-.5, .5), ylim = (-.5, .5), elevation = 50)

    test_ref("references/isosurface/torus.txt", @show_col(p))
end