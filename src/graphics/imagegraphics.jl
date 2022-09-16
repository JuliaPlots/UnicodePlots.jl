struct ImageGraphics{C<:Colorant} <: GraphicsArea
    img::Matrix{C}
    sixel::RefValue{Bool}
    visible::Bool
    encoded_size::Vector{Int}
    chars::Vector{Vector{Char}}  # nested vector structure chars[row][col] is more suited for this context
    fgcols::Vector{Vector{ColorType}}  # only used in no-sixel context
    bgcols::Vector{Vector{ColorType}}  # only used in no-sixel context
end

ImageGraphics(img::AbstractArray{<:Colorant}) = ImageGraphics(
    img,
    Ref(false),
    true,
    [0, 0],
    Vector{Char}[],
    Vector{ColorType}[],
    Vector{ColorType}[],
)

@inline nrows(c::ImageGraphics) = c.encoded_size[1]
@inline ncols(c::ImageGraphics) = c.encoded_size[2]

function preprocess!(io::IO, c::ImageGraphics)
    ctx = IOContext(PipeBuffer(), :displaysize => displaysize(io))
    c.sixel[] = false
    char_h = char_w = nothing  # determine the terminal caret size, in pixels
    if (choose_sixel = ImageInTerminal.choose_sixel(c.img))
        ans = ImageInTerminal.Sixel.TerminalTools.query_terminal("\e[16t", stdout)
        if ans isa String && (m = match(r"\e\[6;(\d+);(\d+)t", ans)) ≢ nothing
            char_h, char_w = tryparse.(Int, m.captures)
            c.sixel[] = char_h ≢ nothing && char_w ≢ nothing
        end
    end
    postprocess = c -> begin
        c.encoded_size .= (0, 0)
        empty!(c.chars)
        empty!(c.fgcols)
        empty!(c.bgcols)
        nothing
    end
    if c.sixel[]
        h, w = size(c.img)
        for r ∈ 1:char_h:h
            ImageInTerminal.sixel_encode(ctx, c.img[r:min(r + char_h - 1, h), :])
            push!(c.chars, read(ctx, String) |> collect)
        end
        nc = ceil(Int, w / char_w)
    else
        ImageInTerminal.imshow(ctx, c.img)
        lines_colors = readlines(ctx)  # characters and ansi colors
        re_bg_24bit = r"\e\[38;2;(\d+);(\d+);(\d+);48;2;(\d+);(\d+);(\d+)m"
        re_bg_8bit = r"\e\[38;5;(\d+);48;5;(\d+)m"
        re_fg_24bit = r"\e\[38;2;(\d+);(\d+);(\d+)m"
        re_fg_8bit = r"\e\[38;5;(\d+)m"
        line1 = first(lines_colors)
        nc = line1 |> no_ansi_escape |> length
        invalid = m -> INVALID_COLOR
        re, re_fg, fgcolor, bgcolor =
            if eachmatch(re_bg_24bit, line1) |> collect |> length > 0
                (
                    re_bg_24bit,
                    re_fg_24bit,
                    m -> ansi_color(parse.(Int, m.captures[1:3]) |> Tuple),
                    m -> ansi_color(parse.(Int, m.captures[4:6]) |> Tuple),
                )
            elseif eachmatch(re_bg_8bit, line1) |> collect |> length > 0
                (
                    re_bg_8bit,
                    re_fg_8bit,
                    m -> ansi_color(parse(Int, m.captures[1])),
                    m -> ansi_color(parse(Int, m.captures[2])),
                )
            elseif eachmatch(re_fg_24bit, line1) |> collect |> length > 0
                (
                    re_fg_24bit,
                    re_fg_24bit,
                    m -> ansi_color(parse.(Int, m.captures) |> Tuple),
                    invalid,
                )
            elseif eachmatch(re_fg_8bit, line1) |> collect |> length > 0
                (
                    re_fg_8bit,
                    re_fg_8bit,
                    m -> ansi_color(parse(Int, m.captures[1])),
                    invalid,
                )
            else
                # degenerate case where the sixel encoder is chosen, but auto selection in `ImageInTerminal.Sixel.TerminalTools` failed (e.g. tests)
                @error "something went wrong: choose_sixel=$choose_sixel - c.sixel[]=$(c.sixel[])"
                return postprocess
            end
        for line_col in lines_colors
            push!(c.chars, no_ansi_escape(line_col) |> collect)
            colors, bgcolor =
                if (colors = eachmatch(re, line_col) |> collect) |> length == 0
                    eachmatch(re_fg, line_col) |> collect, invalid
                else
                    colors, bgcolor
                end
            push!(c.fgcols, fgcolor.(colors))
            push!(c.bgcols, bgcolor.(colors))
        end
    end
    c.encoded_size .= length(c.chars), nc
    postprocess
end

function print_row(io::IO, _, print_color, c::ImageGraphics, row::Integer)
    0 < row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    if c.sixel[]
        print_color(io, INVALID_COLOR, String(c.chars[row]))  # color already encoded
    else
        for col ∈ 1:ncols(c)
            bgcol = (bgcol = c.bgcols[row][col]) == INVALID_COLOR ? missing : bgcol
            print_color(io, c.fgcols[row][col], c.chars[row][col]; bgcol = bgcol)
        end
    end
    nothing
end
