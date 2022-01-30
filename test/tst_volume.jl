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

ellipsoid(θs = -π / 2:π / 10:π / 2, ϕs = -π:π / 20:π, a = 4, b = 2, c = .25) = (
    [a * cos(θ) .* cos(ϕ) for (ϕ, θ) = Iterators.product(ϕs, θs)] |> vec,
    [b * cos(θ) .* sin(ϕ) for (ϕ, θ) = Iterators.product(ϕs, θs)] |> vec,
    [c * sin(θ) for (ϕ, θ) = Iterators.product(ϕs, θs)] |> vec,
)

@testset "volume" begin
    x, y, z = ellipsoid()
    p = Plot(x, y, z, xlim = (-1, 1), ylim = (-1, 1), transform = :orthographic)
    scatterplot!(p, ellipsoid()...)
    draw_axes!(p, [-.7, -.7], 2)

    test_ref("references/volume/ellipsoid.txt", @show_col(p))

    for proj in (:orthographic, :perspective)
        ortho = proj === :orthographic

        T = MVP(
            projection = proj,
            elevation = ortho ? atand(1 / √2) : 0,
            azimuth = ortho ? -45 : 0
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
        draw_axes!(p, [1, -0.5, 0])

        test_ref("references/volume/cube_$proj.txt", @show_col(p))
    end
end
