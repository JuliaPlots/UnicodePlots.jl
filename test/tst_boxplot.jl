@testset "default" begin
    p = @inferred boxplot([1,2,3,4,5])
    test_ref("references/boxplot/default.txt", @show_col(p))
    p = @inferred boxplot("series1", [1,2,3,4,5])
    test_ref("references/boxplot/default_name.txt", @show_col(p))
    p = @inferred boxplot("series1", [1,2,3,4,5], title = "Test", xlim = (-1,8), color = :blue, width = 50, border = :solid, xlabel="foo")
    test_ref("references/boxplot/default_parameters.txt", @show_col(p))
    p = @inferred boxplot("series1", [1,2,3,4,5], title = "Test", xlim = [-1,8], color = :blue, width = 50, border = :solid, xlabel="foo")
    test_ref("references/boxplot/default_parameters.txt", @show_col(p))
    test_ref(
        "references/boxplot/default_parameters_nocolor.txt",
        @io2str(show(IOContext(::IO, :color=>false), p))
    )
end

@testset "scaling" begin
    for (i, max_x) in enumerate([5,6,10,20,40])
        p = @inferred boxplot([1,2,3,4,5], xlim=(0,max_x))
        test_ref("references/boxplot/scale$i.txt", @show_col(p))
        p = @inferred boxplot([1,2,3,4,5], xlim=[0,max_x])
        test_ref("references/boxplot/scale$i.txt", @show_col(p))
    end
end

@testset "multi-series" begin
    p = @inferred boxplot(["one", "two"], [[1,2,3,4,5], [2,3,4,5,6,7,8,9]], title="Multi-series", xlabel="foo", color=:yellow)
    test_ref("references/boxplot/multi1.txt", @show_col(p))
    @test @inferred(boxplot!(p, "one more", [-1,2,3,4,11])) === p
    test_ref("references/boxplot/multi2.txt", @show_col(p))
    @test @inferred(boxplot!(p, [4,2,2.5,4,14], name = "last one")) === p
    test_ref("references/boxplot/multi3.txt", @show_col(p))
end

@testset "colors" begin
    p = @inferred boxplot(["one", "two"], [[1,2,3], [4,5,6]], color=214)
    test_ref("references/boxplot/col1.txt", @show_col(p))

    p = @inferred boxplot(["one", "two"], [[1,2,3], [4,5,6]], color=(187,0,187))
    test_ref("references/boxplot/col2.txt", @show_col(p))
end