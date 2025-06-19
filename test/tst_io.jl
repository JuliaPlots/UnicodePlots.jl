@testset "show" begin
    io = IOContext(PipeBuffer(), :color => false)

    # test padding (NOTE: @check_padidng embedded in @show_col)
    @show_col scatterplot(1:2, labels = false)

    @show_col scatterplot(1:2, labels = false, title = "scatterplot")

    @show_col scatterplot(1:2, title = "scatterplot", xlabel = "x")

    @show_col scatterplot(1:2, title = "scatterplot", xlabel = "x", compact = true)

    A = repeat(collect(0:10)', outer = (11, 1))
    # complex right padding, with colorbar and limit labels
    for zlabel in ("zlab", ""), n = 1:10
        @show_col heatmap(A; margin = 0, title = "fancy", zlabel, zlim = (1, 10^n))
    end
end

@testset "savefig" begin
    font_found = UnicodePlots.get_font_face() ≢ nothing  # `PkgEval` can fail
    for p ∈ (
        lineplot(-π / 2, 2π, [cos, sin, x -> 0.5, x -> -0.5], title = "fancy title"),
        barplot([:a, :b, :c, :d, :e], [20, 30, 60, 50, 40]),
    )
        for bbox ∈ (nothing, :red), tr ∈ (true, false)
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

const STABLE = Base.get_bool_env("UP_STABLE", false) || isempty(VERSION.prerelease)  # occursin("DEV", string(VERSION)) or length(VERSION.prerelease) < 2
const MEASURE = Sys.islinux() && STABLE && !is_pkgeval()

macro measure(ex, tol, versioned)
    quote
        base_tol = is_ci() ? 2 : 1.25
        @test string($ex; color = true) isa String  # 1st pass - ttfp
        if MEASURE
            GC.enable(false)
            stats = @timed string($ex; color = true)  # repeated !
            GC.enable(true)
            key = VersionNumber(VERSION.major, VERSION.minor)
            dct = $versioned
            if haskey(dct, key)
                kbytes, msecs = dct[key]
                kb = round(Int, stats.bytes / 1e3)
                ms = round(stats.time * 1e3; digits = 3)
                @show (VERSION, kb, ms)
                @test kb < kbytes
                @test ms < $tol * base_tol * msecs
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
            v"1.10" => (20, 0.028),  # ~ 19kB
            v"1.11" => (20, 0.022),  # ~ 18kB
            v"1.12" => (25, 0.021),  # ~ 20kB
        )
    end

    let c = BrailleCanvas(15, 40)
        lines!(c, 0.0, 1.0, 0.5, 0.0; color = :green)
        @measure c 1 Dict(
            v"1.10" => (30, 0.035),  # ~ 27kB
            v"1.11" => (30, 0.028),  # ~ 24kB
            v"1.12" => (30, 0.038),  # ~ 27kB
        )
    end

    let p = lineplot(1:10)
        @measure p 1 Dict(
            v"1.10" => (55, 0.056),  # ~ 50kB
            v"1.11" => (45, 0.048),  # ~ 43kB
            v"1.12" => (60, 0.051),  # ~ 56kB
        )
    end

    let p = heatmap(collect(1:30) * collect(1:30)')
        @measure p 1 Dict(
            v"1.10" => (360, 0.273),  # ~ 356kB
            v"1.11" => (415, 0.468),  # ~ 411kB
            v"1.12" => (555, 0.285),  # ~ 552kB
        )
    end

    let p = surfaceplot(-8:0.5:8, -8:0.5:8, sombrero; axes3d = false)
        @measure p 1 Dict(
            v"1.10" => (155, 0.140),  # ~ 151kB
            v"1.11" => (125, 0.124),  # ~ 123kB
            v"1.12" => (220, 0.151),  # ~ 217kB
        )
    end
end

@testset "Term extension" begin
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:5); show_placeholder = true))
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:3); layout = (2, nothing)))
    show(devnull, gridplot(map(i -> lineplot((-i):i), 1:3); layout = (nothing, 1)))
end
