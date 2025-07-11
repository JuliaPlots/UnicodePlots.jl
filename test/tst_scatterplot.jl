x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@testset "input" begin
    @test scatterplot() isa Plot
    @test_throws MethodError scatterplot(sin, x)
    @test_throws DimensionMismatch scatterplot([sin], x)
    @test_throws DimensionMismatch scatterplot([1, 2], [1, 2, 3])
    @test_throws DimensionMismatch scatterplot([1, 2, 3], [1, 2])
    @test_throws DimensionMismatch scatterplot([1, 2, 3], 1:2)
    @test_throws DimensionMismatch scatterplot(1:3, [1, 2])
    @test_throws DimensionMismatch scatterplot(1:3, 1:2)
end

@testset "boundaries" begin
    # tests that the two points are drawn correctly on the canvas
    for canvas in (BrailleCanvas, OctantCanvas, DotCanvas, AsciiCanvas)
        for width in (20:10:60), height in (10:5:30)
            p = scatterplot(1:2, reverse(1:2); height, width, canvas)
            @test first(p.graphics.grid) != UnicodePlots.blank(p.graphics)
            @test last(p.graphics.grid) != UnicodePlots.blank(p.graphics)
        end
    end
end

@testset "positional types" begin
    for p in (
            @binf(scatterplot(x, y)),
            @binf(scatterplot(float.(x), y)),
            @binf(scatterplot(x, float.(y))),
        )
        @test p isa Plot
        test_ref("scatterplot/default.txt", @show_col(p))
    end

    for p in (@binf(scatterplot(y)), @binf(scatterplot(float.(y))))
        @test p isa Plot
        test_ref("scatterplot/y_only.txt", @show_col(p))
    end

    p = @binf scatterplot(6:10)
    @test p isa Plot
    test_ref("scatterplot/range1.txt", @show_col(p))

    p = @binf scatterplot(11:15, 6:10)
    @test p isa Plot
    test_ref("scatterplot/range2.txt", @show_col(p))

    p = @binf scatterplot(x .* 1.0e3 .+ 15, y .* 1.0e-3 .- 15)
    test_ref("scatterplot/scale1.txt", @show_col(p))
    p = @binf scatterplot(x .* 1.0e-3 .+ 15, y .* 1.0e3 .- 15)
    test_ref("scatterplot/scale2.txt", @show_col(p))
    miny = -1.2796649117521434e218
    maxy = -miny
    p = @binf scatterplot([1], [miny]; xlim = (1, 1), ylim = (miny, maxy))
    test_ref("scatterplot/scale3.txt", @show_col(p))
    p = @binf scatterplot([1], [miny]; xlim = [1, 1], ylim = [miny, maxy])
    test_ref("scatterplot/scale3.txt", @show_col(p))
end

@testset "keyword arguments" begin
    p = @binf scatterplot(x, y; xlim = (-1.5, 3.5), ylim = (-5.5, 2.5))
    test_ref("scatterplot/limits.txt", @show_col(p))
    p = @binf scatterplot(x, y; xlim = [-1.5, 3.5], ylim = [-5.5, 2.5])
    test_ref("scatterplot/limits.txt", @show_col(p))

    p = @binf scatterplot(x, y; grid = false)
    test_ref("scatterplot/nogrid.txt", @show_col(p))

    p = @binf scatterplot(x, y; color = :blue, name = "points1")
    test_ref("scatterplot/blue.txt", @show_col(p))

    p = @binf scatterplot(
        x,
        y;
        name = "points1",
        title = "Scatter",
        xlabel = "x",
        ylabel = "y",
    )
    @test p isa Plot
    test_ref("scatterplot/parameters1.txt", @show_col(p))

    @test @binf(scatterplot!(p, [0.5, 1, 1.5]; name = "points2")) ≡ p
    test_ref("scatterplot/parameters2.txt", @show_col(p))

    @test @binf(scatterplot!(p, [-0.5, 0.5, 1.5], [0.5, 1, 1.5]; name = "points3")) ≡ p
    test_ref("scatterplot/parameters3.txt", @show_col(p))
    test_ref("scatterplot/nocolor.txt", @show_nocol(p))

    p = scatterplot(x, y, title = "Scatter"; canvas = DotCanvas, height = 5, width = 10)
    @test p isa Plot
    test_ref("scatterplot/canvassize.txt", @show_col(p))
end

@testset "markers" begin
    p = scatterplot(
        x,
        y;
        title = "Vector of markers",
        marker = [:circle, "!", '.', :star5, :vline],
        color = [:red, :green, :yellow, :blue, :cyan],
    )
    test_ref("scatterplot/markers_vector.txt", @show_col(p))

    scatterplot(x, y, marker = :circle)

    n = collect(1:length(UnicodePlots.MARKERS))
    m = collect(keys(UnicodePlots.MARKERS))
    for canvas in (BrailleCanvas, OctantCanvas, DotCanvas, AsciiCanvas)
        p = scatterplot(n, n, title = "Supported markers", marker = m)
        test_ref("scatterplot/markers_$(canvas).txt", @show_col(p))
    end
end

@testset "units" begin
    y1 = [22.0, 23.0, 24.0] * u"°C"
    p = scatterplot(y1; marker = :circle)
    y2 = [23.5, 22.5, 23.0] * u"°C"
    p = scatterplot!(p, y2; marker = :cross, color = :red)
    test_ref("scatterplot/units_temp.txt", @show_col(p))
end

@testset "multiple series (matrix columns)" begin
    n = 3
    x = 1:n
    y1, y2 = [0:2:4 4:2:8], [fill(3, n) fill(5, n)]

    p = scatterplot(x, y1)
    scatterplot!(p, x, y2, marker = :pentagon)
    test_ref("scatterplot/matrix_auto.txt", @show_col(p))

    for name in (["1", "2"], ["1" "2"])
        p = scatterplot(x, y1; name, color = [:red :green], marker = [:utriangle :rect])
        scatterplot!(
            p,
            x,
            y2;
            name = ["3", "4"],
            color = [:yellow :cyan],
            marker = [:circle :cross],
        )

        test_ref("scatterplot/matrix_parameters.txt", @show_col(p))
    end
end
