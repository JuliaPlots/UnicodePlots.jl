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
        @test_throws AssertionError BarplotGraphics(0:2:10, 30, symb="--")
        g = @inferred BarplotGraphics([0, 0], 20)
        @test @inferred(nrows(g)) === 2
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/bar_empty.txt",
            @io2str(show(IOContext(::IO, :color=>true), g)),
            render = BeforeAfterFull()
        )
        g = @inferred BarplotGraphics([1, 1], 20, color=:green)
        @test @inferred(nrows(g)) === 2
        @test @inferred(ncols(g)) === 20
        @test_reference(
            "references/graphics/bar_green.txt",
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
