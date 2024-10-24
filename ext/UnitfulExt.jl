module UnitfulExt

import UnicodePlots: UnicodePlots, KEYWORDS, Plot, Canvas, unitless
import Unitful: Quantity, RealOrRealQuantity, ustrip, unit

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

unitless(x::Quantity) = ustrip(x)  # NOTE: keep in sync with src/common.jl

# ---------------------------------------------------------------------------- #
# lineplot
function UnicodePlots.lineplot(
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:RealOrRealQuantity};
    unicode_exponent::Bool = KEYWORDS.unicode_exponent,
    canvas::Type = KEYWORDS.canvas,
    xlabel = KEYWORDS.xlabel,
    ylabel = KEYWORDS.ylabel,
    kw...,
)
    pkw, okw = UnicodePlots.split_plot_kw(kw)
    x, ux = number_unit(x, unicode_exponent)
    y, uy = number_unit(y, unicode_exponent)
    x_, y_ = unitless.(x), unitless.(y)
    plot = Plot(
        x_,
        y_,
        nothing,
        canvas;
        xlabel = unit_label(xlabel, ux),
        ylabel = unit_label(ylabel, uy),
        unicode_exponent,
        pkw...,
    )
    UnicodePlots.lineplot!(plot, x_, y_; okw...)
end

UnicodePlots.lineplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:Quantity};
    kw...,
) = UnicodePlots.lineplot!(plot, unitless.(x), unitless.(y); kw...)

# ---------------------------------------------------------------------------- #
# scatterplot
function UnicodePlots.scatterplot(
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:RealOrRealQuantity};
    unicode_exponent::Bool = KEYWORDS.unicode_exponent,
    canvas::Type = KEYWORDS.canvas,
    xlabel = KEYWORDS.xlabel,
    ylabel = KEYWORDS.ylabel,
    kw...,
)
    pkw, okw = UnicodePlots.split_plot_kw(kw)
    x, ux = number_unit(x, unicode_exponent)
    y, uy = number_unit(y, unicode_exponent)
    x_, y_ = unitless.(x), unitless.(y)
    plot = Plot(
        x_,
        y_,
        nothing,
        canvas;
        xlabel = unit_label(xlabel, ux),
        ylabel = unit_label(ylabel, uy),
        unicode_exponent,
        pkw...,
    )
    UnicodePlots.scatterplot!(plot, x_, y_; okw...)
end

UnicodePlots.scatterplot!(
    plot::Plot{<:Canvas},
    x::AbstractVector{<:RealOrRealQuantity},
    y::AbstractVector{<:Quantity};
    kw...,
) = UnicodePlots.scatterplot!(plot, unitless.(x), unitless.(y); kw...)

end  # module
