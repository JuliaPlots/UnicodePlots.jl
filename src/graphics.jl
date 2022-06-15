abstract type GraphicsArea end

function nrows end
function ncols end
function printrow end

suitable_color(c::GraphicsArea, color::Union{UserColorType,AbstractVector}) = ansi_color(
    color ≡ nothing && length(c.colors) > 0 ? c.colors[end] :
    (color isa AbstractVector ? first(color) : color),
)

Base.print(io::IO, c::GraphicsArea) = _print(io, print, print_color, c)

function _print(io::IO, print_nc, print_col, c::GraphicsArea)
    for row in 1:nrows(c)
        printrow(io, print_nc, print_col, c, row)
        row < nrows(c) && print_nc(io, '\n')
    end
    nothing
end

Base.show(io::IO, c::GraphicsArea) = _show(io, print, print_color, c)

function _show(io::IO, print_nc, print_col, c::GraphicsArea)
    b = BORDER_SOLID
    bc = BORDER_COLOR[]
    border_length = ncols(c)
    print_border(io, print_nc, print_col, :t, border_length, "", "\n", b, bc)
    for row in 1:nrows(c)
        print_col(io, bc, b[:l])
        printrow(io, print_nc, print_col, c, row)
        print_col(io, bc, b[:r])
        row < nrows(c) && print_nc(io, '\n')
    end
    print_border(io, print_nc, print_col, :b, border_length, "\n", "", b, bc)
    nothing
end

printrow(io::IO, c::GraphicsArea, row::Int) = printrow(io, print, print_color, c, row)
