@testset "BrailleCanvas" begin
    seed!(1337)
    canvas = BrailleCanvas(40, 10, origin_x = 0., origin_y = 0., width = 1., height = 1.)
    lines!(canvas, 0., 0., 1., 1., :blue)
    points!(canvas, rand(20), rand(20), :white)
    points!(canvas, rand(50), rand(50), color = :red)
    lines!(canvas, 0., 1., .5, 0., :yellow)
    points!(canvas, 1., 1.)
    lines!(canvas, [1.,2], [2.,1])
    lines!(canvas, 0., 0., .9, 9999., :yellow)
    lines!(canvas, 0., 0., 1., 1., color = :blue)
    lines!(canvas, .3, .7, 1., 0., :red)
    lines!(canvas, 0., 2., .5, 0., :yellow)
    @test_reference(
        "references/canvas/braillecanvas_print.txt",
        @io2str(print(IOContext(::IO, :color=>true), canvas)),
        mode = BeforeAfterFull()
    )
    @test_reference(
        "references/canvas/braillecanvas_show.txt",
        @io2str(show(IOContext(::IO, :color=>true), canvas)),
        mode = BeforeAfterFull()
    )
end
