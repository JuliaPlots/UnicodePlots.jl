x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@test_throws MethodError scatterplot()
@test_throws MethodError scatterplot(sin, x)
@test_throws MethodError scatterplot([sin], x)
@test_throws DimensionMismatch scatterplot([1, 2], [1, 2, 3])
@test_throws DimensionMismatch scatterplot([1, 2, 3], [1, 2])
@test_throws DimensionMismatch scatterplot([1, 2, 3], 1:2)
@test_throws DimensionMismatch scatterplot(1:3, [1, 2])
@test_throws DimensionMismatch scatterplot(1:3, 1:2)

@testset "positional types" begin
    for p in (
        @inferred(scatterplot(x, y)),
        @inferred(scatterplot(float.(x), y)),
        @inferred(scatterplot(x, float.(y))),
    )
        @test p isa Plot
        test_ref("references/scatterplot/default.txt", @show_col(p))
    end

    for p in (@inferred(scatterplot(y)), @inferred(scatterplot(float.(y))))
        @test p isa Plot
        test_ref("references/scatterplot/y_only.txt", @show_col(p))
    end

    p = @inferred scatterplot(6:10)
    @test p isa Plot
    test_ref("references/scatterplot/range1.txt", @show_col(p))

    p = @inferred scatterplot(11:15, 6:10)
    @test p isa Plot
    test_ref("references/scatterplot/range2.txt", @show_col(p))

    p = @inferred scatterplot(x .* 1e3 .+ 15, y .* 1e-3 .- 15)
    test_ref("references/scatterplot/scale1.txt", @show_col(p))
    p = @inferred scatterplot(x .* 1e-3 .+ 15, y .* 1e3 .- 15)
    test_ref("references/scatterplot/scale2.txt", @show_col(p))
    miny = -1.2796649117521434e218
    maxy = -miny
    p = @inferred scatterplot([1], [miny], xlim = (1, 1), ylim = (miny, maxy))
    test_ref("references/scatterplot/scale3.txt", @show_col(p))
    p = @inferred scatterplot([1], [miny], xlim = [1, 1], ylim = [miny, maxy])
    test_ref("references/scatterplot/scale3.txt", @show_col(p))
end

@testset "keyword arguments" begin
    p = @inferred scatterplot(x, y, xlim = (-1.5, 3.5), ylim = (-5.5, 2.5))
    test_ref("references/scatterplot/limits.txt", @show_col(p))
    p = @inferred scatterplot(x, y, xlim = [-1.5, 3.5], ylim = [-5.5, 2.5])
    test_ref("references/scatterplot/limits.txt", @show_col(p))

    p = @inferred scatterplot(x, y, grid = false)
    test_ref("references/scatterplot/nogrid.txt", @show_col(p))

    p = @inferred scatterplot(x, y, color = :blue, name = "points1")
    test_ref("references/scatterplot/blue.txt", @show_col(p))

    p = @inferred scatterplot(
        x,
        y,
        name = "points1",
        title = "Scatter",
        xlabel = "x",
        ylabel = "y",
    )
    @test p isa Plot
    test_ref("references/scatterplot/parameters1.txt", @show_col(p))

    @test @inferred(scatterplot!(p, [0.5, 1, 1.5], name = "points2")) === p
    test_ref("references/scatterplot/parameters2.txt", @show_col(p))

    @test @inferred(scatterplot!(p, [-0.5, 0.5, 1.5], [0.5, 1, 1.5], name = "points3")) ===
          p
    test_ref("references/scatterplot/parameters3.txt", @show_col(p))
    test_ref("references/scatterplot/nocolor.txt", @show_nocol(p))

    p = scatterplot(x, y, title = "Scatter", canvas = DotCanvas, width = 10, height = 5)
    @test p isa Plot
    test_ref("references/scatterplot/canvassize.txt", @show_col(p))
end

@testset "markers" begin
    p = scatterplot(
        x,
        y,
        title = "Vector of markers",
        marker = [:circle, "!", '.', :star5, :vline],
        color = [:red, :green, :yellow, :blue, :cyan],
    )
    test_ref("references/scatterplot/markers_vector.txt", @show_col(p))

    scatterplot(x, y, marker = :circle)

    n = collect(1:length(UnicodePlots.MARKERS))
    m = collect(keys(UnicodePlots.MARKERS))
    for canvas in (BrailleCanvas, DotCanvas, AsciiCanvas)
        p = scatterplot(n, n, title = "Supported markers", marker = m)
        test_ref("references/scatterplot/markers_$(canvas).txt", @show_col(p))
    end
end

@testset "densityplot" begin
    seed!(RNG, 1338)
    dx, dy = randn(RNG, 1000), randn(RNG, 1000)

    p = @inferred densityplot(dx, dy)
    @test @inferred(densityplot!(p, dx .+ 2, dy .+ 2)) === p
    @test p isa Plot
    test_ref("references/scatterplot/densityplot.txt", @show_col(p))

    p = @inferred densityplot(
        dx,
        dy,
        name = "foo",
        color = :red,
        title = "Title",
        xlabel = "x",
    )
    @test @inferred(densityplot!(p, dx .+ 2, dy .+ 2, name = "bar")) === p
    @test p isa Plot
    test_ref("references/scatterplot/densityplot_parameters.txt", @show_col(p))
end
