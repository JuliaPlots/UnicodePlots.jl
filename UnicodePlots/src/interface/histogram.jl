"""
    horizontal_histogram(hist; kw...)

# Description

Draws a horizontal histogram of the given `StatsBase.Histogram`.

Note internally that `horizontal_histogram` is a simply wrapper for
[`barplot`](@ref), which means that it supports the same keyword arguments.

# Usage

    horizontal_histogram(hist; $(keywords((border = :barplot, color = :green), remove = (:ylim, :yscale, :height, :grid), add = (:symbols,))))

# Arguments

$(arguments((hist = "a fitted `StatsBase.Histogram` that should be plotted",); add = (:symbols,)))
"""
function horizontal_histogram(
        hist::Histogram;
        symbols = ('▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'),
        xscale = KEYWORDS.xscale,
        info::AbstractString = "",  # unused in horizontal version
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
        symbols,
        xscale,
        xlabel = transform_name(xscale, "Frequency"),
        kw...,
    )
    return plot
end

"""
    vertical_histogram(hist; kw...)

# Description

Draws a vertical histogram of the given `StatsBase.Histogram`.

# Usage

    vertical_histogram(hist; $(keywords((border = :barplot, color = :green), remove = (:xlim, :ylim, :xscale, :yscale, :width, :height, :grid), add = (:symbols,))))

# Arguments

$(arguments((hist = "a fitted `StatsBase.Histogram` that should be plotted",); add = (:symbols,)))
"""
function vertical_histogram(
        hist::Histogram;
        symbols = ('▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'),
        info::AbstractString = "",
        color::UserColorType = :green,
        canvas::Type{<:Canvas} = BlockCanvas,
        kw...,
    )
    edges, counts = first(hist.edges), hist.weights
    centers = (edges[begin:(end - 1)] + edges[(begin + 1):end]) / 2
    plot = Plot(
        float.(centers),
        float.(counts),
        nothing,
        canvas;
        grid = false,
        border = :corners,
        xlim = extrema(edges),
        ylim = (0, maximum(counts)),
        width = length(centers),
        xlabel = info,
        kw...,
    )
    max_val = maximum(counts)
    nsyms = length(symbols)
    nr = nrows(plot.graphics)
    for (x, y) in zip(centers, counts)
        frac = float(max_val > 0 ? max(y, zero(y)) / max_val : 0)
        n_full = (nsyms > 1 ? floor : round)(Int, frac * nr)
        δ = max_val / nr
        for r in 1:n_full
            annotate!(plot, x, (r - 0.5) * δ, symbols[nsyms]; color)
        end
        if nsyms > 1 && (rem = frac * nr - n_full) > 0
            if 1 ≤ (I = round(Int, rem * nsyms)) ≤ nsyms
                annotate!(plot, x, (n_full + 0.5) * δ, symbols[I]; color)
            end
        end
    end
    return plot
end

"""
    histogram(data; kw...)

# Description

Draws a horizontal or vertical histogram of the given `data`, fitted to an `Histogram`.

# Usage

    histogram(x; nbins, closed = :left, vertical = false, stats = true, $(keywords((border = :barplot, color = :green), remove = (:xlim, :ylim, :xscale, :yscale, :width, :height, :grid), add = (:symbols,))))

# Arguments

$(
    arguments(
        (
            x = "array of numbers for which the histogram should be computed",
            nbins = "approximate number of bins that should be used",
            closed = "if `:left` (default), the bin intervals are left-closed ``[a, b)``; if `:right`, intervals are right-closed ``(a, b]``",
            vertical = "vertical histogram instead of the default horizontal one",
            stats = "display statistics (vertical only)",
        ); add = (:symbols,)
    )
)

# Author(s)

- Iain Dunning (github.com/IainNZ)
- Christof Stocker (github.com/Evizero)
- Kenta Sato (github.com/bicycle1885)

# Examples

```julia-repl
julia> histogram(randn(1_000) * .1, closed=:right, nbins=15)
                  ┌                                        ┐
   (-0.3 , -0.25] ┤▎ 1
   (-0.25, -0.2 ] ┤██▉ 17
   (-0.2 , -0.15] ┤█████████▍ 53
   (-0.15, -0.1 ] ┤████████████████▎ 92
   (-0.1 , -0.05] ┤████████████████████████▋ 141
   (-0.05,  0.0 ] ┤███████████████████████████████████  200
   ( 0.0 ,  0.05] ┤█████████████████████████████████▋ 192
   ( 0.05,  0.1 ] ┤█████████████████████████▏ 143
   ( 0.1 ,  0.15] ┤████████████████▎ 92
   ( 0.15,  0.2 ] ┤███████▊ 45
   ( 0.2 ,  0.25] ┤██▋ 15
   ( 0.25,  0.3 ] ┤█▍ 8
   ( 0.3 ,  0.35] ┤▎ 1
                  └                                        ┘
                                   Frequency
julia> histogram(randn(100_000) .* .1, nbins=60, vertical=true, height=10)
         ┌                                             ┐
   8_093  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▃█▇▃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▅████▆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▇██████▅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▅████████▄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▃██████████▃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▂████████████▂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▂██████████████▃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▁████████████████▃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀▁▅██████████████████▅▁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
       0  ⠀⠀⠀⠀⠀⠀▁▁▂▃▅██████████████████████▆▃▂▁▁⠀⠀⠀⠀⠀⠀⠀
         └                                             ┘
         ⠀-0.44⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀0.46⠀
         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀μ ± σ: 0.0 ± 0.1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
```

# See also

[`Plot`](@ref), [`barplot`](@ref), [`BarplotGraphics`](@ref)
"""
function histogram(x::AbstractArray; closed = :left, vertical = false, stats = true, kw...)
    x_plot = dropdims(x, dims = Tuple(filter(d -> size(x, d) == 1, 1:ndims(x))))
    len = length(x_plot)
    nbins = get(kw, :nbins, sturges(len))
    hist = fit(Histogram, x_plot; closed, nbins)
    info = if vertical && stats
        digits = 2
        mx, Mx = extrema(x_plot)
        μ = sum(x_plot) / len
        σ = √(sum((x_plot .- μ) .^ 2) / len)
        (
            "μ ± σ: " *
                lpad(round(μ; digits), digits + 1) * " ± " *
                lpad(round(σ; digits), digits + 1)
        )
    else
        ""
    end
    callable = vertical ? vertical_histogram : horizontal_histogram
    return callable(hist; info, filter(p -> p.first ≢ :nbins, kw)...)
end
