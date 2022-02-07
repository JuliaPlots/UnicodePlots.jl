seed!(RNG, 1337)
x = randn(RNG, 10000)

@testset "basic" begin
    p = @inferred verticalhistogram(x)
    # test_ref("references/verticalhistogram/basic.txt", @print_col(p))  # TODO plot should be used, I need the team help to apply their style. 
end
