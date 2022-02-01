@testset "surface" begin
    sombrero(x, y) = sinc(√(x^2 + y^2) / π)
    p = surfaceplot(-6:.5:10, -8:.5:10, sombrero)

    test_ref("references/surfaceplot/sombrero.txt", @show_col(p))
end
