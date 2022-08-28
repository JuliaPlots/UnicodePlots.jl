struct ImgCanvas{C<:Colorant} <: Canvas
    img::Matrix{C}
    sixel::RefValue{Bool}
    visible::Bool
    encoded_size::Vector{Int}
    ren::Vector{String}
end

ImgCanvas(img::AbstractArray{<:Colorant}) =
    ImgCanvas(img, Ref(false), true, [0, 0], String[])

@inline nrows(c::ImgCanvas) = c.encoded_size[1]
@inline ncols(c::ImgCanvas) = c.encoded_size[2]

function preprocess!(io::IO, c::ImgCanvas)
    ctx = IOContext(PipeBuffer(), :displaysize => displaysize(io))
    caret = fallback_caret = 15, 7  # determine the terminal caret size, in pixels
    c.sixel[] = false
    if ImageInTerminal.choose_sixel(c.img)
        ans = ImageInTerminal.Sixel.TerminalTools.query_terminal("\e[16t", stdout)
        if ans isa String && (m = match(r"\e\[6;(\d+);(\d+)t", ans)) ≢ nothing
            caret = tryparse.(Int, m.captures)
            c.sixel[] = true
        end
    end
    if c.sixel[]
        char_h, char_w = something.(caret, fallback_caret)
        h, w = size(c.img)
        lines = String[]
        for r ∈ 1:char_h:h
            ImageInTerminal.sixel_encode(ctx, c.img[r:min(r + char_h - 1, h), :])
            push!(lines, read(ctx, String))
        end
        nc = ceil(Int, w / char_w)
    else
        ImageInTerminal.imshow(ctx, c.img)
        lines = readlines(ctx)
        nc = length(no_ansi_escape(first(lines)))
    end
    c.encoded_size .= length(lines), nc
    resize!(c.ren, nrows(c))
    copyto!(c.ren, lines)
    c -> nothing
end

function print_row(io::IO, print_nocol, _, c::ImgCanvas, row::Integer)
    0 < row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    print_nocol(io, c.ren[row])
    nothing
end
