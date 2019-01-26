@testset "default" begin
    p = @inferred boxplot([1,2,3,4,5])
    @test_reference(
        "references/boxplot/default.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred boxplot("series1", [1,2,3,4,5])
    @test_reference(
        "references/boxplot/default_name.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred boxplot("series1", [1,2,3,4,5], title = "Test", xlim = (-1,8), color = :blue, width = 50, border = :solid, xlabel="foo")
    @test_reference(
        "references/boxplot/default_parameters.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred boxplot("series1", [1,2,3,4,5], title = "Test", xlim = [-1,8], color = :blue, width = 50, border = :solid, xlabel="foo")
    @test_reference(
        "references/boxplot/default_parameters.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test_reference(
        "references/boxplot/default_parameters_nocolor.txt",
        @io2str(show(IOContext(::IO, :color=>false), p)),
        render = BeforeAfterFull()
    )
end

@testset "scaling" begin
    for (i, max_x) in enumerate([5,6,10,20,40])
        p = @inferred boxplot([1,2,3,4,5], xlim=(0,max_x))
        @test_reference(
            "references/boxplot/scale$i.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
        p = @inferred boxplot([1,2,3,4,5], xlim=[0,max_x])
        @test_reference(
            "references/boxplot/scale$i.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end
end

@testset "multi-series" begin
    p = @inferred boxplot(["one", "two"], [[1,2,3,4,5], [2,3,4,5,6,7,8,9]], title="Multi-series", xlabel="foo", color=:yellow)
    @test_reference(
        "references/boxplot/multi1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(boxplot!(p, "one more", [-1,2,3,4,11])) === p
    @test_reference(
        "references/boxplot/multi2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    @test @inferred(boxplot!(p, [4,2,2.5,4,14], name = "last one")) === p
    @test_reference(
        "references/boxplot/multi3.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end
