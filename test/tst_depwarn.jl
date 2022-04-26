# NOTE: run with $ julia --depwarn=yes for these tests to pass
seed!(RNG, 1337)

@testset "histogram" begin
    x = randn(RNG, 1_000)
    @test_logs (:warn, r"`symb`.+deprecated") histogram(x, symb = "#", closed = :right)
    @test_logs (:warn, r"`bins`.+deprecated") histogram(x, bins = 5, closed = :right)
    @test_logs (:warn, r"nbins::Int.+deprecated") histogram(x, 5, closed = :right)
    @test_logs (:warn, r"histogram\(hist::Histogram.+deprecated") histogram(
        fit(Histogram, x),
    )
end

@testset "barplot" begin
    @test_logs (:warn, r"`symb`.+deprecated") barplot(
        ["Paris", "Moskau"],
        [2.244, 11.92];
        symb = "#",
    )
end

@testset "plot" begin
    p = Plot([1, 2], [-1, 1])
    @test_logs (:warn, r"`annotate!`.+renamed") annotate!(p, :l, "text 1")
    @test_logs (:warn, r"`annotate!`.+renamed") annotate!(p, :l, "text 2", :red)
    @test_logs (:warn, r"`annotate!`.+renamed") annotate!(p, :l, "text 3", color = :blue)

    for i in 1:2
        @test_logs (:warn, r"`annotate!`.+renamed") annotate!(
            p,
            :l,
            i,
            "$i",
            color = :green,
        )
        @test_logs (:warn, r"`annotate!`.+renamed") annotate!(p, :l, i, "$i", :yellow)
    end

    @test_throws ErrorException savefig(p, tempname() * ".jpg")
end

@testset "spy" begin
    @test_logs (:warn, r"`color = :automatic`.+deprecated") spy(
        _stable_sprand(RNG, 10, 10, 0.15),
        color = :automatic,
    )
end
