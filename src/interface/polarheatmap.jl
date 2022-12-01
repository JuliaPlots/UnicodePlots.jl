"""
# Author(s)

- T Bltg (github.com/t-bltg)

# Examples

"""
function polarheatmap(
    θ::AbstractVector,
    r::Union{Function,AbstractVector},
    A::Union{Function,AbstractVecOrMat};
    rlim = (0, 0),
    kw...
)
    r, lims = polar_lims(θ, r, rlim)
    A = A isa Function ? A.(θ, r) : A

    # reuse polarplot to draw the grid
    plot = polarplot(zero(lims), lims)

    # use vec(A) ..., should we add yet another canvas ??

    plot
end