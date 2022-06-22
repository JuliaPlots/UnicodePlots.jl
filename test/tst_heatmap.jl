@testset "aspect ratio" begin
    seed!(RNG, 1337)
    for i in 1:minimum(T_SZ)
        @test heatmap(rand(i, i)).graphics.grid |> size == (i, i)
    end
    p = @hinf heatmap(collect(1:30) * collect(1:30)', fix_ar = true)
    test_ref("heatmap/fix_aspect_ratio_30x30.txt", @show_col(p, :displaysize => T_SZ))
end

@testset "integer values" begin
    x = repeat(collect(1:20), outer = (1, 20))
    p = @hinf heatmap(x)
    test_ref(
        "heatmap/integers_$(size(x, 1))x$(size(x, 2)).txt",
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

@testset "color maps" begin
    x = collect(0:30) * collect(0:30)'

    for cmap in keys(UnicodePlots.COLOR_MAP_DATA)
        p = @hinf heatmap(x, colormap = cmap)
        test_ref(
            "heatmap/colormap_$(size(x, 1))x$(size(x, 2))_$cmap.txt",
            @show_col(p, :displaysize => T_SZ)
        )
    end

    p = @hinf heatmap(x, colormap = reverse(UnicodePlots.COLOR_MAP_DATA[:jet]))
    test_ref(
        "heatmap/colormap_$(size(x, 1))x$(size(x, 2))_reverse_jet.txt",
        @show_col(p, :displaysize => T_SZ)
    )

    seed!(RNG, 1337)
    rgb = rand(RNG, 20, 20, 3)
    img = RGB.(rgb[:, :, 1], rgb[:, :, 2], rgb[:, :, 3])
    p = @hinf heatmap(img)  # RGB Matrix
    test_ref("heatmap/colormap_rgb.txt", @show_col(p, :displaysize => T_SZ))
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

@testset "matrix display convention" begin
    p = @hinf heatmap(collect(1:20) * collect(1:20)', matrix = true, fix_ar = true)
    test_ref("heatmap/matrix_convention.txt", @show_col(p, :displaysize => T_SZ))
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

kw2str(kw) = replace(
    replace(join(("$(k)_$(v)" for (k, v) in pairs(kw)), '_'), r"[\[\]\(\),]" => ""),
    ' ' => '_',
)

@testset "axis scaling" begin
    x = repeat(collect(0:10), outer = (1, 11))

    for kw in (
        (; xfact = 0.1),
        (; yfact = 0.1),
        (; xfact = 0.1, xoffset = -0.5),
        (; yfact = 0.1, yoffset = -0.5),
        (; xfact = 0.1, xoffset = -0.5, yfact = 10, yoffset = -50),
    )
        p = @hinf heatmap(x; kw...)
        test_ref(
            "heatmap/scaling_$(size(x, 1))x$(size(x, 2))_$(kw2str(kw)).txt",
            @show_col(p, :displaysize => T_SZ)
        )
    end
end

@testset "axis limits" begin
    x = collect(0:30) * collect(0:30)'

    for kw in (
        (; ylim = (10, 20)),
        (; ylim = (50, 50)),
        (; ylim = (1, 50)),
        (; xlim = (10, 20)),
        (; xlim = (50, 50)),
        (; xlim = (1, 50)),
        (; xlim = (10, 20), ylim = (10, 20)),
        (; xlim = (1, 50), ylim = (1, 50)),
        (; xlim = (0, 0.1), xfact = 0.01),
        (; ylim = (0, 0.1), yfact = 0.01),
        (; xlim = (0, 0.1), xfact = 0.01, ylim = (0.1, 0.2), yfact = 0.01),
        (; zlim = (0, 2maximum(x))),
    )
        p = @hinf heatmap(x; kw...)
        test_ref(
            "heatmap/limits_$(size(x, 1))x$(size(x, 2))_$(kw2str(kw)).txt",
            @show_col(p, :displaysize => T_SZ)
        )
    end
end

@testset "parameters" begin
    seed!(RNG, 1337)
    x = randn(RNG, 200, 200)
    for kw in (
        (; colorbar = false),
        (; labels = false),
        (; title = "hmap", zlabel = "lab", colorbar_border = :ascii, colormap = :inferno),
    )
        p = @hinf heatmap(x; kw...)
        test_ref(
            "heatmap/parameters_$(size(x, 1))x$(size(x, 2))_$(kw2str(kw)).txt",
            @show_col(p, :displaysize => T_SZ)
        )
    end

    for sz in ((10, 10), (10, 11))
        seed!(RNG, 1337)
        x = randn(RNG, sz...)
        for kw in ((; xfact = 0.1, colormap = :cividis), (; yfact = 1, colormap = :cividis))
            p = @hinf heatmap(x; kw...)
            test_ref(
                "heatmap/parameters_$(size(x, 1))x$(size(x, 2))_$(kw2str(kw)).txt",
                @show_col(p, :displaysize => T_SZ)
            )
        end
    end
end
