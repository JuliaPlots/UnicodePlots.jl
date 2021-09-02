withenv("LINES"=>24, "COLUMNS"=>80) do
    @testset "sizing" begin
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 10, 10, .15))
        @test p isa Plot
        test_ref(
            "references/spy/default_10x10.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 10, 15, .15))
        test_ref(
            "references/spy/default_10x15.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 15, 10, .15))
        test_ref(
            "references/spy/default_15x10.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 2000, 200, .0001))
        test_ref(
            "references/spy/default_2000x200.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 200, 2000, .0001))
        test_ref(
            "references/spy/default_200x2000.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 2000, 2000, .1))
        test_ref(
            "references/spy/default_overdrawn.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 200, 200, .001))
        test_ref(
            "references/spy/default_200x200_normal.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        test_ref(
            "references/spy/default_200x200_normal_nocolor.txt",
            @io2str(show(IOContext(::IO, :color=>false), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(Matrix(stable_sprand(RNG, 200, 200, .001)))
        test_ref(
            "references/spy/default_200x200_normal.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 200, 200, .001), width=10)
        test_ref(
            "references/spy/default_200x200_normal_small.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 200, 200, .001), height=5)
        test_ref(
            "references/spy/default_200x200_normal_small.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 200, 200, .001), height=5, width=20)
        test_ref(
            "references/spy/default_200x200_normal_misshaped.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
    end

    @testset "parameters" begin
        seed!(RNG, 1337)
        p = @inferred spy(stable_sprand(RNG, 200, 200, .001), color=:green)
        test_ref(
            "references/spy/parameters_200x200_green.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
        test_ref(
            "references/spy/parameters_200x200_green_nocolor.txt",
            @io2str(show(IOContext(::IO, :color=>false), p))
        )
        seed!(RNG, 1337)
        p = spy(stable_sprand(RNG, 200, 200, .001), title="Custom Title", canvas=DotCanvas, border=:ascii)
        test_ref(
            "references/spy/parameters_200x200_dotcanvas.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
    end
end
