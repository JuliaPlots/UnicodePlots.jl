abstract type GraphicsArea end

function nrows end
function ncols end
function printrow end

function Base.print(io::IO, c::GraphicsArea)
    for row in 1:nrows(c)
        printrow(io, c, row)
        row < nrows(c) && print(io, '\n')
    end
end

function Base.show(io::IO, c::GraphicsArea)
    b = border_solid
    border_length = ncols(c)
    print_border_top(io, "", border_length, :solid, :light_black)
    print(io, '\n')
    for row in 1:nrows(c)
        print_color(:light_black, io, b[:l])
        printrow(io, c, row)
        print_color(:light_black, io, b[:r])
        print(io, '\n')
    end
    print_border_bottom(io, "", border_length, :solid, :light_black)
end
