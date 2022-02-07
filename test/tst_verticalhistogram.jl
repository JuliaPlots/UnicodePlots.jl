seed!(RNG, 1337)
x = randn(RNG, 10000)

@testset "basic" begin
    p = @inferred verticalhistogram(x)
    test_ref("references/verticalhistogram/basic.txt", @print_col(p))
end
