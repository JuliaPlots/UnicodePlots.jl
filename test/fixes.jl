using SparseArrays
using Random

# sprand or sprandn is not stable across versions (e.g. 1.0 vs 1.6)
function _stable_sprand(r, m::Integer, n::Integer, density::AbstractFloat)
    I = Int[]
    J = Int[]
    for li in randsubseq(r, 1:(m*n), density)
        j, i = divrem(li - 1, m)
        push!(I, i + 1)
        push!(J, j + 1)
    end
    V = rand(r, length(I))
    sparse(I, J, V)
end
