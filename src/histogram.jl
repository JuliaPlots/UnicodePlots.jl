
# code by IainNZ
function histogram(x, n::Int=5; args...)
  edges, counts = hist(x,n)
  labels = String[]
  binwidth = (edges.step - edges.start) / edges.divisor
  for i in 1:length(counts)
    push!(labels, string("(",edges[i],",",floatround(edges[i]+binwidth),"]"))
  end
  barplot(labels, counts; symb="▇", args...)
end

function histogram(x; bins::Int=5, args...)
  histogram(x, bins; args...)
end
