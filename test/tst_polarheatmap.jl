@testset "simple" begin
    θ = range(0, 2π; length = 100)
    r = range(0, 120; length = 50)
    A = sin.(r ./ 10) .* (cos.(θ))'
    p = polarheatmap(θ, r, A)

    test_ref("polarheatmap/simple.txt", @show_col(p))
end
