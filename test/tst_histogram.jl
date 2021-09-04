seed!(RNG, 1337)
x = randn(RNG, 10000)

@testset "default params" begin
    p = @inferred histogram(x)
    test_ref(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    test_ref(
        "references/histogram/default_nocolor.txt",
        @io2str(print(IOContext(::IO, :color=>false), p))
    )
    p = @inferred histogram(x, closed = :left)
    test_ref(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    hist = fit(Histogram, x, closed = :left)
    p = @inferred histogram(hist)
    test_ref(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(x*100)
    test_ref(
        "references/histogram/default_1e2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(x*0.01)
    test_ref(
        "references/histogram/default_1e-2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(x, xscale = log10)
    test_ref(
        "references/histogram/log10.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(x, xlabel = "custom label", xscale = log10)
    test_ref(
        "references/histogram/log10_label.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram([0.1f0, 0.1f0, 0f0])
    test_ref(
        "references/histogram/float32.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(Histogram([0.0, 0.1, 1.0, 10.0, 100.0], [1, 2, 3, 4]))
    test_ref(
        "references/histogram/nonuniformbins.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    x2 = copy(reshape(x, (1, length(x), 1, 1)))
    p = @inferred Plot histogram(x2)
    test_ref(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(Histogram(1:15., vcat(collect(1:13), 400)))
    test_ref(
        "references/histogram/fraction.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
end

@testset "hist params" begin
    hist = fit(Histogram, x, nbins = 5, closed = :right)
    p = @inferred histogram(hist)
    test_ref(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(x, nbins = 5, closed = :right)
    test_ref(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    # NOTE: run with $ julia --depwarn=yes for this test to pass
    p = @test_logs (:warn, r"`bins`.+deprecated") @inferred histogram(x, bins = 5, closed = :right)
    test_ref(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(x, 5, closed = :right)
    test_ref(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
end

@testset "keyword arguments" begin
    p = @inferred histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :blue,
        margin = 7,
        padding = 3,
    )
    test_ref(
        "references/histogram/parameters1.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    p = @inferred histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :blue,
        margin = 7,
        padding = 3,
        labels = false,
    )
    test_ref(
        "references/histogram/parameters1_nolabels.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )

    p = @inferred histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :yellow,
        border = :solid,
        symbols = ["="],
        width = 50
    )
    test_ref(
        "references/histogram/parameters2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
    # same but with Char as symbols
    p = @inferred histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :yellow,
        border = :solid,
        symbols = ['='],
        width = 50
    )
    test_ref(
        "references/histogram/parameters2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )

    # colors
    p = @inferred histogram(
        x,
        title = "Gray color",
        color = 240,
    )
    test_ref(
        "references/histogram/col1.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )

    p = @inferred histogram(
        x,
        title = "Green color",
        color = (50,100,50),
    )
    test_ref(
        "references/histogram/col2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p))
    )
end
