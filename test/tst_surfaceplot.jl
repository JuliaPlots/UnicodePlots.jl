@testset "surface" begin
    sombrero(x, y) = 15sinc(√(x^2 + y^2) / π)
    p = surfaceplot(-8:.5:8, -8:.5:8, sombrero)

    test_ref("references/surfaceplot/sombrero.txt", @show_col(p))
end
