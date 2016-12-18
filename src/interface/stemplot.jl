function stemplot(data)
	(left_int,leaf) = divrem(sort(data),10)
	i = left_int[end]
	stem = []
	while i >= left_int[1]
		push!(stem,i)
		i -= 1
	end
	function f(i)
		index = find(left_int .== i)
		leaf[index]
	end
	dict = Dict(i => f(i) for i in stem)
	[dict[i] for i in stem]
	for i in stem
		println(i, "|", dict[i])
	end
end
