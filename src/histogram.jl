
# code by IainNZ
function histogram(x, bins::Int=5; args...)
  edges, counts = hist(x, bins)
  labels = (@compat AbstractString)[]
  binwidth = edges.step / edges.divisor
  for i in 1:length(counts)
		val = floatRoundLog10(edges[i])
    push!(labels, string("(", val, ",", floatRoundLog10(val+binwidth), "]"))
  end
  barplot(labels, counts; symb="▇", args...)
end

function histogram(x; bins::Int=5, args...)
  histogram(x, bins; args...)
end
