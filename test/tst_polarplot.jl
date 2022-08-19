@testset "simple" begin
    p = polarplot(range(0, 2π, length = 20), range(0, 2, length = 20))
    test_ref("polarplot/simple.txt", @show_col(p))
end

@testset "simple with 𝓇lim" begin
    p = polarplot(range(0, 2π, length = 20), range(0, 2, length = 20), 𝓇lim = (0, 3))
    test_ref("polarplot/simple_with_rlim.txt", @show_col(p))
end

@testset "callable" begin
    p = polarplot(range(0, 4π, length = 40), θ -> θ ./ 2π)
    test_ref("polarplot/callable.txt", @show_col(p))
end

@testset "kwargs" begin
    h, w = map(x -> round(Int, 1.5x), default_size!())
    p = polarplot(
        range(0, 2π, length = 20),
        range(0, 1, length = 20);
        scatter = true,
        border = :solid,  # override
        color = :red,
        height = h,
        width = w,
    )
    @test nrows(p.graphics) == h
    @test ncols(p.graphics) == w
    test_ref("polarplot/kwargs.txt", @show_col(p))
end
