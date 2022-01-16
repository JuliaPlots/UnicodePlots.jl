abstract type GraphicsArea end

function nrows end
function ncols end
function printrow end

function Base.print(io::IO, c::GraphicsArea)
    for row in 1:nrows(c)
        printrow(io, c, row)
        row < nrows(c) && println(io)
    end
    nothing
end

function Base.show(io::IO, c::GraphicsArea)
    b = border_solid
    border_length = ncols(c)
    print_border(io, :t, border_length, "", "\n", bordermap[:solid], BORDER_COLOR[])
    for row in 1:nrows(c)
        print_color(BORDER_COLOR[], io, b[:l])
        printrow(io, c, row)
        print_color(BORDER_COLOR[], io, b[:r])
        row < nrows(c) && println(io)
    end
    print_border(io, :b, border_length, "\n", "", bordermap[:solid], BORDER_COLOR[])
    nothing
end
