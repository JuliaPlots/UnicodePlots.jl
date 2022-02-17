@testset "densityplot" begin
    seed!(RNG, 1338)
    dx, dy = randn(RNG, 1000), randn(RNG, 1000)

    p = @dinf densityplot(dx, dy)
    @test @dinf(densityplot!(p, dx .+ 2, dy .+ 2)) === p
    @test p isa Plot
    test_ref("references/scatterplot/densityplot.txt", @show_col(p))

    p = @dinf densityplot(dx, dy, name = "foo", color = :red, title = "Title", xlabel = "x")
    @test @dinf(densityplot!(p, dx .+ 2, dy .+ 2, name = "bar")) === p
    @test p isa Plot
    test_ref("references/scatterplot/densityplot_parameters.txt", @show_col(p))
end
