@testset "BrailleCanvas" begin
    @testset "color mixing" begin
        canvas = BrailleCanvas(40, 15, origin_x = 0., origin_y = 0., width = 1.2, height = 1.2)
        lines!(canvas, 0.0, 0.0, 1.2, 0.0, :blue)
        lines!(canvas, 0.0, 0.2, 1.2, 0.2, :red)
        lines!(canvas, 0.0, 0.4, 1.2, 0.4, :green)
        lines!(canvas, 0.0, 0.6, 1.2, 0.6, :yellow)
        lines!(canvas, 0.0, 0.8, 1.2, 0.8, :magenta)
        lines!(canvas, 0.0, 1.0, 1.2, 1.0, :cyan)
        lines!(canvas, 0.0, 1.2, 1.2, 1.2, :white)

        lines!(canvas, 0.0, 0.0, 0.0, 1.2, :blue)
        lines!(canvas, 0.2, 0.0, 0.2, 1.2, :red)
        lines!(canvas, 0.4, 0.0, 0.4, 1.2, :green)
        lines!(canvas, 0.6, 0.0, 0.6, 1.2, :yellow)
        lines!(canvas, 0.8, 0.0, 0.8, 1.2, :magenta)
        lines!(canvas, 1.0, 0.0, 1.0, 1.2, :cyan)
        lines!(canvas, 1.2, 0.0, 1.2, 1.2, :white)
        @test_reference(
            "references/canvas/color_mixing.txt",
            @io2str(print(IOContext(::IO, :color=>true), canvas)),
            render = BeforeAfterFull()
        )
    end
    seed!(1337)
    canvas = BrailleCanvas(40, 10, origin_x = 0., origin_y = 0., width = 1., height = 1.)
    lines!(canvas, 0., 0., 1., 1., :blue)
    points!(canvas, rand(20), rand(20), :white)
    points!(canvas, rand(50), rand(50), color = :red)
    lines!(canvas, 0., 1., .5, 0., :green)
    points!(canvas, 1., 1.)
    lines!(canvas, [1.,2], [2.,1])
    lines!(canvas, 0., 0., .9, 9999., :yellow)
    lines!(canvas, 0., 0., 1., 1., color = :blue)
    lines!(canvas, .1, .7, .9, .6, :red)
    @test_reference(
        "references/canvas/braillecanvas_print.txt",
        @io2str(print(IOContext(::IO, :color=>true), canvas)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/canvas/braillecanvas_show.txt",
        @io2str(show(IOContext(::IO, :color=>true), canvas)),
        render = BeforeAfterFull()
    )
end
