seed!(RNG, 1337)
x, y = randn(RNG, 10_000), randn(RNG, 10_000)

@testset "densityplot" begin
    p = @inferred Plot densityplot(x, y)
    @test densityplot!(p, x .+ 2, y .+ 2) ≡ p
    @test p isa Plot
    test_ref("densityplot/densityplot.txt", @show_col(p))
end

@testset "parameters" begin
    p = @inferred Plot densityplot(
        x,
        y,
        name = "foo",
        color = :red,
        title = "Title",
        xlabel = "x",
    )
    @test densityplot!(p, x .+ 2, y .+ 2, name = "bar") ≡ p
    @test p isa Plot
    test_ref("densityplot/densityplot_parameters.txt", @show_col(p))
end

@testset "dscale" begin
    # UnicodePlots.jl/issues/226
    # identity: only peaks appear (data is hidden)
    # sqrt: we start to see underlying data
    # x -> log(1 + x): start to see the 2D normal law profile
    # x -> x / (x + 1): peak hidden
    for (dscale, name) ∈ (
        (identity, "identity"),
        (sqrt, "sqrt"),
        (x -> log(1 + x), "log"),
        (x -> x / (x + 1), "custom"),
    )
        x′ = copy(x)
        x′[round(Int, 0.1length(x)):round(Int, 0.6length(x))] .= 0.5maximum(x)
        p = densityplot(x′, y; dscale = dscale)
        test_ref("densityplot/densityplot_dscale_$name.txt", @show_col(p))
    end
end
