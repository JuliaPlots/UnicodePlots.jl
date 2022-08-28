if isinteractive()  # FIXME: Sixel.query_terminal(...) fails when !(stdin isa TTY)
    img = testimage("monarch_color_256")

    @testset "sixel" begin
        old_enc = ImageInTerminal.ENCODER_BACKEND[]
        ImageInTerminal.ENCODER_BACKEND[] = :Sixel
        p = imageplot(img, title = "sixel")
        @test p.graphics.sixel[]
        test_ref("imageplot/img_sixel.txt", @show_col(p, :displaysize => T_SZ))
        ImageInTerminal.ENCODER_BACKEND[] = old_enc
    end

    @testset "blocks" begin
        old_enc = ImageInTerminal.ENCODER_BACKEND[]
        ImageInTerminal.ENCODER_BACKEND[] = :XTermColors
        p = imageplot(img, title = "blocks")
        @test !p.graphics.sixel[]
        test_ref("imageplot/img_blocks.txt", @show_col(p, :displaysize => T_SZ))
        ImageInTerminal.ENCODER_BACKEND[] = old_enc
    end
end
