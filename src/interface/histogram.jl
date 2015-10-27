# code by IainNZ
function histogram(x, bins::Int; symb = "▇", args...)
  edges, counts = hist(x, bins)
  labels = Array(UTF8String, length(counts))
  binwidth = edges.step / edges.divisor
  @inbounds for i in 1:length(counts)
		val = floatRoundLog10(edges[i])
    labels[i] = string("(", val, ",", floatRoundLog10(val+binwidth), "]")
  end
  barplot(labels, counts; symb = symb, args...)
end

function histogram(x; bins::Int = sturges(length(x)), args...)
  histogram(x, bins; args...)
end

# Sturges' rule
sturges(n) = n == 0 ? 1 : ceil(Int, log2(n) + 1)
