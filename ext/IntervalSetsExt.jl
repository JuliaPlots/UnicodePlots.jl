module IntervalSetsExt

import UnicodePlots: UnicodePlots, Plot, Canvas
UnicodePlots.@ext_imp_use :import IntervalSets

UnicodePlots.lineplot(
    x::IntervalSets.AbstractInterval,
    f::Function;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot(range(x; length, step), f; kw...)

UnicodePlots.lineplot!(
    plot::Plot{<:Canvas},
    x::IntervalSets.AbstractInterval,
    f::Function;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot!(plot, range(x; length, step), f; kw...)

UnicodePlots.lineplot(
    x::IntervalSets.AbstractInterval,
    F::AbstractVector{<:Function};
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot(range(x; length, step), F; kw...)

end  # module
