x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@test_throws MethodError lineplot()
@test_throws MethodError lineplot(sin, x, y)
@test_throws ArgumentError lineplot(Function[], 0, 3)
@test_throws ArgumentError lineplot(Function[], x)
@test_throws ArgumentError lineplot(Function[])
@test_throws DimensionMismatch lineplot([1,2], [1,2,3])
@test_throws DimensionMismatch lineplot([1,2,3], [1,2])
@test_throws DimensionMismatch lineplot([1,2,3], 1:2)
@test_throws DimensionMismatch lineplot(1:3, [1,2])
@test_throws DimensionMismatch lineplot(1:3, 1:2)

@testset "numeric array types" begin
    for p in (
            @inferred(lineplot(x, y)),
            @inferred(lineplot(float.(x), y)),
            @inferred(lineplot(x, float.(y))),
        )
        @test p isa Plot
        @test_reference(
            "references/lineplot/default.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    for p in (
            @inferred(lineplot(y)),
            @inferred(lineplot(float.(y))),
        )
        @test p isa Plot
        @test_reference(
            "references/lineplot/y_only.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    p = @inferred lineplot(6:10)
    @test p isa Plot
    @test_reference(
        "references/lineplot/range1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(11:15, 6:10)
    @test p isa Plot
    @test_reference(
        "references/lineplot/range2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "axis scaling and offsets" begin
    p = @inferred lineplot(x .* 1e3  .+ 15, y .* 1e-3 .- 15)
    @test_reference(
        "references/lineplot/scale1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(x .* 1e-3 .+ 15, y .* 1e3  .- 15)
    @test_reference(
        "references/lineplot/scale2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    tx = [-1.,2, 3, 700000]
    ty = [1.,2, 9, 4000000]
    p = @inferred lineplot(tx, ty)
    @test_reference(
        "references/lineplot/scale3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred lineplot(tx, ty, width=5, height=5)
    @test_reference(
        "references/lineplot/scale3_small.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "dates" begin
    d = collect(Date(1999,12,31):Day(1):Date(2000,1,30))
    v = range(0, stop=3pi, length=31)
    p = @inferred lineplot(d, sin.(v), name="sin", height=5, xlabel="date")
    @test_reference(
        "references/lineplot/dates1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(lineplot!(p, d, cos.(v), name = "cos")) === p
    @test_reference(
        "references/lineplot/dates2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "line with intercept and slope" begin
    p = @inferred lineplot(y)
    @test @inferred(lineplot!(p, -3, 1)) === p
    @test_reference(
        "references/lineplot/slope1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(lineplot!(p, -4, .5, color = :cyan, name = "foo")) === p
    @test_reference(
        "references/lineplot/slope2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "functions" begin
    @test_throws ArgumentError lineplot(sin, 1:.5:12, color=:blue, ylim=(-1.,1., 2.))
    @test_throws ArgumentError lineplot(sin, 1:.5:12, color=:blue, ylim=[-1.,1., 2.])
    p = @inferred lineplot(sin)
    @test_reference(
        "references/lineplot/sin.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(lineplot!(p, cos)) === p
    @test_reference(
        "references/lineplot/sincos.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred lineplot([sin, cos])
    @test_reference(
        "references/lineplot/sincos.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(sin, -.5, 6)
    @test_reference(
        "references/lineplot/sin2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(lineplot!(p, cos)) === p
    @test_reference(
        "references/lineplot/sincos2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(lineplot!(p, tan, 2.5, 3.5)) === p
    @test_reference(
        "references/lineplot/sincostan2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot([sin, cos], -.5, 3)
    @test_reference(
        "references/lineplot/sincos3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    tmp = [-.5, .6, 1.4, 2.5]
    p = @inferred lineplot(sin, tmp)
    @test_reference(
        "references/lineplot/sin4.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(lineplot!(p, cos, tmp)) === p
    @test_reference(
        "references/lineplot/sincos4.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred lineplot([sin, cos], tmp)
    @test_reference(
        "references/lineplot/sincos4.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    @test_throws DimensionMismatch lineplot([sin, cos], -.5, 3, name = ["s", "c", "d"])
    @test_throws DimensionMismatch lineplot([sin, cos], -.5, 3, color = [:red])
    p = @inferred lineplot([sin, cos], -.5, 3, name = ["s", "c"], color = [:red, :yellow], title = "Funs", ylabel = "f", xlabel = "num", xlim = (-.5, 2.5), ylim = (-.9, 1.2))
    @test_reference(
        "references/lineplot/sincos_parameters.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred lineplot([sin, cos], -.5, 3, name = ["s", "c"], color = [:red, :yellow], title = "Funs", ylabel = "f", xlabel = "num", xlim = [-.5, 2.5], ylim = [-.9, 1.2])
    @test_reference(
        "references/lineplot/sincos_parameters.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "keyword arguments" begin
    p = @inferred lineplot(x, y, xlim = (-1.5, 3.5), ylim = (-5.5, 2.5))
    @test_reference(
        "references/lineplot/limits.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred lineplot(x, y, xlim = [-1.5, 3.5], ylim = [-5.5, 2.5])
    @test_reference(
        "references/lineplot/limits.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(x, y, grid = false)
    @test_reference(
        "references/lineplot/nogrid.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(x, y, color = :blue, name = "points1")
    @test_reference(
        "references/lineplot/blue.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(x, y, name = "points1", title = "Scatter", xlabel = "x", ylabel = "y")
    @test p isa Plot
    @test_reference(
        "references/lineplot/parameters1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    @test @inferred(lineplot!(p, [0.5, 1, 1.5], name = "points2")) === p
    @test_reference(
        "references/lineplot/parameters2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    @test @inferred(lineplot!(p, [-0.5, 0.5, 1.5], [0.5, 1, 1.5], name = "points3")) === p
    @test_reference(
        "references/lineplot/parameters3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/lineplot/nocolor.txt",
        @io2str(show(IOContext(::IO, :color=>false), p)),
        render = BeforeAfterFull()
    )

    p = lineplot(x, y, title = "Scatter", canvas = DotCanvas, width = 10, height = 5)
    @test p isa Plot
    @test_reference(
        "references/lineplot/canvassize.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end

@testset "stairs" begin
    sx = [1, 2, 4, 7, 8]
    sy = [1, 3, 4, 2, 7]

    p = @inferred stairs(sx, sy, style = :pre)
    @test p isa Plot
    @test_reference(
        "references/lineplot/stairs_pre.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred stairs(sx, sy)
    @test_reference(
        "references/lineplot/stairs_post.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred stairs(sx, sy, style = :post)
    @test_reference(
        "references/lineplot/stairs_post.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred stairs(sx, sy, title = "Foo", color = :red, xlabel = "x", name = "1")
    @test @inferred(stairs!(p, sx .- .2, sy .+ 1.5, name = "2")) === p
    @test_reference(
        "references/lineplot/stairs_parameters.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(stairs!(p, sx, sy, name = "3", style = :pre)) === p
    @test_reference(
        "references/lineplot/stairs_parameters2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/lineplot/stairs_parameters2_nocolor.txt",
        @io2str(show(IOContext(::IO, :color=>false), p)),
        render = BeforeAfterFull()
    )

    # special weird case
    p = stairs(sx, [1, 3, 4, 2, 7000])
    @test_reference(
        "references/lineplot/stairs_edgecase.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = stairs(sx, sy, width = 10, padding = 3)
    annotate!(p, :tl, "Hello")
    annotate!(p, :t, "how are")
    annotate!(p, :tr, "you?")
    annotate!(p, :bl, "Hello")
    annotate!(p, :b, "how are")
    annotate!(p, :br, "you?")
    lineplot!(p, 1, .5)
    @test_reference(
        "references/lineplot/squeeze_annotations.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end
