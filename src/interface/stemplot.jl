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
                  expand::Bool)
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

TODO
====

- Add tests to make plot more robust
- Test negative values for key. key: -5|-2 = -5-2 :(
- Test key: 0|4 = 04 :(
- Test different scales eg, decimals, large numbers, negative ect.
- Left Justify: If possible the separator symbole should be at least 6 cols from edge of terminal. 
- Remove brackets around leaves.

"""
function stemplot(
                  v::Vector;
                  divider::AbstractString="|", 
                  )
    left_ints,leaves = divrem(sort(v),10)

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
	max_stem_width = length(string(maximum(stems)))
	println()
	for stem in stems
		stemleaves = dict[stem]
		# print the stem and divider
		print(pad, rpad(stem, max_stem_width + 1), divider)
		# if leaves exist print them without dict brackets
		if !isempty(stemleaves)
			print(string(stemleaves)[2:(end-1)])
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
		# Print first leaf in stem
		key_leaf = dict[key_stem][1]
		println("\n",pad, "key: $(key_stem)$(divider)$(key_leaf) = $(key_stem)$(key_leaf)")
	end
end
