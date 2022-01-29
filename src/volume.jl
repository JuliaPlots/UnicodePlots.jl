translate_4x4(v) = [
    1 0 0 v[1]
    0 1 0 v[2]
    0 0 1 v[3]
    0 0 0 1
]

rotate_4x4(r) = cat(r, 1; dims = (1, 2))

camera_4x4(l, u, f, eye) = [
    l[1] l[2] l[3] -dot(l, eye)
    u[1] u[2] u[3] -dot(u, eye)
    f[1] f[2] f[3] -dot(f, eye)
    0 0 0 1
]

"""
  lookat(args...; kwargs...)

# Arguments
  - `eye`: position of the camera in world space (e.g. [0, 0, 10])
  - `target`: target point to look at in world space (usually to origin = [0, 0, 0])
  - `up`: up vector (usually +y = [0, 1, 0])
"""
lookat(eye, target = [0, 0, 0], up = [0, 1, 0]) = begin
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
frustum(l, r, b, t, n, f) = begin
    @assert n > 0 && f > 0
    [
        2n/(r - l) 0 0 0
        0 2n/(t - b) 0 0
        0 0 1 0
        0 0 0 1
    ] *
    [
        1 0 0 (r + l)/2n
        0 1 0 (t + b)/2n
        0 0 1 0
        0 0 0 1
    ] *
    [
        1 0 0 0
        0 1 0 0
        0 0 (f + n)/(f - n) -2f * n/(f - n)
        0 0 1 0
    ]
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
ortho(l, r, b, t, n, f) =
    [
        2/(r - l) 0 0 0
        0 2/(t - b) 0 0
        0 0 2/(f - n) 0
        0 0 0 1
    ] * [
        1 0 0 -(l + r)/2
        0 1 0 -(t + b)/2
        0 0 1 -(f + n)/2
        0 0 0 1
    ]

abstract type Projection end

struct Orthographic{T} <: Projection where {T}
    A::Matrix{T}
    Orthographic(l::T, r::T, b::T, t::T, n::T, f::T) where {T} =
        new{T}(ortho(l, r, b, t, n, f))
end

struct Perspective{T} <: Projection where {T}
    A::Matrix{T}
    Perspective(l::T, r::T, b::T, t::T, n::T, f::T) where {T} =
        new{T}(frustum(l, r, b, t, n, f))
end

"""
  MVP

# Description
  Model - View - Projection transformation matrix
"""
struct MVP
    A::Matrix
    ortho::Bool
    MVP(M::AbstractMatrix, V::AbstractMatrix, P::Projection) =
        new(P.A * V * M, P isa Orthographic)
end

(t::MVP)(v::Union{AbstractVector,NTuple{3}}) = begin
    x, y, z, w = t.A * [v..., 1]
    if abs(w) > eps()
        x /= w
        y /= w
        z /= w
    end
    t.ortho ? [x, y] : [x / z, y / z]
end

segment2xy(a, b) = [a[1], b[1]], [a[2], b[2]]
segment2xy(s) = [s[1][1], s[2][1]], [s[1][2], s[2][2]]

axis(T, o, l, d) = begin
    a = copy(o)
    a[d] += l
    segment2xy(T(o), T(a))
end

xaxis(T, o, l) = axis(T, float(o), l, 1)
yaxis(T, o, l) = axis(T, float(o), l, 2)
zaxis(T, o, l) = axis(T, float(o), l, 3)

draw_axes!(p, T, o = [0, 0, 0], l = 0.5) = begin
    lineplot!(p, xaxis(T, o, l)..., color = :red)
    lineplot!(p, yaxis(T, o, l)..., color = :green)
    lineplot!(p, zaxis(T, o, l)..., color = :blue)
    p
end
