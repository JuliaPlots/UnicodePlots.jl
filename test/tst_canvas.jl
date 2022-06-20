@test Canvas <: GraphicsArea

@testset "Nan / Inf" begin
    c = BrailleCanvas(40, 15)
    lines!(c, [0, NaN], [0, 0])
    lines!(c, [0, 0], [+Inf, 0])
    lines!(c, [0, 0], [0, -Inf])
end

@testset "interface" begin
    for (T, xres, yres) in [
        (BrailleCanvas, 2, 4),
        (DensityCanvas, 1, 2),
        (BlockCanvas, 2, 2),
        (AsciiCanvas, 3, 3),
        (DotCanvas, 1, 2),
        (HeatmapCanvas, 1, 2),
    ]
        @testset "$(nameof(T))" begin
            @test T <: Canvas
            c = @inferred T(30, 15, origin_x = -1, origin_y = -1.5, width = 2, height = 3)
            @test @inferred(size(c)) ≡ (2.0, 3.0)
            @test @inferred(width(c)) ≡ 2.0
            @test @inferred(height(c)) ≡ 3.0
            @test @inferred(origin(c)) ≡ (-1.0, -1.5)
            @test @inferred(origin_x(c)) ≡ -1.0
            @test @inferred(origin_y(c)) ≡ -1.5
            @test @inferred(ncols(c)) ≡ 30
            @test @inferred(nrows(c)) ≡ (T == HeatmapCanvas ? 8 : 15)
            @test @inferred(UnicodePlots.x_pixel_per_char(T)) ≡ xres
            @test @inferred(UnicodePlots.y_pixel_per_char(T)) ≡ yres
            @test @inferred(pixel_width(c)) ≡ 30 * xres
            @test @inferred(pixel_height(c)) ≡ 15 * yres
            @test @inferred(pixel_size(c)) ≡ (pixel_width(c), pixel_height(c))
            if T <: UnicodePlots.LookupCanvas  # coverage
                @test length(UnicodePlots.lookup_encode(c)) > 0
                @test length(UnicodePlots.lookup_decode(c)) > 0
            end
        end
    end
end

@testset "print and show" begin
    seed!(RNG, 1337)
    x1, y1 = rand(RNG, 20), rand(RNG, 20)
    x2, y2 = rand(RNG, 50), rand(RNG, 50)
    for (T, str) in [
        (BrailleCanvas, "braille"),
        (DensityCanvas, "density"),
        (BlockCanvas, "block"),
        (AsciiCanvas, "ascii"),
        (DotCanvas, "dot"),
        (HeatmapCanvas, "heatmap"),
    ]
        @testset "$T" begin
            c = T(40, 10, origin_x = 0.0, origin_y = 0.0, width = 1.0, height = 1.0)
            if T == BrailleCanvas
                test_ref("canvas/empty_braille_show.txt", @show_col(c))
            elseif T == HeatmapCanvas
                test_ref("canvas/empty_heatmap_show.txt", @show_col(c))
            else
                test_ref("canvas/empty_show.txt", @show_col(c))
            end
            @test @inferred(lines!(c, 0.0, 0.0, 1.0, 1.0, :blue)) ≡ c
            @test @inferred(points!(c, x1, y1, :white)) ≡ c
            @test @inferred(pixel!(c, 2, 4, color = :cyan)) ≡ c
            points!(c, x2, y2, color = :red)
            lines!(c, 0.0, 1.0, 0.5, 0.0, :green)
            points!(c, 0.05, 0.3, color = :cyan)
            lines!(c, [1.0, 2], [2.0, 1])
            lines!(c, 0.0, 0.0, 0.9, 9999.0, :yellow)
            lines!(c, 0, 0, 1, 1, color = :blue)
            lines!(c, 0.1, 0.7, 0.9, 0.6, :red)
            callback! = preprocess!(c)
            test_ref(
                "canvas/$(str)_printrow.txt",
                @io2str(printrow(IOContext(::IO, :color => true), c, 3))
            )
            callback!(c)
            test_ref("canvas/$(str)_print.txt", @print_col(c))
            test_ref("canvas/$(str)_print_nocolor.txt", @print_nocol(c))
            test_ref("canvas/$(str)_show.txt", @show_col(c))
            test_ref("canvas/$(str)_show_nocolor.txt", @show_nocol(c))
        end
    end
end

vline!(c, m, M, x, col) = lines!(c, x, m, x, M, col)
hline!(c, m, M, y, col) = lines!(c, m, y, M, y, col)

@testset "color mixing 4bit" begin
    m, M = 0.0, 1.4
    c = BrailleCanvas(40, 15, origin_x = m, origin_y = m, width = M, height = M)

    for line in (vline!, hline!)
        line(c, m, M, 0.0, :dark_gray)
        line(c, m, M, 0.2, :light_red)
        line(c, m, M, 0.4, :light_green)
        line(c, m, M, 0.6, :light_yellow)
        line(c, m, M, 0.8, :light_blue)
        line(c, m, M, 1.0, :light_magenta)
        line(c, m, M, 1.2, :light_cyan)
        line(c, m, M, 1.4, :white)
    end

    test_ref("canvas/color_mixing_4bit.txt", @print_col(c))
end

@testset "color mixing (8bit)" begin
    m, M = 0.0, 1.4
    c = BrailleCanvas(40, 15, origin_x = m, origin_y = m, width = M, height = M)

    for line in (vline!, hline!)
        line(c, m, M, 0.0, 8)
        line(c, m, M, 0.2, 9)
        line(c, m, M, 0.4, 10)
        line(c, m, M, 0.6, 11)
        line(c, m, M, 0.8, 12)
        line(c, m, M, 1.0, 13)
        line(c, m, M, 1.2, 14)
        line(c, m, M, 1.4, 15)
    end

    test_ref("canvas/color_mixing_8bit.txt", @print_col(c))
end

@testset "color mixing (24bit)" begin
    m, M = 0.0, 1.4
    c = BrailleCanvas(40, 15, origin_x = m, origin_y = m, width = M, height = M)

    for line in (vline!, hline!)
        line(c, m, M, 0.0, (0, 0, 0))
        line(c, m, M, 0.2, (255, 0, 0))
        line(c, m, M, 0.4, (0, 255, 0))
        line(c, m, M, 0.6, (255, 255, 0))
        line(c, m, M, 0.8, (0, 0, 255))
        line(c, m, M, 1.0, (255, 0, 255))
        line(c, m, M, 1.2, (0, 255, 255))
        line(c, m, M, 1.4, (255, 255, 255))
    end

    test_ref("canvas/color_mixing_24bit.txt", @print_col(c))
end
