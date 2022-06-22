using SparseArrays
using Random

# split from runtests.jl for docs generating script (gen_imgs.jl)

# `sprand` or `sprandn` is not stable across versions (e.g. 1.0 vs 1.6)
function _stable_sprand(rng, m::Integer, n::Integer, density::AbstractFloat)
    I = Int[]
    J = Int[]
    for li in randsubseq(rng, 1:(m * n), density)
        j, i = divrem(li - 1, m)
        push!(I, i + 1)
        push!(J, j + 1)
    end
    V = rand(rng, length(I))
    sparse(I, J, V)
end
