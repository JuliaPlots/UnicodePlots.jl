seed!(RNG, 1337)
x = randn(RNG, 10_000)

@testset "default params" begin
    p = histogram(x)
    test_ref("histogram/default.txt", @print_col(p))
    test_ref("histogram/default_nocolor.txt", @print_nocol(p))
    p = histogram(x, closed = :left)
    test_ref("histogram/default.txt", @print_col(p))
    hist = fit(Histogram, x, closed = :left)
    p = horizontal_histogram(hist)
    test_ref("histogram/default.txt", @print_col(p))
    p = histogram(x * 100)
    test_ref("histogram/default_1e2.txt", @print_col(p))
    p = histogram(x * 0.01)
    test_ref("histogram/default_1e-2.txt", @print_col(p))
    p = histogram(x, xscale = :log10)
    test_ref("histogram/log10.txt", @print_col(p))
    p = histogram(x, xlabel = "custom label", xscale = :log10)
    test_ref("histogram/log10_label.txt", @print_col(p))
    p = histogram([0.1f0, 0.1f0, 0.0f0])
    test_ref("histogram/float32.txt", @print_col(p))
    p = horizontal_histogram(Histogram([0.0, 0.1, 1.0, 10.0, 100.0], [1, 2, 3, 4]))
    test_ref("histogram/nonuniformbins.txt", @print_col(p))
    x2 = copy(reshape(x, 1, length(x), 1, 1))
    p = histogram(x2)
    test_ref("histogram/default.txt", @print_col(p))
    p = horizontal_histogram(Histogram(1:15.0, vcat(collect(1:13), 400)))
    test_ref("histogram/fraction.txt", @print_col(p))
end

@testset "hist params" begin
    hist = fit(Histogram, x, nbins = 5, closed = :right)
    p = horizontal_histogram(hist)
    test_ref("histogram/hist_params.txt", @print_col(p))
    p = histogram(x, nbins = 5, closed = :right)
    test_ref("histogram/hist_params.txt", @print_col(p))
end

@testset "keyword arguments" begin
    p = histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :blue,
        margin = 7,
        padding = 3,
    )
    test_ref("histogram/parameters1.txt", @print_col(p))
    p = histogram(
        x,
        title = "My Histogram",
        xlabel = "Absolute Frequency",
        color = :blue,
        margin = 7,
        padding = 3,
        labels = false,
    )
    test_ref("histogram/parameters1_nolabels.txt", @print_col(p))

    for symbols ∈ (["="], ['='], tuple("="), tuple('='))
        p = histogram(
            x,
            title = "My Histogram",
            xlabel = "Absolute Frequency",
            color = :yellow,
            border = :solid,
            symbols = symbols,
            width = 50,
        )
        test_ref("histogram/parameters2.txt", @print_col(p))
    end

    # colors
    p = histogram(x, title = "Gray color", color = 240)
    test_ref("histogram/col1.txt", @print_col(p))

    p = histogram(x, title = "Green color", color = (0, 135, 95))
    test_ref("histogram/col2.txt", @print_col(p))
end

@testset "vertical - normal distribution" begin
    p = histogram(x; vertical = true, nbins = 100)
    test_ref("histogram/vert1.txt", @print_col(p))
end

@testset "vertical" begin
    n = 30
    dat = Float64[]
    foreach(i -> append!(dat, repeat([i], i)), 1:n)
    p = histogram(dat; vertical = true, nbins = n)
    test_ref("histogram/vert2.txt", @print_col(p))
end
