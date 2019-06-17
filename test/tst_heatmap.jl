
withenv("LINES"=>24, "COLUMNS"=>80) do
    @testset "sizing" begin
        for dims in [(10, 10), (10, 15), (15, 10), (2000, 200), (200, 2000), (2000, 2000)]
            seed!(1337)
            p = @inferred heatmap(randn(dims))
            @test p isa Plot
            @test_reference(
                "references/heatmap/default_$(dims[1])x$(dims[2]).txt",
                @io2str(show(IOContext(::IO, :color=>true), p)),
                render = BeforeAfterFull()
            )
        end
    end
    @testset "parameters" begin
        seed!(1337)
        p = @inferred heatmap(randn(200,200), colorbar=:true)
        @test_reference(
            "references/heatmap/parameters_200x200_colorbar.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        seed!(1337)
        p = heatmap(randn(200, 200), title="Custom Title", zlabel="Custom Label", colorbar_border=:ascii)
        @test_reference(
            "references/spy/parameters_200x200_zlabel_ascii_border.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end
end
