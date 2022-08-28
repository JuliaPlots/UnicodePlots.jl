function print_colorbar_row(
    io::IO,
    print_nocol,
    print_color,
    c::Canvas,
    row::Integer,
    cmap::ColorMap,
    lim_str,
    plot_padding,
    zlabel,
    max_len,
    blank::AbstractChar,
)
    b = BORDERMAP[cmap.border]
    bc = BORDER_COLOR[]
    label = ""
    if row == 1
        label = lim_str[2]
        # print top border and maximum z value
        print_color(io, bc, b[:tl], b[:t], b[:t], b[:tr])
        print_nocol(io, plot_padding)
        print_color(io, bc, label)
    elseif row == nrows(c)
        label = lim_str[1]
        # print bottom border and minimum z value
        print_color(io, bc, b[:bl], b[:b], b[:b], b[:br])
        print_nocol(io, plot_padding)
        print_color(io, bc, label)
    else
        # print gradient
        print_color(io, bc, b[:l])
        if cmap.lim[1] == cmap.lim[2]  # if min and max are the same, single color
            fgcol = bgcol = cmap.callback(1, 1, 1)
        else  # otherwise, blend from min to max
            n = 2(nrows(c) - 2)
            r = row - 2
            fgcol = cmap.callback(n - 2r - 1, 1, n)
            bgcol = cmap.callback(n - 2r, 1, n)
        end
        print_color(io, fgcol, HALF_BLOCK, HALF_BLOCK; bgcol = bgcol)
        print_color(io, bc, b[:r])
        print_nocol(io, plot_padding)
        # print z label
        if row == div(nrows(c), 2) + 1
            label = zlabel
            print_nocol(io, label)
        end
    end
    print_nocol(io, blank^(max_len - length(label)))
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
    pre_pad = blank^(offset > 0 ? offset : 0)
    print_nocol(io, left_pad, pre_pad)
    print_color(io, color, title)
    post_pad = blank^(max(0, p_width - length(pre_pad) - length(title)))
    print_nocol(io, post_pad, right_pad)
    (
        count(string('\n'), title) + 1,  # NOTE: string(...) for compat with 1.6
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
    mloc::Symbol,
    p::Plot,
    border_length,
    left_pad::AbstractString,
    right_pad::AbstractString,
    blank::AbstractChar,
)
    p.labels || return 0
    bc        = BORDER_COLOR[]
    lloc      = Symbol(mloc, :l)
    rloc      = Symbol(mloc, :r)
    left_str  = get(p.decorations, lloc, "")
    left_col  = get(p.colors_deco, lloc, bc)
    mid_str   = get(p.decorations, mloc, "")
    mid_col   = get(p.colors_deco, mloc, bc)
    right_str = get(p.decorations, rloc, "")
    right_col = get(p.colors_deco, rloc, bc)
    if left_str != "" || right_str != "" || mid_str != ""
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
    return 0
end

Base.show(io::IO, p::Plot) = _show(io, print, print_color, p)

function _show(end_io::IO, print_nocol, print_color, p::Plot)
    buf = PipeBuffer()  # buffering, for performance
    io_color = get(end_io, :color, false)
    io = IOContext(buf, :color => io_color, :displaysize => displaysize(end_io))

    c = p.graphics
    🗷 = Char(BLANK)  # blank outside canvas
    🗹 = blank(c)  # blank inside canvas
    ############################################################
    # 🗷 = 'x'  # debug
    # 🗹 = Char(typeof(c) <: BrailleCanvas ? '⠿' : 'o')  # debug
    ############################################################
    postprocess! = preprocess!(io, c)

    nr = nrows(c)
    nc = ncols(c)
    p_width = nc + 2  # left corner + border length (number of canvas cols) + right corner

    bmap = BORDERMAP[p.border ≡ :none && c isa BrailleCanvas ? :bnone : p.border]
    bc = BORDER_COLOR[]

    # get length of largest strings to the left and right
    max_len_l = if p.labels && !isempty(p.labels_left)
        maximum(map(length ∘ no_ansi_escape, values(p.labels_left)))
    else
        0
    end
    max_len_r = if p.labels && !isempty(p.labels_right)
        maximum(map(length ∘ no_ansi_escape, values(p.labels_right)))
    else
        0
    end
    if !p.compact && p.labels && ylabel(p) != ""
        max_len_l += length(ylabel(p)) + 1
    end

    # offset where the plot (including border) begins
    plot_offset = max_len_l + p.margin + p.padding

    # padding-string from left to border
    plot_padding = 🗷^p.padding

    cbar_pad = if p.cmap.bar
        min_max_z_str =
            map(x -> nice_repr(roundable(x) ? x : float_round_log10(x)), p.cmap.lim)
        cbar_max_len = maximum(length, (min_max_z_str..., no_ansi_escape(zlabel(p))))
        plot_padding * 🗹^4 * plot_padding * 🗷^cbar_max_len
    else
        ""
    end

    # padding-string between labels and border
    border_left_pad = 🗷^plot_offset

    # trailing
    border_right_pad = 🗷^max_len_r * (p.labels ? plot_padding : "") * cbar_pad

    # plot the title and the top border
    h_ttl, w_ttl = print_title(
        io,
        print_nocol,
        print_color,
        border_left_pad,
        title(p),
        border_right_pad * '\n',
        🗹;
        p_width = p_width,
        color = io_color ? Crayon(foreground = :white, bold = true) : nothing,
    )
    h_lbl = print_labels(
        io,
        print_nocol,
        print_color,
        :t,
        p,
        nc - 2,
        border_left_pad * 🗹,
        🗹 * border_right_pad * '\n',
        🗹,
    )
    c.visible && print_border(
        io,
        print_nocol,
        print_color,
        :t,
        nc,
        border_left_pad,
        border_right_pad * '\n',
        bmap,
    )

    # compute position of ylabel
    y_lab_row = round(nr / 2, RoundNearestTiesUp)

    # plot all rows
    for row ∈ 1:nr
        # print left annotations
        print_nocol(io, 🗷^p.margin)
        if p.labels
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
            if !p.compact && row == y_lab_row
                # print ylabel
                print_color(io, :normal, ylabel(p))
                print_nocol(io, 🗷^(max_len_l - length(ylabel(p)) - left_len))
            else
                # print padding to fill ylabel length
                print_nocol(io, 🗷^(max_len_l - left_len))
            end
            # print the left annotation
            print_color(io, left_col, left_str)
        end
        if c.visible
            # print left border
            print_nocol(io, plot_padding)
            print_color(io, bc, bmap[:l])
            # print canvas row
            print_row(io, print_nocol, print_color, c, row)
            if c isa ImgCanvas && c.sixel[]
                offset = plot_offset + nc + 1
                # 1F: move cursor to beginning of previous line, 1 line up
                # $(offset)C: move cursor right $offset columns
                write(io, "\e[1F\e[$(offset)C")
            end
            # print right label and padding
            print_color(io, bc, bmap[:r])
        end
        if p.labels
            print_nocol(io, plot_padding)
            print_color(io, right_col, right_str)
            print_nocol(io, 🗷^(max_len_r - right_len))
        end
        # print colorbar
        if p.cmap.bar
            print_nocol(io, plot_padding)
            print_colorbar_row(
                io,
                print_nocol,
                print_color,
                c,
                row,
                p.cmap,
                min_max_z_str,
                plot_padding,
                zlabel(p),
                cbar_max_len,
                🗷,
            )
        end
        row < nrows(c) && print_nocol(io, '\n')
    end

    postprocess!(c)

    # draw bottom border
    c.visible && print_border(
        io,
        print_nocol,
        print_color,
        :b,
        nc,
        '\n' * border_left_pad,
        border_right_pad,
        bmap,
    )
    # print bottom labels
    w_lbl = 0
    if p.labels
        h_lbl += print_labels(
            io,
            print_nocol,
            print_color,
            :b,
            p,
            nc - 2,
            '\n' * border_left_pad * 🗹,
            🗹 * border_right_pad,
            🗹,
        )
        if !p.compact
            h_w = print_title(
                io,
                print_nocol,
                print_color,
                '\n' * border_left_pad,
                xlabel(p),
                border_right_pad,
                🗹;
                p_width = p_width,
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
        max(w_ttl, w_lbl, length(border_left_pad) + p_width + length(border_right_pad)),
    )
end

# COV_EXCL_START
fallback_font(mono::Bool = false) =
    if Sys.islinux()
        mono ? "DejaVu Sans Mono" : "DejaVu Sans"
    elseif Sys.isbsd()
        mono ? "Courier New" : "Helvetica"
    elseif Sys.iswindows()
        mono ? "Courier New" : "Arial"
    else
        @warn "Unsupported $(Base.KERNEL)"
        mono ? "Courier" : "Helvetica"
    end
# COV_EXCL_STOP

const FT_FONTS = Dict{String,FreeTypeAbstraction.FTFont}()

"""
    png_image(p::Plot, font = nothing, pixelsize = 32, transparent = true, foreground = nothing, background = nothing, bounding_box = nothing, bounding_box_glyph = nothing)

Render `png` image.

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

    # render image
    face = nothing
    for name ∈ filter(!isnothing, (font, "JuliaMono", fallback_font()))
        if (face = get(FT_FONTS, name, nothing)) ≡ nothing
            if (ft = FreeTypeAbstraction.findfont(name)) ≢ nothing
                face = FT_FONTS[name] = ft
                break
            end
        else
            break
        end
    end

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
        incy = FreeTypeAbstraction.renderstring!(
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
            bbox_glyph = bbox_glyph,
            bbox = bbox,
            gstr = gchars,
            off_bg = 1,
            incx = incx,
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
julia> savefig(lineplot([0, 1]), "foo.png"; font = "JuliaMono", pixelsize = 32)
```
"""
function savefig(p::Plot, filename::AbstractString; color::Bool = false, kw...)
    ext = lowercase(splitext(filename)[2])
    if ext ∈ ("", ".txt")
        open(filename, "w") do io
            show(IOContext(io, :color => color), p)
        end
    elseif ext == ".png"
        FileIO.save(filename, png_image(p; kw...))
    else
        throw(
            ArgumentError(
                "extension \"$ext\" is unsupported: `savefig` only supports writing to `txt` or `png` files",
            ),
        )
    end
    nothing
end

function Base.string(p::Plot; color = false)
    io = PipeBuffer()
    show(IOContext(io, :color => color), p)
    read(io, String)
end
