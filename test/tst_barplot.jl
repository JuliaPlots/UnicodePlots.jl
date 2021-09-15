@testset "positional types" begin
    dct = Dict("foo" => 37, "bar" => 23)
    p = @inferred Plot barplot(dct)
    test_ref("references/barplot/default.txt", @print_col(p))
    test_ref("references/barplot/default.txt", @show_col(p))
    test_ref("references/barplot/nocolor.txt", @show_nocol(p))

    dct = Dict("foo" => 37., :bar => 23., 2.1 => 10)
    p = @inferred Plot barplot(dct)
    test_ref("references/barplot/default_mixed.txt", @print_col(p))

    dct = Dict(:foo => 37, :bar => 23)
    p = @inferred Plot barplot(dct)
    test_ref("references/barplot/default.txt", @print_col(p))

    p = @inferred barplot([:bar, :foo], Int16[23, 37])
    test_ref("references/barplot/default.txt", @print_col(p))

    p = @inferred barplot(["bar", "foo"], [23, 37])
    test_ref("references/barplot/default.txt", @print_col(p))
    @test_throws DimensionMismatch barplot!(p, ["zoom"], [90, 80])
    @test_throws DimensionMismatch barplot!(p, ["zoom", "boom"], [90])
    @test_throws MethodError barplot!(p, ["zoom"], [90.])
    @test_throws InexactError barplot!(p, "zoom", 90.1)
    @test @inferred(barplot!(p, ["zoom"], [90])) === p
    test_ref("references/barplot/default2.txt", @print_col(p))

    p = @inferred barplot(["bar", "foo"], [23, 37])
    @test @inferred(barplot!(p, :zoom, 90.)) === p
    test_ref("references/barplot/default2.txt", @print_col(p))

    p = @inferred barplot(["bar", "foo"], [23, 37])
    @test_throws MethodError barplot!(p, Dict("zoom" => 90.))
    @test @inferred(barplot!(p, Dict("zoom" => 90))) === p
    test_ref("references/barplot/default2.txt", @print_col(p))

    p = @inferred barplot(["bar", "foo"], [23, 37])
    @test @inferred(barplot!(p, Dict(:zoom => 90))) === p
    test_ref("references/barplot/default2.txt", @print_col(p))

    p = @inferred barplot(2:6, 11:15)
    test_ref("references/barplot/ranges.txt", @print_col(p))
    @test @inferred(barplot!(p, 9:10, 20:21)) === p
    test_ref("references/barplot/ranges2.txt", @print_col(p))
end

@testset "keyword arguments" begin
    p = @inferred barplot(
        [:a, :b, :c, :d, :e],
        [0, 1, 10, 100, 1000],
        title = "Logscale Plot",
        xscale = :log10,
    )
    test_ref("references/barplot/log10.txt", @print_col(p))
    p = @inferred barplot(
        [:a, :b, :c, :d, :e],
        [0, 1, 10, 100, 1000],
        title = "Logscale Plot",
        xlabel = "custom label",
        xscale = :log10,
    )
    test_ref("references/barplot/log10_label.txt", @print_col(p))

    p = @inferred barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :blue,
        margin = 7,
        padding = 3,
    )
    test_ref("references/barplot/parameters1.txt", @print_col(p))
    p = @inferred barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = (0,0,255),
        margin = 7,
        padding = 3,
        labels = false,
    )
    test_ref("references/barplot/parameters1_nolabels.txt", @print_col(p))

    p = @inferred barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :yellow,
        border = :solid,
        symbols = ["="],
        width = 60
    )
    test_ref("references/barplot/parameters2.txt", @print_col(p))
    # same but with Char as symbols
    p = @inferred barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :yellow,
        border = :solid,
        symbols = ['='],
        width = 60
    )
    test_ref("references/barplot/parameters2.txt", @print_col(p))
end

@testset "edge cases" begin
    @test_throws ArgumentError barplot([:a, :b], [-1, 2])
    p = barplot([5,4,3,2,1], [0,0,0,0,0])
    test_ref("references/barplot/edgecase_zeros.txt", @print_col(p))
    p = barplot([:a,:b,:c,:d], [1,1,1,1000000])
    test_ref("references/barplot/edgecase_onelarge.txt", @print_col(p))
end

@testset "colors" begin
    p = barplot(["B","A"], [2,1], color=9)
    test_ref("references/barplot/col1.txt", @print_col(p))
    p = barplot(["B","A"], [2,1], color=(200,50,0))
    test_ref("references/barplot/col2.txt", @print_col(p))
end
