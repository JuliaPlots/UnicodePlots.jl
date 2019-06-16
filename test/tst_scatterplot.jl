x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@test_throws MethodError scatterplot()
@test_throws MethodError scatterplot(sin, x)
@test_throws MethodError scatterplot([sin], x)
@test_throws DimensionMismatch scatterplot([1,2], [1,2,3])
@test_throws DimensionMismatch scatterplot([1,2,3], [1,2])
@test_throws DimensionMismatch scatterplot([1,2,3], 1:2)
@test_throws DimensionMismatch scatterplot(1:3, [1,2])
@test_throws DimensionMismatch scatterplot(1:3, 1:2)

@testset "positional types" begin
    for p in (
            @inferred(scatterplot(x, y)),
            @inferred(scatterplot(float.(x), y)),
            @inferred(scatterplot(x, float.(y))),
        )
        @test p isa Plot
        @test_reference(
            "references/scatterplot/default.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    for p in (
            @inferred(scatterplot(y)),
            @inferred(scatterplot(float.(y))),
        )
        @test p isa Plot
        @test_reference(
            "references/scatterplot/y_only.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    p = @inferred scatterplot(6:10)
    @test p isa Plot
    @test_reference(
        "references/scatterplot/range1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred scatterplot(11:15, 6:10)
    @test p isa Plot
    @test_reference(
        "references/scatterplot/range2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred scatterplot(x .* 1e3  .+ 15, y .* 1e-3 .- 15)
    @test_reference(
        "references/scatterplot/scale1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred scatterplot(x .* 1e-3 .+ 15, y .* 1e3  .- 15)
    @test_reference(
        "references/scatterplot/scale2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    miny = -1.2796649117521434e218
    maxy = -miny
    p = @inferred scatterplot([1],[miny],xlim=(1,1),ylim=(miny,maxy))
    @test_reference(
        "references/scatterplot/scale3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred scatterplot([1],[miny],xlim=[1,1],ylim=[miny,maxy])
    @test_reference(
        "references/scatterplot/scale3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "keyword arguments" begin
    p = @inferred scatterplot(x, y, xlim = (-1.5, 3.5), ylim = (-5.5, 2.5))
    @test_reference(
        "references/scatterplot/limits.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred scatterplot(x, y, xlim = [-1.5, 3.5], ylim = [-5.5, 2.5])
    @test_reference(
        "references/scatterplot/limits.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred scatterplot(x, y, grid = false)
    @test_reference(
        "references/scatterplot/nogrid.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred scatterplot(x, y, color = :blue, name = "points1")
    @test_reference(
        "references/scatterplot/blue.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred scatterplot(x, y, name = "points1", title = "Scatter", xlabel = "x", ylabel = "y")
    @test p isa Plot
    @test_reference(
        "references/scatterplot/parameters1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    @test @inferred(scatterplot!(p, [0.5, 1, 1.5], name = "points2")) === p
    @test_reference(
        "references/scatterplot/parameters2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    @test @inferred(scatterplot!(p, [-0.5, 0.5, 1.5], [0.5, 1, 1.5], name = "points3")) === p
    @test_reference(
        "references/scatterplot/parameters3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/scatterplot/nocolor.txt",
        @io2str(show(IOContext(::IO, :color=>false), p)),
        render = BeforeAfterFull()
    )

    p = scatterplot(x, y, title = "Scatter", canvas = DotCanvas, width = 10, height = 5)
    @test p isa Plot
    @test_reference(
        "references/scatterplot/canvassize.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "densityplot" begin
    seed!(1338)
    dx, dy = randn(1000), randn(1000)

    p = @inferred densityplot(dx, dy)
    @test @inferred(densityplot!(p, dx .+ 2, dy .+ 2)) === p
    @test p isa Plot
    @test_reference(
        "references/scatterplot/densityplot.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred densityplot(dx, dy, name = "foo", color = :red, title = "Title", xlabel = "x")
    @test @inferred(densityplot!(p, dx .+ 2, dy .+ 2, name = "bar")) === p
    @test p isa Plot
    @test_reference(
        "references/scatterplot/densityplot_parameters.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end
