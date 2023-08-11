"""
FilledCanvas uses the Unicode [Symbols for Legacy Computing](https://en.wikipedia.org/wiki/Symbols_for_Legacy_Computing)
to draw boundary segments. This is used for filled contour plots.
"""

struct FilledCanvas{YS<:Function,XS<:Function} <: LookupCanvas
    grid::Transpose{UInt16,Matrix{UInt16}}
    colors::Transpose{ColorType,Matrix{ColorType}}
    visible::Bool
    blend::Bool
    yflip::Bool
    xflip::Bool
    pixel_height::Int
    pixel_width::Int
    origin_y::Float64
    origin_x::Float64
    height::Float64
    width::Float64
    min_max::NTuple{2,UnicodeType}
    yscale::YS
    xscale::XS
end

const FILLED_LOOKUP = Dict{NTuple{2, Int},Char}()

FILLED_LOOKUP[(1, 4)]= '🭍'
FILLED_LOOKUP[(1, 5)]= '🭏'
FILLED_LOOKUP[(1, 6)]= '◣'
FILLED_LOOKUP[(1, 7)]= '🭀'
FILLED_LOOKUP[(2, 4)]= '🭌'
FILLED_LOOKUP[(2, 5)]= '🭎'
FILLED_LOOKUP[(2, 6)]= '🭐'
FILLED_LOOKUP[(2, 7)]= '▌'
FILLED_LOOKUP[(2, 8)]= '🭛'
FILLED_LOOKUP[(2, 9)]= '🭙'
FILLED_LOOKUP[(2, 10)]= '🭗'
FILLED_LOOKUP[(3, 7)]= '🭡'
FILLED_LOOKUP[(3, 8)]= '◤'
FILLED_LOOKUP[(3, 9)]= '🭚'
FILLED_LOOKUP[(3, 10)]= '🭘'
FILLED_LOOKUP[(4, 1)]= '🭣'
FILLED_LOOKUP[(4, 2)]= '🭢'
FILLED_LOOKUP[(4, 7)]= '🭟'
FILLED_LOOKUP[(4, 8)]= '🭠'
FILLED_LOOKUP[(4, 9)]= '🭜'
FILLED_LOOKUP[(4, 10)]= '🬂'
FILLED_LOOKUP[(5, 1)]= '🭥'
FILLED_LOOKUP[(5, 2)]= '🭤'
FILLED_LOOKUP[(5, 7)]= '🭝'
FILLED_LOOKUP[(5, 8)]= '🭞'
FILLED_LOOKUP[(5, 9)]= '🬎'
FILLED_LOOKUP[(5, 10)]= '🭧'
FILLED_LOOKUP[(6, 1)]= '◥'
FILLED_LOOKUP[(6, 2)]= '🭦'
FILLED_LOOKUP[(6, 9)]= '🭓'
FILLED_LOOKUP[(6, 10)]= '🭕'
FILLED_LOOKUP[(7, 1)]= '🭖'
FILLED_LOOKUP[(7, 2)]= '▐'
FILLED_LOOKUP[(7, 3)]= '🭋'
FILLED_LOOKUP[(7, 4)]= '🭉'
FILLED_LOOKUP[(7, 5)]= '🭇'
FILLED_LOOKUP[(7, 9)]= '🭒'
FILLED_LOOKUP[(7, 10)]= '🭔'
FILLED_LOOKUP[(8, 2)]= '🭅'
FILLED_LOOKUP[(8, 3)]= '◢'
FILLED_LOOKUP[(8, 4)]= '🭊'
FILLED_LOOKUP[(8, 5)]= '🭈'
FILLED_LOOKUP[(9, 2)]= '🭃'
FILLED_LOOKUP[(9, 3)]= '🭄'
FILLED_LOOKUP[(9, 4)]= '🭆'
FILLED_LOOKUP[(9, 5)]= '🬭'
FILLED_LOOKUP[(9, 6)]= '🬽'
FILLED_LOOKUP[(9, 7)]= '🬼'
FILLED_LOOKUP[(10, 2)]= '🭁'
FILLED_LOOKUP[(10, 3)]= '🭂'
FILLED_LOOKUP[(10, 4)]= '🬹'
FILLED_LOOKUP[(10, 5)]= '🭑'
FILLED_LOOKUP[(10, 6)]= '🬿'
FILLED_LOOKUP[(10, 7)]= '🬾'

const N_FILLED = grid_type(FilledCanvas)(56)
const FILLED_DECODE = Vector{Char}(undef, typemax(N_FILLED))

FILLED_DECODE[1] = EMPTY_BLOCK   # replaced during rendering, not to overdraw lower layers
FILLED_DECODE[2] = FULL_BLOCK
let n = 0
    for (_, v) ∈ sort(collect(FILLED_LOOKUP))
        FILLED_DECODE[(n += 1)+2] = v
    end
end

@inline x_pixel_per_char(::Type{<:FilledCanvas}) = 1
@inline y_pixel_per_char(::Type{<:FilledCanvas}) = 1

@inline lookup_encode(::FilledCanvas) = FILLED_ENCODE
@inline lookup_decode(::FilledCanvas) = FILLED_DECODE
@inline lookup_offset(::FilledCanvas) = N_FILLED

FilledCanvas(args...; kw...) = CreateLookupCanvas(FilledCanvas, (0, 56), args...; kw...)
