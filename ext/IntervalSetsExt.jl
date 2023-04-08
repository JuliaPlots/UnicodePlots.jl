module IntervalSetsExt

import UnicodePlots: UnicodePlots, Plot, Canvas
UnicodePlots.@ext_imp_use :import IntervalSets

UnicodePlots.lineplot(
    f::Function,
    x::IntervalSets.AbstractInterval;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot(f, range(x; length, step); kw...)

UnicodePlots.lineplot!(
    plot::Plot{<:Canvas},
    f::Function,
    x::IntervalSets.AbstractInterval;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot!(plot, f, range(x; length, step); kw...)

UnicodePlots.lineplot(
    F::AbstractVector{<:Function},
    x::IntervalSets.AbstractInterval;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot(F, range(x; length, step); kw...)

end  # module
