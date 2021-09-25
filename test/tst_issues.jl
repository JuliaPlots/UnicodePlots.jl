@testset "reported issues" begin
    @testset "plot hang (tan → ∞) (#129)" begin
        p = lineplot([cos, sin, tan], -π/2, 2π)
        test_ref("references/issues/cos_sin_tan.txt", @show_col(p))
    end

    @testset "integer edges (#139)" begin
        p_int = histogram(fit(Histogram, rand(10), 0:3))
        p_float = histogram(fit(Histogram, rand(10), 0.0:1.0:3.0))
        @test @print_col(p_int) == @print_col(p_float)
    end

    @testset "barplot nl in text (#102)" begin
        p = barplot(["I need a\nbreak", "I don't but could", :Hello, :Again], [30, 40, 20, 10])
        test_ref("references/issues/barplot_nl.txt", @show_col(p))
    end
end
