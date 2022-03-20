@testset "aspect ratio" begin
    for i in 1:minimum(T_SZ)
        @test heatmap(rand(i, i)).graphics.grid |> size == (i, i)
    end
    seed!(RNG, 1337)
    p = @hinf heatmap(collect(1:30) * collect(1:30)', fix_ar = true)
    test_ref("heatmap/fix_aspect_ratio_30x30.txt", @show_col(p, :displaysize => T_SZ))
end

@testset "sizing" begin
    for dims in (
        (0, 0),
        (1, 1),
        (2, 1),
        (1, 2),
        (2, 2),
        (3, 6),
        (6, 3),
        (9, 4),
        (4, 9),
        (5, 0),
        (0, 5),
        (5, 1),
        (1, 5),
        (10, 0),
        (0, 10),
        (6, 8),
        (8, 6),
        (10, 10),
        (10, 15),
        (15, 10),
        (2000, 200),
        (200, 2000),
        (2000, 2000),
    )
        seed!(RNG, 1337)
        p = @hinf heatmap(randn(RNG, dims))
        @test p isa Plot
        test_ref(
            "heatmap/default_$(dims[1])x$(dims[2]).txt",
            @show_col(p, :displaysize => T_SZ)
        )
    end
end

@testset "axis scaling" begin
    x = repeat(collect(0:10), outer = (1, 11))
    p = @hinf heatmap(x, xfact = 0.1)
    test_ref(
        "heatmap/scaling_$(size(x, 1))x$(size(x, 2))_xfact_0.1.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xfact = 0.1, xoffset = -0.5)
    test_ref(
        "heatmap/scaling_$(size(x, 1))x$(size(x, 2))_xfact_0.1_xoffset-0.5.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, yfact = 0.1)
    test_ref(
        "heatmap/scaling_$(size(x, 1))x$(size(x, 2))_yfact_0.1.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, yfact = 0.1, yoffset = -0.5)
    test_ref(
        "heatmap/scaling_$(size(x, 1))x$(size(x, 2))_yfact_0.1_yoffset-0.5.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xfact = 0.1, xoffset = -0.5, yfact = 10, yoffset = -50)
    test_ref(
        "heatmap/scaling_$(size(x, 1))x$(size(x, 2))_xfact_0.1_xoffset-0.5_yfact_10_yoffset_-50.txt",
        @show_col(p, :displaysize => T_SZ)
    )
end

@testset "integer values" begin
    x = repeat(collect(1:20), outer = (1, 20))
    p = @hinf heatmap(x)
    test_ref(
        "heatmap/integers_$(size(x, 1))x$(size(x, 2)).txt",
        @show_col(p, :displaysize => T_SZ)
    )
end

@testset "color maps" begin
    x = collect(0:30) * collect(0:30)'
    for cmap in keys(UnicodePlots.COLOR_MAP_DATA)
        p = @hinf heatmap(x, colormap = cmap)
        test_ref(
            "heatmap/colormap_$(size(x, 1))x$(size(x, 2))_$cmap.txt",
            @show_col(p, :displaysize => T_SZ)
        )
    end
    p = @hinf heatmap(x, colormap = reverse(UnicodePlots.COLOR_MAP_DATA[:viridis]))
    test_ref(
        "heatmap/colormap_$(size(x, 1))x$(size(x, 2))_reverse_viridis.txt",
        @show_col(p, :displaysize => T_SZ)
    )

    seed!(RNG, 1337)
    rgb = rand(RNG, 20, 20, 3)
    img = RGB.(rgb[:, :, 1], rgb[:, :, 2], rgb[:, :, 3])
    p = @hinf heatmap(img)  # RGB Matrix
    test_ref("heatmap/rgb.txt", @show_col(p, :displaysize => T_SZ))
end

@testset "axis limits" begin
    x = collect(0:30) * collect(0:30)'
    p = @hinf heatmap(x, ylim = [10, 20])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_ylim_10_20.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, ylim = [50, 50])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_ylim_50_50.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [10, 20])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xlim_10_20.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [50, 50])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xlim_50_50.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [10, 20], ylim = [10, 20])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xlim_10_20_ylim_10_20.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [0, 0.1], xfact = 0.01)
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xfact_0.01_xlim_0_0.1.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, ylim = [0, 0.1], yfact = 0.01)
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_yfact_0.01_ylim_0_0.1.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [0, 0.1], xfact = 0.01, ylim = [0.1, 0.2], yfact = 0.01)
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xfact_0.01_xlim_0_0.1_yfact_0.01_ylim_0.1_0.2.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, ylim = [1, 50])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_ylim_1_50.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [1, 50])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xlim_1_50.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    p = @hinf heatmap(x, xlim = [1, 50], ylim = [1, 50])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_xlim_1_50_ylim_1_50.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    zmax = 2 * maximum(x)
    p = @hinf heatmap(x, zlim = [0, zmax])
    test_ref(
        "heatmap/limits_$(size(x, 1))x$(size(x, 2))_zlim_0_$zmax.txt",
        @show_col(p, :displaysize => T_SZ)
    )
end

@testset "all zero values" begin
    x = zeros(20, 20)
    p = @hinf heatmap(x)
    test_ref(
        "heatmap/zeros_$(size(x, 1))x$(size(x, 2)).txt",
        @show_col(p, :displaysize => T_SZ)
    )
end

@testset "parameters" begin
    seed!(RNG, 1337)
    p = @hinf heatmap(randn(RNG, 200, 200), colorbar = false)
    test_ref(
        "heatmap/parameters_200x200_no_colorbar.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    seed!(RNG, 1337)
    p = @hinf heatmap(randn(RNG, 200, 200), labels = false)
    test_ref("heatmap/parameters_200x200_no_labels.txt", @show_col(p, :displaysize => T_SZ))
    seed!(RNG, 1337)
    p = heatmap(
        randn(RNG, 200, 200),
        title = "Custom Title",
        zlabel = "Custom Label",
        colorbar_border = :ascii,
        colormap = :inferno,
    )
    test_ref(
        "heatmap/parameters_200x200_zlabel_ascii_border.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    seed!(RNG, 1337)
    p = @hinf heatmap(randn(RNG, 10, 10), xfact = 0.1, colormap = :inferno)
    test_ref(
        "heatmap/parameters_10x10_xfact_inferno.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    seed!(RNG, 1337)
    p = @hinf heatmap(randn(RNG, 10, 11), xfact = 0.1, colormap = :inferno)
    test_ref(
        "heatmap/parameters_10x11_xfact_inferno.txt",
        @show_col(p, :displaysize => T_SZ)
    )
    seed!(RNG, 1337)
    p = @hinf heatmap(randn(RNG, 10, 10), yfact = 1, colormap = :inferno)
    test_ref(
        "heatmap/parameters_10x10_yfact_inferno.txt",
        @show_col(p, :displaysize => T_SZ)
    )
end

@testset "squareness (aspect ratio)" begin
    seed!(RNG, 1337)
    for m in 1:minimum(T_SZ)
        p = @hinf heatmap(randn(RNG, m, m))
        @test size(p.graphics.grid) == (m, m)
    end
    for m in minimum(T_SZ):maximum(T_SZ)
        p = @hinf heatmap(randn(RNG, m, m))
        s1, s2 = size(p.graphics.grid)
        @test s1 == s2
    end
end
