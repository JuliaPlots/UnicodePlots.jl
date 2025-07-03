const FTE = if isdefined(Base, :get_extension)
    Base.get_extension(UnicodePlots, :FreeTypeExt)
else
    UnicodePlots.FreeTypeExt
end
const FT_DIR = joinpath(@__DIR__, "fonts")
push!(FTE.VALID_FONTPATHS, FT_DIR)

@testset "init and done" begin
    @test_throws ErrorException FTE.ft_init()
    @test FTE.ft_done()
    @test_throws ErrorException FTE.ft_done()
    @test FTE.ft_init()
end

face = FTE.find_font("hack")  # must occur after `ft_init` and `ft_done` !

@testset "basics" begin
    @test face ≢ nothing
    @test :size in propertynames(face)
    @test repr(face) == "FTFont (family = Hack, style = Regular)"

    FTE.set_pixelsize(face, 64)  # should be the default
    img, extent = FTE.render_face(face, 'C', 64)
    @test size(img) == (30, 49)
    @test typeof(img) == Array{UInt8, 2}

    @test FTE.hadvance(extent) == 39
    @test FTE.vadvance(extent) == 62
    @test FTE.inkheight(extent) == 49
    @test FTE.hbearing_ori_to_left(extent) == 4
    @test FTE.hbearing_ori_to_top(extent) == 48
    @test FTE.leftinkbound(extent) == 4
    @test FTE.rightinkbound(extent) == 34
    @test FTE.bottominkbound(extent) == -1
    @test FTE.topinkbound(extent) == 48

    a = UnicodePlots.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 10, 10)

    @test any(a[3:12, :] .≠ 0)
    @test all(a[vcat(1:2, 13:20), :] .== 0)
    @test any(a[:, 11:40] .≠ 0)
    @test all(a[:, vcat(1:10, 41:100)] .== 0)
    a = UnicodePlots.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 15, 70)
    @test any(a[8:17, :] .≠ 0)
    @test all(a[vcat(1:7, 18:20), :] .== 0)
    @test any(a[:, 71:100] .≠ 0)
    @test all(a[:, 1:70] .== 0)

    a = UnicodePlots.render_string!(zeros(Float32, 20, 100), "helgo", face, 10, 10, 50)
    @test maximum(a) ≤ 1.0
    a = UnicodePlots.render_string!(zeros(Float64, 20, 100), "helgo", face, 10, 10, 50)
    @test maximum(a) ≤ 1.0

    @test UnicodePlots.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 25, 80) isa
        Matrix
end

@testset "ways to access glyphs" begin
    i = FTE.glyph_index(face, 'A')
    @test FTE.glyph_index(face, i) == i
    @test FTE.glyph_index(face, "A") == i
end

@testset "alignments" begin
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        valign = :vtop,
    )

    @test all(a[1:10, :] .== 0)
    @test any(a[11:20, :] .≠ 0)
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        valign = :vcenter,
    )
    @test all(a[vcat(1:5, 16:end), :] .== 0)
    @test any(a[6:15, :] .≠ 0)
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        valign = :vbaseline,
    )
    @test all(a[vcat(1:2, 13:end), :] .== 0)
    @test any(a[3:12, :] .≠ 0)
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        valign = :vbottom,
    )
    @test any(a[1:10, :] .≠ 0)
    @test all(a[11:20, :] .== 0)
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        halign = :hleft,
    )
    @test all(a[:, 1:50] .== 0)
    @test any(a[:, 51:100] .≠ 0)
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        halign = :hcenter,
    )
    @test all(a[:, vcat(1:35, 66:end)] .== 0)
    @test any(a[:, 36:65] .≠ 0)
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        halign = :hright,
    )
    @test any(a[:, 1:50] .≠ 0)
    @test all(a[:, 51:100] .== 0)

    UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        1,
        1,
        halign = :hcenter,
        valign = :vcenter,
    )
end

@testset "foreground / background colors" begin
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        fcolor = 0x80,
    )
    @test maximum(a) ≤ 0x80
    a = UnicodePlots.render_string!(
        zeros(UInt8, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        fcolor = 0x80,
        bcolor = 0x40,
    )
    @test any(a .== 0x40)
    a = UnicodePlots.render_string!(
        fill(0x01, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        bcolor = nothing,
    )
    @test !any(a .== 0x00)
end

@testset "array of grays" begin
    @test UnicodePlots.render_string!(zeros(Gray, 20, 100), "helgo", face, 10, 10, 50) isa
        Matrix
    @test UnicodePlots.render_string!(
        zeros(Gray{Float64}, 20, 100),
        "helgo",
        face,
        10,
        10,
        50,
        fcolor = Gray(0.5),
    ) isa Matrix
end

@testset "per char background / colors" begin
    for str in ("helgo", collect("helgo"))
        fcolor = [RGB{Float32}(rand(3)...) for _ in 1:length(str)]
        @test UnicodePlots.render_string!(
            zeros(RGB{Float32}, 20, 100),
            str,
            face,
            10,
            1,
            1;
            fcolor = fcolor,
        ) isa Matrix
        gcolor = [RGB{Float32}(rand(3)...) for _ in 1:length(str)]
        gstr = fill('█', length(str))
        @test UnicodePlots.render_string!(
            zeros(RGB{Float32}, 20, 100),
            str,
            face,
            10,
            1,
            1;
            fcolor = fcolor,
            gcolor = gcolor,
            gstr = gstr,
        ) isa Matrix
    end
end

@testset "draw bounding boxes" begin
    @test UnicodePlots.render_string!(
        zeros(RGB{Float32}, 20, 100),
        "helgo",
        face,
        10,
        1,
        1;
        gcolor = RGB{Float32}(0.0, 1.0, 0.0),
        bbox = RGB{Float32}(1.0, 0.0, 0.0),
        bbox_glyph = RGB{Float32}(0.0, 0.0, 1.0),
    ) isa Matrix
end

@testset "misc" begin
    @test FTE.fallback_fonts() isa Tuple
end

@testset "thread safety" begin
    mktempdir() do dir
        n = 100
        fontfiles = map(1:n) do i
            cp(joinpath(FT_DIR, "hack_regular.ttf"), joinpath(dir, "hack_regular_$i.ttf"))
        end
        Threads.@threads for f in fontfiles
            fo = FTE.FTFont(f)
            Threads.@threads for i in 1:n
                FTE.load_glyph(fo, i)
                FTE.load_glyph(fo, i, 64)
                FTE.render_face(fo, i, 16)
            end
        end
    end
end

pop!(FTE.VALID_FONTPATHS)
