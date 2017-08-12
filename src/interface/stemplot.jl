type Stemplot
  left_ints::Vector{AbstractFloat}
  leaves::Vector{AbstractFloat}

  function Stemplot{T<:Real}(v::AbstractVector{T}; scale=10)
    v = convert(Vector{AbstractFloat}, v)
    left_ints, leaves = divrem(v, scale)
    left_ints[(left_ints .== 0) .& (sign.(leaves) .== -1)] = -0.00
    new(left_ints, leaves)
  end

end

function getstems(left_ints::Vector{AbstractFloat}; trim::Bool=false)
  # Stem range => sorted hexadecimal
  stemrng= minimum(left_ints):maximum(left_ints)
  stems = trim ? sort(unique(left_ints)) : sort(unique(vcat(stemrng, left_ints)))
  stems = num2hex.(stems); left_ints = num2hex.(left_ints)
  return stems, left_ints
end

stemplot_getlabel(s) = s == num2hex(-0.) ? "-0" : string(Int(hex2num(s)))
stemplot_getleaf(s, l_i, lv) = join(string.( sort(abs.(trunc(Int, lv[l_i .== s]))) ))

"""
`stemplot(v; nargs...)`->` Plot`

Description
============

Draws a stem leaf plot of the given vector `v`.

Usage
----------
```julia
`stemplot(v)`
function stemplot(
                  v::Vector,
                  scale::Int64,
                  divider::AbstractString,
                  padchar::AbstractString)
```
Arguments
----------

-**`v`** : Vector for which the stem leaf plot should be computed

-**`scale`**: Set scale of plot. Default = 10. Scale is changed via orders of magnitude common values are ".1","1"."10".

-**`divider`**: Symbol for break between stem and leaf. Default = "|"

-**`padchar`**: Character(s) to separate stems, leaves and dividers. Default = " "

Results
----------

A plot of object type

Author(s)
----------

- Alex Hallam (Github: https://github.com/alexhallam)

- Matthew Amos (Github: https://github.com/equinetic)

Examples
----------
```julia

stemplot(rand(1:100,80))
stemplot(rand(-100:100,300))
stemplot(randn(50),scale = 1)
     -2 | 00000
     -1 | 0000000
      0 | 00000000000000
      0 | 0000000000000000
      1 | 00000000
    Key: 1|0 = 1.0
    Description: The decimal is 0 digit(s) to the right of |
```

"""
function stemplot(plt::Stemplot;
                  scale=10,
                  divider::AbstractString="|",
                  padchar::AbstractString=" ",
                  trim::Bool=false,
                  )

    left_ints = plt.left_ints
    leaves = plt.leaves

    stems, left_ints = getstems(left_ints, trim=trim)

    labels = stemplot_getlabel.(stems)
    lbl_len = maximum(length.(labels))
    col_len = lbl_len + 1

    # Stem | Leaf print routine
    for i = 1:length(stems)
      stem = rpad(lpad(labels[i], lbl_len, padchar), col_len, padchar)
      leaf = stemplot_getleaf(stems[i], left_ints, leaves)
      println(stem, divider, padchar, leaf)
    end

    # Print key
    println("\nKey: 1$(divider)0 = $(scale)")
    # Description of where the decimal is
    ndigits = abs.(trunc(Int,log10(scale)))
    right_or_left = ifelse(trunc(Int,log10(scale)) < 0, "left", "right")
    println("The decimal is $(ndigits) digit(s) to the $(right_or_left) of $(divider)")

end

# back to back
function stemplot(plt1::Stemplot, plt2::Stemplot;
                  scale=10,
                  divider::AbstractString="|",
                  padchar::AbstractString=" ",
                  trim::Bool=false,
                  )

    leaves1 = plt1.leaves
    leaves2 = plt2.leaves

    stems1, li_1 = getstems(plt1.left_ints, trim=trim)
    stems2, li_2 = getstems(plt2.left_ints, trim=trim)
    stems, = getstems(vcat(plt1.left_ints, plt2.left_ints), trim=trim)

    labels = stemplot_getlabel.(stems)
    lbl_len = maximum(length.(labels))
    col_len = lbl_len + 1

    # Stem | Leaf print routine
    left_leaves = [stemplot_getleaf(stems[i], li_1, leaves1) for i=1:length(stems)]
    leftleaf_len = maximum(length.(left_leaves))

    for i = 1:length(stems)
      left_leaf = lpad(reverse(left_leaves[i]), leftleaf_len, padchar)
      right_leaf = stemplot_getleaf(stems[i], li_2, leaves2)
      stem = rpad(lpad(labels[i], col_len, padchar), col_len+1, padchar)
      println(left_leaf, padchar, divider, stem, divider, padchar, right_leaf)
    end

    # Print key
    println("\nKey: 1$(divider)0 = $(scale)")
    # Description of where the decimal is
    ndigits = abs.(trunc(Int,log10(scale)))
    right_or_left = ifelse(trunc(Int,log10(scale)) < 0, "left", "right")
    println("The decimal is $(ndigits) digit(s) to the $(right_or_left) of $(divider)")

end

# Single
function stemplot{T<:Real}(v::AbstractVector{T}; scale=10, args...)
  # Stemplot object
  plt = Stemplot(v, scale=scale)

  # Dispatch to plot routine
  stemplot(plt; scale=scale, args...)
end

# Back to back
function stemplot{T<:Real}(v1::AbstractVector{T}, v2::AbstractVector; scale=10, args...)
  # Stemplot object
  plt1 = Stemplot(v1, scale=scale)
  plt2 = Stemplot(v2, scale=scale)

  # Dispatch to plot routine
  stemplot(plt1, plt2; scale=scale, args...)
end
