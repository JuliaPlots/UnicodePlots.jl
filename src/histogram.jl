
# code by IainNZ
function histogram(x, bins::Int = sturges(length(x)); args...)
  edges, counts = hist(x, bins)
  labels = UTF8String[]
  binwidth = edges.step / edges.divisor
  for i in 1:length(counts)
		val = floatRoundLog10(edges[i])
    push!(labels, string("(", val, ",", floatRoundLog10(val+binwidth), "]"))
  end
  barplot(labels, counts; symb="▇", args...)
end

function histogram(x; bins::Int = sturges(length(x)), args...)
  histogram(x, bins; args...)
end

# Sturges' rule
sturges(n) = n == 0 ? 1 : ceil(Int, log2(n) + 1)
