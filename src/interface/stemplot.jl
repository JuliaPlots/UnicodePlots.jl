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

`stemplot(rand(1:200,80))

TODO

TODO
====

- Add tests to make plot more robust
- Test negative values
- Test different scales eg, decimals, large numbers, negative ect.
- Left Justify: I noticed that the "-" and multi-digits  shifted values over a little. 
- Remove brackets around leaves.

"""
function stemplot(
                  v::Vector;
                  symbol::AbstractString="|", 
                  )
    (left_int,leaf) = divrem(sort(v),10)
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
    println("\n")
    pad = "  "
    i = stem[end]
    while i <= stem[1]
        if isempty(dict[i])
            println(pad, i, lpad(symbol,2), "")
        else
            println(pad, i, lpad(symbol,2),dict[i])
        end
        i += 1
    end
    # Find a non empty stem-leaf pair to use for the key 
    #is_stemleaf = false
    i=1
    while i == 1
        key_stem = rand(stem)
        if isempty(dict[key_stem]) == false
            key_leaf = dict[key_stem][1]
            println("\n",pad,"key: $key_stem$symbol$key_leaf = $key_stem$key_leaf ")
            i=0
        else
            i=1
        end
    end
end
