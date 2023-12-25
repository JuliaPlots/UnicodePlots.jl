module TermExt

import UnicodePlots: UnicodePlots, Plot
UnicodePlots.@ext_imp_use :import Term

function UnicodePlots.panel(p; kw...)
    p.margin[] = p.padding[] = 0  # make plots more compact
    p.compact[] = true
    Term.Panel(string(p; color = true); style = "hidden", fit = true, kw...)
end

UnicodePlots.gridplot(plots::Union{AbstractVector,Tuple}; kw...) =
    UnicodePlots.gridplot(plots...; kw...)
UnicodePlots.gridplot(plots::Plot...; kw...) =
    Term.grid(map(UnicodePlots.panel, plots); kw...)

end  # module
