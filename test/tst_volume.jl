import Rotations

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

@testset "volume" begin
    for proj in (:orthographic, :perspective)
        if proj === :orthographic
            el = atan(1 / √2)
            az = -π / 4
            l = -2.0
            r = +2.0
            b = -2.0
            t = +2.0
            n = l
            f = r
            P = Orthographic(l, r, b, t, n, f)
        else
            el = az = 0
            l = -1.0
            r = +1.0
            b = -1.0
            t = +1.0
            n = 1.0
            f = 100.0
            P = Perspective(l, r, b, t, n, f)
            P.A[1, 1] *= -1
            P.A[2, 2] *= -1
        end

        cam_rot = Rotations.RotXY(el, az)
        cam_pos = [0, 0, 0.5]

        M = UnicodePlots.rotate_4x4(cam_rot)
        V = lookat(cam_pos)

        T = MVP(M, V, P)

        cube_screen = [T.(segment) for segment in cube3d()]

        p = lineplot(
            UnicodePlots.segment2xy(cube_screen[1])...,
            xlim = (-1, 1),
            ylim = (-1, 1),
            grid = false,
            blend = false,
        )
        for s in cube_screen[2:end]
            lineplot!(p, UnicodePlots.segment2xy(s)...)
        end
        draw_axes!(p, T, [1, -0.5, 0])

        test_ref("references/volume/$proj.txt", @show_col(p))
    end
end
