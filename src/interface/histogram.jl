"""
    horizontal_histogram(hist; kw...)

# Description

Draws a horizontal histogram of the given `StatsBase.Histogram`.

Note internally that `horizontal_histogram` is a simply wrapper for
[`barplot`](@ref), which means that it supports the same keyword arguments.

# Usage

    horizontal_histogram(hist; $(keywords((border = :barplot, color = :green), remove = (:ylim, :yscale, :height, :grid), add = (:symbols,)))

# Arguments

$(arguments((hist = "a fitted `StatsBase.Histogram` that should be plotted",); add = (:symbols,)))
"""
function horizontal_histogram(
    hist::Histogram;
    symb = nothing,  # deprecated
    symbols = ['▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'],
    xscale = KEYWORDS.xscale,
    xlabel = transform_name(xscale, "Frequency"),
    info::AbstractString = "",  # unused
    kw...,
)
    edges, counts = hist.edges[1], hist.weights
    labels = Vector{String}(undef, length(counts))
    binwidths = diff(edges)
    # compute label padding based on all labels.
    # this is done to make all decimal points align.
    pad_left, pad_right = 0, 0
    io = PipeBuffer()
    for i in eachindex(counts)
        binwidth = binwidths[i]
        val1 = float_round_log10(edges[i], binwidth)
        val2 = float_round_log10(val1 + binwidth, binwidth)
        a1 = Base.alignment(io, val1)
        a2 = Base.alignment(io, val2)
        pad_left = max(pad_left, a1[1], a2[1])
        pad_right = max(pad_right, a1[2], a2[2])
    end
    # compute the labels using the computed padding
    l_chr = hist.closed ≡ :right ? '(' : '['
    r_chr = hist.closed ≡ :right ? ']' : ')'
    for i in eachindex(counts)
        binwidth = binwidths[i]
        val1 = float_round_log10(edges[i], binwidth)
        val2 = float_round_log10(val1 + binwidth, binwidth)
        a1 = Base.alignment(io, val1)
        a2 = Base.alignment(io, val2)
        labels[i] = string(
            l_chr,
            ' '^(pad_left - a1[1]),
            compact_repr(val1),
            ' '^(pad_right - a1[2]),
            ", ",
            ' '^(pad_left - a2[1]),
            compact_repr(val2),
            ' '^(pad_right - a2[2]),
            r_chr,
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
    plot
end

"""
    vertical_histogram(hist; kw...)

# Description

Draws a vertical histogram of the given `StatsBase.Histogram`.

# Usage

    vertical_histogram(hist; $(keywords((border = :barplot, color = :green), remove = (:xlim, :ylim, :xscale, :yscale, :width, :height, :grid), add = (:symbols,)))

# Arguments

$(arguments((hist = "a fitted `StatsBase.Histogram` that should be plotted",); add = (:symbols,)))
"""
function vertical_histogram(
    hist::Histogram;
    symb = nothing,  # deprecated
    symbols = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'],
    info::AbstractString = "",
    color = :green,
    kw...,
)
    edges, counts = hist.edges[1], hist.weights
    centers = (edges[1:(end - 1)] + edges[2:end]) / 2
    plot = Plot(
        float.(centers),
        float.(counts);
        grid = false,
        border = :corners,
        xlim = extrema(edges),
        ylim = (0, maximum(counts)),
        width = length(centers),
        xlabel = info,
        kw...,
    )
    symbols = _handle_deprecated_symb(symb, symbols)
    max_val = maximum(counts)
    nsyms = length(symbols)
    canvas = plot.graphics
    nr = nrows(canvas)
    for (x, y) in zip(centers, counts)
        frac = float(max_val > 0 ? max(y, zero(y)) / max_val : 0)
        n_full = (nsyms > 1 ? floor : round)(Int, frac * nr)
        δ = max_val / nr
        for r in 1:n_full
            annotate!(plot, x, (r - 0.5) * δ, symbols[nsyms]; color = color)
        end
        if nsyms > 1 && (rem = frac * nr - n_full) > 0
            if 1 ≤ (I = round(Int, rem * nsyms)) ≤ nsyms
                annotate!(plot, x, (n_full + 0.5) * δ, symbols[I]; color = color)
            end
        end
    end
    plot
end

"""
    histogram(data; kw...)

# Description

Draws a horizontal or vertical histogram of the given `data`, fitted to an `Histogram`.

# Usage

    histogram(x; nbins, closed = :left, vertical = false, stats = true, kw...)

# Arguments

$(arguments(
    (
        x = "array of numbers for which the histogram should be computed",
        nbins = "approximate number of bins that should be used",
        closed = "if `:left` (default), the bin intervals are left-closed ``[a, b)``; if `:right`, intervals are right-closed ``(a, b]``",
        vertical = "vertical histogram",
        stats = "display statistics (vertical only)",
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
    x::AbstractArray;
    bins = nothing,
    closed = :left,
    vertical = false,
    stats = true,
    kw...,
)
    x_plot = dropdims(x, dims = Tuple(filter(d -> size(x, d) == 1, 1:ndims(x))))
    hist = if bins ≢ nothing
        Base.depwarn(
            "The keyword parameter `bins` is deprecated, use `nbins` instead",
            :histogram,
        )
        fit(Histogram, x_plot; nbins = bins, closed = closed)
    else
        fit(Histogram, x_plot; closed = closed, filter(p -> p.first ≡ :nbins, kw)...)
    end
    info = if vertical && stats
        digits = 2
        mx, Mx = extrema(x_plot)
        μ = sum(x_plot) / length(x_plot)
        σ = √(sum((x_plot .- μ) .^ 2) / length(x_plot))
        "μ ± σ: " *
        lpad(round(μ; digits = digits), digits + 1) *
        " ± " *
        lpad(round(σ; digits = digits), digits + 1)
    else
        ""
    end
    callable = vertical ? vertical_histogram : horizontal_histogram
    callable(hist; info = info, filter(p -> p.first ≢ :nbins, kw)...)
end

@deprecate histogram(x::AbstractArray, nbins::Int; kw...) histogram(x; nbins = nbins, kw...)
@deprecate histogram(hist::Histogram; kw...) horizontal_histogram(hist; kw...)
