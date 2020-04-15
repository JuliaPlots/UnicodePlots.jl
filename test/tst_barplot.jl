@testset "positional types" begin
    dct = Dict("foo" => 37, "bar" => 23)
    p = barplot(dct)
    @test_reference(
        "references/barplot/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/barplot/default.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/barplot/nocolor.txt",
        @io2str(show(::IO, p)),
        render = BeforeAfterFull()
    )

    dct = Dict("foo" => 37., :bar => 23., 2.1 => 10)
    p = barplot(dct)
    @test_reference(
        "references/barplot/default_mixed.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    dct = Dict(:foo => 37, :bar => 23)
    p = barplot(dct)
    @test_reference(
        "references/barplot/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot([:bar, :foo], Int16[23, 37])
    @test_reference(
        "references/barplot/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot(["bar", "foo"], [23, 37])
    @test_reference(
        "references/barplot/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_throws DimensionMismatch barplot!(p, ["zoom"], [90, 80])
    @test_throws DimensionMismatch barplot!(p, ["zoom", "boom"], [90])
    @test_throws MethodError barplot!(p, ["zoom"], [90.])
    @test_throws InexactError barplot!(p, "zoom", 90.1)
    @test barplot!(p, ["zoom"], [90]) === p
    @test_reference(
        "references/barplot/default2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p =  barplot(["bar", "foo"], [23, 37])
    @test barplot!(p, :zoom, 90.) === p
    @test_reference(
        "references/barplot/default2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot(["bar", "foo"], [23, 37])
    @test_throws MethodError barplot!(p, Dict("zoom" => 90.))
    @test barplot!(p, Dict("zoom" => 90)) === p
    @test_reference(
        "references/barplot/default2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot(["bar", "foo"], [23, 37])
    @test barplot!(p, Dict(:zoom => 90)) === p
    @test_reference(
        "references/barplot/default2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot(2:6, 11:15)
    @test_reference(
        "references/barplot/ranges.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test barplot!(p, 9:10, 20:21) === p
    @test_reference(
        "references/barplot/ranges2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "keyword arguments" begin
    p = barplot(
        [:a, :b, :c, :d, :e],
        [0, 1, 10, 100, 1000],
        title = "Logscale Plot",
        xscale = log10,
    )
    @test_reference(
        "references/barplot/log10.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = barplot(
        [:a, :b, :c, :d, :e],
        [0, 1, 10, 100, 1000],
        title = "Logscale Plot",
        xlabel = "custom label",
        xscale = log10,
    )
    @test_reference(
        "references/barplot/log10_label.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :blue,
        margin = 7,
        padding = 3,
    )
    @test_reference(
        "references/barplot/parameters1.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :blue,
        margin = 7,
        padding = 3,
        labels = false,
    )
    @test_reference(
        "references/barplot/parameters1_nolabels.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :yellow,
        border = :solid,
        symb = "=",
        width = 60
    )
    @test_reference(
        "references/barplot/parameters2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    # same but with Char as symb
    p = barplot(
        ["Paris", "New York", "Moskau", "Madrid"],
        [2.244, 8.406, 11.92, 3.165],
        title = "Relative sizes of cities",
        xlabel = "population [in mil]",
        color = :yellow,
        border = :solid,
        symb = '=',
        width = 60
    )
    @test_reference(
        "references/barplot/parameters2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "edge cases" begin
    @test_throws ArgumentError barplot([:a, :b], [-1, 2])
    p = barplot([5,4,3,2,1], [0,0,0,0,0])
    @test_reference(
        "references/barplot/edgecase_zeros.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = barplot([:a,:b,:c,:d], [1,1,1,1000000])
    @test_reference(
        "references/barplot/edgecase_onelarge.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end
