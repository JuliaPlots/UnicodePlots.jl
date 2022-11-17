abstract type GraphicsArea end

@inline blank(c::GraphicsArea) = Char(BLANK)

suitable_color(c::GraphicsArea, color::Union{UserColorType,AbstractVector}) = ansi_color(
    color ≡ nothing && length(c.colors) > 0 ? c.colors[end] :
    (color isa AbstractVector ? first(color) : color),
)

Base.print(io::IO, c::GraphicsArea) = _print(io, print, print_color, c)

function _print(io::IO, print_nocol, print_color, c::GraphicsArea)
    postprocess! = preprocess!(io, c)
    for row ∈ 1:nrows(c)
        print_row(io, print_nocol, print_color, c, row)
        row < nrows(c) && print_nocol(io, '\n')
    end
    postprocess!(c)
    nothing
end

Base.show(io::IO, c::GraphicsArea) = _show(io, print, print_color, c)

function _show(io::IO, print_nocol, print_color, c::GraphicsArea)
    b = BORDER_SOLID
    bc = BORDER_COLOR[]
    border_length = ncols(c)
    print_border(io, print_nocol, print_color, :t, border_length, nothing, '\n', b, bc)
    postprocess! = preprocess!(io, c)
    for row ∈ 1:nrows(c)
        print_color(io, bc, b[:l])
        print_row(io, print_nocol, print_color, c, row)
        print_color(io, bc, b[:r])
        row < nrows(c) && print_nocol(io, '\n')
    end
    postprocess!(c)
    print_border(io, print_nocol, print_color, :b, border_length, '\n', nothing, b, bc)
    nothing
end

print_row(io::IO, c::GraphicsArea, row::Integer) = print_row(io, print, print_color, c, row)

"""
    preprocess!(c::GraphicsArea)

Optional step: pre-process canvas before printing rows (e.g. for costly computations).
Returns a callback for optional cleanup after printing.
"""
preprocess!(::IO, c::GraphicsArea) = c -> nothing
