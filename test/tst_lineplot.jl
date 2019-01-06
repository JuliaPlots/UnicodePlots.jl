x = [-1, 1, 3, 3, -1]
y = [2, 0, -5, 2, -5]

@test_throws MethodError lineplot()
@test_throws MethodError lineplot(sin, x, y)
@test_throws DimensionMismatch lineplot([1,2], [1,2,3])
@test_throws DimensionMismatch lineplot([1,2,3], [1,2])
@test_throws DimensionMismatch lineplot([1,2,3], 1:2)
@test_throws DimensionMismatch lineplot(1:3, [1,2])
@test_throws DimensionMismatch lineplot(1:3, 1:2)

@testset "array types and scales" begin
    for p in (
            @inferred(lineplot(x, y)),
            @inferred(lineplot(float.(x), y)),
            @inferred(lineplot(x, float.(y))),
        )
        @test p isa Plot
        @test_reference(
            "references/lineplot/default.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    for p in (
            @inferred(lineplot(y)),
            @inferred(lineplot(float.(y))),
        )
        @test p isa Plot
        @test_reference(
            "references/lineplot/y_only.txt",
            @io2str(show(IOContext(::IO, :color=>true), p)),
            render = BeforeAfterFull()
        )
    end

    p = @inferred lineplot(6:10)
    @test p isa Plot
    @test_reference(
        "references/lineplot/range1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(11:15, 6:10)
    @test p isa Plot
    @test_reference(
        "references/lineplot/range2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )

    p = @inferred lineplot(x .* 1e3  .+ 15, y .* 1e-3 .- 15)
    @test_reference(
        "references/lineplot/scale1.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
    p = @inferred lineplot(x .* 1e-3 .+ 15, y .* 1e3  .- 15)
    @test_reference(
        "references/lineplot/scale2.txt",
        @io2str(show(IOContext(::IO, :color=>true), p)),
        render = BeforeAfterFull()
    )
end
