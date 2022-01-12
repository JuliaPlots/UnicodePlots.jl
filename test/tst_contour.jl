exp_data() = begin
    # credit: matplotlib.org/stable/gallery/images_contours_and_fields/contour_demo.html
    δ = .025
    x = range(-3, 3; step=δ)
    y = range(-2, 3; step=δ)

    X = repeat(reshape(x, 1, :), length(y), 1)
    Y = repeat(y, 1, length(x))

    z = 2(exp.(-X.^2 - Y.^2) - exp.(-(X .- 1).^2 - (Y .- 1).^2))
    x, y, z
end

@testset "colormap" begin
    colormap = "cividis"
    p = @inferred contour(exp_data()...; colormap = Symbol(colormap))
    test_ref("references/contour/exp_$colormap.txt", @show_col(p, :displaysize=>T_SZ))
end

@testset "levels" begin
    levels = 5
    p = @inferred contour(exp_data()...; levels = levels)
    test_ref("references/contour/exp_$(levels)levels.txt", @show_col(p, :displaysize=>T_SZ))
end
