translate_4x4(v) = @SMatrix([
    1 0 0 v[1]
    0 1 0 v[2]
    0 0 1 v[3]
    0 0 0 1
])

scale_4x4(v) = @SMatrix([
    v[1] 0 0 0
    0 v[2] 0 0
    0 0 v[3] 0
    0 0 0 1
])

rotd_x(θ) = @SMatrix([
    1 0 0 0
    0 cosd(θ) -sind(θ) 0
    0 sind(θ) +cosd(θ) 0
    0 0 0 1
])

rotd_y(θ) = @SMatrix([
    +cosd(θ) 0 sind(θ) 0
    0 1 0 0
    -sind(θ) 0 cosd(θ) 0
    0 0 0 1
])

rotd_z(θ) = @SMatrix([
    cosd(θ) -sind(θ) 0 0
    sind(θ) +cosd(θ) 0 0
    0 0 1 0
    0 0 0 1
])

"""
    lookat(eye, target, up_vector)

# Description

Computes the scene camera (see songho.ca/opengl/gl_camera.html).

# Arguments

    - `eye`: position of the camera in world space (e.g. [0, 0, 10]).
    - `target`: target point to look at in world space (usually to origin = [0, 0, 0]).
    - `up_vector`: up vector (usually +z = [0, 0, 1]).
"""
function lookat(eye, target = [0, 0, 0], up_vector = [0, 0, 1])
    f = normalize(eye - target)  # forward vector
    l = normalize(cross(up_vector, f))  # left vector
    u = cross(f, l)  # up vector

    @SMatrix(
        [
            l[1] l[2] l[3] -dot(l, eye)
            u[1] u[2] u[3] -dot(u, eye)
            f[1] f[2] f[3] -dot(f, eye)
            0 0 0 1
        ]
    ),
    f
end

"""
    frustum(l, r, b, t, n, f)

# Description

Computes the perspective projection matrix (see songho.ca/opengl/gl_projectionmatrix.html#perspective).

# Arguments

    - `l`: left coordinate of the vertical clipping plane.
    - `r` : right coordinate of the vertical clipping plane.
    - `b`: bottom coordinate of the horizontal clipping plane.
    - `t`: top coordinate of the horizontal clipping plane.
    - `n`: distance to the near depth clipping plane.
    - `f`: distance to the far depth clipping plane.
"""
function frustum(l, r, b, t, n, f)
    @assert n > 0 && f > 0
    *(
        @SMatrix([  # scale
            2n/(r - l) 0 0 0
            0 2n/(t - b) 0 0
            0 0 1 0
            0 0 0 1
        ]),
        @SMatrix([  # translate
            1 0 0 (l + r)/2n
            0 1 0 (b + t)/2n
            0 0 1 0
            0 0 0 1
        ]),
        @SMatrix([  # perspective
            -1 0 0 0  # flip x
            0 -1 0 0  # flip y
            0 0 (f + n)/(f - n) -2f * n/(f - n)
            0 0 1 0
        ]),
    )
end

"""
    ortho(l, r, b, t, n, f)

# Description

Computes the orthographic projection matrix (see songho.ca/opengl/gl_projectionmatrix.html#ortho).

# Arguments

    - `l`: left coordinate of the vertical clipping plane.
    - `r` : right coordinate of the vertical clipping plane.
    - `b`: bottom coordinate of the horizontal clipping plane.
    - `t`: top coordinate of the horizontal clipping plane.
    - `n`: distance to the near depth clipping plane.
    - `f`: distance to the far depth clipping plane.
"""
ortho(l, r, b, t, n, f) = *(
    @SMatrix([  # scale
        2/(r - l) 0 0 0
        0 2/(t - b) 0 0
        0 0 2/(f - n) 0
        0 0 0 1
    ]),
    @SMatrix([  # translate
        1 0 0 -(l + r)/2
        0 1 0 -(b + t)/2
        0 0 1 -(n + f)/2
        0 0 0 1
    ]),
)

abstract type Projection end

struct Orthographic{T} <: Projection where {T}
    A::SMatrix{4,4,T}
    Orthographic(args::T...) where {T} = new{float(T)}(ortho(args...))
end

struct Perspective{T} <: Projection where {T}
    A::SMatrix{4,4,T}
    Perspective(args::T...) where {T} = new{float(T)}(frustum(args...))
end

(t::Projection)(p::AbstractVecOrMat) = t.A * p

"""
    ctr_len_diag(x, y, z)

# Description

Computes data center, minimum and maximum points, and cube diagonal.
"""
function ctr_len_diag(x, y, z)
    mx, Mx = NaNMath.extrema(as_float(x))
    my, My = NaNMath.extrema(as_float(y))
    mz, Mz = NaNMath.extrema(as_float(z))

    lx = Mx - mx
    ly = My - my
    lz = Mz - mz

    (
        @SVector([mx + 0.5lx, my + 0.5ly, mz + 0.5lz]),
        @SVector([mx, my, mz]),
        @SVector([Mx, My, Mz]),
        @SVector([lx, ly, lz]),
        √(lx^2 + ly^2 + lz^2),
    )
end

cube_corners(mx, Mx, my, My, mz, Mz) = [
    mx mx mx mx Mx Mx Mx Mx
    my my My My my my My My
    mx Mz mx Mz mx Mz mx Mz
]

function view_matrix(center, distance, elevation, azimuth, up)
    up_str = string(up)
    shift = if (up_axis = Symbol(up_str[end])) === :x
        0
    elseif up_axis === :y
        1
    elseif up_axis === :z
        2
    else
        throw(ArgumentError("up=$up not understood"))
    end
    # we support :x -> +x, :px -> +x or :mx -> -x
    up_vector = circshift(
        [
            length(up_str) == 1 ? 1 : (p = +1, m = -1)[Symbol(up_str[1])]
            0
            0
        ],
        shift,
    )
    cam_move = circshift(
        distance .* [
            sind(elevation)
            cosd(azimuth) * cosd(elevation)
            sind(azimuth) * cosd(elevation)
        ],
        shift,
    )
    lookat(center .+ cam_move, center, up_vector)
end

"""
    MVP(x, y, z; $(keywords(; default = (), add = (:x, :y, :z, :projection, :elevation, :azimuth, :zoom, :up))))

# Description

Build up the "Model - View - Projection" transformation matrix (see codinglabs.net/article_world_view_projection_matrix.aspx).

This is typically used to adjust how 3D plot is viewed, see also
the `projection` keyword in [`surfaceplot`](@ref), [`isosurface`](@ref).
"""
struct MVP{T}
    mvp_mat::SMatrix{4,4,T}
    mvp_ortho_mat::SMatrix{4,4,T}
    mvp_persp_mat::SMatrix{4,4,T}
    view_dir::SVector{3,T}
    dist::T
    ortho::Bool
    function MVP(
        x,
        y,
        z;
        projection = KEYWORDS.projection,
        elevation = KEYWORDS.elevation,
        azimuth = KEYWORDS.azimuth,
        zoom = KEYWORDS.zoom,
        near = KEYWORDS.near,
        far = KEYWORDS.far,
        up = KEYWORDS.up,
    )
        @assert projection ∈ (:orthographic, :perspective)
        @assert -180 ≤ azimuth ≤ 180
        @assert -90 ≤ elevation ≤ 90

        F = float(eltype(x))
        ortho = projection === :orthographic
        ctr, mini, maxi, len, diag = ctr_len_diag(x, y, z)

        # half the diagonal (cam distance to the center)
        disto = dist = (diag / 2) / zoom
        distp = disto / 2

        # avoid `NaN`s in `V` when `elevation` is close to ±90
        δ = 100eps()
        elev = max(-90 + δ, min(elevation, 90 - δ))

        # Model Matrix
        M = I  # we don't scale, nor translate, nor rotate input data

        # View Matrix
        V_ortho, view_dir = view_matrix(ctr, disto, elev, azimuth, up)
        V_persp, view_dir = view_matrix(ctr, distp, elev, azimuth, up)
        V = ortho ? V_ortho : V_persp

        # Projection Matrix
        P_ortho = Orthographic(-disto, disto, -disto, disto, -disto, disto)
        P_persp = Perspective(-distp, distp, -distp, distp, near, far)
        P = ortho ? P_ortho : P_persp

        new{F}(P(V * M), P_ortho(V_ortho * M), P_persp(V_persp * M), view_dir, dist, ortho)
    end
end

transform_matrix(t::MVP, n::Symbol) =
    (user = t.mvp_mat, orthographic = t.mvp_ortho_mat, perspective = t.mvp_persp_mat)[n]

is_ortho(t::MVP, n::Symbol) = (user = t.ortho, orthographic = true, perspective = false)[n]

function (t::MVP{T})(p::AbstractMatrix, n::Symbol = :user) where {T}
    # homogeneous coordinates
    dat = transform_matrix(t, n) * (size(p, 1) == 4 ? p : vcat(p, ones(1, size(p, 2))))
    xs, ys, zs, ws = dat[1, :], dat[2, :], dat[3, :], dat[4, :]
    @inbounds for (i, w) in enumerate(ws)
        if abs(w) > eps(T)
            xs[i] /= w
            ys[i] /= w
            zs[i] /= w
        end
    end
    is_ortho(t, n) ? (xs, ys) : (xs ./ zs, ys ./ zs)
end

function (t::MVP{T})(v::Union{AbstractVector,NTuple{3}}, n::Symbol = :user) where {T}
    # homogeneous coordinates
    x, y, z, w = transform_matrix(t, n) * [v..., 1]
    if abs(w) > eps(T)
        x /= w
        y /= w
        z /= w
    end
    is_ortho(t, n) ? (x, y) : (x / z, y / z)
end

"""
    draw_axes!(plot; p = [0, 0, 0], len = nothing)

# Description

Draws (X, Y, Z) cartesian coordinates axes in (R, G, B) colors, at position `p = (x, y, z)`.
If `p = (x, y)` is given, draws at screen coordinates.
"""
function draw_axes!(plot, p = [0, 0, 0], len = nothing, scale = 0.25)
    T = plot.projection
    # constant apparent size
    l = len === nothing ? scale .* @SVector([T.dist, T.dist, T.dist]) : len

    proj = :orthographic  # force axes projection

    pos = if length(p) == 2
        (transform_matrix(T, proj) \ vcat(p, 0, 1))[1:3]
    else
        p
    end

    axis(p, d) = begin
        e = copy(p)
        e[d] += l[d]
        T(hcat(p, e), proj)
    end

    lines!(plot.graphics, axis(float(pos), 1)..., color = :red)
    lines!(plot.graphics, axis(float(pos), 2)..., color = :green)
    lines!(plot.graphics, axis(float(pos), 3)..., color = :blue)

    plot
end
