
# code by dpo
function spy(A::AbstractArray;
             width::Int = 0,
             height::Int = 0,
             color = :automatic,
             labels::Bool = true,
             margin::Int = 3,
             padding::Int = 1,
             title::(@compat AbstractString) = "Sparsity Pattern",
             args...)
  rows, cols, vals = findnz(A)
  nrow, ncol = size(A)
  min_canheight = safeCeil(nrow / 4)
  min_canwidth = safeCeil(ncol / 2)
  min_plotheight = min_canheight + 6
  min_plotwidth = min_canwidth + margin + padding + 2 + length(string(ncol))
  autosized = false
  if width == 0 && height == 0
    if isinteractive()
      term_height, term_width = Base.tty_size()
      if min_plotheight <= term_height - 2 && min_plotwidth <= term_width
        height = min_canheight
        width = min_canwidth
        autosized = true
      end
    end
  end
  if width == 0 && height == 0 && autosized == false
    width = 40
    height = 20
  end
  canvas = BrailleCanvas(width, height,
                         plotWidth = float(ncol) + 1,
                         plotHeight = float(nrow) + 1)
  plot = Plot(canvas; showLabels = labels, title = title, margin = margin, padding = padding, args...)
  height = nrows(plot.graphics)
  width = ncols(plot.graphics)
  plot = if color != :automatic
    setPoint!(plot,
              convert(Vector{(@compat AbstractFloat)}, cols),
              nrow + 1 - convert(Vector{(@compat AbstractFloat)}, rows),
              color)
  else
    pos_idx = vals .> 0
    neg_idx = !pos_idx
    pos_cols = cols[pos_idx]
    pos_rows = rows[pos_idx]
    neg_cols = cols[neg_idx]
    neg_rows = rows[neg_idx]
    setPoint!(plot,
              convert(Vector{(@compat AbstractFloat)}, pos_cols),
              nrow + 1 - convert(Vector{(@compat AbstractFloat)}, pos_rows),
              :red)
    setPoint!(plot,
              convert(Vector{(@compat AbstractFloat)}, neg_cols),
              nrow + 1 - convert(Vector{(@compat AbstractFloat)}, neg_rows),
              :blue)
  end
  annotate!(plot, :l, 1, "1")
  annotate!(plot, :l, height, string(nrow))
  annotate!(plot, :bl, "1")
  annotate!(plot, :br, string(ncol))
  xlabel!(plot, string("nz = ", length(vals)))
  return plot
end
