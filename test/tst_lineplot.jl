x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@test_throws MethodError lineplot()
@test_throws MethodError lineplot(sin, x, y)
@test_throws ArgumentError lineplot(0, 3, Function[])
@test_throws ArgumentError lineplot(x, Function[])
@test_throws ArgumentError lineplot(Function[])
@test_throws Union{BoundsError,DimensionMismatch} lineplot([1, 2], [1, 2, 3])
@test_throws Union{BoundsError,DimensionMismatch} lineplot([1, 2, 3], [1, 2])
@test_throws Union{BoundsError,DimensionMismatch} lineplot([1, 2, 3], 1:2)
@test_throws Union{BoundsError,DimensionMismatch} lineplot(1:3, [1, 2])
@test_throws Union{BoundsError,DimensionMismatch} lineplot(1:3, 1:2)

@testset "Nan / Inf" begin
    @test lineplot([0, NaN], [0, 0]) isa Plot
    @test lineplot([0, 0], [+Inf, 0]) isa Plot
    @test lineplot([0, 0], [0, -Inf]) isa Plot
end

@testset "numeric array types" begin
    for p ∈ (
        @binf(lineplot(x, y)),
        @binf(lineplot(float.(x), y)),
        @binf(lineplot(x, float.(y))),
    )
        @test p isa Plot
        test_ref("lineplot/default.txt", @show_col(p))
    end

    for p ∈ (@binf(lineplot(y)), @binf(lineplot(float.(y))))
        @test p isa Plot
        test_ref("lineplot/y_only.txt", @show_col(p))
    end

    p = @binf lineplot(6:10)
    @test p isa Plot
    test_ref("lineplot/range1.txt", @show_col(p))

    p = @binf lineplot(11:15, 6:10)
    @test p isa Plot
    test_ref("lineplot/range2.txt", @show_col(p))
end

@testset "axis scaling and offsets" begin
    p = @binf lineplot(x .* 1e3 .+ 15, y .* 1e-3 .- 15)
    test_ref("lineplot/scale1.txt", @show_col(p))

    p = @binf lineplot(x .* 1e-3 .+ 15, y .* 1e3 .- 15)
    test_ref("lineplot/scale2.txt", @show_col(p))
    tx = [-1.0, 2, 3, 700_000]
    ty = [1.0, 2, 9, 4_000_000]
    p = @binf lineplot(tx, ty)
    test_ref("lineplot/scale3.txt", @show_col(p))
    p = @binf lineplot(tx, ty, height = 5, width = 18)
    test_ref("lineplot/scale3_small.txt", @show_col(p))
end

@testset "dates" begin
    d = collect(Date(1999, 12, 31):Day(1):Date(2000, 1, 30))
    v = range(0, stop = 3pi, length = 31)
    p = @binf lineplot(d, sin.(v); name = "sin", height = 5, xlabel = "date")
    test_ref("lineplot/dates1.txt", @show_col(p))
    @test @binf(lineplot!(p, d, cos.(v); name = "cos")) ≡ p
    test_ref("lineplot/dates2.txt", @show_col(p))
end

@testset "dataframes" begin
    df = DataFrame(
        Time = map(x -> DateTime(2022, 09, 20, x...), [1:3, 4:6, 7:9]),
        Test = [0, 1, -1],
    )
    p = lineplot(df.Time, df.Test; xticks = false)
    test_ref("lineplot/df1.txt", @show_col(p))
    p = lineplot(df.Time, df.Test; format = "M:S:s")
    test_ref("lineplot/df2.txt", @show_col(p))
end

@testset "line with intercept and slope" begin
    p = @binf lineplot(y)
    @test @binf(lineplot!(p, -3, 1)) ≡ p
    test_ref("lineplot/slope1.txt", @show_col(p))
    @test @binf(lineplot!(p, -4, 0.5; color = :cyan, name = "foo")) ≡ p
    test_ref("lineplot/slope2.txt", @show_col(p))
end

@testset "functions" begin
    @test_throws ArgumentError lineplot(
        1:0.5:12,
        sin,
        color = :blue,
        ylim = (-1.0, 1.0, 2.0),
    )
    @test_throws ArgumentError lineplot(
        1:0.5:12,
        sin,
        color = (0, 0, 255),
        ylim = [-1.0, 1.0, 2.0],
    )
    p = @binf lineplot(sin)
    test_ref("lineplot/sin.txt", @show_col(p))
    @test @binf(lineplot!(p, cos)) ≡ p
    test_ref("lineplot/sincos.txt", @show_col(p))
    p = @binf lineplot([sin, cos])
    test_ref("lineplot/sincos.txt", @show_col(p))

    p = @binf lineplot(-0.5, 6, sin)
    test_ref("lineplot/sin2.txt", @show_col(p))
    @test @binf(lineplot!(p, cos)) ≡ p
    test_ref("lineplot/sincos2.txt", @show_col(p))
    @test @binf(lineplot!(p, 2.5, 3.5, tan)) ≡ p
    test_ref("lineplot/sincostan2.txt", @show_col(p))

    p = @binf lineplot(-0.5, 3, [sin, cos])
    test_ref("lineplot/sincos3.txt", @show_col(p))

    tmp = [-0.5, 0.6, 1.4, 2.5]
    p = @binf lineplot(tmp, sin)
    test_ref("lineplot/sin4.txt", @show_col(p))
    @test @binf(lineplot!(p, tmp, cos)) ≡ p
    test_ref("lineplot/sincos4.txt", @show_col(p))
    p = @binf lineplot(tmp, [sin, cos])
    test_ref("lineplot/sincos4.txt", @show_col(p))

    @test_throws DimensionMismatch lineplot(-0.5, 3, [sin, cos]; name = ["s", "c", "d"])
    @test_throws DimensionMismatch lineplot(-0.5, 3, [sin, cos]; color = [:red])
    for (xlim, ylim) ∈ zip(((-0.5, 2.5), [-0.5, 2.5]), ((-0.9, 1.2), [-0.9, 1.2]))
        p = @binf lineplot(
            -0.5,
            3,
            [sin, cos],
            name = ["s", "c"],
            color = [:red, :yellow],
            title = "Funs",
            ylabel = "f",
            xlabel = "num",
            xlim = (-0.5, 2.5),
            ylim = (-0.9, 1.2),
        )
        test_ref("lineplot/sincos_parameters.txt", @show_col(p))
    end
end

@testset "keyword arguments" begin
    for (xlim, ylim) ∈ zip(((-1.5, 3.5), [-1.5, 3.5]), ((-5.5, 2.5), [-5.5, 2.5]))
        p = @binf lineplot(x, y, xlim = (-1.5, 3.5), ylim = (-5.5, 2.5))
        test_ref("lineplot/limits.txt", @show_col(p))
    end

    p = @binf lineplot(x, y, grid = false)
    test_ref("lineplot/nogrid.txt", @show_col(p))

    p = @binf lineplot(x, y; color = 20, name = "points1")
    test_ref("lineplot/blue.txt", @show_col(p))

    p = @binf lineplot(
        x,
        y,
        name = "points1",
        title = "Scatter",
        xlabel = "x",
        ylabel = "y",
    )
    @test p isa Plot
    test_ref("lineplot/parameters1.txt", @show_col(p))

    @test @binf(lineplot!(p, [0.5, 1, 1.5]; name = "points2")) ≡ p
    test_ref("lineplot/parameters2.txt", @show_col(p))

    @test @binf(lineplot!(p, [-0.5, 0.5, 1.5], [0.5, 1, 1.5]; name = "points3")) ≡ p
    test_ref("lineplot/parameters3.txt", @show_col(p))
    test_ref("lineplot/nocolor.txt", @show_nocol(p))

    p = lineplot(x, y; title = "Scatter", canvas = DotCanvas, height = 5, width = 10)
    @test p isa Plot
    test_ref("lineplot/canvassize.txt", @show_col(p))
end

@testset "stairs" begin
    sx = [1, 2, 4, 7, 8]
    sy = [1, 3, 4, 2, 7]

    p = @binf stairs(sx, sy, style = :pre)
    test_ref("lineplot/stairs_pre.txt", @show_col(p))
    p = @binf stairs(sx, sy)
    test_ref("lineplot/stairs_post.txt", @show_col(p))
    p = @binf stairs(sx, sy, style = :post)
    test_ref("lineplot/stairs_post.txt", @show_col(p))

    p = @binf stairs(sx, sy; title = "Foo", color = :red, xlabel = "x", name = "1")
    @test @binf(stairs!(p, sx .- 0.2, sy .+ 1.5; name = "2")) ≡ p
    test_ref("lineplot/stairs_parameters.txt", @show_col(p))
    @test @binf(stairs!(p, sx, sy; name = "3", style = :pre)) ≡ p
    test_ref("lineplot/stairs_parameters2.txt", @show_col(p))
    test_ref("lineplot/stairs_parameters2_nocolor.txt", @show_nocol(p))

    # special weird case
    p = stairs(sx, [1, 3, 4, 2, 7_000])
    test_ref("lineplot/stairs_edgecase.txt", @show_col(p))

    p = stairs(sx, sy, width = 20)
    label!(p, :tl, "Hello")
    label!(p, :t, "how are")
    label!(p, :tr, "you?")
    label!(p, :bl, "Hello")
    label!(p, :b, "how are")
    label!(p, :br, "you?")
    lineplot!(p, 1, 0.5)
    test_ref("lineplot/squeeze_annotations.txt", @show_col(p))

    dx = map(i -> Date(2020, 8, i), 1:10)
    p = stairs(dx, 1:10, xlim = (Date(2020, 8, 1), Date(2020, 8, 15)))
    test_ref("lineplot/stairs_date.txt", @show_col(p))
end

@testset "scales" begin
    x = y = collect(10:10:1_000)
    tmp = tempname()
    for s ∈ (:ln, :log2, :log10)
        fscale = UnicodePlots.FSCALES[s]

        xs = fscale.(x)
        ys = fscale.(y)

        # xscale
        savefig(lineplot(xs, y; xlim = extrema(xs), labels = false), tmp; color = true)
        test_ref(tmp, @show_col(lineplot(x, y; xscale = s, labels = false)))

        # yscale
        savefig(lineplot(x, ys; ylim = extrema(ys), labels = false), tmp; color = true)
        test_ref(tmp, @show_col(lineplot(x, y; yscale = s, labels = false)))

        # xscale & yscale
        savefig(
            lineplot(xs, ys; xlim = extrema(xs), ylim = extrema(xs), labels = false),
            tmp;
            color = true,
        )
        test_ref(tmp, @show_col(lineplot(x, y; xscale = s, yscale = s, labels = false)))

        # xscale & yscale & labels
        test_ref(
            "lineplot/$(s)_scale.txt",
            @show_col(lineplot(x, y, xscale = s, yscale = s))
        )
    end

    lineplot(1:10, 1:10, xscale = x -> log10(x))  # arbitrary scale function
    scl(x) = log(x)
    lineplot(1:10, 1:10, yscale = scl)
end

@testset "arrows" begin
    p = lineplot([0.0, 1.0], [0.0, 1.0]; head_tail = :head, name = "head", color = :red)
    lineplot!(p, [0.0, 1.0], [1.0, 0.0]; head_tail = :tail, name = "tail", color = :green)
    lineplot!(p, [0.0, 1.0], [0.5, 0.5]; head_tail = :both, name = "both", color = :blue)
    test_ref("lineplot/arrows.txt", @show_col(p))

    n = 20
    x = range(1, 2; length = n)
    p = lineplot(
        x,
        fill(0, n),
        ylim = (-1, 5),
        head_tail = :head,
        head_tail_frac = 0.05,
        name = "5%",
    )
    for (i, (frac, name)) in
        enumerate(zip((0.1, 0.15, 0.2, 0.25), ("10%", "15%", "20%", "25%")))
        lineplot!(p, x, fill(i, n); name, head_tail = :head, head_tail_frac = frac)
    end
    test_ref("lineplot/arrows_fractions.txt", @show_col(p))
end

@testset "color vector" begin
    x = [[-1, 2], [2, 3], [3, 7]]
    y = [[-1, 2], [2, 9], [9, 4]]
    p = Plot([-1, 7], [-1, 9])
    lineplot!(p, x, y, color = [:red, :green, :blue])
    test_ref("lineplot/color_vector.txt", @show_col(p))
end

@testset "units" begin
    a = 1u"m/s^2"
    t = collect(Float64, 0:100) * u"s"
    x = a / 2 * t .^ 2
    v = a * t
    p = lineplot(x, v, xlabel = "position", ylabel = "speed")
    lineplot!(p, extrema(x) |> collect, [maximum(v), maximum(v)]; color = :red)
    test_ref("lineplot/units_pos_vel.txt", @show_col(p))
end

@testset "multiple series (matrix columns)" begin
    x, y1, y2 = 0:10, [-2:8 2:12 6:16], [reverse(-4:6) reverse(8:18)]

    p = lineplot(x, y1)
    lineplot!(p, x, y2)
    test_ref("lineplot/matrix_auto.txt", @show_col(p))

    for name ∈ (["1", "2", "3"], ["1" "2" "3"])
        p = lineplot(x, y1; name, color = [:red :green :blue])
        lineplot!(p, x, y2; name = ["4" "5"], color = [:yellow :cyan])
        test_ref("lineplot/matrix_parameters.txt", @show_col(p))
    end
end

@testset "hline - vline" begin
    p = Plot([NaN], [NaN]; xlim = (0, 8), ylim = (0, 8))
    vline!(p, [2, 6], [2, 6]; color = :red)
    hline!(p, [2, 6], [2, 6]; color = :white)

    hline!(p, 7)
    vline!(p, 1)
    test_ref("lineplot/hvline.txt", @show_col(p))
end

@testset "IntervalSets" begin
    p = lineplot(0 .. 2, identity)
    lineplot!(p, 0 .. 2, sqrt; length = 50)
    test_ref("lineplot/intervalsets1.txt", @show_col(p))

    p = lineplot(0 .. 1, [sqrt, cbrt], step = 0.01)
    test_ref("lineplot/intervalsets2.txt", @show_col(p))
end
