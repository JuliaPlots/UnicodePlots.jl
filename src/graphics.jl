abstract type GraphicsArea end

function nrows end
function ncols end
function printrow end

function Base.print(io::IO, c::GraphicsArea)
    for row in 1:(nr = nrows(c))
        printrow(io, c, row)
        row < nr && println(io)
    end
    nothing
end

function Base.show(io::IO, c::GraphicsArea)
    b = border_solid
    border_length = ncols(c)
    print_border(io, :t, border_length, "", "\n", bordermap[:solid], :light_black)
    for row in 1:(nr = nrows(c))
        print_color(:light_black, io, b[:l])
        printrow(io, c, row)
        print_color(:light_black, io, b[:r])
        row < nr && println(io)
    end
    print_border(io, :b, border_length, "\n", "", bordermap[:solid], :light_black)
    nothing
end
