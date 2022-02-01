cube3d() = [
    [(-1, 1, 1), (1, 1, 1)],
    [(-1, -1, 1), (-1, 1, 1)],
    [(-1, -1, 1), (1, -1, 1)],
    [(1, -1, 1), (1, 1, 1)],
    [(1, 1, -1), (1, 1, 1)],
    [(-1, 1, -1), (-1, 1, 1)],
    [(-1, -1, -1), (-1, -1, 1)],
    [(1, -1, -1), (1, -1, 1)],
    [(-1, 1, -1), (1, 1, -1)],
    [(-1, -1, -1), (-1, 1, -1)],
    [(-1, -1, -1), (1, -1, -1)],
    [(1, -1, -1), (1, 1, -1)],
]

segment2xyz(s) = [s[1][1], s[2][1]], [s[1][2], s[2][2]], [s[1][3], s[2][3]]

ellipsoid(θs = (-π / 2):(π / 10):(π / 2), ϕs = (-π):(π / 10):π, a = 2, b = 0.5, c = 1) = (
    [a * cos(θ) .* cos(ϕ) for (ϕ, θ) in Iterators.product(ϕs, θs)] |> vec,
    [b * cos(θ) .* sin(ϕ) for (ϕ, θ) in Iterators.product(ϕs, θs)] |> vec,
    [c * sin(θ) for (ϕ, θ) in Iterators.product(ϕs, θs)] |> vec,
)

@testset "volume" begin
    x, y, z = ellipsoid()
    for (plane, az, el) in [("yz", 0, 0), ("xz", -90, 0), ("xy", -90, 90)]
        p = Plot(
            x,
            y,
            z,
            xlim = (-1, 1),
            ylim = (-1, 1),
            transform = :orthographic,
            elevation = el,
            azimuth = az,
        )
        scatterplot!(p, x, y, z)
        draw_axes!(p, [-0.8, -0.8])

        test_ref("references/volume/ellipsoid_$plane.txt", @show_col(p))
    end

    for proj in (:orthographic, :perspective)
        ortho = proj === :orthographic

        T = MVP(
            [-1, 1],
            [-1, 1],
            [-1, 1];
            projection = proj,
            elevation = ortho ? atand(1 / √2) : 0,
            azimuth = ortho ? 45 : 0,
        )
        @test T.ortho == ortho

        segments = cube3d()
        p = lineplot(
            segment2xyz(segments[1])...,
            transform = T,
            xlim = (-1, 1),
            ylim = (-1, 1),
        )
        for s in segments[2:end]
            lineplot!(p, segment2xyz(s)...)
        end
        draw_axes!(p, ortho ? [-0.8, -0.8] : [1, -0.5, 0])

        test_ref("references/volume/cube_$proj.txt", @show_col(p))
    end
end
