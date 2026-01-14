"""
    ImageGraphics

Structure to hold an image.
"""
struct ImageGraphics{C <: Colorant} <: GraphicsArea
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
    return ImageGraphics(
        img,
        Ref(false),
        true,
        [0, 0],
        sizehint!(Vector{Char}[], h),
        sizehint!(Vector{ColorType}[], h),
        sizehint!(Vector{ColorType}[], h),
    )
end

@inline nrows(c::ImageGraphics) = first(c.encoded_size)
@inline ncols(c::ImageGraphics) = last(c.encoded_size)

# # generic functions for `ImageInTerminalExt`
function terminal_specs end
function sixel_encode end
function imshow end

function preprocess!(io::IO, c::ImageGraphics)
    ctx = IOContext(PipeBuffer(), :displaysize => displaysize(io))
    c.sixel[], char_h, char_w = terminal_specs(c.img)
    postprocess = c -> begin
        c.encoded_size .= (0, 0)
        empty!(c.chars)
        empty!(c.fgcols)
        empty!(c.bgcols)
        nothing
    end
    img_h, img_w = size(c.img)
    c.encoded_size .= if c.sixel[]
        # COV_EXCL_START
        # it is better to encode the whole image in a single pass
        # otherwise, issues with the last line (see previous implementation)
        sixel_encode(ctx, c.img)
        push!(c.chars, read(ctx, String) |> collect)
        length(1:char_h:img_h), ceil(Int, img_w / char_w)
        # COV_EXCL_STOP
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
            for _ in eachindex(chars)
                push!(c.fgcols[row], _fgcol)
                push!(c.bgcols[row], _bgcol)
            end
            nothing
        end
        imshow(ctx, c.img; callback)
        length(c.chars), length(c.chars |> first)
    end
    return postprocess
end

function print_row(io::IO, print_nocol, print_color, c::ImageGraphics, row::Integer)
    1 ≤ row ≤ nrows(c) || throw(ArgumentError("`row` out of bounds: $row"))
    if c.sixel[]  # encoded in a pass => row == 1
        row == 1 && print_nocol(io, String(c.chars[row]))  # COV_EXCL_LINE
    else
        bgcols = c.bgcols[row]
        fgcols = c.fgcols[row]
        chars = c.chars[row]
        for col in 1:ncols(c)
            # NOTE: the last row can be hidden (only the upper pixel colored)
            # see XTermColors.jl/src/ascii.jl - SmallBlocks encoder
            bgcol = (bgcol = bgcols[col]) == INVALID_COLOR ? missing : bgcol
            print_color(io, fgcols[col], chars[col]; bgcol)
        end
    end
    return nothing
end
