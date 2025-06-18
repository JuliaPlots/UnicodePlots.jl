module TermExt

import UnicodePlots
import Term

function UnicodePlots.panel(p; kw...)
    p.margin[] = p.padding[] = 0  # make plots more compact
    p.compact_labels[] = p.compact[] = true
    Term.Panel(string(p; color = true); style = "hidden", fit = true, kw...)
end

UnicodePlots.gridplot(plots::Union{AbstractVector,Tuple}; kw...) =
    UnicodePlots.gridplot(plots...; kw...)
UnicodePlots.gridplot(plots::UnicodePlots.Plot...; kw...) =
    Term.grid(map(UnicodePlots.panel, plots); kw...)

end  # module
