@testset "Aqua" begin
    # JuliaTesting/Aqua.jl/issues/77
    Aqua.test_all(UnicodePlots; ambiguities = false)
    Aqua.test_ambiguities(UnicodePlots)
end
