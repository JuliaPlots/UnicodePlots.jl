@testset "no world age issue" begin
    @testset "png_image" begin
        tmpname = joinpath(tempdir(), "foo.png")
        savefig(lineplot([0, 1]), tmpname)
        @test isfile(tmpname)
    end
end
