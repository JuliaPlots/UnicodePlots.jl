@testset "simple" begin
    p = polarplot(range(0, 2π, length = 20), range(0, 2, length = 20))
    test_ref("polarplot/simple.txt", @show_col(p))
end

@testset "callable" begin
    p = polarplot(range(0, 4π, length = 40), θ -> θ ./ 2π)
    test_ref("polarplot/callable.txt", @show_col(p))
end

@testset "kwargs" begin
    p = polarplot(
        range(0, 2π, length = 20),
        range(0, 2, length = 20);
        color = :red,
        scatter = true,
    )
    test_ref("polarplot/kwargs.txt", @show_col(p))
end
