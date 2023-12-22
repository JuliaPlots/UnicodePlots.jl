@testset "Aqua" begin
    # JuliaTesting/Aqua.jl/issues/77
    Aqua.test_all(
        UnicodePlots;
        ambiguities = false,
        deps_compat = false,
        stale_deps = !isdefined(Base, :get_extension),  # issue with `Requires` not used when weak deps are enabled
    )
    Aqua.test_ambiguities(UnicodePlots)
end
