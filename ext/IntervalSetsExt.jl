module IntervalSetsExt

import UnicodePlots: UnicodePlots, Plot, Canvas
UnicodePlots.@ext_imp_use :import IntervalSets

function interval_range(x::IntervalSets.AbstractInterval, length, step)
    if length ≡ nothing && step ≡ nothing
        length = UnicodePlots.DEFAULT_WIDTH[]
    end
    range(x; length, step)
end

UnicodePlots.lineplot(
    x::IntervalSets.AbstractInterval,
    f::Function;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot(interval_range(x, length, step), f; kw...)

UnicodePlots.lineplot!(
    plot::Plot{<:Canvas},
    x::IntervalSets.AbstractInterval,
    f::Function;
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot!(plot, interval_range(x, length, step), f; kw...)

UnicodePlots.lineplot(
    x::IntervalSets.AbstractInterval,
    F::AbstractVector{<:Function};
    length = nothing,
    step = nothing,
    kw...,
) = UnicodePlots.lineplot(interval_range(x, length, step), F; kw...)

end  # module
