const WIDTH_CB = 4  # NOTE: 4 = 2border + 2gradient => colorbar width

function print_colorbar_row(
    io::IO,
    print_nocol,
    print_color,
    p::Plot,
    row::Integer,
    nr::Integer,
    zlab,
    bc,
    max_len::Integer,
    blank::AbstractChar,
)
    lab = ""
    cmap = p.cmap
    b = BORDERMAP[cmap.border]
    if (first_r = row == 1) || row == nr
        sym = first_r ? :t : :b
        # print border and z value
        print_color(io, bc, b[Symbol(sym, :l)], b[sym], b[sym], b[Symbol(sym, :r)])
    else
        # print gradient
        print_color(io, bc, b[:l])
        if cmap.lim[1] ≈ cmap.lim[2]  # if `zmin` and `zmax` are close, single color
            fgcol = bgcol = cmap.callback(1, 1, 1)
        else  # otherwise, blend from `zmin` to `zmax`
            n = 2(nr - 2)
            r = row - 2
            fgcol = cmap.callback(n - 2r - 1, 1, n)
            bgcol = cmap.callback(n - 2r, 1, n)
        end
        print_color(io, fgcol, HALF_BLOCK, HALF_BLOCK; bgcol)
        print_color(io, bc, b[:r])
        row == div(nr, 2) + 1 && (lab = zlab)
    end
    lpad = isempty(zlab) ? 0 : p.padding[]
    rpad = max_len - lpad - WIDTH_CB - length(lab)
    print_nocol(io, blank^lpad * lab * blank^rpad)
    nothing
end

function print_colorbar_lim(
    io::IO,
    print_nocol,
    print_color,
    p::Plot,
    lab::AbstractString,
    bc,
    max_len::Integer,
    blank::AbstractChar,
    trail,
)
    lpad = p.padding[] + if (len = length(lab)) ≥ WIDTH_CB
        -(len - WIDTH_CB) ÷ 2  # wide label mode (left shifted)
    else
        ((c = get(lab, 1, '_')) == '-' || c == '+') ? 0 : 1  # left colorbar border or sign
    end
    lpad = max(0, lpad)
    rpad = max(0, max_len - (lpad - p.padding[]) - len)
    print_nocol(io, blank^lpad)
    print_color(io, bc, lab)
    print_nocol(io, blank^rpad * trail)
    nothing
end

function print_title(
    io::IO,
    print_nocol,
    print_color,
    left_pad::AbstractString,
    title::AbstractString,
    right_pad::AbstractString,
    blank::AbstractChar;
    p_width::Integer = 0,
    color::UserColorType = :normal,
)
    isempty(title) && return (0, 0)
    offset = round(Int, p_width / 2 - length(title) / 2, RoundNearestTiesUp)
    pre_pad = blank^max(0, offset)
    print_nocol(io, left_pad, pre_pad)
    print_color(io, color, title)
    post_pad = blank^(max(0, p_width - length(pre_pad) - length(title)))
    print_nocol(io, post_pad, right_pad)
    (
        count('\n', title) + 1,
        length(strip(left_pad * pre_pad * title * post_pad * right_pad, '\n')),
    )
end

function print_border(
    io::IO,
    print_nocol,
    print_color,
    loc::Symbol,
    length::Integer,
    left_pad::Union{Nothing,AbstractChar,AbstractString},
    right_pad::Union{Nothing,AbstractChar,AbstractString},
    bmap = BORDERMAP[KEYWORDS.border],
    color::UserColorType = BORDER_COLOR[],
)
    left_pad ≡ nothing || print_nocol(io, string(left_pad))
    print_color(io, color, bmap[Symbol(loc, :l)], bmap[loc]^length, bmap[Symbol(loc, :r)])
    right_pad ≡ nothing || print_nocol(io, string(right_pad))
    nothing
end

function print_labels(
    io::IO,
    print_nocol,
    print_color,
    p::Plot,
    mloc::Symbol,
    border_length,
    left_pad::AbstractString,
    right_pad::AbstractString,
    blank::AbstractChar,
)
    p.labels[] || return 0
    bc        = BORDER_COLOR[]
    lloc      = Symbol(mloc, :l)
    rloc      = Symbol(mloc, :r)
    left_str  = get(p.decorations, lloc, "")
    mid_str   = get(p.decorations, mloc, "")
    right_str = get(p.decorations, rloc, "")
    (isempty(left_str) && isempty(mid_str) && isempty(right_str)) && return 0
    left_col  = get(p.colors_deco, lloc, bc)
    mid_col   = get(p.colors_deco, mloc, bc)
    right_col = get(p.colors_deco, rloc, bc)
    left_len  = length(left_str)
    mid_len   = length(mid_str)
    right_len = length(right_str)
    print_nocol(io, left_pad)
    print_color(io, left_col, left_str)
    cnt = round(Int, border_length / 2 - mid_len / 2 - left_len, RoundNearestTiesAway)
    print_nocol(io, cnt > 0 ? blank^cnt : "")
    print_color(io, mid_col, mid_str)
    cnt = border_length - right_len - left_len - mid_len + 2 - cnt
    print_nocol(io, cnt > 0 ? blank^cnt : "")
    print_color(io, right_col, right_str)
    print_nocol(io, right_pad)
    return 1
end

Base.show(io::IO, p::Plot) = _show(io, print, print_color, p)

"""
Display a `Plot` object to a terminal emulator.
"""
function _show(end_io::IO, print_nocol, print_color, p::Plot)
    buf = PipeBuffer()  # buffering, for performance
    io_color = get(end_io, :color, false)
    io = IOContext(buf, :color => io_color, :displaysize => displaysize(end_io))

    g = p.graphics
    🗷 = Char(BLANK)  # blank outside graphics
    🗹 = blank(g)  # blank inside graphics
    ############################################################
    # 🗷 = 'x'  # debug
    # 🗹 = Char(typeof(g) <: BrailleCanvas ? '⠿' : 'o')  # debug
    ############################################################
    xlab, ylab, zlab = axes_labels = xlabel(p), ylabel(p), zlabel(p)
    postprocess! = preprocess!(io, g)
    nr, nc = nrows(g), ncols(g)

    p_width = nc + 2  # left corner + border length (number of graphics cols) + right corner
    if p.compact[]
        isempty(xlab) || label!(p, :b, xlab)
        isempty(ylab) || label!(p, :l, round(Int, nr / 2), ylab)
    end

    bmap = BORDERMAP[p.border[] ≡ :none && g isa BrailleCanvas ? :bnone : p.border[]]
    bc = BORDER_COLOR[]

    # get length of largest strings to the left and right
    max_len_l = if p.labels[] && !isempty(p.labels_left)
        maximum(length ∘ no_ansi_escape, values(p.labels_left))
    else
        0
    end
    max_len_r = if p.labels[] && !isempty(p.labels_right)
        maximum(length ∘ no_ansi_escape, values(p.labels_right))
    else
        0
    end
    max_len_a = p.labels[] ? maximum(length ∘ no_ansi_escape, axes_labels) : 0
    if !p.compact[] && p.labels[] && !isempty(ylab)
        max_len_l += length(ylab) + 1
    end

    has_labels =
        max_len_l > 0 || max_len_r > 0 || max_len_a > 0 || length(p.decorations) > 0
    has_labels &= p.labels[]

    plot_offset = max_len_l + p.margin[] + p.padding[]  # offset where the plot (including border) begins
    border_left_pad = 🗷^plot_offset  # padding-string between labels and border
    plot_padding = 🗷^p.padding[]  # base padding-string (e.g. left to border)

    cbar_pad = if p.cmap.bar
        min_z_str, max_z_str =
            map(x -> nice_repr(roundable(x) ? x : float_round_log10(x), p), p.cmap.lim)
        len_z_lab = length(no_ansi_escape(zlabel(p)))
        cbar_max_len = max(
            length(min_z_str),
            length(max_z_str),
            WIDTH_CB + (len_z_lab > 0 ? p.padding[] + len_z_lab : 0),
        )
        🗷^cbar_max_len
    else
        ""
    end

    # trailing
    border_right_pad = if p.cmap.bar
        🗷^max_len_r  # colorbar labels can overlap padding
    else
        plot_padding * 🗷^max_len_r
    end
    border_right_cbar_pad = plot_padding * 🗷^max_len_r * cbar_pad

    # plot the title and the top border
    h_ttl, w_ttl = print_title(
        io,
        print_nocol,
        print_color,
        border_left_pad,
        title(p),
        border_right_cbar_pad * '\n',
        🗹;
        p_width = p_width,
        color = io_color ? Crayon(foreground = :white, bold = true) : nothing,
    )
    h_lbl = print_labels(
        io,
        print_nocol,
        print_color,
        p,
        :t,
        nc - 2,
        border_left_pad * 🗹,
        🗹 * border_right_cbar_pad * '\n',
        🗹,
    )
    g.visible && print_border(
        io,
        print_nocol,
        print_color,
        :t,
        nc,
        border_left_pad,
        border_right_pad * (p.cmap.bar ? "" : "\n"),
        bmap,
    )
    p.cmap.bar && print_colorbar_lim(
        io,
        print_nocol,
        print_color,
        p,
        max_z_str,
        bc,
        cbar_max_len,
        🗷,
        '\n',
    )

    # compute position of ylabel
    y_lab_row = round(nr / 2, RoundNearestTiesUp)

    # plot all rows
    for row ∈ 1:nr
        # print left annotations
        print_nocol(io, 🗷^p.margin[])
        if has_labels
            # Current labels to left and right of the row and their length
            left_str   = get(p.labels_left, row, "")
            left_col   = get(p.colors_left, row, bc)
            right_str  = get(p.labels_right, row, "")
            right_col  = get(p.colors_right, row, bc)
            left_str_  = no_ansi_escape(left_str)
            right_str_ = no_ansi_escape(right_str)
            left_len   = length(left_str_)
            right_len  = length(right_str_)
            if !io_color
                left_str  = left_str_
                right_str = right_str_
            end
            if !p.compact[] && row == y_lab_row
                # print ylabel
                print_color(io, :normal, ylab)
                print_nocol(io, 🗷^(max_len_l - length(ylab) - left_len))
            else
                # print padding to fill ylabel length
                print_nocol(io, 🗷^(max_len_l - left_len))
            end
            # print the left annotation
            print_color(io, left_col, left_str)
        end
        if g.visible
            # print left border
            print_nocol(io, plot_padding)
            print_color(io, bc, bmap[:l])
            # print canvas row
            print_row(io, print_nocol, print_color, g, row)
            if g isa ImageGraphics && g.sixel[]
                offset = plot_offset + nc + 1  # COV_EXCL_LINE
                # 1F: move cursor to the beginning of the previous line, 1 line up
                # $(offset)C: move cursor to the right by an amount of $offset columns
                print_nocol(io, "\e[1F\e[$(offset)C")  # COV_EXCL_LINE
            end
            # print right border (symmetry with left border and padding)
            print_color(io, bc, bmap[:r])
            print_nocol(io, plot_padding)
        end
        if has_labels
            print_color(io, right_col, right_str)
            print_nocol(io, 🗷^(max_len_r - right_len))
        end
        # print a colorbar element
        p.cmap.bar && print_colorbar_row(
            io,
            print_nocol,
            print_color,
            p,
            row,
            nr,
            zlab,
            bc,
            cbar_max_len,
            🗷,
        )
        row < nr && print_nocol(io, '\n')
    end
    postprocess!(g)

    (g.visible || p.cmap.bar || has_labels) && print_nocol(io, '\n')

    # draw bottom border
    g.visible && print_border(
        io,
        print_nocol,
        print_color,
        :b,
        nc,
        border_left_pad,
        border_right_pad,
        bmap,
    )
    p.cmap.bar && print_colorbar_lim(
        io,
        print_nocol,
        print_color,
        p,
        min_z_str,
        bc,
        cbar_max_len,
        🗷,
        "",
    )

    # print bottom labels
    w_lbl = 0
    if has_labels
        h_lbl += print_labels(
            io,
            print_nocol,
            print_color,
            p,
            :b,
            nc - 2,
            '\n' * border_left_pad * 🗹,
            🗹 * border_right_cbar_pad,
            🗹,
        )
        if !p.compact[]
            h_w = print_title(
                io,
                print_nocol,
                print_color,
                '\n' * border_left_pad,
                xlab,
                border_right_cbar_pad,
                🗹;
                p_width,
            )
            h_lbl += h_w[1]
            w_lbl += h_w[2]
        end
    end

    # delayed print (buffering)
    print_nocol(end_io, read(buf, String))

    # return the approximate image size
    (
        h_ttl + 1 + nr + 1 + h_lbl,  # +1 for borders
        max(
            w_ttl,
            w_lbl,
            length(border_left_pad) + p_width + length(border_right_cbar_pad),
        ),
    )
end

# generic functions for `FreeTypeExt`
function get_font_face end
function render_string! end
function save_image end

"""
    png_image(p::Plot, font = nothing, pixelsize = 32, transparent = true, foreground = nothing, background = nothing, bounding_box = nothing, bounding_box_glyph = nothing)

Renders a `png` image.

# Arguments
- `pixelsize::Integer = 32`: controls the image size scaling.
- `font::Union{Nothing,AbstractString} = nothing`: select a font by name, or fall-back to a system font.
- `transparent::Bool = true`: use a transparent background.
- `foreground::UserColorType = nothing`: choose a foreground color for un-colored text.
- `background::UserColorType = nothing`: choose a background color for the rendered image.
- `bounding_box::UserColorType = nothing`: debugging bounding box color.
- `bounding_box_glyph::UserColorType = nothing`: debugging glyph bounding box color.
- `row_fact::Union{Nothing,Real} = nothing`: row spacing multiplier (e.g. for histogram).
"""
function png_image(
    p::Plot;
    font::Union{Nothing,AbstractString} = nothing,
    pixelsize::Integer = 32,
    transparent::Bool = true,
    foreground::UserColorType = nothing,
    background::UserColorType = nothing,
    bounding_box_glyph::UserColorType = nothing,
    bounding_box::UserColorType = nothing,
    row_fact::Union{Nothing,Real} = nothing,
)
    canvas = p.graphics
    #####################################
    # visual fixes
    incx = if canvas isa HeatmapCanvas || canvas isa BarplotGraphics || p.cmap.bar
        -1
    else
        0
    end
    row_fact = something(row_fact, if canvas isa BarplotGraphics  # histogram
        1.08
    else
        1.0
    end)
    #####################################

    fg_color = ansi_color(something(foreground, transparent ? 244 : 252))
    bg_color = ansi_color(something(background, 235))

    rgba(color::ColorType, alpha = 1.0) = begin
        color == INVALID_COLOR && (color = fg_color)
        color < THRESHOLD || (color = LUT_8BIT[1 + (color - THRESHOLD)])
        RGBA{Float32}(convert(RGB{Float32}, reinterpret(RGB24, color)), alpha)
    end

    default_fg_color = rgba(fg_color)
    default_bg_color = rgba(bg_color, transparent ? 0.0 : 1.0)
    bbox = if bounding_box ≢ nothing
        rgba(ansi_color(bounding_box))
    else
        bounding_box
    end
    bbox_glyph = if bounding_box_glyph ≢ nothing
        rgba(ansi_color(bounding_box_glyph))
    else
        bounding_box_glyph
    end

    # compute final image size
    noop = (args...; kw...) -> nothing
    nr, nc = _show(devnull, noop, noop, p)

    # hack printing to collect chars & colors
    fchars = sizehint!(Char[], nr * nc)
    gchars = sizehint!(Char[], nr * nc)
    fcolors = sizehint!(RGBA{Float32}[], nr * nc)
    gcolors = sizehint!(RGBA{Float32}[], nr * nc)

    print_nocol(io::IO, args...) = begin
        line = string(args...)
        len = length(line)
        append!(fchars, line)
        append!(gchars, line)
        append!(fcolors, fill(default_fg_color, len))
        append!(gcolors, fill(default_bg_color, len))
        nothing
    end

    print_color(io::IO, color, args...; bgcol = missing) = begin
        fcolor = rgba(ansi_color(color))
        gcolor = if ismissing(bgcol)
            default_bg_color
        else
            rgba(ansi_color(bgcol))
        end
        line = string(args...)
        len = length(line)
        append!(fchars, line)
        append!(gchars, ismissing(bgcol) ? line : fill(FULL_BLOCK, len))  # for heatmap, colorbars - BORDER_SOLID[:l]
        append!(fcolors, fill(fcolor, len))
        append!(gcolors, fill(gcolor, len))
        nothing
    end

    # compute 1D stream of chars and colors
    _show(IOContext(devnull, :color => true), print_nocol, print_color, p)

    # compute 2D grid (image) of chars and colors
    lfchars = sizehint!([Char[]], nr)
    lgchars = sizehint!([Char[]], nr)
    lfcols = sizehint!([RGBA{Float32}[]], nr)
    lgcols = sizehint!([RGBA{Float32}[]], nr)
    r = 1
    for (fchar, gchar, fcol, gcol) ∈ zip(fchars, gchars, fcolors, gcolors)
        if fchar ≡ '\n'
            r += 1
            push!(lfchars, Char[])
            push!(lgchars, Char[])
            push!(lfcols, RGBA{Float32}[])
            push!(lgcols, RGBA{Float32}[])
            continue
        end
        push!(lfchars[r], fchar)
        push!(lgchars[r], gchar)
        push!(lfcols[r], fcol)
        push!(lgcols[r], gcol)
    end

    if (face = get_font_face(font)) ≡ nothing
        @warn "font=$font has not been found, or missing fallback font: no `png` image has been generated."  # COV_EXCL_LINE
        return  # COV_EXCL_LINE
    end

    # render image
    kr = ASPECT_RATIO[]
    kc = kr / 2

    img = fill(
        default_bg_color,
        ceil(Int, kr * pixelsize * nr * row_fact),
        ceil(Int, kc * pixelsize * nc),
    )

    y0 = ceil(Int, (kr * pixelsize) / 2)
    x0 = ceil(Int, (kc * pixelsize * nc) / 2)

    for (r, (fchars, gchars, fcols, gcols)) in
        enumerate(zip(lfchars, lgchars, lfcols, lgcols))
        y = ceil(Int, y0 + (kr * pixelsize * row_fact) * (r - 1))
        incy = render_string!(
            img,
            fchars,
            face,
            pixelsize,
            y,
            x0;
            fcolor = fcols,
            gcolor = gcols,
            bcolor = nothing,  # not needed (initial fill, avoid overlaps)
            valign = :vcenter,
            halign = :hcenter,
            gstr = gchars,
            off_bg = 1,
            bbox_glyph,
            bbox,
            incx,
        )
    end

    img
end

"""
    savefig(p, filename; color = false, kw...)

Save the given plot to a `txt or `png` file.

# Arguments - `txt`
- `color::Bool = false`: output the ANSI color codes to the file.

# Arguments - `png`
see help?> UnicodePlots.png_image

# Examples

```julia-repl
julia> savefig(lineplot([0, 1]), "foo.txt")
julia> savefig(lineplot([0, 1]), "foo.png"; font = "JuliaMono", pixelsize = 32, transparent = false)
```
"""
function savefig(p::Plot, filename::AbstractString; color::Bool = false, kw...)
    ext = lowercase(splitext(filename)[2])
    if ext ∈ ("", ".txt")
        open(filename, "w") do io
            show(IOContext(io, :color => color), p)
        end
    elseif ext == ".png"
        # `png_image` can fail if fonts are not found: a warning has already been
        # thrown there, so just bail out at this stage
        (img = png_image(p; kw...)) ≢ nothing && save_image(filename, img)
    else
        "extension \"$ext\" is unsupported: `savefig` only supports writing to `txt` or `png` files" |>
        ArgumentError |>
        throw
    end
    nothing
end

function Base.string(p::Plot; color = false)
    io = PipeBuffer()
    show(IOContext(io, :color => color), p)
    read(io, String)
end
