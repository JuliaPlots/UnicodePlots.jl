@testset "positional types" begin
    dct = Dict("foo" => 37, "bar" => 23)
    p = barplot(dct)
    test_ref("barplot/default.txt", @print_col(p))
    test_ref("barplot/default.txt", @show_col(p))
    test_ref("barplot/nocolor.txt", @show_nocol(p))

    dct = Dict("foo" => 37.0, :bar => 23.0, 2.1 => 10)
    p = barplot(dct)
    test_ref("barplot/default_mixed.txt", @print_col(p))

    dct = Dict(:foo => 37, :bar => 23)
    p = barplot(dct)
    test_ref("barplot/default.txt", @print_col(p))

    p = barplot([:bar, :foo], Int16[23, 37])
    test_ref("barplot/default.txt", @print_col(p))

    p = barplot(["bar", "foo"], [23, 37])
    test_ref("barplot/default.txt", @print_col(p))
    @test_throws DimensionMismatch barplot!(p, ["zoom"], [90, 80])
    @test_throws DimensionMismatch barplot!(p, ["zoom", "boom"], [90])
    @test_throws MethodError barplot!(p, ["zoom"], [90.0])
    @test_throws InexactError barplot!(p, "zoom", 90.1)
    @test barplot!(p, ["zoom"], [90]) ≡ p
    test_ref("barplot/default2.txt", @print_col(p))

    p = barplot(["bar", "foo"], [23, 37])
    @test barplot!(p, :zoom, 90.0) ≡ p
    test_ref("barplot/default2.txt", @print_col(p))

    p = barplot(["bar", "foo"], [23, 37])
    @test_throws MethodError barplot!(p, Dict("zoom" => 90.0))
    @test barplot!(p, Dict("zoom" => 90)) ≡ p
    test_ref("barplot/default2.txt", @print_col(p))

    p = barplot(["bar", "foo"], [23, 37])
    @test barplot!(p, Dict(:zoom => 90)) ≡ p
    test_ref("barplot/default2.txt", @print_col(p))

    p = barplot(2:6, 11:15)
    test_ref("barplot/ranges.txt", @print_col(p))
    @test barplot!(p, 9:10, 20:21) ≡ p
    test_ref("barplot/ranges2.txt", @print_col(p))
end

@testset "keyword arguments" begin
    p = barplot(
        [:a, :b, :c, :d, :e],
        [0, 1, 10, 100, 1000],
        title = "Logscale Plot",
        xscale = :log10,
    )
    test_ref("barplot/log10.txt", @print_col(p))

    p = barplot(
        [:a, :b, :c, :d, :e],
        [0, 1, 10, 100, 1000],
        title = "Logscale Plot",
        xlabel = "custom label",
        xscale = :log10,
    )
    test_ref("barplot/log10_label.txt", @print_col(p))

    p = barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :blue,
        margin = 7,
        padding = 3,
    )
    test_ref("barplot/parameters1.txt", @print_col(p))

    p = barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = (0, 0, 255),
        margin = 7,
        padding = 3,
        labels = false,
    )
    test_ref("barplot/parameters1_nolabels.txt", @print_col(p))

    for sym ∈ ("=", '=')
        p = barplot(
            ["Paris", "New York", "Moskau", "Madrid"],
            [2.244, 8.406, 11.92, 3.165],
            title = "Relative sizes of cities",
            xlabel = "population [in mil]",
            color = :yellow,
            border = :solid,
            symbols = [sym],
            width = 60,
        )
        test_ref("barplot/parameters2.txt", @print_col(p))
    end
end

@testset "edge cases" begin
    @test_throws ArgumentError barplot([:a, :b], [-1, 2])
    p = barplot([5, 4, 3, 2, 1], [0, 0, 0, 0, 0])
    test_ref("barplot/edgecase_zeros.txt", @print_col(p))
    p = barplot([:a, :b, :c, :d], [1, 1, 1, 1000000])
    test_ref("barplot/edgecase_onelarge.txt", @print_col(p))
    barplot("one", 1)
end

@testset "colors" begin
    p = barplot(["B", "A"], [2, 1], color = 9)
    test_ref("barplot/col1.txt", @print_col(p))
    p = barplot(["B", "A"], [2, 1], color = (200, 50, 0))
    test_ref("barplot/col2.txt", @print_col(p))
end

@testset "different colors" begin
    p = barplot(
        [:a, :b, :c, :d, :e],
        [20, 30, 60, 50, 40],
        color = [:red, :green, :blue, :yellow, :normal],
    )
    test_ref("barplot/colors.txt", @print_col(p))
end

@testset "maximum - labels" begin
    p = barplot(
        ["1", "2", "3"],
        [1, 2, 3],
        color = :blue,
        name = "1ˢᵗ series",
        maximum = 10,
    )
    test_ref("barplot/maximum_series1.txt", @print_col(p))
    barplot!(p, ["4", "5", "6"], [6, 1, 10], color = :red, name = "2ⁿᵈ series")
    test_ref("barplot/maximum_series2.txt", @print_col(p))
end
