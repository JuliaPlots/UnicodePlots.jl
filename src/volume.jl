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
    0 0 0 s1
])

camera_4x4(l, u, f, eye) = @SMatrix([
    l[1] l[2] l[3] -dot(l, eye)
    u[1] u[2] u[3] -dot(u, eye)
    f[1] f[2] f[3] -dot(f, eye)
    0 0 0 1
])

"""
    lookat(args...; kwargs...)

# Arguments
    - `eye`: position of the camera in world space (e.g. [0, 0, 10])
    - `target`: target point to look at in world space (usually to origin = [0, 0, 0])
    - `up`: up vector (usually +y = [0, 1, 0])
"""
function lookat(eye, target = [0, 0, 0], up = [0, 1, 0])
    f = normalize(eye - target)  # forward vector.
    l = normalize(cross(up, f))  # left vector
    u = cross(f, l)  # up vector

    camera_4x4(l, u, f, eye)
end

"""
    frustum(args...; kwargs...)

# Description

Computes the perspective projection matrix.

# Arguments
    - `l`: left coordinate of the vertical clipping plane
    - `r` : right coordinate of the vertical clipping plane
    - `b`: bottom coordinate of the horizontal clipping plane
    - `t`: top coordinate of the horizontal clipping plane
    - `n`: distance to the near depth clipping plane
    - `f`: distance to the far depth clipping plane
"""
function frustum(l, r, b, t, n, f)
    @assert n > 0 && f > 0
    *(
        @SMatrix([
            2n/(r - l) 0 0 0
            0 2n/(t - b) 0 0
            0 0 1 0
            0 0 0 1
        ]),
        @SMatrix([
            1 0 0 (r + l)/2n
            0 1 0 (t + b)/2n
            0 0 1 0
            0 0 0 1
        ]),
        @SMatrix([
            1 0 0 0
            0 1 0 0
            0 0 (f + n)/(f - n) -2f * n/(f - n)
            0 0 1 0
        ]),
    )
end

"""
    ortho(args...; kwargs...)

# Description

Computes the orthographic projection matrix.

# Arguments
    - `l`: left coordinate of the vertical clipping plane
    - `r` : right coordinate of the vertical clipping plane
    - `b`: bottom coordinate of the horizontal clipping plane
    - `t`: top coordinate of the horizontal clipping plane
    - `n`: distance to the near depth clipping plane
    - `f`: distance to the far depth clipping plane
"""
ortho(l, r, b, t, n, f) = *(
    @SMatrix([
        2/(r - l) 0 0 0
        0 2/(t - b) 0 0
        0 0 2/(f - n) 0
        0 0 0 1
    ]),
    @SMatrix([
        1 0 0 -(l + r)/2
        0 1 0 -(t + b)/2
        0 0 1 -(f + n)/2
        0 0 0 1
    ]),
)

abstract type Projection end

struct Orthographic{T} <: Projection where {T}
    A::Matrix{T}
    Orthographic(args::T...) where {T} = new{float(T)}(ortho(args...))
end

struct Perspective{T} <: Projection where {T}
    A::Matrix{T}
    function Perspective(args::T...) where {T}
        P = new{float(T)}(frustum(args...))
        P.A[1, 1] *= -1  # flip x
        P.A[2, 2] *= -1  # flip y
        P
    end
end

center_diagonal(x, y, z) = begin
  F = float(eltype(x))

  mx, Mx = extrema(F, x)
  my, My = extrema(F, y)
  mz, Mz = extrema(F, z)

  lx = Mx - mx
  ly = My - my
  lz = Mz - mz

  [mx + .5lx, my + .5ly, mz + .5lz], √(lx^2 + ly^2 + lz^2)
end

"""
    MVP(M::AbstractMatrix, V::AbstractMatrix, P::Projection)
    MVP(M::AbstractMatrix, V::AbstractMatrix, P::AbstractMatrix, ortho::Bool)
    MVP(x, y, z, p::Symbol = :orthographic, elevation = atand(1 / √2), azimuth = -45, distance = 1, up = [0, 1, 0])

# Description

Model - View - Projection transformation matrix.
"""
struct MVP{T}
    A::Matrix{T}
    distance::T
    ortho::Bool
    MVP(M::AbstractMatrix{T}, V::AbstractMatrix{T}, P::Projection) where {T} =
        new{T}(P.A * V * M, 1, P isa Orthographic)
    MVP(M::AbstractMatrix{T}, V::AbstractMatrix{T}, P::AbstractMatrix{T}, ortho::Bool) where {T} =
        new{T}(P * V * M, 1, ortho)
    function MVP(
        x, y, z;
        projection::Symbol = :orthographic,
        elevation = KEYWORDS.elevation,
        azimuth = KEYWORDS.azimuth,
        zoom = KEYWORDS.zoom,
        up = KEYWORDS.up,
    )
        @assert projection ∈ (:orthographic, :perspective)
        @assert -180 ≤ azimuth ≤ 180
        @assert -90 ≤ elevation ≤ 90
        ortho = projection === :orthographic
        # Model Matrix
        M = I
        # View Matrix
        ctr, diag = center_diagonal(x, y, z)
        dist = .5diag / zoom / (ortho ? 1 : 2)
        correction = sign(elevation) * 100eps()
        eye = ctr .+ dist .* [
            cosd(azimuth) * cosd(elevation - correction)
            sind(azimuth) * cosd(elevation - correction)
            sind(elevation - correction)
        ]
        @show ctr dist eye
        V = lookat(eye, ctr, up)
        # Projection Matrix
        P = if ortho
            Orthographic(-dist, dist, -dist, dist, -dist, dist)
        else
            Perspective(-dist, dist, -dist, dist, 1., 100.)
        end
        @show P.A V M
        show(stdout, "text/plain", P.A * V * M); println()
        new{float(eltype(x))}(P.A * V * M, dist, ortho)
    end
end

function (t::MVP)(p::AbstractMatrix, clip = false)
    F = eltype(t.A)
    ε = eps(F)
    # homogeneous coordinates
    dat = t.A * (size(p, 1) == 4 ? p : vcat(p, ones(1, size(p, 2))))
    xs, ys, zs, ws = dat[1, :], dat[2, :], dat[3, :], dat[4, :]
    @inbounds for (i, w) in enumerate(ws)
        if (abs_w = abs(w)) > ε
            if clip
                thres = abs_w + ε
                if abs(w - 1) > ε && (abs(xs[i]) > thres || abs(ys[i]) > thres || abs(xs[i]) > thres)
                    xs[i] = NaN
                    ys[i] = NaN
                    zs[i] = NaN
                end
            else
                xs[i] /= w
                ys[i] /= w
                zs[i] /= w
            end
        end
    end
    # w_nz = ws .> ε
    # xs[w_nz] ./= ws[w_nz]
    # ys[w_nz] ./= ws[w_nz]
    # zs[w_nz] ./= ws[w_nz]
    t.ortho ? (xs, ys) : (xs ./ zs, ys ./ zs)
end

function (t::MVP)(v::Union{AbstractVector,NTuple{3}}, clip = false)
    F = eltype(t.A)
    ε = eps(F)
    # homogeneous coordinates
    x, y, z, w = t.A * [v..., 1]
    if (abs_w = abs(w)) > ε
        if clip
            thres = abs_w + ε
            if abs(w - 1) > ε && (abs(x) > thres || abs(y) > thres || abs(z) > thres)
                x = y = z = F(NaN)
            end
        else
            x /= w
            y /= w
            z /= w
        end
    end
    t.ortho ? (x, y) : (x / z, y / z)
end

"""
    draw_axes!(args...; kwargs...)

# Description

Draws (X, Y, Z) cartesian coordinates axes in (R, G, B) colors, at position `p = (x, y, z)`.
If `p = (x, y)` is given, draws at screen coordinates (only correct in orthographic projection).
"""
function draw_axes!(plot, p = [0, 0, 0], len = nothing)
    T = plot.transform
    l = len === nothing ? T.distance / 4 : len

    axis(p, d) = begin
        e = copy(p)
        e[d] += l
        T(hcat(p, e))
    end

    pos = if length(p) == 2
        T.ortho ? (inv(T.A) * vcat(p, 0, 1))[1:3] : vcat(p, 0)
    else
        p
    end
    lineplot!(plot, axis(float(pos), 1)..., color = :red)
    lineplot!(plot, axis(float(pos), 2)..., color = :green)
    lineplot!(plot, axis(float(pos), 3)..., color = :blue)
    plot
end
