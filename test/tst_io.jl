@testset "show" begin
    io = IOContext(PipeBuffer(), :color => false)

    # test padding (NOTE: @check_padidng embedded in @show_col)
    @show_col scatterplot(1:2, labels = false)

    @show_col scatterplot(1:2, labels = false, title = "scatterplot")

    @show_col scatterplot(1:2, title = "scatterplot", xlabel = "x")

    @show_col scatterplot(1:2, title = "scatterplot", xlabel = "x", compact = true)

    A = repeat(collect(0:10)', outer = (11, 1))
    # complex right padding, with colorbar and limit labels
    for zlabel in ("zlab", ""), n = 1:10
        @show_col heatmap(A; margin = 0, title = "fancy", zlabel, zlim = (1, 10^n))
    end
end

@testset "savefig" begin
    font_found = UnicodePlots.get_font_face() ≢ nothing  # `PkgEval` can fail
    for p ∈ (
        lineplot(-π / 2, 2π, [cos, sin, x -> 0.5, x -> -0.5], title = "fancy title"),
        barplot([:a, :b, :c, :d, :e], [20, 30, 60, 50, 40]),
    )
        for bbox ∈ (nothing, :red), tr ∈ (true, false)
            tmp = tempname() * ".png"

            savefig(
                p,
                tmp;
                transparent = tr,
                bounding_box_glyph = bbox,
                bounding_box = bbox,
            )

            if font_found
                @test filesize(tmp) > 1_000

                img = FileIO.load(tmp)
                @test all(size(img) .> (100, 100))
            end
        end

        @test_throws ArgumentError savefig(p, tempname() * ".jpg")
    end

    # for Plots
    if font_found
        p = lineplot(1:2)
        tmp = tempname() * ".png"
        open(tmp, "w") do io
            UnicodePlots.save_image(io, UnicodePlots.png_image(p))
        end
        @test filesize(tmp) > 1_000
    end
end

sombrero(x, y) = 30sinc(√(x^2 + y^2) / π)

@testset "stringify plot - performance regression" begin
    nightly = occursin("DEV", string(VERSION))  # or length(VERSION.prerelease) < 2
    measure = Sys.islinux() && VERSION > v"1.10.0-" && !nightly

    let p = heatmap(collect(1:30) * collect(1:30)')
        @test string(p; color = true) isa String  # 1st pass - ttfp

        if measure
            GC.enable(false)
            stats = @timed string(p; color = true)  # repeated !
            @test stats.bytes / 1e3 < 500  # ~ 292kB on 1.11
            @test stats.time * 1e3 < 0.8  # ~ 0.3ms on 1.11
            GC.enable(true)
        end
    end

    let p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero; axes3d = false)
        @test string(p; color = true) isa String  # 1st pass - ttfp

        if measure
            GC.enable(false)
            stats = @timed string(p; color = true)  # repeated !
            @test stats.bytes / 1e3 < 160  # ~ 123kB on 1.11
            @test stats.time * 1e3 < 0.5  # ~ 0.2ms on 1.11
            GC.enable(true)
        end
    end
end

@testset "Term extension" begin
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:5); show_placeholder = true))
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:3); layout = (2, nothing)))
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:3); layout = (nothing, 1)))
end
