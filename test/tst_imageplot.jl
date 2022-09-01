img = testimage("monarch_color_256")

@testset "blocks" begin
    _old_enc = ImageInTerminal.ENCODER_BACKEND[]
    ImageInTerminal.ENCODER_BACKEND[] = :XTermColors
    p = imageplot(img, title = "blocks")
    test_ref("imageplot/img_blocks.txt", @show_col(p, :displaysize => T_SZ))
    @test !p.graphics.sixel[]
    ImageInTerminal.ENCODER_BACKEND[] = _old_enc
end

if ImageInTerminal.Sixel.is_sixel_supported()
    @testset "sixel" begin
        _old_enc = ImageInTerminal.ENCODER_BACKEND[]
        ImageInTerminal.ENCODER_BACKEND[] = :Sixel
        p = imageplot(img, title = "sixel")
        test_ref("imageplot/img_sixel.txt", @show_col(p, :displaysize => T_SZ))
        @test p.graphics.sixel[]
        ImageInTerminal.ENCODER_BACKEND[] = _old_enc
    end
end
