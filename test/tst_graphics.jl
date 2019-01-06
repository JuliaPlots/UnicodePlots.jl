@test supertype(GraphicsArea) == Any

@testset "BarplotGraphics" begin
    @test BarplotGraphics <: GraphicsArea
    @test !(BarplotGraphics <: Canvas)

    @testset "basic API and display" begin
        g = @inferred BarplotGraphics(0:2:10, 30)
        @test @inferred(nrows(g)) === 6
        @test @inferred(ncols(g)) === 30
        @test_throws ArgumentError printrow(stdout, g, 0)
        @test_throws ArgumentError printrow(stdout, g, 7)
        @test_reference(
            "references/graphics/bar_printrow.txt",
            @io2str(printrow(IOContext(::IO, :color=>true), g, 3)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/bar_print.txt",
            @io2str(print(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/bar_show.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/bar_print_nocolor.txt",
            @io2str(print(::IO, g)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/bar_show_nocolor.txt",
            @io2str(show(::IO, g)),
            render = BeforeAfterFull()
        )
        @test @inferred(addrow!(g, 3)) === g
        @test @inferred(nrows(g)) === 7
        @test @inferred(ncols(g)) === 30
        @test_throws InexactError addrow!(g, 3.5)
        @test_reference(
            "references/graphics/bar_addrow_scalar.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        @test @inferred(addrow!(g, [50, 7])) === g
        @test_throws MethodError addrow!(g, [3.5])
        @test @inferred(nrows(g)) === 9
        @test @inferred(ncols(g)) === 30
        @test_reference(
            "references/graphics/bar_addrow_vector.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
    end

    @testset "Constructor parameter" begin
        @test_throws MethodError BarplotGraphics(0:2:10)
        @test_throws ArgumentError BarplotGraphics(Int[], 20)
        @test_throws ArgumentError BarplotGraphics(0:2:10, 30, symb="--")
        g = @inferred BarplotGraphics([0, 0], 20)
        @test @inferred(nrows(g)) === 2
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/bar_empty.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BarplotGraphics([1, 1], 20, color=:blue)
        @test @inferred(nrows(g)) === 2
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/bar_blue.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BarplotGraphics([0, 1, 10, 100, 1000], 20, log10)
        @test @inferred(nrows(g)) === 5
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/bar_log10.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BarplotGraphics([0, 1, 10], 20, symb="#")
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/bar_symb.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BarplotGraphics([0, 1, 9], 1)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 10
        @test_reference(
            "references/graphics/bar_short.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BarplotGraphics([0, 1, 10000000], 1)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 15
        @test_reference(
            "references/graphics/bar_short2.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
    end
end

@testset "BoxplotGraphics" begin
    @test BoxplotGraphics <: GraphicsArea
    @test !(BoxplotGraphics <: Canvas)

    @testset "basic API and display" begin
        g = @inferred BoxplotGraphics([1,2,2,4,5,6], 30)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 30
        @test_throws ArgumentError printrow(stdout, g, 0)
        @test_throws ArgumentError printrow(stdout, g, 4)
        @test_reference(
            "references/graphics/box_printrow.txt",
            @io2str(printrow(IOContext(::IO, :color=>true), g, 3)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/box_print.txt",
            @io2str(print(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/box_show.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/box_print_nocolor.txt",
            @io2str(print(::IO, g)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/graphics/box_show_nocolor.txt",
            @io2str(show(::IO, g)),
            render = BeforeAfterFull()
        )
        @test @inferred(UnicodePlots.addseries!(g, [3.,3,2,4,0,1])) === g
        @test @inferred(nrows(g)) === 6
        @test @inferred(ncols(g)) === 30
        @test_reference(
            "references/graphics/box_addseries.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        @test @inferred(UnicodePlots.addseries!(g, [2,2,2])) === g
        @test @inferred(nrows(g)) === 9
        @test @inferred(ncols(g)) === 30
        @test_reference(
            "references/graphics/box_addseries_small.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
    end

    @testset "Constructor parameter" begin
        @test_throws MethodError BoxplotGraphics([1,2,2,4,5,6])
        @test_throws ArgumentError BoxplotGraphics(Int[], 30)
        g = @inferred BoxplotGraphics([0, 0], 20)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/box_empty.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BoxplotGraphics([1, 2], 20, color=:blue)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/box_blue.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BoxplotGraphics([0, 1, 9], 1)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 10
        @test_reference(
            "references/graphics/box_short.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BoxplotGraphics([1,2,2,4,5,6], 30, min_x = 2, max_x = 8)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 30
        @test_reference(
            "references/graphics/box_minmax1.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BoxplotGraphics([1,2,2,4,5,6], 30, min_x = 0, max_x = 7)
        @test @inferred(nrows(g)) === 3
        @test @inferred(ncols(g)) === 30
        @test_reference(
            "references/graphics/box_minmax2.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        # FIXME: boxplot break if max_x or min_x is doesn't conver the data
    end
end
