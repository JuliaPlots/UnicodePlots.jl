"""
`stemplot(v)`->` Plot`

Description
===========

Draws a stem leaf plot of the given vector 'v'.

Usage
=====

`stemplot(v)`

Arguments
=========

-**`v`** : Vector for which the stem leaf plot should be computed

Results
=======

A plot of object type 

TODO

Author(s)
========
- Iain Dunning (Github: https://github.com/IainNZ)
- Christof Stocker (Github: https://github.com/Evizero)
- Kenta Sato (Github: https://github.com/bicycle1885)
- Alex Hallam (Github: https://github.com/alexhallam)

Examples
========

`julia> stemplot(rand(1:80,20))`

TODO
"""
function stemplot(data)
	println("The decimal point is 1 digit(s) to the right of the | \n")
	# get the left most integer and the remainders, aka leaves.
	# also infer scale of values from median of vector.
	k = floor(Int64,log10(median(data)))
	(left_int,leaf) = divrem(sort(data),10^k)
	i = left_int[end]
	stem = []
	# Create a range of values for stem. This is so we don't miss
	# empty sets.
	while i >= left_int[1]
		push!(stem,i)
		i -= 1
	end
	# generator function to be used in the Dict. Looks up the leaf corresponding to the stem
	function f(i)
		index = find(left_int .== i)
		leaf[index]
	end
	# Dict where key == stem and value == leaves. 
	dict = Dict(i => f(i) for i in stem)
	[dict[i] for i in stem]
	# Print the results as a stem leaf plot
	for i in stem
		if isempty(dict[i])
			println(i, "|", "")
		else
			println(i, "|", dict[i])
		end
	end
end

