
@testset "reported issues" begin
    @testset "plot hang (tan → ∞) (#129)" begin
        p = lineplot([cos, sin, tan], -π/2, 2π)
        test_ref(
            "references/issues/cos_sin_tan.txt",
            @io2str(show(IOContext(::IO, :color=>true), p))
        )
    end

    @testset "integer edges (#139)" begin
        p_int = histogram(fit(Histogram, rand(10), 0:3))
        p_float = histogram(fit(Histogram, rand(10), 0.0:1.0:3.0))
        @test @io2str(print(IOContext(::IO, :color=>true), p_int)) ==
            @io2str(print(IOContext(::IO, :color=>true), p_float))
    end
end
