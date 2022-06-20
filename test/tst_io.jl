@testset "show" begin
    io = IOContext(PipeBuffer(), :color => false)

    show(io, scatterplot(1:2, labels = false))
    @test length.(eachline(io)) |> unique |> length == 1

    show(io, scatterplot(1:2, labels = false, title = "scatterplot"))
    @test length.(eachline(io)) |> unique |> length == 1

    show(io, scatterplot(1:2, title = "scatterplot", xlabel = "x"))
    @test length.(eachline(io)) |> unique |> length == 1

    show(io, scatterplot(1:2, title = "scatterplot", xlabel = "x", compact = true))
    @test length.(eachline(io)) |> unique |> length == 1

    show(io, heatmap(repeat(collect(0:10)', outer = (11, 1)), title = "heatmap"))
    @test length.(eachline(io)) |> unique |> length == 1
end

@testset "save as png" begin
    for p in (
        lineplot([cos, sin, x -> 0.5, x -> -0.5], -π / 2, 2π, title = "fancy title"),
        barplot([:a, :b, :c, :d, :e], [20, 30, 60, 50, 40]),
    )
        for bbox in (nothing, :red)
            for tr in (true, false)
                tmp = tempname() * ".png"

                savefig(
                    p,
                    tmp;
                    transparent = tr,
                    bounding_box_glyph = bbox,
                    bounding_box = bbox,
                )
                @test filesize(tmp) > 1_000

                img = FileIO.load(tmp)
                @test all(size(img) .> (100, 100))
            end
        end
    end
end

@testset "stringify plot - performance regression" begin
    p = heatmap(collect(1:30) * collect(1:30)')
    @test string(p; color = true) isa String

    stats = @timed string(p; color = true)  # repeated !
    @test stats.bytes / 1e3 < 550  # ~ 500kB on 1.7
    @test stats.time * 1e3 < 2  # ~ 1.5ms on 1.7

    sombrero(x, y) = 30sinc(√(x^2 + y^2) / π)
    p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero; axes3d = false)
    @test string(p; color = true) isa String

    stats = @timed string(p; color = true)  # repeated !
    @test stats.bytes / 1e3 < 150  # ~ 124kB on 1.7
    @test stats.time * 1e6 < 900  # ~ 420µs on 1.7
end
