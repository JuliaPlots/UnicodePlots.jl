@testset "reported issues" begin
    @testset "barplot nl in text (#102)" begin
        p = barplot(
            ["I need a\nbreak", "I don't but could", :Hello, :Again],
            [30, 40, 20, 10],
        )
        test_ref("issues/barplot_nl.txt", @show_col(p))
    end

    @testset "plot hang (tan → ∞) (#129)" begin
        p = lineplot(-π / 2, 2π, [cos, sin, tan])
        test_ref("issues/cos_sin_tan.txt", @show_col(p))
    end

    @testset "integer edges (#139)" begin
        p_int = horizontal_histogram(fit(Histogram, rand(10), 0:3))
        p_float = horizontal_histogram(fit(Histogram, rand(10), 0.0:1.0:3.0))
        @test @print_col(p_int) == @print_col(p_float)
    end

    @testset "isolated colorbar (#169)" begin
        p = Plot(
            [0],
            [0],
            colorbar = true,
            colormap = :cividis,
            width = -1,
            margin = 0,
            padding = 0,
        )
        test_ref("issues/isolated_colorbar.txt", @show_col(p))
    end

    @testset "steps (#211)" begin
        x = 1:5
        y = [1.0, 2.0, 3.0, 2.0, 1.0]
        p = scatterplot(x, y, marker = :circle)
        x = [1.0, 1.0, 2.0, 2.0, 3.0, 3.0, 4.0, 4.0, 5.0]
        y = [1.0, 2.0, 2.0, 3.0, 3.0, 2.0, 2.0, 1.0, 1.0]
        p = lineplot!(p, x, y)
        test_ref("issues/steps.txt", @show_col(p))
    end

    @testset "signed zero (#229)" begin
        p = histogram([-1.0, -0.0, 1.0])
        test_ref("issues/signed_zero.txt", @show_col(p))
    end

    @testset "grid log scale (#265)" begin
        @test lineplot(0.01:10, 0.01:10, xscale = :log10, yscale = :log10) isa Plot
    end

    @testset "float input (#277)" begin
        for FX ∈ (Float16, Float32, Float64), FY ∈ (Float16, Float32, Float64)
            @test lineplot(FX[-1, 2], FY[-1, 9]) isa Plot
        end
        @test barplot(["Paris", "Madrid"], Float32[2.2, 8.4]; maximum = 10.0f0) isa Plot
    end

    @testset "invalid data (#297)" begin
        @test_logs (:warn, "Invalid plotting range") lineplot([
            nextfloat(-Inf),
            prevfloat(+Inf),
        ]) isa Plot
        @test lineplot([nextfloat(-Inf32), prevfloat(+Inf32)]) isa Plot
        @test lineplot([nextfloat(-Inf16), prevfloat(+Inf16)]) isa Plot
    end

    @testset "NaNs in heatmap (#321)" begin
        A = Array(1.0 * I, 5, 5)
        A[begin, begin] = A[end, end] = NaN
        p = heatmap(A; colorbar = true)
        test_ref("issues/heatmap_nans.txt", @show_col(p))

        p = heatmap(fill(NaN, 5, 5); colorbar = true)
        test_ref("issues/heatmap_all_nans.txt", @show_col(p))

        # while resolving #321, a bug in printing the last row was observed
        A = Array(1.0 * I, 4, 4)
        p = heatmap(A; array = true)
        test_ref("issues/heatmap_identity_array.txt", @show_col(p))

        p = heatmap(A)
        test_ref("issues/heatmap_identity.txt", @show_col(p))
    end

    @testset "Unitful mix units, lims (#321)" begin
        x = 1:3
        y = @. 2x * u"s"
        ylim = (0u"s", 8u"s")

        p = lineplot(x, y; ylim)
        show(devnull, p)

        p = scatterplot(x, y; ylim)
        show(devnull, p)
    end
end
