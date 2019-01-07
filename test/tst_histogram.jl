seed!(1337)
x = randn(10000)

@testset "default params" begin
    p = @inferred histogram(x)
    @test_reference(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/histogram/default_nocolor.txt",
        @io2str(print(IOContext(::IO, :color=>false), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram(x, closed = :left)
    @test_reference(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    hist = fit(Histogram, x, closed = :left)
    p = @inferred histogram(hist)
    @test_reference(
        "references/histogram/default.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram(x*100)
    @test_reference(
        "references/histogram/default_1e2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram(x*0.01)
    @test_reference(
        "references/histogram/default_1e-2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram(x, xscale = log10)
    @test_reference(
        "references/histogram/log10.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram(x, xlabel = "custom label", xscale = log10)
    @test_reference(
        "references/histogram/log10_label.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram([0.1f0, 0.1f0, 0f0])
    @test_reference(
        "references/histogram/float32.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "hist params" begin
    hist = fit(Histogram, x, nbins = 5, closed = :right)
    p = @inferred histogram(hist)
    @test_reference(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred histogram(x, nbins = 5, closed = :right)
    @test_reference(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = nothing
    p = @test_logs (:warn, r"`bins`.+deprecated") @inferred histogram(x, bins = 5, closed = :right)
    @test_reference(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = nothing
    p = @test_logs (:warn, r"deprecated") @inferred histogram(x, 5, closed = :right)
    @test_reference(
        "references/histogram/hist_params.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
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
    @test_reference(
        "references/histogram/parameters1.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
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
    @test_reference(
        "references/histogram/parameters1_nolabels.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :yellow,
        border = :solid,
        symb = "=",
        width = 50
    )
    @test_reference(
        "references/histogram/parameters2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    # same but with Char as symb
    p = @inferred histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :yellow,
        border = :solid,
        symb = '=',
        width = 50
    )
    @test_reference(
        "references/histogram/parameters2.txt",
        @io2str(print(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end
