
# code by dpo
function spy(A::AbstractArray;
             width::Int = 40,
             height::Int = 20,
             color = :green,
             labels::Bool = true,
             title::String = "Sparsity Pattern",
             args...)
  rows, cols, vals = findnz(A)
  nrow, ncol = size(A)
  canvas = BrailleCanvas(width, height,
                         plotWidth = float(ncol) + 1,
                         plotHeight = float(nrow) + 1)
  plot = Plot(canvas; showLabels = labels, title = title, args...)
  setPoint!(plot,
            convert(Vector{FloatingPoint}, cols),
            nrow + 1 - convert(Vector{FloatingPoint}, rows),
            color)
  annotate!(plot, :l, 1, "1")
  annotate!(plot, :l, height, string(nrow))
  annotate!(plot, :bl, "1")
  annotate!(plot, :b, string("nz = ", length(vals)))
  annotate!(plot, :br, string(ncol))
  return plot
end
