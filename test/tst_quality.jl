@testset "Aqua" begin
    # JuliaTesting/Aqua.jl/issues/77
    Aqua.test_all(
        UnicodePlots;
        ambiguities = false,
        stale_deps = (; ignore = [:FreeTypeAbstraction]),  # conditionally loaded using `@lazy`
    )
    Aqua.test_ambiguities(UnicodePlots)
end
