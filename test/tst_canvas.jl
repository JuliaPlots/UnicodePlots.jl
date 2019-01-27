@test Canvas <: GraphicsArea

@testset "interface" begin
    for (T, xres, yres) in [
            (BrailleCanvas, 2, 4),
            (DensityCanvas, 1, 2),
            (BlockCanvas,   2, 2),
            (AsciiCanvas,   3, 3),
            (DotCanvas,     1, 2),
        ]
        @testset "$(nameof(T))" begin
            @test T <: Canvas
            c = @inferred T(30, 15, origin_x = -1, origin_y = -1.5, width = 2, height = 3)
            @test @inferred(size(c)) === (2., 3.)
            @test @inferred(width(c)) === 2.
            @test @inferred(height(c)) === 3.
            @test @inferred(origin(c)) === (-1.0, -1.5)
            @test @inferred(origin_x(c)) === -1.0
            @test @inferred(origin_y(c)) === -1.5
            @test @inferred(ncols(c)) === 30
            @test @inferred(nrows(c)) === 15
            @test @inferred(UnicodePlots.x_pixel_per_char(typeof(c))) === xres
            @test @inferred(UnicodePlots.y_pixel_per_char(typeof(c))) === yres
            @test @inferred(pixel_width(c)) === 30 * xres
            @test @inferred(pixel_height(c)) === 15 * yres
            @test @inferred(pixel_size(c)) === (pixel_width(c), pixel_height(c))
        end
    end
end

@testset "print and show" begin
    seed!(1337)
    x1, y1 = rand(20), rand(20)
    x2, y2 = rand(50), rand(50)
    for (T, str) in [
            (BrailleCanvas, "braille"),
            (DensityCanvas, "density"),
            (BlockCanvas,   "block"),
            (AsciiCanvas,   "ascii"),
            (DotCanvas,     "dot"),
        ]
        @testset "$(nameof(T))" begin
            c = T(40, 10, origin_x = 0., origin_y = 0., width = 1., height = 1.)
            if T == BrailleCanvas
                @test_reference(
                    "references/canvas/empty_braille_show.txt",
                    @io2str(show(IOContext(::IO, :color=>true), c)),
                    render = BeforeAfterFull()
                )
            else
                @test_reference(
                    "references/canvas/empty_show.txt",
                    @io2str(show(IOContext(::IO, :color=>true), c)),
                    render = BeforeAfterFull()
                )
            end
            @test @inferred(lines!(c, 0., 0., 1., 1., :blue)) === c
            @test @inferred(points!(c, x1, y1, :white)) === c
            @test @inferred(pixel!(c, 2, 4, color = :cyan)) === c
            points!(c, x2, y2, color = :red)
            lines!(c, 0., 1., .5, 0., :green)
            points!(c, .05, .3, color = :cyan)
            lines!(c, [1.,2], [2.,1])
            lines!(c, 0., 0., .9, 9999., :yellow)
            lines!(c, 0, 0, 1, 1, color = :blue)
            lines!(c, .1, .7, .9, .6, :red)
            @test_reference(
                "references/canvas/$(str)_printrow.txt",
                @io2str(printrow(IOContext(::IO, :color=>true), c, 3)),
                render = BeforeAfterFull()
            )
            @test_reference(
                "references/canvas/$(str)_print.txt",
                @io2str(print(IOContext(::IO, :color=>true), c)),
                render = BeforeAfterFull()
            )
            @test_reference(
                "references/canvas/$(str)_print_nocolor.txt",
                @io2str(print(::IO, c)),
                render = BeforeAfterFull()
            )
            @test_reference(
                "references/canvas/$(str)_show.txt",
                @io2str(show(IOContext(::IO, :color=>true), c)),
                render = BeforeAfterFull()
            )
            @test_reference(
                "references/canvas/$(str)_show_nocolor.txt",
                @io2str(show(::IO, c)),
                render = BeforeAfterFull()
            )
        end
    end
end

@testset "color mixing" begin
    c = BrailleCanvas(40, 15, origin_x = 0., origin_y = 0., width = 1.2, height = 1.2)
    @inferred lines!(c, 0.0, 0.0, 1.2, 0.0, :blue)
    lines!(c, 0.0, 0.2, 1.2, 0.2, :red)
    lines!(c, 0.0, 0.4, 1.2, 0.4, :green)
    lines!(c, 0.0, 0.6, 1.2, 0.6, :yellow)
    lines!(c, 0.0, 0.8, 1.2, 0.8, :magenta)
    lines!(c, 0.0, 1.0, 1.2, 1.0, :cyan)
    lines!(c, 0.0, 1.2, 1.2, 1.2, :white)

    lines!(c, 0.0, 0.0, 0.0, 1.2, :blue)
    lines!(c, 0.2, 0.0, 0.2, 1.2, :red)
    lines!(c, 0.4, 0.0, 0.4, 1.2, :green)
    lines!(c, 0.6, 0.0, 0.6, 1.2, :yellow)
    lines!(c, 0.8, 0.0, 0.8, 1.2, :magenta)
    lines!(c, 1.0, 0.0, 1.0, 1.2, :cyan)
    lines!(c, 1.2, 0.0, 1.2, 1.2, :normal)
    @test_reference(
        "references/canvas/color_mixing.txt",
        @io2str(print(IOContext(::IO, :color=>true), c)),
        render = BeforeAfterFull()
    )
end
