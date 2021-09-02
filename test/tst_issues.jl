
@testset "issues" begin
    # #129
    p = lineplot([cos, sin, tan], -π/2, 2π)
    test_ref(
        "references/issues/cos_sin_tan.txt",
        @io2str(show(IOContext(::IO, :color=>true), p))
    )
end
