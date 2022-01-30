translate_4x4(v) = @SMatrix([
    1 0 0 v[1]
    0 1 0 v[2]
    0 0 1 v[3]
    0 0 0 1
])

rotate_4x4(r) = cat(r, 1; dims = (1, 2))

rot_x(θ) = @SMatrix([
    1 0 0 0 
    0 cosd(θ) -sind(θ) 0
    0 sind(θ) +cosd(θ) 0
    0 0 0 1
])

rot_y(θ) = @SMatrix([
    +cosd(θ) 0 sind(θ) 0
    0 1 0 0
    -sind(θ) 0 cosd(θ) 0
    0 0 0 1
])

rot_z(θ) = @SMatrix([
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
    Orthographic(args::T...) where {T} = new{T}(ortho(args...))
end

struct Perspective{T} <: Projection where {T}
    A::Matrix{T}
    function Perspective(args::T...) where {T}
        P = new{T}(frustum(args...))
        P.A[1, 1] *= -1  # flip x
        P.A[2, 2] *= -1  # flip y
        P
    end
end

"""
  MVP(M::AbstractMatrix, V::AbstractMatrix, P::Projection)
  MVP(M::AbstractMatrix, V::AbstractMatrix, P::AbstractMatrix, ortho::Bool)
  MVP(x, y, z, p::Symbol = :orthographic, elevation = 30, azimuth = -37.5)

# Description

Model - View - Projection transformation matrix.
"""
struct MVP
    A::Matrix
    ortho::Bool
    MVP(M::AbstractMatrix, V::AbstractMatrix, P::Projection) =
        new(P.A * V * M, P isa Orthographic)
    MVP(M::AbstractMatrix, V::AbstractMatrix, P::AbstractMatrix, ortho::Bool) =
        new(P * V * M, ortho)
    function MVP(
        x = nothing, y = nothing, z = nothing;
        projection::Symbol = :orthographic, elevation::Number = 30, azimuth::Number = -37.5,
        l = nothing, r = nothing, b = nothing, t = nothing, n = nothing, f = nothing
    )
        if (ortho = projection === :orthographic)
            l_, r_ = x === nothing ? (-2., 2.) : 2 .* extrema(Float64, x)
            b_, t_ = y === nothing ? (l_, r_) : 2 .* extrema(Float64, y)
            n_, f_ = z === nothing ? (l_, r_) : 2 .* extrema(Float64, z)
        else
            l_, r_ = x === nothing ? (-1., 1.) : extrema(Float64, x)
            b_, t_ = y === nothing ? (l_, r_) : extrema(Float64, y)
            n_, f_ = 1., 100.
        end
        args = (
            something(l, l_),
            something(r, r_),
            something(b, b_),
            something(t, t_),
            something(n, n_),
            something(f, f_),
        )
        P = ortho ? Orthographic(args...) : Perspective(args...)
        cam_pos = [0, 0, 0.5]
        M = I * (rot_x(elevation) * rot_y(azimuth)) * I  # translate * rotate * scale
        V = lookat(cam_pos)
        new(P.A * V * M, ortho)
    end
end

function (t::MVP)(a::AbstractMatrix)
    dat = t.A * (size(a, 1) == 4 ? a : vcat(a, ones(1, size(a, 2))))
    x, y, z, w = dat[1, :], dat[2, :], dat[3, :], dat[4, :]
    w_nz = w .> eps(eltype(t.A))  # homogeneous coordinates
    x[w_nz] ./= w[w_nz]
    y[w_nz] ./= w[w_nz]
    z[w_nz] ./= w[w_nz]
    t.ortho ? (x, y) : (x ./ z, y ./ z)
end

function (t::MVP)(v::Union{AbstractVector,NTuple{3}})
    x, y, z, w = t.A * [v..., 1]
    if abs(w) > eps(eltype(t.A))
        x /= w
        y /= w
        z /= w
    end
    t.ortho ? (x, y) : (x / z, y / z)
end

function axis(T, o, l, d)
    e = copy(o)
    e[d] += l
    T(hcat(o, e))
end

xaxis(T, o, l) = axis(T, float(o), l, 1)
yaxis(T, o, l) = axis(T, float(o), l, 2)
zaxis(T, o, l) = axis(T, float(o), l, 3)

"""
    draw_axes!(args...; kwargs...)

# Description

Draws (x, y, z) cartesian coordinates axes in (R, G, B) colors.
"""
function draw_axes!(p, o = [0, 0, 0], l = 0.5)
    origin = length(o) == 3 ? o : (inv(p.transform.A) * [o..., 0, 1])[1:3]
    lineplot!(p, xaxis(p.transform, origin, l)..., color = :red)
    lineplot!(p, yaxis(p.transform, origin, l)..., color = :green)
    lineplot!(p, zaxis(p.transform, origin, l)..., color = :blue)
    p
end
