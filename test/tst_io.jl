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
    p = lineplot([cos, sin, x -> 0.5, x -> -0.5], -π / 2, 2π, title = "fancy title")

    for tr in (true, false)
        tmp = tempname() * ".png"

        savefig(p, tmp; transparent = tr)
        @test filesize(tmp) > 9000

        img = FileIO.load(tmp)
        @test all(size(img) .> (400, 600))
    end
end
