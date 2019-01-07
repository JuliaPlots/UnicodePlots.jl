withenv("LINES"=>24, "COLUMNS"=>80) do
    @testset "sizing" begin
        seed!(1337)
        p = @inferred spy(sprand(10,10,.15))
        @test p isa Plot
        @test_reference(
            "references/spy/default_10x10.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprand(10,15,.15))
        @test_reference(
            "references/spy/default_10x15.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprand(15,10,.15))
        @test_reference(
            "references/spy/default_15x10.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprand(2000,200,.0001))
        @test_reference(
            "references/spy/default_2000x200.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprand(200,2000,.0001))
        @test_reference(
            "references/spy/default_200x2000.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprand(2000,2000,.1))
        @test_reference(
            "references/spy/default_overdrawn.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprandn(200,200,.001))
        @test_reference(
            "references/spy/default_200x200_normal.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/spy/default_200x200_normal_nocolor.txt",
            @io2str(show(IOContext(::IO, :color=>false), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(Matrix(sprandn(200,200,.001)))
        @test_reference(
            "references/spy/default_200x200_normal.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprandn(200,200,.001), width=10)
        @test_reference(
            "references/spy/default_200x200_normal_small.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprandn(200,200,.001), height=5)
        @test_reference(
            "references/spy/default_200x200_normal_small.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = @inferred spy(sprandn(200,200,.001), height=5, width=20)
        @test_reference(
            "references/spy/default_200x200_normal_misshaped.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    @testset "parameters" begin
        seed!(1337)
        p = @inferred spy(sprandn(200,200,.001), color=:green)
        @test_reference(
            "references/spy/parameters_200x200_green.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        @test_reference(
            "references/spy/parameters_200x200_green_nocolor.txt",
            @io2str(show(IOContext(::IO, :color=>false), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = spy(sprandn(200,200,.001), title="Custom Title", canvas=DotCanvas, border=:ascii)
        @test_reference(
            "references/spy/parameters_200x200_dotcanvas.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end
end
