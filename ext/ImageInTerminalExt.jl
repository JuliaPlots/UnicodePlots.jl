module ImageInTerminalExt

import UnicodePlots
isdefined(Base, :get_extension) ? (import ImageInTerminal) : (import ..ImageInTerminal)    
using ColorTypes

UnicodePlots.sixel_encode(args...; kw...) = ImageInTerminal.sixel_encode(args...; kw...)
UnicodePlots.imshow(args...; kw...) = ImageInTerminal.imshow(args...; kw...)

function UnicodePlots.terminal_specs(img)
    if ImageInTerminal.choose_sixel(img)
        ans = ImageInTerminal.Sixel.TerminalTools.query_terminal("\e[16t", stdout)
        if ans isa String && (m = match(r"\e\[6;(\d+);(\d+)t", ans)) ≢ nothing
            char_h, char_w = tryparse.(Int, m.captures)
            return char_h ≢ nothing && char_w ≢ nothing, char_h, char_w
        end
    end
    false, nothing, nothing
end

UnicodePlots.imageplot(img::AbstractArray{<:Colorant}; kw...) =
    UnicodePlots.Plot(UnicodePlots.ImageGraphics(img); border = :corners, kw...)

end
