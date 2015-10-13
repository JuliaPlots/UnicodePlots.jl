
# code by dpo
function spy(A::AbstractArray;
             width::Int = 0,
             height::Int = 0,
             color = :automatic,
             labels::Bool = true,
             margin::Int = 3,
             padding::Int = 1,
             maxwidth::Int = 70,
             maxheight::Int = 40,
             title::(@compat AbstractString) = "Sparsity Pattern",
             args...)
  rows, cols, vals = findnz(A)
  nrow, ncol = size(A)
  min_canvheight = safeCeil(nrow / 4)
  min_canvwidth = safeCeil(ncol / 2)
  aspect_ratio = min_canvwidth / min_canvheight
  min_plotheight = min_canvheight + 6
  min_plotwidth = min_canvwidth + margin + padding + 2 + length(string(ncol))

  # Check if the size of the plot should be derived from the matrix
  # Note: if both width and height are 0, it means that there are no
  #       constraints and the plot should resemble the structure of 
  #       the matrix as close as possible
  if width == 0 && height == 0
    # If julia is interactive, then try to fit the terminal
    autosized = false
    if isinteractive()
      term_height, term_width = Base.tty_size()
      if min_plotheight <= term_height - 2 && min_plotwidth <= term_width
        height = min_canvheight
        width = min_canvwidth
        autosized = true
      end
    end
    # If the interactive code did not take care of this then try
    # to plot the matrix in the correct aspect ratio (within specified bounds) 
    if !autosized
      if min_canvheight > min_canvwidth 
        # long matrix (according to pixel density)
        height = min_canvheight
        width = height * aspect_ratio
        if width > maxwidth
          width = maxwidth
          height = width / aspect_ratio
        end
        if height > maxheight
          height = maxheight
          width = min(height * aspect_ratio, maxwidth)
        end
      else
        # wide matrix
        width = min_canvwidth
        height = width / aspect_ratio
        if height > maxheight
          height = maxheight
          width = height * aspect_ratio
        end
        if width > maxwidth
          width = maxwidth
          height = min(width / aspect_ratio, maxheight)
        end
      end
      autosized = true
    end
  end
  if width == 0 && height > 0
    width = min(height * aspect_ratio, maxwidth)
  elseif width > 0 && height == 0
    height = min(width / aspect_ratio, maxheight)
  elseif width == 0 && height == 0
    width = 40
    height = 20
  end
  width = int(width)
  height = int(height)
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
