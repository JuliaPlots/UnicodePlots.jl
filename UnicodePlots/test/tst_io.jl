@testset "show" begin
    io = IOContext(PipeBuffer(), :color => false)

    # test padding (NOTE: @check_padidng embedded in @show_col)
    @show_col scatterplot(1:2, labels = false)

    @show_col scatterplot(1:2, labels = false, title = "scatterplot")

    @show_col scatterplot(1:2, title = "scatterplot", xlabel = "x")

    @show_col scatterplot(1:2, title = "scatterplot", xlabel = "x", compact = true)

    A = repeat(collect(0:10)', outer = (11, 1))
    # complex right padding, with colorbar and limit labels
    for zlabel in ("zlab", ""), n in 1:10
        @show_col heatmap(A; margin = 0, title = "fancy", zlabel, zlim = (1, 10^n))
    end
end

@testset "savefig" begin
    font_found = UnicodePlots.get_font_face() ≢ nothing  # `PkgEval` can fail
    for p in (
            lineplot(-π / 2, 2π, [cos, sin, x -> 0.5, x -> -0.5], title = "fancy title"),
            barplot([:a, :b, :c, :d, :e], [20, 30, 60, 50, 40]),
        )
        for bbox in (nothing, :red), tr in (true, false)
            tmp = tempname() * ".png"

            savefig(
                p,
                tmp;
                transparent = tr,
                bounding_box_glyph = bbox,
                bounding_box = bbox,
            )

            if font_found
                @test filesize(tmp) > 1_000

                img = FileIO.load(tmp)
                @test all(size(img) .> (100, 100))
            end
        end

        @test_throws ArgumentError savefig(p, tempname() * ".jpg")
    end

    # for Plots
    if font_found
        p = lineplot(1:2)
        tmp = tempname() * ".png"
        open(tmp, "w") do io
            UnicodePlots.save_image(io, UnicodePlots.png_image(p))
        end
        @test filesize(tmp) > 1_000
    end
end

macro measure(ex, tol, versioned)
    return quote
        base_tol = is_ci() ? 2 : 1.25
        @test string($ex; color = true) isa String  # 1st pass - ttfp
        if (
                UnicodePlots.get_have_truecolor() &&
                    (STABLE || PRE) &&
                    Sys.islinux() &&
                    !is_pkgeval()
            )
            n = 10
            kb = fill(0.0, n)
            ms = fill(0.0, n)
            GC.enable(false)
            for i in 1:n
                stats = @timed string($ex; color = true)  # repeated !
                kb[i] = stats.bytes / 1_000
                ms[i] = stats.time * 1_000
                # sleep(1e-2 + rand() / i)
            end
            GC.enable(true)
            key = VersionNumber(VERSION.major, VERSION.minor)
            dct = $versioned
            if haskey(dct, key)
                kbytes, msecs = dct[key]
                avg_kb = round(Int, sum(kb) / n, RoundUp)
                avg_ms = round(sum(ms) / n; digits = 3)
                @show (VERSION, (avg_kb, avg_ms), (kbytes, msecs))
                @test avg_kb ≤ kbytes
                @test avg_ms < $tol * base_tol * msecs
            else
                @warn "missing info for $VERSION ($kb, $ms) !"
            end
        end
    end |> esc
end

sombrero(x, y) = 30sinc(√(x^2 + y^2) / π)

@testset "stringify plot - performance regression" begin
    let c = BrailleCanvas(15, 40)
        lines!(c, 0.0, 1.0, 0.5, 0.0)
        @measure c 1 Dict(
            v"1.10" => (20, 0.031),
            v"1.11" => (18, 0.025),
            v"1.12" => (19, 0.041),
        )
    end

    let c = BrailleCanvas(15, 40)
        lines!(c, 0.0, 1.0, 0.5, 0.0; color = :green)
        @measure c 1 Dict(
            v"1.10" => (28, 0.039),
            v"1.11" => (24, 0.03),
            v"1.12" => (28, 0.042),
        )
    end

    let p = lineplot(1:10)
        @measure p 1 Dict(
            v"1.10" => (50, 0.07),
            v"1.11" => (44, 0.061),
            v"1.12" => (60, 0.045),
        )
    end

    let p = heatmap(collect(1:15) * collect(1:15)')
        @measure p 1 Dict(
            v"1.10" => (153, 0.106),
            v"1.11" => (182, 0.178),
            v"1.12" => (268, 0.16),
        )
    end

    let p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero; axes3d = false)
        @measure p 1 Dict(
            v"1.10" => (152, 0.142),
            v"1.11" => (124, 0.122),
            v"1.12" => (226, 0.106),
        )
    end
end

@testset "Term extension" begin
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:5); show_placeholder = true))
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:3); layout = (2, nothing)))
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:3); layout = (nothing, 1)))
end
