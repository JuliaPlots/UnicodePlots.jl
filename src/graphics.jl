abstract type GraphicsArea end

function nrows end
function ncols end
function printrow end

suitable_color(c::GraphicsArea, color::Union{UserColorType,AbstractVector}) = ansi_color(
    color === nothing && length(c.colors) > 0 ? c.colors[end] :
    (color isa AbstractVector ? first(color) : color),
)

function Base.print(io::IO, c::GraphicsArea)
    for row in 1:nrows(c)
        printrow(io, c, row)
        row < nrows(c) && println(io)
    end
    nothing
end

function Base.show(io::IO, c::GraphicsArea)
    b = BORDER_SOLID
    bc = BORDER_COLOR[]
    border_length = ncols(c)
    print_border(io, :t, border_length, "", "\n", b, bc)
    for row in 1:nrows(c)
        print_color(bc, io, b[:l])
        printrow(io, c, row)
        print_color(bc, io, b[:r])
        row < nrows(c) && println(io)
    end
    print_border(io, :b, border_length, "\n", "", b, bc)
    nothing
end
