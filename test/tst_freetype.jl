const FR = UnicodePlots.FreeTypeRendering
push!(FR.VALID_FONTPATHS, joinpath(@__DIR__, "fonts"))

@testset "init and done" begin
    @test_throws ErrorException FR.ft_init()
    @test FR.ft_done()
    @test_throws ErrorException FR.ft_done()
    @test FR.ft_init()
end

face = FR.find_font("hack")  # must occur after `ft_init` and `ft_done` !

@testset "basics" begin
    @test face ≢ nothing
    @test :size in propertynames(face)
    @test repr(face) == "FTFont (family = Hack, style = Regular)"

    FR.set_pixelsize(face, 64)  # should be the default
    img, extent = FR.render_face(face, 'C', 64)
    @test size(img) == (30, 49)
    @test typeof(img) == Array{UInt8,2}

    @test FR.hadvance(extent) == 39
    @test FR.vadvance(extent) == 62
    @test FR.inkheight(extent) == 49
    @test FR.hbearing_ori_to_left(extent) == 4
    @test FR.hbearing_ori_to_top(extent) == 48
    @test FR.leftinkbound(extent) == 4
    @test FR.rightinkbound(extent) == 34
    @test FR.bottominkbound(extent) == -1
    @test FR.topinkbound(extent) == 48

    a = FR.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 10, 10)

    @test any(a[3:12, :] .≠ 0)
    @test all(a[vcat(1:2, 13:20), :] .== 0)
    @test any(a[:, 11:40] .≠ 0)
    @test all(a[:, vcat(1:10, 41:100)] .== 0)
    a = FR.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 15, 70)
    @test any(a[8:17, :] .≠ 0)
    @test all(a[vcat(1:7, 18:20), :] .== 0)
    @test any(a[:, 71:100] .≠ 0)
    @test all(a[:, 1:70] .== 0)

    a = FR.render_string!(zeros(Float32, 20, 100), "helgo", face, 10, 10, 50)
    @test maximum(a) ≤ 1.0
    a = FR.render_string!(zeros(Float64, 20, 100), "helgo", face, 10, 10, 50)
    @test maximum(a) ≤ 1.0

    @test FR.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 25, 80) isa Matrix
end

@testset "ways to access glyphs" begin
    i = FR.glyph_index(face, 'A')
    @test FR.glyph_index(face, i) == i
    @test FR.glyph_index(face, "A") == i
end

@testset "alignements" begin
    a = FR.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 10, 50, valign = :vtop)

    @test all(a[1:10, :] .== 0)
    @test any(a[11:20, :] .≠ 0)
    a = FR.render_string!(
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
    a = FR.render_string!(
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
    a = FR.render_string!(
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
    a = FR.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 10, 50, halign = :hleft)
    @test all(a[:, 1:50] .== 0)
    @test any(a[:, 51:100] .≠ 0)
    a = FR.render_string!(
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
    a = FR.render_string!(
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

    FR.render_string!(
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
    a = FR.render_string!(zeros(UInt8, 20, 100), "helgo", face, 10, 10, 50, fcolor = 0x80)
    @test maximum(a) ≤ 0x80
    a = FR.render_string!(
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
    a = FR.render_string!(fill(0x01, 20, 100), "helgo", face, 10, 10, 50, bcolor = nothing)
    @test !any(a .== 0x00)
end

@testset "array of grays" begin
    @test FR.render_string!(zeros(Gray, 20, 100), "helgo", face, 10, 10, 50) isa Matrix
    @test FR.render_string!(
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
    for str ∈ ("helgo", collect("helgo"))
        fcolor = [RGB{Float32}(rand(3)...) for _ ∈ 1:length(str)]
        @test FR.render_string!(
            zeros(RGB{Float32}, 20, 100),
            str,
            face,
            10,
            1,
            1;
            fcolor = fcolor,
        ) isa Matrix
        gcolor = [RGB{Float32}(rand(3)...) for _ ∈ 1:length(str)]
        gstr = fill('█', length(str))
        @test FR.render_string!(
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
    @test FR.render_string!(
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
    @test FR.fallback_fonts() isa Tuple
end

pop!(FR.VALID_FONTPATHS)
