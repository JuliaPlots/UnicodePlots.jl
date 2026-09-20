ring = GI.LinearRing([(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0), (0.0, 0.0)])
hole = GI.LinearRing([(3.0, 3.0), (6.0, 3.0), (6.0, 6.0), (3.0, 6.0), (3.0, 3.0)])
polygon = GI.Polygon([ring, hole])
triangle = GI.Polygon([GI.LinearRing([(11.0, 0.0), (20.0, 0.0), (20.0, 9.0), (11.0, 0.0)])])
features = GI.FeatureCollection(
    [
        GI.Feature(polygon; properties = (; pop = 1.0, continent = "north")),
        GI.Feature(triangle; properties = (; pop = 2.0, continent = "south")),
    ]
)

dots(p) = sum(c -> '⠀' ≤ c ≤ '⣿' ? count_ones(c - '⠀') : 0, @print_nocol(p))

@testset "geometries" begin
    p = geoplot(polygon; name = "polygon", title = "geometries")
    geoplot!(p, GI.LineString([(1.0, 9.0), (9.0, 1.0)]); name = "line")
    geoplot!(p, GI.MultiPoint([(2.0, 2.0), (8.0, 8.0)]); name = "points", color = :red)
    @test p.series[] == 3
    test_ref("geoplot/geometries.txt", @show_col(p))
end

@testset "vector of geometries" begin
    p = geoplot([polygon, missing])
    @test p.series[] == 1
    @test @print_nocol(p) == @print_nocol(geoplot(polygon))  # `missing` is skipped
end

@testset "fill" begin
    @test dots(geoplot(polygon; fill = 1)) >
        dots(geoplot(polygon; fill = true)) >
        dots(geoplot(polygon; fill = false))
    @test_throws ArgumentError geoplot(polygon; fill = -1)
end

@testset "numeric feature property" begin
    p = geoplot(features; color = "pop", colormap = :viridis, name = "pop")
    @test p.cmap.bar
    @test p.cmap.lim == (1.0, 2.0)
    test_ref("geoplot/numeric.txt", @show_col(p))

    @test geoplot(features; color = "pop", zlim = (0, 10)).cmap.lim == (0, 10)
end

@testset "categorical feature property" begin
    p = geoplot(features; color = "continent")
    @test !p.cmap.bar
    @test p.labels_right[1] == "north"
    @test p.labels_right[2] == "south"
    test_ref("geoplot/categorical.txt", @show_col(p))
end

@testset "color vector" begin
    p = geoplot(features; color = [:red, :blue])
    @test @print_nocol(p) == @print_nocol(geoplot(features; color = :red))
    @test_throws ArgumentError geoplot(features; color = [:red])
end
