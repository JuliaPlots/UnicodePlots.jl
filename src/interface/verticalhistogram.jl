"""
    verticalhistogram(data; width=64, height=3, title="", printstat=true)

# Description

Draws a verticalhorizontal histogram of the given `data`.
The positional parameter `data` can either be `AbstractVector`.

# Usage

		verticalhistogram(randn(10000).+2, width=100, height=5, title="Random num generation histrogram", printstat=true)
    histogram(hist; $(keywords((border = :barplot, color = :green,), remove = (:ylim, :yscale, :height, :grid), add = (:symbols,)))

# Arguments

$(arguments(
    (
        x = "array of numbers for which the histogram should be computed",
        nbins = "approximate number of bins that should be used",
        closed = "if `:left` (default), the bin intervals are left-closed ``[a, b)``; if `:right`, intervals are right-closed ``(a, b]``",
        xscale = "`Function` or `Symbol` to transform the bar length before plotting: this effectively scales the `x`-axis without influencing the captions of the individual bars (use `xscale = :log10` for logscale)",
        hist = "a fitted `StatsBase.Histogram` that should be plotted",
    ); add = (:symbols,)
))

# Returns

Values mean, value standard deviation, minimum and maximum value.

# Author(s)

- Marcell Havlik (github.com/Cvikli)

# Examples

```julia-repl
julia> histogram(randn(1000).+2, width=100, height=5, title="Random num generation histrogram", printstat=true)
                                  Random num generation histrogram
                                        ▄  █ █   ▅    ▂  ▂▂                                         
                                        █▄▆█▇█ ▅ ██ ▂▃█▄▂██▂                                        
                           ▃   ▂▃▄▂▅█ █▇██████▇█▅██▇████████▆  ▅▇                                   
                     ▂ ▅  ▅█▆▄▆██████▇████████████████████████▅███▃▂█                               
▂▁▁▂▁▁▁▁▂▁▁▃▁▅▂▃▃▂▃▃▇█▆██▇█████████████████████████████████████████████▇▆▇▇▄▁█▄▅▄▄▄▁▃▃▂▁▁▁▃▁▁▂▁▁▁▁▁▃
-1.187264                                                                                   5.468818
Values (mean ± σ): 2.022943 ± 0.97807
```

# See also

[`histogram`](@ref)
"""
function verticalhistogram(
    data::AbstractVector;
    width = 64,
    height = 3,
    title = "",
    printstat = true,
)
    ϵ = 1e-11
    histbars_blocks = [' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█']
    blocknum = length(histbars_blocks)
    histbin_codes = fill('█', (blocknum - 1) * height, height)
    for h in 1:height
        histbin_codes[
            ((h - 1) * (blocknum - 1) + 1):(h * (blocknum - 1)),
            height - h + 1,
        ] .= histbars_blocks[2:end]
    end
    histbin_codes[map(
        ci -> cld(ci[1], blocknum - 1) + ci[2] <= height,
        CartesianIndices(histbin_codes),
    )] .= ' '
    # for h in 1:height 	
    # 	println(join(histbin_codes[:,h],"")," █")
    # end
    firstbin = minimum(data)
    endbin = maximum(data) + ϵ
    binsize = (endbin - firstbin) / width
    histogram_bins = zeros(Int, width)
    for v in data
        histogram_bins[floor(Int, (v - firstbin) / binsize) + 1] += 1
    end
    maxbin = maximum(histogram_bins)
    unicode_matrix = Matrix{Char}(undef, width, height)
    for (i, bin) in enumerate(histogram_bins)
        strength = bin / (maxbin + ϵ) * size(histbin_codes, 1)
        unicode_matrix[i, :] .= histbin_codes[floor(Int, strength) + 1, :]
    end

    title !== "" &&
        printstyled(" "^max(0, cld((width - length(title)), 2)), title, "\n"; bold = true)
    for h in 1:height
        println(join(unicode_matrix[:, h], ""))
    end
    printstyled(round(firstbin; digits = 6), bold = true)
    sign_width = (sign(firstbin) < 0 ? 1 : 0) + (sign(endbin) < 0 ? 1 : 0)
    print(
        " "^(
            width - 14 - Int(ceil(log10(abs(firstbin))) + ceil(log10(abs(endbin)))) -
            sign_width
        ),
    )
    printstyled(round(endbin; digits = 6), bold = true)
    println()
    v_mean = sum(data) / length(data)
    v_σ = sqrt(sum((data .- v_mean) .^ 2) / (length(data) - 1))
    if printstat
        print("data (mean ± σ): ")
        printstyled(lpad(round(v_mean; digits = 6), 6); color = :green, bold = true)
        print(" ± ")
        printstyled(lpad(round(v_σ; digits = 6), 6); color = :green, bold = true)
        println()
        # print("Range (min … max): ") 
        # printstyled(lpad(round(firstbin; digits=6), 6); color=:green, bold=true)
        # print(" … ")
        # printstyled(lpad(round(endbin; digits=6), 6); color=:green, bold=true)
        println()
    end
    v_mean, v_σ, firstbin, endbin
end