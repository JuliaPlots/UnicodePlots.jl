@test supertype(GraphicsArea) == Any

@testset "BarplotGraphics" begin
    @test BarplotGraphics <: GraphicsArea
    @test !(BarplotGraphics <: Canvas)

    @testset "basic API and display" begin
        g = BarplotGraphics(0:2:10, 30)
        @test @inferred(nrows(g)) ≡ 6
        @test @inferred(ncols(g)) ≡ 30
        @test_throws ArgumentError print_row(stdout, g, 0)
        @test_throws ArgumentError print_row(stdout, g, 7)
        postprocess! = preprocess!(devnull, g)
        test_ref(
            "graphics/bar_print_row.txt",
            @io2str(print_row(IOContext(::IO, :color => true), g, 3))
        )
        postprocess!(g)
        test_ref("graphics/bar_print.txt", @print_col(g))
        test_ref("graphics/bar_show.txt", @show_col(g))
        test_ref("graphics/bar_print_nocolor.txt", @print_nocol(g))
        test_ref("graphics/bar_show_nocolor.txt", @show_nocol(g))
        @test @inferred(addrow!(g, 3)) ≡ g
        @test @inferred(nrows(g)) ≡ 7
        @test @inferred(ncols(g)) ≡ 30
        @test_throws InexactError addrow!(g, 3.5)
        test_ref("graphics/bar_addrow_scalar.txt", @show_col(g))
        @test @inferred(addrow!(g, [50, 7])) ≡ g
        @test_throws MethodError addrow!(g, [3.5])
        @test @inferred(nrows(g)) ≡ 9
        @test @inferred(ncols(g)) ≡ 30
        test_ref("graphics/bar_addrow_vector.txt", @show_col(g))
        @test @inferred(addrow!(g, [25, 12], [:blue, :red])) ≡ g
        test_ref("graphics/bar_addrow_vector_colors.txt", @show_col(g))
        @test @inferred(nrows(g)) ≡ 11
        @test @inferred(ncols(g)) ≡ 30
    end

    @testset "Constructor parameter" begin
        @test_throws MethodError BarplotGraphics(0:2:10)
        @test_throws Union{ArgumentError, MethodError} BarplotGraphics(Int[], 20)
        @test_throws ArgumentError BarplotGraphics(0:2:10, 30; symbols = ["--"])  # invalids symbols
        g = BarplotGraphics([0, 0], 20)
        @test @inferred(nrows(g)) ≡ 2
        @test @inferred(ncols(g)) ≡ 20
        test_ref("graphics/bar_empty.txt", @show_col(g))
        g = BarplotGraphics([1, 1], 20, color = :blue)
        @test @inferred(nrows(g)) ≡ 2
        @test @inferred(ncols(g)) ≡ 20
        test_ref("graphics/bar_blue.txt", @show_col(g))
        g = BarplotGraphics([0, 1, 10, 100, 1_000], 20; xscale = log10)
        @test @inferred(nrows(g)) ≡ 5
        @test @inferred(ncols(g)) ≡ 20
        test_ref("graphics/bar_log10.txt", @show_col(g))
        g = BarplotGraphics([0, 1, 10], 20; symbols = ["#"])
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 20
        test_ref("graphics/bar_symb.txt", @show_col(g))
        g = BarplotGraphics([0, 1, 9], 1)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 10
        test_ref("graphics/bar_short.txt", @show_col(g))
        g = BarplotGraphics([0, 1, 100_000], 1)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 13
        test_ref("graphics/bar_short2.txt", @show_col(g))
    end
end

@testset "BoxplotGraphics" begin
    @test BoxplotGraphics <: GraphicsArea
    @test !(BoxplotGraphics <: Canvas)

    @testset "basic API and display" begin
        g = @inferred BoxplotGraphics([1, 2, 2, 4, 5, 6], 30)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 30
        @test_throws ArgumentError print_row(stdout, g, 0)
        @test_throws ArgumentError print_row(stdout, g, 4)
        postprocess! = preprocess!(devnull, g)
        test_ref(
            "graphics/box_print_row.txt",
            @io2str(print_row(IOContext(::IO, :color => true), g, 3))
        )
        postprocess!(g)
        test_ref("graphics/box_print.txt", @print_col(g))
        test_ref("graphics/box_show.txt", @show_col(g))
        test_ref("graphics/box_print_nocolor.txt", @print_nocol(g))
        test_ref("graphics/box_show_nocolor.txt", @show_nocol(g))
        @test @inferred(UnicodePlots.addseries!(g, [3.0, 3, 2, 4, 0, 1])) ≡ g
        @test @inferred(nrows(g)) ≡ 6
        @test @inferred(ncols(g)) ≡ 30
        test_ref("graphics/box_addseries.txt", @show_col(g))
        @test @inferred(UnicodePlots.addseries!(g, [2, 2, 2])) ≡ g
        @test @inferred(nrows(g)) ≡ 9
        @test @inferred(ncols(g)) ≡ 30
        test_ref("graphics/box_addseries_small.txt", @show_col(g))
    end

    @testset "Constructor parameter" begin
        @test_throws MethodError BoxplotGraphics([1, 2, 2, 4, 5, 6])
        @test_throws Union{ArgumentError, MethodError} BoxplotGraphics(Int[], 30)
        g = @inferred BoxplotGraphics([0, 0], 20)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 20
        test_ref("graphics/box_empty.txt", @show_col(g))
        g = @inferred BoxplotGraphics([1, 2], 20, color = :blue)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 20
        test_ref("graphics/box_blue.txt", @show_col(g))
        g = @inferred BoxplotGraphics([0, 1, 9], 1)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 10
        test_ref("graphics/box_short.txt", @show_col(g))
        g = @inferred BoxplotGraphics([1, 2, 2, 4, 5, 6], 30, min_x = 2, max_x = 8)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 30
        test_ref("graphics/box_minmax1.txt", @show_col(g))
        g = @inferred BoxplotGraphics([1, 2, 2, 4, 5, 6], 30, min_x = 0, max_x = 7)
        @test @inferred(nrows(g)) ≡ 3
        @test @inferred(ncols(g)) ≡ 30
        test_ref("graphics/box_minmax2.txt", @show_col(g))
        # FIXME: boxplot breaks if `max_x` or `min_x` doesn't cover data span
    end
end
