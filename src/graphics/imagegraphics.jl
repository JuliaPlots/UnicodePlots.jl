struct ImageGraphics{C<:Colorant} <: GraphicsArea
    img::Matrix{C}
    sixel::RefValue{Bool}
    visible::Bool
    encoded_size::Vector{Int}
    ren::Vector{String}
end

ImageGraphics(img::AbstractArray{<:Colorant}) =
    ImageGraphics(img, Ref(false), true, [0, 0], String[])

@inline nrows(c::ImageGraphics) = c.encoded_size[1]
@inline ncols(c::ImageGraphics) = c.encoded_size[2]

function preprocess!(io::IO, c::ImageGraphics)
    ctx = IOContext(PipeBuffer(), :displaysize => displaysize(io))
    c.sixel[] = false
    char_h = char_w = nothing  # determine the terminal caret size, in pixels
    if ImageInTerminal.choose_sixel(c.img)
        ans = ImageInTerminal.Sixel.TerminalTools.query_terminal("\e[16t", stdout)
        if ans isa String && (m = match(r"\e\[6;(\d+);(\d+)t", ans)) ≢ nothing
            char_h, char_w = tryparse.(Int, m.captures)
            c.sixel[] = char_h ≢ nothing && char_w ≢ nothing
        end
    end
    if c.sixel[]
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

function print_row(io::IO, _, print_color, c::ImageGraphics, row::Integer)
    0 < row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    print_color(io, INVALID_COLOR, c.ren[row])  # color already encoded
    nothing
end
