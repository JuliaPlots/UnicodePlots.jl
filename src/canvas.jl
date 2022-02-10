abstract type Canvas <: GraphicsArea end

origin(c::Canvas) = (origin_x(c), origin_y(c))
Base.size(c::Canvas) = (width(c), height(c))
pixel_size(c::Canvas) = (pixel_width(c), pixel_height(c))

pixel!(c::Canvas, pixel_x::Integer, pixel_y::Integer; color::UserColorType = :normal) =
    pixel!(c, pixel_x, pixel_y, color)

function points!(c::Canvas, x::Number, y::Number, color::UserColorType)
    origin_x(c) <= (xs = c.xscale(x)) <= origin_x(c) + width(c) || return c
    origin_y(c) <= (ys = c.yscale(y)) <= origin_y(c) + height(c) || return c
    pixel_x = (xs - origin_x(c)) / width(c) * pixel_width(c)
    pixel_y = pixel_height(c) - (ys - origin_y(c)) / height(c) * pixel_height(c)
    pixel!(c, floor(Int, pixel_x), floor(Int, pixel_y), color)
end

points!(c::Canvas, x::Number, y::Number; color::UserColorType = :normal) =
    points!(c, x, y, color)

function points!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for I in eachindex(X, Y)
        points!(c, X[I], Y[I], color)
    end
    c
end

function points!(
    c::Canvas,
    X::AbstractVector,
    Y::AbstractVector,
    color::AbstractVector{T},
) where {T<:UserColorType}
    (length(X) == length(color) && length(X) == length(Y)) ||
        throw(DimensionMismatch("X, Y, and color must be the same length"))
    for i in 1:length(X)
        points!(c, X[i], Y[i], color[i])
    end
    c
end

points!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) =
    points!(c, X, Y, color)

function const_color_line!(
    c,
    nsteps,
    length,
    step,
    px,
    Px,
    py,
    Py,
    cur_x,
    cur_y,
    δx,
    δy,
    col,
)
    pixel!(c, floor(Int, cur_x), floor(Int, cur_y), col)
    for _ in range(1, stop = nsteps, length = length, step = step)
        cur_x += δx
        cur_y += δy
        (cur_y < py || cur_y > Py) && continue
        (cur_x < px || cur_x > Px) && continue
        pixel!(c, floor(Int, cur_x), floor(Int, cur_y), col)
    end
    return
end

function interp_color_line!(
    c,
    nsteps,
    length,
    step,
    px,
    Px,
    py,
    Py,
    cur_x,
    cur_y,
    δx,
    δy,
    iΔ,
    val1,
    val2,
    col_cb,
)
    pixel!(c, floor(Int, cur_x), floor(Int, cur_y), col_cb(val1))
    start_x, start_y = cur_x, cur_y
    for i in range(1, stop = nsteps, length = length, step = step)
        cur_x += δx
        cur_y += δy
        (cur_y < py || cur_y > Py) && continue
        (cur_x < px || cur_x > Px) && continue
        weight = √((cur_x - start_x)^2 + (cur_y - start_y)^2) * iΔ
        pixel!(
            c,
            floor(Int, cur_x),
            floor(Int, cur_y),
            col_cb((1 - weight) * val1 + weight * val2),
        )
    end
    return
end

# Implementation of the digital differential analyser (DDA)
function lines!(
    c::Canvas,
    x1::T,
    y1::T,
    x2::T,
    y2::T,
    c_or_v1::Union{AbstractFloat,UserColorType},  # either floating point values or colors
    c_or_v2::Union{AbstractFloat,UserColorType} = nothing,
    col_cb = nothing,  # color callback (map values to colors)
) where {T<:Number}

    # FIXME: type dispatch issues, because xscale `Function` is stored in a struct ?
    # c.xscale(x1) is inferred as returning Any
    x1::T = c.xscale(x1)
    x2::T = c.xscale(x2)
    y1::T = c.yscale(y1)
    y2::T = c.yscale(y2)

    mx = origin_x(c)
    Mx = origin_x(c) + width(c)
    ((x1 < mx && x2 < mx) || (x1 > Mx && x2 > Mx)) && return c

    my = origin_y(c)
    My = origin_y(c) + height(c)
    ((y1 < my && y2 < my) || (y1 > My && y2 > My)) && return c

    x2p(x) = (x - mx) / width(c) * pixel_width(c)
    y2p(y) = pixel_height(c) - (y - my) / height(c) * pixel_height(c)

    Δx = x2p(x2) - (cur_x = x2p(x1))
    Δy = y2p(y2) - (cur_y = y2p(y1))

    nsteps = abs(Δx) > abs(Δy) ? abs(Δx) : abs(Δy)
    nsteps = min(nsteps, typemax(Int32))  # hard limit

    px, Px = x2p(mx), x2p(Mx)
    py, Py = y2p(my), y2p(My)

    max_num_iter = typemax(Int16)  # performance limit
    rng = if nsteps > max_num_iter
        nsteps, max_num_iter, nothing
    else
        nsteps, nothing, 1
    end

    args = (
        rng...,
        min(px, Px),
        max(px, Px),
        min(py, Py),
        max(py, Py),
        cur_x,
        cur_y,
        Δx / nsteps,
        Δy / nsteps,
    )

    if c_or_v1 isa AbstractFloat && c_or_v2 isa AbstractFloat && col_cb !== nothing
        interp_color_line!(c, args..., 1 / √(Δx^2 + Δy^2), c_or_v1, c_or_v2, col_cb)
    else
        const_color_line!(c, args..., c_or_v1)
    end
    c
end

lines!(
    c::Canvas,
    x1::Number,
    y1::Number,
    x2::Number,
    y2::Number;
    color::UserColorType = :normal,
) = lines!(c, x1, y1, x2, y2, color)

function lines!(c::Canvas, X::AbstractVector, Y::AbstractVector, color::UserColorType)
    length(X) == length(Y) || throw(DimensionMismatch("X and Y must be the same length"))
    for i in 2:length(X)
        isfinite(X[i - 1]) || continue
        isfinite(Y[i - 1]) || continue
        isfinite(X[i]) || continue
        isfinite(Y[i]) || continue
        lines!(c, X[i - 1], Y[i - 1], X[i], Y[i], color)
    end
    c
end

lines!(c::Canvas, X::AbstractVector, Y::AbstractVector; color::UserColorType = :normal) =
    lines!(c, X, Y, color)

function get_canvas_dimensions_for_matrix(
    canvas::Type{T},
    nrow::Int,
    ncol::Int,
    max_width::Int,
    max_height::Int,
    width::Int,
    height::Int,
    margin::Int,
    padding::Int,
    out_stream::Union{Nothing,IO},
    fix_ar::Bool;
    extra_rows = 0,
    extra_cols = 0,
) where {T<:Canvas}
    canv_height = nrow / y_pixel_per_char(T)
    canv_width  = ncol / x_pixel_per_char(T)
    # e.g. heatmap(collect(1:2) * collect(1:2)') with nrow = 2, ncol = 2
    # on a HeatmapCanvas, x_pixel_per_char = 1 and y_pixel_per_char = 2
    # hence the canvas aspect ratio (canv_ar) is 2
    canv_ar = canv_width / canv_height

    # min_canv_height := minimal number of y canvas characters
    # (holding y_pixel_per_char pixels) to represent the input data
    min_canv_height = ceil(Int, canv_height)
    min_canv_width  = ceil(Int, canv_width)

    height_diff = extra_rows
    width_diff  = margin + padding + length(string(ncol)) + extra_cols

    term_height, term_width =
        out_stream === nothing ? displaysize() : displaysize(out_stream)
    max_height = max_height > 0 ? max_height : term_height - height_diff
    max_width = max_width > 0 ? max_width : term_width - width_diff

    if nrow == 0 && ncol == 0
        return 0, 0, max_width, max_height
    end

    # Check if the size of the plot should be derived from the matrix
    # Note: if both width and height are 0, it means that there are no
    #       constraints and the plot should resemble the structure of
    #       the matrix as close as possible
    if width == 0 && height == 0
        # If the interactive code did not take care of this then try
        # to plot the matrix in the correct aspect ratio (within specified bounds)
        if min_canv_height > min_canv_width
            # long matrix (according to pixel density)
            width  = min(min_canv_height * canv_ar, max_width)
            height = min(width / canv_ar, max_height)
            width  = min(height * canv_ar, max_width)
        else
            # wide matrix
            height = min(min_canv_width / canv_ar, max_height)
            width  = min(height * canv_ar, max_width)
            height = min(width / canv_ar, max_height)
        end
    end

    if width == 0 && height > 0
        width = min(height * canv_ar, max_width)
    elseif width > 0 && height == 0
        height = min(width / canv_ar, max_height)
    end

    width  = round(Int, width)
    height = round(Int, height / (fix_ar ? ASPECT_RATIO : 1))  # optional terminal aspect ratio (4:3) correction

    # the canvas will target a (height, width) grid to represent the input data
    width, height, max_width, max_height
end

function align_char_point(
    text::AbstractString,
    char_x::Integer,
    char_y::Integer,
    halign::Symbol,
    valign::Symbol,
)
    nchar = length(text)
    char_x = if halign in (:center, :hcenter)
        char_x - nchar ÷ 2
    elseif halign == :left
        char_x
    elseif halign == :right
        char_x - (nchar - 1)
    else
        error("Argument `halign=$halign` not supported.")
    end
    char_y = if valign in (:center, :vcenter)
        char_y
    elseif valign == :top
        char_y + 1
    elseif valign == :bottom
        char_y - 1
    else
        error("Argument `valign=$valign` not supported.")
    end
    char_x, char_y
end

function annotate!(
    c::Canvas,
    x::Number,
    y::Number,
    text::AbstractString,
    color::UserColorType;
    halign = :center,
    valign = :center,
)
    xs = c.xscale(x)
    ys = c.yscale(y)
    pixel_x = (xs - origin_x(c)) / width(c) * pixel_width(c)
    pixel_y = pixel_height(c) - (ys - origin_y(c)) / height(c) * pixel_height(c)

    char_x, char_y = pixel_to_char_point(c, pixel_x, pixel_y)
    char_x, char_y = align_char_point(text, char_x, char_y, halign, valign)
    for char in text
        char_point!(c, char_x, char_y, char, color)
        char_x += 1
    end
    c
end

function annotate!(c::Canvas, x::Number, y::Number, text::Char, color::UserColorType)
    xs = c.xscale(x)
    ys = c.yscale(y)
    pixel_x = (xs - origin_x(c)) / width(c) * pixel_width(c)
    pixel_y = pixel_height(c) - (ys - origin_y(c)) / height(c) * pixel_height(c)

    char_x, char_y = pixel_to_char_point(c, pixel_x, pixel_y)
    char_point!(c, char_x, char_y, text, color)
    c
end

function printcolorbarrow(
    io::IO,
    c::Canvas,
    row::Int,
    colormap::Function,
    border::Symbol,
    lim,
    lim_str,
    plot_padding,
    zlabel,
    max_len,
    blank::Char,
)
    b = BORDERMAP[border]
    min_z, max_z = lim
    label = ""
    if row == 1
        label = lim_str[2]
        # print top border and maximum z value
        print_color(:light_black, io, b[:tl], b[:t], b[:t], b[:tr])
        print(io, plot_padding)
        print_color(:light_black, io, label)
    elseif row == nrows(c)
        label = lim_str[1]
        # print bottom border and minimum z value
        print_color(:light_black, io, b[:bl], b[:b], b[:b], b[:br])
        print(io, plot_padding)
        print_color(:light_black, io, label)
    else
        # print gradient
        print_color(:light_black, io, b[:l])
        if min_z == max_z  # if min and max are the same, single color
            fgcol = bgcol = colormap(1, 1, 1)
        else  # otherwise, blend from min to max
            n = 2(nrows(c) - 2)
            r = row - 2
            bgcol = colormap(n - 2r, 1, n)
            fgcol = colormap(n - 2r - 1, 1, n)
        end
        print(
            io,
            Crayon(foreground = fgcol, background = bgcol),
            HALF_BLOCK,
            HALF_BLOCK,
            Crayon(reset = true),
        )
        print_color(:light_black, io, b[:r])
        print(io, plot_padding)
        # print z label
        if row == div(nrows(c), 2) + 1
            label = zlabel
            print(io, label)
        end
    end
    print(io, repeat(blank, max_len - length(label)))
    nothing
end
