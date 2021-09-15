x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@test_throws MethodError lineplot()
@test_throws MethodError lineplot(sin, x, y)
@test_throws ArgumentError lineplot(Function[], 0, 3)
@test_throws ArgumentError lineplot(Function[], x)
@test_throws ArgumentError lineplot(Function[])
@test_throws Union{BoundsError,DimensionMismatch} lineplot([1,2], [1,2,3])
@test_throws Union{BoundsError,DimensionMismatch} lineplot([1,2,3], [1,2])
@test_throws Union{BoundsError,DimensionMismatch} lineplot([1,2,3], 1:2)
@test_throws Union{BoundsError,DimensionMismatch} lineplot(1:3, [1,2])
@test_throws Union{BoundsError,DimensionMismatch} lineplot(1:3, 1:2)

@testset "Nan / Inf" begin
    lineplot([0, NaN], [0, 0])
    lineplot([0, 0], [+Inf, 0])
    lineplot([0, 0], [0, -Inf])
end

@testset "numeric array types" begin
    for p in (
            @inferred(lineplot(x, y)),
            @inferred(lineplot(float.(x), y)),
            @inferred(lineplot(x, float.(y))),
        )
        @test p isa Plot
        test_ref("references/lineplot/default.txt", @show_col(p))
    end

    for p in (
            @inferred(lineplot(y)),
            @inferred(lineplot(float.(y))),
        )
        @test p isa Plot
        test_ref("references/lineplot/y_only.txt", @show_col(p))
    end

    p = @inferred lineplot(6:10)
    @test p isa Plot
    test_ref("references/lineplot/range1.txt", @show_col(p))

    p = @inferred lineplot(11:15, 6:10)
    @test p isa Plot
    test_ref("references/lineplot/range2.txt", @show_col(p))
end

@testset "axis scaling and offsets" begin
    p = @inferred lineplot(x .* 1e3  .+ 15, y .* 1e-3 .- 15)
    test_ref("references/lineplot/scale1.txt", @show_col(p))

    p = @inferred lineplot(x .* 1e-3 .+ 15, y .* 1e3  .- 15)
    test_ref("references/lineplot/scale2.txt", @show_col(p))
    tx = [-1.,2, 3, 700000]
    ty = [1.,2, 9, 4000000]
    p = @inferred lineplot(tx, ty)
    test_ref("references/lineplot/scale3.txt", @show_col(p))
    p = @inferred lineplot(tx, ty, width=5, height=5)
    test_ref("references/lineplot/scale3_small.txt", @show_col(p))
end

@testset "dates" begin
    d = collect(Date(1999,12,31):Day(1):Date(2000,1,30))
    v = range(0, stop=3pi, length=31)
    p = @inferred lineplot(d, sin.(v), name="sin", height=5, xlabel="date")
    test_ref("references/lineplot/dates1.txt", @show_col(p))
    @test @inferred(lineplot!(p, d, cos.(v), name = "cos")) === p
    test_ref("references/lineplot/dates2.txt", @show_col(p))
end

@testset "line with intercept and slope" begin
    p = @inferred lineplot(y)
    @test @inferred(lineplot!(p, -3, 1)) === p
    test_ref("references/lineplot/slope1.txt", @show_col(p))
    @test @inferred(lineplot!(p, -4, .5, color = :cyan, name = "foo")) === p
    test_ref("references/lineplot/slope2.txt", @show_col(p))
end

@testset "functions" begin
    @test_throws ArgumentError lineplot(sin, 1:.5:12, color=:blue, ylim=(-1.,1., 2.))
    @test_throws ArgumentError lineplot(sin, 1:.5:12, color=(0,0,255), ylim=[-1.,1., 2.])
    p = @inferred lineplot(sin)
    test_ref("references/lineplot/sin.txt", @show_col(p))
    @test @inferred(lineplot!(p, cos)) === p
    test_ref("references/lineplot/sincos.txt", @show_col(p))
    p = @inferred lineplot([sin, cos])
    test_ref("references/lineplot/sincos.txt", @show_col(p))

    p = @inferred lineplot(sin, -.5, 6)
    test_ref("references/lineplot/sin2.txt", @show_col(p))
    @test @inferred(lineplot!(p, cos)) === p
    test_ref("references/lineplot/sincos2.txt", @show_col(p))
    @test @inferred(lineplot!(p, tan, 2.5, 3.5)) === p
    test_ref("references/lineplot/sincostan2.txt", @show_col(p))

    p = @inferred lineplot([sin, cos], -.5, 3)
    test_ref("references/lineplot/sincos3.txt", @show_col(p))

    tmp = [-.5, .6, 1.4, 2.5]
    p = @inferred lineplot(sin, tmp)
    test_ref("references/lineplot/sin4.txt", @show_col(p))
    @test @inferred(lineplot!(p, cos, tmp)) === p
    test_ref("references/lineplot/sincos4.txt", @show_col(p))
    p = @inferred lineplot([sin, cos], tmp)
    test_ref("references/lineplot/sincos4.txt", @show_col(p))

    @test_throws DimensionMismatch lineplot([sin, cos], -.5, 3, name = ["s", "c", "d"])
    @test_throws DimensionMismatch lineplot([sin, cos], -.5, 3, color = [:red])
    p = @inferred lineplot(
        [sin, cos], -.5, 3, name = ["s", "c"], color = [:red, :yellow],
        title = "Funs", ylabel = "f", xlabel = "num", xlim = (-.5, 2.5), ylim = (-.9, 1.2)
    )
    test_ref("references/lineplot/sincos_parameters.txt", @show_col(p))
    p = @inferred lineplot(
        [sin, cos], -.5, 3, name = ["s", "c"], color = [:red, :yellow],
        title = "Funs", ylabel = "f", xlabel = "num", xlim = [-.5, 2.5], ylim = [-.9, 1.2]
    )
    test_ref("references/lineplot/sincos_parameters.txt", @show_col(p))
end

@testset "keyword arguments" begin
    p = @inferred lineplot(x, y, xlim = (-1.5, 3.5), ylim = (-5.5, 2.5))
    test_ref("references/lineplot/limits.txt", @show_col(p))
    p = @inferred lineplot(x, y, xlim = [-1.5, 3.5], ylim = [-5.5, 2.5])
    test_ref("references/lineplot/limits.txt", @show_col(p))

    p = @inferred lineplot(x, y, grid = false)
    test_ref("references/lineplot/nogrid.txt", @show_col(p))

    p = @inferred lineplot(x, y, color = 20, name = "points1")
    test_ref("references/lineplot/blue.txt", @show_col(p))

    p = @inferred lineplot(x, y, name = "points1", title = "Scatter", xlabel = "x", ylabel = "y")
    @test p isa Plot
    test_ref("references/lineplot/parameters1.txt", @show_col(p))

    @test @inferred(lineplot!(p, [0.5, 1, 1.5], name = "points2")) === p
    test_ref("references/lineplot/parameters2.txt", @show_col(p))

    @test @inferred(lineplot!(p, [-0.5, 0.5, 1.5], [0.5, 1, 1.5], name = "points3")) === p
    test_ref("references/lineplot/parameters3.txt", @show_col(p))
    test_ref("references/lineplot/nocolor.txt", @show_nocol(p))

    p = lineplot(x, y, title = "Scatter", canvas = DotCanvas, width = 10, height = 5)
    @test p isa Plot
    test_ref("references/lineplot/canvassize.txt", @show_col(p))
end

@testset "stairs" begin
    sx = [1, 2, 4, 7, 8]
    sy = [1, 3, 4, 2, 7]

    p = @inferred stairs(sx, sy, style = :pre)
    @test p isa Plot
    test_ref("references/lineplot/stairs_pre.txt", @show_col(p))

    p = @inferred stairs(sx, sy)
    test_ref("references/lineplot/stairs_post.txt", @show_col(p))
    p = @inferred stairs(sx, sy, style = :post)
    test_ref("references/lineplot/stairs_post.txt", @show_col(p))

    p = @inferred stairs(sx, sy, title = "Foo", color = :red, xlabel = "x", name = "1")
    @test @inferred(stairs!(p, sx .- .2, sy .+ 1.5, name = "2")) === p
    test_ref("references/lineplot/stairs_parameters.txt", @show_col(p))
    @test @inferred(stairs!(p, sx, sy, name = "3", style = :pre)) === p
    test_ref("references/lineplot/stairs_parameters2.txt", @show_col(p))
    test_ref("references/lineplot/stairs_parameters2_nocolor.txt", @show_nocol(p))

    # special weird case
    p = stairs(sx, [1, 3, 4, 2, 7000])
    test_ref("references/lineplot/stairs_edgecase.txt", @show_col(p))

    p = stairs(sx, sy, width = 10, padding = 3)
    label!(p, :tl, "Hello")
    label!(p, :t, "how are")
    label!(p, :tr, "you?")
    label!(p, :bl, "Hello")
    label!(p, :b, "how are")
    label!(p, :br, "you?")
    lineplot!(p, 1, .5)
    test_ref("references/lineplot/squeeze_annotations.txt", @show_col(p))

    dx = [Date(2020,8,i) for i = 1:10]
    p = stairs(dx,1:10, xlim=(Date(2020,8,1), Date(2020,8,15)))
    test_ref("references/lineplot/stairs_date.txt", @show_col(p))
end

@testset "scales" begin
    x = y = collect(10:10:1000)
    tmp = tempname()
    for s ∈ (:ln, :log2, :log10)
        fscale = UnicodePlots.FSCALES[s]

        xs = fscale.(x)
        ys = fscale.(y)

        # xscale
        savefig(lineplot(xs, y, xlim=extrema(xs), labels=false), tmp; color=true)
        test_ref(tmp, @show_col(lineplot(x, y, xscale=s, labels=false)))

        # yscale
        savefig(lineplot(x, ys, ylim=extrema(ys), labels=false), tmp; color=true)
        test_ref(tmp, @show_col(lineplot(x, y, yscale=s, labels=false)))

        # xscale and yscale
        savefig(lineplot(xs, ys, xlim=extrema(xs), ylim=extrema(xs), labels=false), tmp; color=true)
        test_ref(tmp, @show_col(lineplot(x, y, xscale=s, yscale=s, labels=false)))

        # scale labels
        test_ref("references/lineplot/$(s)_scale.txt", @show_col(lineplot(x, y, xscale=s, yscale=s)))
    end

    lineplot(1:10, 1:10, xscale=x->log10(x))  # arbitrary scale function
    scl(x) = log(x)
    lineplot(1:10, 1:10, yscale=scl)
end
