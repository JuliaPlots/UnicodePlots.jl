@testset "default" begin
    p = boxplot([1, 2, 3, 4, 5])
    test_ref("boxplot/default.txt", @show_col(p))
    p = boxplot("series1", [1, 2, 3, 4, 5])
    test_ref("boxplot/default_name.txt", @show_col(p))
    for xlim ∈ ([-1, 8], (-1, 8))
        p = boxplot(
            "series1",
            [1, 2, 3, 4, 5],
            title = "Test",
            xlim = xlim,
            color = :blue,
            width = 50,
            border = :solid,
            xlabel = "foo",
        )
        test_ref("boxplot/default_parameters.txt", @show_col(p))
        test_ref("boxplot/default_parameters_nocolor.txt", @show_nocol(p))
    end
end

@testset "scaling" begin
    for (i, max_x) ∈ enumerate([5, 6, 10, 20, 40])
        for xlim ∈ ((0, max_x), [0, max_x])
            p = boxplot([1, 2, 3, 4, 5], xlim = xlim)
            test_ref("boxplot/scale$i.txt", @show_col(p))
        end
    end
end

@testset "multi-series" begin
    p = boxplot(
        ["one", "two"],
        [[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]],
        title = "Multi-series",
        xlabel = "foo",
        color = :yellow,
    )
    test_ref("boxplot/multi1.txt", @show_col(p))
    @test @inferred(boxplot!(p, "one more", [-1, 2, 3, 4, 11])) ≡ p
    test_ref("boxplot/multi2.txt", @show_col(p))
    @test @inferred(boxplot!(p, [4, 2, 2.5, 4, 14], name = "last one")) ≡ p
    test_ref("boxplot/multi3.txt", @show_col(p))
    p = boxplot([[1, 2, 3, 4, 5], [2, 3, 4, 5, 6, 7, 8, 9]])
    test_ref("boxplot/multi4.txt", @show_col(p))
end

@testset "colors" begin
    p = boxplot(["one", "two"], [[1, 2, 3], [4, 5, 6]], color = 214)
    test_ref("boxplot/col1.txt", @show_col(p))

    p = boxplot(["one", "two"], [[1, 2, 3], [4, 5, 6]], color = (187, 0, 187))
    test_ref("boxplot/col2.txt", @show_col(p))
end

@testset "different colors" begin
    p = boxplot(["one", "two"], [[1, 2, 3], [4, 5, 6]], color = [:red, :green])
    test_ref("boxplot/colors.txt", @show_col(p))
end
