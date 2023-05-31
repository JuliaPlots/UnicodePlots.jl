module UnitfulExt

import UnicodePlots: UnicodePlots, KEYWORDS, Plot, Canvas
UnicodePlots.@ext_imp_use :import Unitful Quantity RealOrRealQuantity ustrip unit

function unit_str(x, fancy)
    io = IOContext(PipeBuffer(), :fancy_exponent => fancy)
    show(io, unit(x))
    read(io, String)
end

unit_label(label::AbstractString, unit::AbstractString) =
    (lab_strip = rstrip(label)) |> isempty ? unit : "$lab_strip ($unit)"
unit_label(label::AbstractString, unit::Nothing) = rstrip(label)

number_unit(x::Union{AbstractVector,Number}, args...) = x, nothing
number_unit(x::AbstractVector{<:Quantity}, fancy = true) =
    ustrip.(x), unit_str(first(x), fancy)
number_unit(x::Quantity, fancy = true) = ustrip(x), unit_str(x, fancy)

maybe_ustrip(x::Quantity) = ustrip(x)
maybe_ustrip(x) = x

UnicodePlots.strip_units(x) = maybe_ustrip(x)

# ---------------------------------------------------------------------------- #
# lineplot
function UnicodePlots.lineplot(
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:Quantity};
    unicode_exponent::Bool = KEYWORDS.unicode_exponent,
    xlabel = KEYWORDS.xlabel,
    ylabel = KEYWORDS.ylabel,
    kw...,
)
    x, ux = number_unit(x, unicode_exponent)
    y, uy = number_unit(y, unicode_exponent)
    UnicodePlots.lineplot(
        maybe_ustrip.(x),
        maybe_ustrip.(y);
        xlabel = unit_label(xlabel, ux),
        ylabel = unit_label(ylabel, uy),
        unicode_exponent,
        kw...,
    )
end

UnicodePlots.lineplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:Quantity};
    kw...,
) = UnicodePlots.lineplot!(plot, maybe_ustrip.(x), maybe_ustrip.(y); kw...)

# ---------------------------------------------------------------------------- #
# scatterplot
function UnicodePlots.scatterplot(
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:Quantity};
    unicode_exponent::Bool = KEYWORDS.unicode_exponent,
    xlabel = KEYWORDS.xlabel,
    ylabel = KEYWORDS.ylabel,
    kw...,
)
    x, ux = number_unit(x, unicode_exponent)
    y, uy = number_unit(y, unicode_exponent)
    UnicodePlots.scatterplot(
        maybe_ustrip.(x),
        maybe_ustrip.(y);
        xlabel = unit_label(xlabel, ux),
        ylabel = unit_label(ylabel, uy),
        unicode_exponent,
        kw...,
    )
end

UnicodePlots.scatterplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:Quantity};
    kw...,
) = UnicodePlots.scatterplot!(plot, maybe_ustrip.(x), maybe_ustrip.(y); kw...)

end  # module
