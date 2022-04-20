"""
    histogram(data; kw...)

# Description

Draws a horizontal histogram of the given `data`.
The positional parameter `data` can either be a `StatsBase.Histogram`, or some `AbstractArray`.
In the later case the `Histogram` will be fitted automatically.

Note internally that `histogram` is a simply wrapper for
[`barplot`](@ref), which means that it supports the same keyword arguments.

# Usage

    histogram(x; nbins, closed = :left, stats = true, kw...)

    histogram(x, hist; $(keywords((border = :barplot, color = :green, horizontal = true), remove = (:ylim, :yscale, :height, :grid), add = (:symbols,)))

# Arguments

$(arguments(
    (
        x = "array of numbers for which the histogram should be computed",
        nbins = "approximate number of bins that should be used",
        closed = "if `:left` (default), the bin intervals are left-closed ``[a, b)``; if `:right`, intervals are right-closed ``(a, b]``",
        stats = "display statistics",
        xscale = "`Function` or `Symbol` to transform the bar length before plotting: this effectively scales the `x`-axis without influencing the captions of the individual bars (use `xscale = :log10` for logscale)",
        hist = "a fitted `StatsBase.Histogram` that should be plotted",
    ); add = (:symbols,)
))

# Author(s)

- Iain Dunning (github.com/IainNZ)
- Christof Stocker (github.com/Evizero)
- Kenta Sato (github.com/bicycle1885)

# Examples

```julia-repl
julia> histogram(randn(1000) * 0.1, closed = :right, nbins = 15)
                  ┌                                        ┐ 
   (-0.3 , -0.25] ┤▇ 4                                       
   (-0.25, -0.2 ] ┤▇▇ 12                                     
   (-0.2 , -0.15] ┤▇▇▇▇▇▇▇▇▇ 48                              
   (-0.15, -0.1 ] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 114                 
   (-0.1 , -0.05] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 143            
   (-0.05, -0.0 ] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 177      
   ( 0.0 ,  0.05] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 192   
   ( 0.05,  0.1 ] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 152          
   ( 0.1 ,  0.15] ┤▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 83                        
   ( 0.15,  0.2 ] ┤▇▇▇▇▇▇▇▇ 45                               
   ( 0.2 ,  0.25] ┤▇▇▇▇ 23                                   
   ( 0.25,  0.3 ] ┤▇ 6                                       
   ( 0.3 ,  0.35] ┤ 1                                        
                  └                                        ┘ 
                                   Frequency                 
```

# See also

[`Plot`](@ref), [`barplot`](@ref), [`BarplotGraphics`](@ref)
"""
function histogram(
    hist::Histogram;
    horizontal::Bool = true,
    symb = nothing,  # deprecated
    symbols = default_symbols(horizontal),
    xscale = KEYWORDS.xscale,
    xlabel = transform_name(xscale, "Frequency"),
    info::AbstractString = KEYWORDS.info,
    kw...,
)
    edges, counts = hist.edges[1], hist.weights
    if horizontal
        labels = Vector{String}(undef, length(counts))
        binwidths = diff(edges)
        # compute label padding based on all labels.
        # this is done to make all decimal points align.
        pad_left, pad_right = 0, 0
        for i in 1:length(counts)
            binwidth = binwidths[i]
            val1 = float_round_log10(edges[i], binwidth)
            val2 = float_round_log10(val1 + binwidth, binwidth)
            a1 = Base.alignment(IOBuffer(), val1)
            a2 = Base.alignment(IOBuffer(), val2)
            pad_left = max(pad_left, a1[1], a2[1])
            pad_right = max(pad_right, a1[2], a2[2])
        end
        # compute the labels using the computed padding
        l_str = hist.closed === :right ? "(" : "["
        r_str = hist.closed === :right ? "]" : ")"
        for i in 1:length(counts)
            binwidth = binwidths[i]
            val1 = float_round_log10(edges[i], binwidth)
            val2 = float_round_log10(val1 + binwidth, binwidth)
            a1 = Base.alignment(IOBuffer(), val1)
            a2 = Base.alignment(IOBuffer(), val2)
            labels[i] = string(
                l_str,
                repeat(" ", pad_left - a1[1]),
                string(val1),
                repeat(" ", pad_right - a1[2]),
                ", ",
                repeat(" ", pad_left - a2[1]),
                string(val2),
                repeat(" ", pad_right - a2[2]),
                r_str,
            )
        end
        plot = barplot(
            labels,
            counts;
            symbols = _handle_deprecated_symb(symb, symbols),
            xlabel = xlabel,
            xscale = xscale,
            kw...,
        )
    else
        centers = (edges[1:(end - 1)] + edges[2:end]) / 2
        plot = Plot(
            float.(centers),
            float.(counts);
            xlabel = xlabel,
            xscale = xscale,
            grid = false,
            border = :none,
            xlim = extrema(centers),
            ylim = extrema(counts),
            width = length(centers),
            info = info,
            kw...,
        )
        symbols = _handle_deprecated_symb(symb, symbols)
        max_val = maximum(counts)
        nsyms = length(symbols)
        nr = nrows(plot.graphics)
        for (x, y) in zip(centers, counts)
            frac = float(max_val > 0 ? max(y, zero(y)) / max_val : 0)
            n_full = round(Int, frac * nr, nsyms > 1 ? RoundDown : RoundNearestTiesUp)
            δ = max_val / nr
            for r in 1:n_full
                annotate!(plot, x, (r - 0.5) * δ, symbols[nsyms]; color = :green)
            end
            if nsyms > 1 && (rem = frac * nr - n_full) > 0
                annotate!(
                    plot,
                    x,
                    (n_full + 0.5) * δ,
                    symbols[1 + round(Int, rem * (nsyms - 1))];
                    color = :green,
                )
            end
        end
    end

    plot
end

default_symbols(horizontal::Bool) =
    if horizontal
        ['▏', '▎', '▍', '▌', '▋', '▊', '▉', '█']
    else
        ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█']
    end

function histogram(x; bins = nothing, closed = :left, stats = true, kw...)
    x_plot = dropdims(x, dims = Tuple(filter(d -> size(x, d) == 1, 1:ndims(x))))
    hist = if bins !== nothing
        Base.depwarn(
            "The keyword parameter `bins` is deprecated, use `nbins` instead",
            :histogram,
        )
        fit(Histogram, x_plot; nbins = bins, closed = closed)
    else
        fit(Histogram, x_plot; closed = closed, filter(p -> p.first == :nbins, kw)...)
    end
    info = if stats
        mx, Mx = extrema(x_plot)
        μ = sum(x_plot) / length(x_plot)
        σ = √(sum((x_plot .- μ) .^ 2) / length(x_plot))
        buf = PipeBuffer()
        print_fmt =
            x -> printstyled(
                buf,
                lpad(round(x; digits = 2), 3);
                color = :green,
                bold = true,
            )
        print(buf, "min: ")
        print_fmt(mx)
        print(buf, " ≤ μ ± σ: ")
        print_fmt(μ)
        print(buf, " ± ")
        print_fmt(σ)
        print(buf, " ≤ max: ")
        print_fmt(Mx)
        read(buf, String)
    else
        ""
    end
    histogram(hist; info = info, filter(p -> p.first ∉ (:nbins, :stats), kw)...)
end

@deprecate histogram(x::AbstractArray, nbins::Int; kw...) histogram(x; nbins = nbins, kw...)
