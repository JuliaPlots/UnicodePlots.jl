dct = Dict("foo" => 37, "bar" => 23)
p = @inferred barplot(dct)
@test_reference(
    "references/barplot/default.txt",
    @io2str(print(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
@test_reference(
    "references/barplot/default.txt",
    @io2str(show(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
@test_reference(
    "references/barplot/nocolor.txt",
    @io2str(show(::IO, p)),
    render = BeforeAfterFull()
)
p = @inferred barplot(["bar", "foo"], [23, 37])
@test_reference(
    "references/barplot/default.txt",
    @io2str(print(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)
@test_throws MethodError barplot!(p, ["zoom"], [90.])
@test @inferred(barplot!(p, ["zoom"], [90])) === p
@test_reference(
    "references/barplot/default2.txt",
    @io2str(print(IOContext(::IO, :color=>true), p)),
    render = BeforeAfterFull()
)

p = barplot(["Paris", "New York", "Moskau", "Madrid"], [2.244, 8.406, 11.92, 3.165], title = "Population")
