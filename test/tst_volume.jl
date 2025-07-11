@testset "camera" begin
    # NOTE: the output of view_matrix uses the OpenGL convention:
    # x pointing to the east, y pointing to the north, z pointing out of the screen, towards the user
    # when our up vector = y (openGL default), V looks like I
    # up vector = :x -> cam_dir = :y
    # up vector = :y -> cam_dir = :z
    # up vector = :z -> cam_dir = :x
    V, dir = UnicodePlots.view_matrix([0, 0, 0], 1, 0, 0, :x)
    @test V ≈ [
        0 0 1 0
        1 0 0 0
        0 1 0 -1
        0 0 0 1
    ]
    @test dir == [0, 1, 0]
    V, dir = UnicodePlots.view_matrix([0, 0, 0], 1, 0, 0, :y)
    @test V ≈ [
        1 0 0 0
        0 1 0 0
        0 0 1 -1
        0 0 0 1
    ]
    @test dir == [0, 0, 1]
    V, dir = UnicodePlots.view_matrix([0, 0, 0], 1, 0, 0, :z)
    @test V ≈ [
        0 1 0 0
        0 0 1 0
        1 0 0 -1
        0 0 0 1
    ]
    @test dir == [1, 0, 0]

    @test_throws ArgumentError UnicodePlots.view_matrix([0, 0, 0], 1, 0, 0, :not_supported)

    @test UnicodePlots.scale_4x4([1, 1, 1]) ≈ I
    @test UnicodePlots.translate_4x4([0, 0, 0]) ≈ I
    @test UnicodePlots.rotd_x(0) ≈ I
    @test UnicodePlots.rotd_y(0) ≈ I
    @test UnicodePlots.rotd_z(0) ≈ I

    T = MVP([-1.0, 1.0], [-1.0, 1.0], [-1.0, 1.0])
    @test length(T([1, 2, 3], :user)) == 2
    @test length(T([1, 2, 3], :ortho)) == 2
    @test length(T([1, 2, 3], :persp)) == 2

    @test UnicodePlots.transform_matrix(T, :user) |> size == (4, 4)
    @test UnicodePlots.transform_matrix(T, :orthographic) |> size == (4, 4)
    @test UnicodePlots.transform_matrix(T, :perspective) |> size == (4, 4)

    @test UnicodePlots.is_ortho(T, :user)
    @test UnicodePlots.is_ortho(T, :orthographic)
    @test UnicodePlots.is_ortho(T, :ortho)
    @test !UnicodePlots.is_ortho(T, :perspective)
    @test !UnicodePlots.is_ortho(T, :persp)

    corners = UnicodePlots.cube_corners(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0)
    @test size(corners) == (3, 8)
    @test all(-1 .≤ corners .≤ 1)

    p = Plot([-1, 1], [-1, 1], [-1, 1]; projection = :ortho)
    @test p.projection.ortho
    p = Plot([-1, 1], [-1, 1], [-1, 1]; projection = :persp)
    @test !p.projection.ortho
end

@testset "azimuth / elevation" begin
    ellipsoid(θs = (-π / 2):(π / 10):(π / 2), ϕs = (-π):(π / 10):π, a = 2, b = 0.5, c = 1) =
        (
        [a * cos(θ) .* cos(ϕ) for (ϕ, θ) in Iterators.product(ϕs, θs)] |> vec,
        [b * cos(θ) .* sin(ϕ) for (ϕ, θ) in Iterators.product(ϕs, θs)] |> vec,
        [c * sin(θ) for (ϕ, θ) in Iterators.product(ϕs, θs)] |> vec,
    )

    x, y, z = ellipsoid()
    for (pl, azimuth, elevation) in [("yz", 0, 0), ("xz", -90, 0), ("xy", -90, 90)]
        p = Plot(x, y, z; title = "plane=$pl", projection = :ortho, elevation, azimuth)
        scatterplot!(p, x, y, z)

        test_ref("volume/ellipsoid_$pl.txt", @show_col(p))
    end
end

@testset "cube" begin
    for projection in (:ortho, :orthographic, :persp, :perspective)
        ortho = projection ∈ (:ortho, :orthographic)

        T = MVP(
            [-1, 1],
            [-1, 1],
            [-1, 1];
            projection,
            elevation = ortho ? UnicodePlots.KEYWORDS.elevation : 0,
            azimuth = ortho ? UnicodePlots.KEYWORDS.azimuth : 0,
        )
        @test T.ortho == ortho

        cube = (
            # near plane square
            [(-1, 1, 1), (1, 1, 1)],
            [(-1, -1, 1), (-1, 1, 1)],
            [(-1, -1, 1), (1, -1, 1)],
            [(1, -1, 1), (1, 1, 1)],
            # transversal edges
            [(1, 1, -1), (1, 1, 1)],
            [(-1, 1, -1), (-1, 1, 1)],
            [(-1, -1, -1), (-1, -1, 1)],
            [(1, -1, -1), (1, -1, 1)],
            # far plane square
            [(-1, 1, -1), (1, 1, -1)],
            [(-1, -1, -1), (-1, 1, -1)],
            [(-1, -1, -1), (1, -1, -1)],
            [(1, -1, -1), (1, 1, -1)],
        )

        segment2xyz(s) = [s[1][1], s[2][1]], [s[1][2], s[2][2]], [s[1][3], s[2][3]]

        p = lineplot(
            segment2xyz(first(cube))...,
            projection = T,
            title = "proj=$projection",
            axes3d = false,
        )
        for (i, s) in enumerate(cube)
            i == 1 && continue
            lineplot!(p, segment2xyz(s)...)
        end

        test_ref("volume/cube_$projection.txt", @show_col(p))
    end
end

@testset "zoom" begin
    for zoom in (0.5, 1, 2)
        T = MVP([-1, 1], [-1, 1], [-1, 1]; zoom)

        tetrahedron = (
            # 1st triangle
            [(0, 0, 0), (1, 0, 0)],
            [(1, 0, 0), (0, 0, 1)],
            [(0, 0, 1), (0, 0, 0)],
            # 2nd triangle
            [(0, 0, 0), (0, 1, 0)],
            [(0, 1, 0), (0, 0, 1)],
            [(0, 0, 1), (0, 0, 0)],
            # 3rd triangle
            [(1, 0, 0), (0, 1, 0)],
            [(0, 1, 0), (0, 0, 1)],
            [(0, 0, 1), (1, 0, 0)],
        )

        segments2xyz(segments) = (
            [p[1] for s in segments for p in s],
            [p[2] for s in segments for p in s],
            [p[3] for s in segments for p in s],
        )

        p = lineplot(
            segments2xyz(tetrahedron)...,
            projection = T,
            title = "zoom=$zoom",
            axes3d = false,
        )
        test_ref("volume/tetrahedron_$zoom.txt", @show_col(p))
    end
end
