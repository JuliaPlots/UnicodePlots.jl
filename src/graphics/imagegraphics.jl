struct ImageGraphics{C<:Colorant} <: GraphicsArea
    img::Matrix{C}
    sixel::RefValue{Bool}
    visible::Bool
    encoded_size::Vector{Int}
    chars::Vector{Vector{Char}}  # nested vector structure chars[row][col] is more suited for this context
    fgcols::Vector{Vector{ColorType}}  # only used in no-sixel context
    bgcols::Vector{Vector{ColorType}}  # only used in no-sixel context
end

function ImageGraphics(img::AbstractArray{<:Colorant})
    h = size(img, 1)
    ImageGraphics(
        img,
        Ref(false),
        true,
        [0, 0],
        sizehint!(Vector{Char}[], h),
        sizehint!(Vector{ColorType}[], h),
        sizehint!(Vector{ColorType}[], h),
    )
end

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
    postprocess = c -> begin
        c.encoded_size .= (0, 0)
        empty!(c.chars)
        empty!(c.fgcols)
        empty!(c.bgcols)
        nothing
    end
    img_h, img_w = size(c.img)
    if c.sixel[]
        for r ∈ 1:char_h:img_h
            ImageInTerminal.sixel_encode(ctx, c.img[r:min(r + char_h - 1, img_h), :])
            push!(c.chars, read(ctx, String) |> collect)
        end
        nc = ceil(Int, img_w / char_w)
    else
        callback(I, fgcol, bgcol, chars...) = begin
            if (row = first(I)) > length(c.chars)
                push!(c.chars, sizehint!(Char[], img_w))
                push!(c.fgcols, sizehint!(ColorType[], img_w))
                push!(c.bgcols, sizehint!(ColorType[], img_w))
            end
            append!(c.chars[row], chars)
            _fgcol = ansi_color(fgcol)
            _bgcol = ansi_color(bgcol)
            for _ ∈ eachindex(chars)
                push!(c.fgcols[row], _fgcol)
                push!(c.bgcols[row], _bgcol)
            end
            nothing
        end
        ImageInTerminal.imshow(ctx, c.img; callback = callback)
        nc = length(c.chars |> first)
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
