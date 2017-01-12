"""
`stemplot(v; nargs...)`->` Plot`

Description
===========

Draws a stem leaf plot of the given vector 'v'.

Usage
=====

`stemplot(v)`

function stemplot(
                  v::Vector,
                  symbol::AbstractString, 
                  scale::Int64)
Arguments
=========

-**`v`** : Vector for which the stem leaf plot should be computed
-**`symbol`: Symbol for break between stem and leaf. default = "|"
-**`expand`**: Bool for expanded (true) plot or collapsed (false). default = true
-**`color`**: Set color of plot. default = white TODO

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

`stemplot(rand(1:200,80))`

`stemplot(randn(50),scale = 1)`


TODO
====

- Test key: 0|4 = 04 :( Should be 0.4
- Test different scales eg, decimals, large numbers, negative ect.
- When negative values exist create -0
- Include a description for where the decimal is.
"""
function stemplot(
                  v::Vector;
                  divider::AbstractString="|", 
				  scale=10
                  )
	left_ints,leaves = divrem(sort(v),scale)
	leaves = trunc(Int, leaves)

	# Create range of values for stems. This is so the empty sets are not missed
	stems = collect(minimum(left_ints) : maximum(left_ints)) 
	
	# Get the leaves associated with a given stem
	getleaves(stem) = leaves[left_ints .== stem]

	# Dict mapping stems to leaves
	dict = Dict(stem => getleaves(stem) for stem in stems)
	
	# Prep and print stemplot
	# Set pad
	pad = "  "
	# width needed for proper formating of stem-to-divider
	max_stem_width = length(string(maximum(round(Int64,stems))))
	println()
	for stem in stems
		stemleaves = dict[stem]
		# print the stem and divider
		print(pad, rpad(round(Int64,stem), max_stem_width + 1), divider)
		# if leaves exist print them without dict brackets
		if !isempty(stemleaves)
			leaf_string = string(stemleaves)[2:(end-1)]
			print(replace(leaf_string,r"[,-]",""))
		end
		println()
	end
	println()
	
	# Get and print key
	# Get index of last stem
	key_stem_index = findlast(s -> !isempty(getleaves(stem)),stems)
	# If a key_stem exsits
	if key_stem_index > 0
		key_stem = stems[key_stem_index]
		# Print first leaf in stem and remove negative on leaf, if leaf is negative.
		key_leaf = norm(dict[key_stem][1])
		println("\n",pad, "key: $(key_stem)$(divider)$(key_leaf) = $(key_stem)$(key_leaf)")
	end
end
