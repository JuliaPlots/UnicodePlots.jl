# adapted from github.com/JuliaGraphics/FreeTypeAbstraction.jl/blob/master/src/rendering.jl
# credits to the `FreeTypeAbstraction` authors (@SimonDanisch, @jkrumbiegel).

module FreeTypeExt

import UnicodePlots
import FileIO

using StaticArrays
using ColorTypes
using FreeType

const REGULAR_STYLES = "regular", "normal", "medium", "standard", "roman", "book"
const FT_LIB = FT_Library[C_NULL]
const LIB_LOCK = ReentrantLock()
const VALID_FONTPATHS = String[]

struct FontExtent{T}
    vertical_bearing::SVector{2,T}
    horizontal_bearing::SVector{2,T}
    advance::SVector{2,T}
    scale::SVector{2,T}
end

mutable struct FTFont
    ft_ptr::FT_Face
    lock::ReentrantLock  # lock this for the duration of any FT operation on ft_ptr
    function FTFont(ft_ptr::FT_Face)
        face = new(ft_ptr, ReentrantLock())
        finalizer(safe_free, face)
        face
    end
end

function safe_free(face::FTFont)
    @lock face.lock begin
        (face.ft_ptr != C_NULL && FT_LIB[1] != C_NULL) && FT_Done_Face(face)
    end
end

FTFont(path::String) = FTFont(new_face(path))
FTFont(::Nothing) = nothing

family_name(font::FTFont) = lowercase(ft_property(font, :family_name))
style_name(font::FTFont) = lowercase(ft_property(font, :style_name))
Base.propertynames(font::FTFont) = fieldnames(FT_FaceRec)

# C interop
Base.cconvert(::Type{FT_Face}, font::FTFont) = font
Base.unsafe_convert(::Type{FT_Face}, font::FTFont) = font.ft_ptr

function ft_property(face::FTFont, fieldname::Symbol)
    font_rect = @lock face.lock unsafe_load(face.ft_ptr)
    if (field = getfield(font_rect, fieldname)) isa Ptr{FT_String}
        field == C_NULL && return ""
        unsafe_string(field)
    else
        field
    end
end

Base.show(io::IO, font::FTFont) = print(
    io,
    "FTFont (family = $(ft_property(font, :family_name)), style = $(ft_property(font, :style_name)))",
)

check_error(err, error_msg) = err == 0 || error("$error_msg with error: $err")

function new_face(name, index::Real = 0, ftlib = FT_LIB)
    face = Ref{FT_Face}()
    err = @lock LIB_LOCK FT_New_Face(ftlib[1], name, Int32(index), face)
    check_error(err, "Couldn't load font $name")
    face[]
end

add_mono(fts...) = tuple(map(x -> x * "Mono", fts)..., fts...)

# COV_EXCL_START
fallback_fonts() =
# those fallback fonts are likely to fail braille characters
    if Sys.islinux()
        add_mono("DejaVu Sans ", "Ubuntu ", "Noto ", "Free", "Liberation ")  # NOTE: tailing space intended
    elseif Sys.isbsd()
        ("Courier New", "Helvetica")
    elseif Sys.iswindows()
        ("Courier New", "Arial")
    else
        @warn "Unsupported $(Base.KERNEL)"
        ("Courier", "Helvetica")
    end::Tuple
# COV_EXCL_STOP

const FT_FONTS = Dict{String,FTFont}()

"""
Match a font using the user-specified search string.
Each part of the search string is searched in the family name first,
which has to match once to include the font in the candidate list.
For fonts with a family match the style name is matched next.
For fonts with the same family and style name scores, regular fonts are preferred
(any font that is "regular", "normal", "medium", "standard" or "roman"),
and as a last tie-breaker, shorter overall font names are preferred.

Example:

If we had only four fonts:
- Helvetica Italic
- Helvetica Regular
- Helvetica Neue Regular
- Helvetica Neue Light

Then this is how this function would match different search strings:
- "helvetica"           => Helvetica Regular
- "helv"                => Helvetica Regular
- "HeLvEtIcA"           => Helvetica Regular
- "helvetica italic"    => Helvetica Italic
- "helve ita"           => Helvetica Italic
- "helvetica neue"      => Helvetica Neue Regular
- "tica eue"            => Helvetica Neue Regular
- "helvetica light"     => Helvetica Neue Light
- "light"               => Helvetica Neue Light
- "helvetica bold"      => Helvetica Regular
- "helvetica neue bold" => Helvetica Neue Regular
- "times"               => no match
- "arial"               => no match
"""
function match_font(face::FTFont, searchparts)::Tuple{Int,Int,Bool,Int}
    fname, sname = family_name(face), style_name(face)
    is_regular_style = any(occursin.(REGULAR_STYLES, Ref(sname)))

    fontlength_penalty = -length(fname) - length(sname)
    family_matches = any(occursin.(searchparts, Ref(fname)))

    # return early if family name doesn't have a match
    family_matches || return 0, 0, is_regular_style, fontlength_penalty
    family_score = sum(map(length, filter(part -> occursin(part, fname), searchparts)))

    # now enhance the score with style information
    remaining_parts = filter(part -> !occursin(part, fname), searchparts)

    isempty(remaining_parts) && return family_score, 0, is_regular_style, fontlength_penalty

    # check if any parts match the style name, otherwise return early
    any(occursin.(remaining_parts, Ref(sname))) ||
        return family_score, 0, is_regular_style, fontlength_penalty

    style_score = sum(map(length, filter(part -> occursin(part, sname), remaining_parts)))  # COV_EXCL_LINE
    family_score, style_score, is_regular_style, fontlength_penalty  # COV_EXCL_LINE
end

function find_font(searchstring::String; additional_fonts::String = "")
    font_folders = copy(VALID_FONTPATHS)
    isempty(additional_fonts) || pushfirst!(font_folders, additional_fonts)

    # \W splits at all groups of non-word characters (like space, -, ., etc)
    searchparts = unique(split(lowercase(searchstring), r"\W+", keepempty = false))

    best_score = 0, 0, false, typemin(Int)
    best_fpath = face = nothing

    for folder in font_folders, font in readdir(folder)
        fpath = joinpath(folder, font)
        try
            face = FTFont(fpath)
        catch
            continue
        end

        score = match_font(face, searchparts)
        # we can compare all four tuple elements of the score at once in order of importance:
        # 1. number of family match characters
        # 2. number of style match characters
        # 3. is font a "regular" style variant ?
        # 4. the negative length of the font name, the shorter the better
        if (family_match_score = first(score)) > 0 && score > best_score
            best_fpath = fpath
            best_score = score
        end
        finalize(face)
    end
    FTFont(best_fpath)
end

hadvance(ext::FontExtent) = ext.advance[1]
vadvance(ext::FontExtent) = ext.advance[2]
inkwidth(ext::FontExtent) = ext.scale[1]
inkheight(ext::FontExtent) = ext.scale[2]
hbearing_ori_to_left(ext::FontExtent) = ext.horizontal_bearing[1]
hbearing_ori_to_top(ext::FontExtent) = ext.horizontal_bearing[2]
leftinkbound(ext::FontExtent) = hbearing_ori_to_left(ext)
rightinkbound(ext::FontExtent) = leftinkbound(ext) + inkwidth(ext)
bottominkbound(ext::FontExtent) = hbearing_ori_to_top(ext) - inkheight(ext)
topinkbound(ext::FontExtent) = hbearing_ori_to_top(ext)

FontExtent(fontmetric::FT_Glyph_Metrics, scale::T = 64.0) where {T<:AbstractFloat} =
    FontExtent(
        SVector{2,T}(fontmetric.vertBearingX, fontmetric.vertBearingY) ./ scale,
        SVector{2,T}(fontmetric.horiBearingX, fontmetric.horiBearingY) ./ scale,
        SVector{2,T}(fontmetric.horiAdvance, fontmetric.vertAdvance) ./ scale,
        SVector{2,T}(fontmetric.width, fontmetric.height) ./ scale,
    )

FontExtent(func::Function, ext::FontExtent) = FontExtent(
    func(ext.vertical_bearing),
    func(ext.horizontal_bearing),
    func(ext.advance),
    func(ext.scale),
)

function set_pixelsize(face::FTFont, size::Integer)
    @lock face.lock check_error(
        FT_Set_Pixel_Sizes(face, size, size),
        "Couldn't set pixelsize",
    )
    size
end

glyph_index(face::FTFont, glyphname::String)::UInt64 =
    @lock face.lock FT_Get_Name_Index(face, glyphname)
glyph_index(face::FTFont, char::Char)::UInt64 =
    @lock face.lock FT_Get_Char_Index(face, char)
glyph_index(face::FTFont, idx::Integer) = UInt64(idx)

function kerning(face::FTFont, glyphspecs...)
    i1, i2 = glyph_index.(Ref(face), glyphspecs)
    kerning2d = Ref{FT_Vector}()
    err = @lock face.lock FT_Get_Kerning(face, i1, i2, FT_KERNING_DEFAULT, kerning2d)
    # can error if font has no kerning ! Since that's somewhat expected, we just return 0
    err == 0 || return SVector(0.0, 0.0)
    divisor = 64  # 64 since metrics are in 1/64 units (units to 26.6 fractional pixels)
    SVector(kerning2d[].x / divisor, kerning2d[].y / divisor)
end

function load_glyph(face::FTFont, glyph)
    gi = glyph_index(face, glyph)
    err = @lock face.lock FT_Load_Glyph(face, gi, FT_LOAD_RENDER)
    check_error(err, "Could not load glyph $(repr(glyph)) from $face to render.")
end

function load_glyph(face::FTFont, glyph, pixelsize::Integer; set_pix = true)
    set_pix && set_pixelsize(face, pixelsize)
    load_glyph(face, glyph)
    gl = @lock face.lock unsafe_load(ft_property(face, :glyph))
    @assert gl.format == FT_GLYPH_FORMAT_BITMAP
    gl
end

function glyph_bitmap(bitmap::FT_Bitmap)
    @assert bitmap.pixel_mode == FT_PIXEL_MODE_GRAY
    bmp = Matrix{UInt8}(undef, bitmap.width, bitmap.rows)
    row = bitmap.buffer
    bitmap.pitch < 0 && (row -= bitmap.pitch * (rbmpRec.rows - 1))
    for r = 1:(bitmap.rows)
        bmp[:, r] = unsafe_wrap(Array, row, bitmap.width)
        row += bitmap.pitch
    end
    bmp
end

render_face(face::FTFont, glyph, pixelsize::Integer; kw...) =
    let gl = load_glyph(face, glyph, pixelsize; kw...)
        glyph_bitmap(gl.bitmap), FontExtent(gl.metrics)
    end

extents(face::FTFont, glyph, pixelsize::Integer) =
    FontExtent(load_glyph(face, glyph, pixelsize).metrics)

one_or_typemax(::Type{T}) where {T<:Union{Real,Colorant}} =
    T <: Integer ? typemax(T) : oneunit(T)

"""
    render_string!(img::AbstractMatrix, str::String, face, pixelsize, y0, x0;
                   fcolor=one_or_typemax(T), bcolor=zero(T), halign=:hleft, valign=:vbaseline) -> Matrix
Render `str` into `img` using the font `face` of size `pixelsize` at coordinates `y0,x0`.
Uses the conventions of freetype.org/freetype2/docs/glyphs/glyphs-3.html
# Arguments
- `y0,x0`: origin is in upper left with positive `y` going down.
- `fcolor`: foreground color; AbstractVector{T}, typemax(T) for T<:Integer, otherwise one(T).
- `gcolor`: background color; AbstractVector{T}, typemax(T) for T<:Integer, otherwise one(T).
- `bcolor`: canvas background color; set to `nothing` for transparent.
- `halign`: :hleft, :hcenter, or :hright.
- `valign`: :vtop, :vcenter, :vbaseline, or :vbttom.
- `bbox_glyph`: glyph bounding box color (debugging).
- `bbox`: bounding box color (debugging).
- `gstr`: background string or array of chars (for background sizing).
- `incx`: extra x spacing.
"""
function UnicodePlots.render_string!(
    img::AbstractMatrix{T},
    fstr::Union{AbstractVector{Char},String},
    face::FTFont,
    pixelsize::Int,
    y0,
    x0;
    fcolor::Union{AbstractVector{T},T} = one_or_typemax(T),
    gcolor::Union{AbstractVector{T},T,Nothing} = nothing,
    bcolor::Union{T,Nothing} = zero(T),
    halign::Symbol = :hleft,
    valign::Symbol = :vbaseline,
    bbox_glyph::Union{T,Nothing} = nothing,
    bbox::Union{T,Nothing} = nothing,
    gstr::Union{AbstractVector{Char},String,Nothing} = nothing,
    off_bg::Int = 0,
    incx::Int = 0,
) where {T<:Union{Real,Colorant}}
    set_pixelsize(face, pixelsize)

    fstr = fstr isa AbstractVector ? fstr : collect(fstr)
    if gstr ≢ nothing
        gstr = gstr isa AbstractVector ? gstr : collect(gstr)
    end

    len = length(fstr)
    bitmaps = Vector{Matrix{UInt8}}(undef, len)
    metrics = Vector{FontExtent{Int}}(undef, len)

    y_min = y_max = sum_adv_x = 0  # y_min and y_max are w.r.t the baseline
    for (i, char) in enumerate(fstr)
        bitmap, metricf = render_face(face, char, pixelsize; set_pix = false)
        metric = FontExtent(x -> round.(Int, x), metricf)
        bitmaps[i] = bitmap
        metrics[i] = metric

        y_min = min(y_min, bottominkbound(metric))
        y_max = max(y_max, topinkbound(metric))
        sum_adv_x += hadvance(metric)
    end

    bitmap_max = bitmaps |> first |> eltype |> typemax
    imgh, imgw = size(img)

    # initial pen position
    px = x0 - (halign ≡ :hright ? sum_adv_x : halign ≡ :hcenter ? sum_adv_x >> 1 : 0)
    py =
        y0 + (
            valign ≡ :vtop ? y_max :
            valign ≡ :vbottom ? y_min :
            valign ≡ :vcenter ? (y_max - y_min) >> 1 + y_min : 0
        )

    if bcolor ≢ nothing
        img[
            clamp(py - y_max, 1, imgh):clamp(py - y_min, 1, imgh),
            clamp(px, 1, imgw):clamp(px + sum_adv_x, 1, imgw),
        ] .= bcolor
    end

    first_char = first(fstr)
    for (i, char) in enumerate(fstr)
        bitmap = bitmaps[i]
        metric = metrics[i]
        bx, by = metric.horizontal_bearing
        ax, ay = metric.advance
        sx, sy = metric.scale

        i > 1 && (px += round(Int, kerning(face, first_char, char) |> first))

        # glyph origin
        oy = py - by
        ox = px + bx

        fcol = fcolor isa AbstractVector ? fcolor[i] : fcolor
        gcol = gcolor isa AbstractVector ? gcolor[i] : gcolor

        # trim parts of glyph images that are outside the destination
        row_lo, row_hi = 1 + max(0, -oy), sy - max(0, oy + sy - imgh)
        col_lo, col_hi = 1 + max(0, -ox), sx - max(0, ox + sx - imgw)

        if gcol ≡ nothing
            for r = row_lo:row_hi, c = col_lo:col_hi
                (bm = bitmap[c, r]) == 0 && continue
                color = bm / bitmap_max * fcol
                img[oy + r, ox + c] = T <: Integer ? round(T, color) : T(color)
            end
        else
            if gstr ≢ nothing
                gexts = extents(face, gstr[i], pixelsize)
                gmetric = FontExtent(x -> round.(Int, x), gexts)
                y_min = bottominkbound(gmetric)
                y_max = topinkbound(gmetric)
            end

            # fill background
            by1, by2 = py - y_max, py - y_min
            bx1, bx2 = px, px + ax
            r1, r2 = clamp(by1, 1, imgh), clamp(by2, 1, imgh)
            c1, c2 = clamp(bx1, 1, imgw), clamp(bx2, 1, imgw)
            for r = (r1 + off_bg):(r2 - off_bg), c = (c1 + off_bg):(c2 - off_bg)
                img[r, c] = gcol
            end

            # render character by drawing the corresponding glyph
            for r = row_lo:row_hi, c = col_lo:col_hi
                (bm = bitmap[c, r]) == 0 && continue
                w1 = bm / bitmap_max
                color0 = w1 * fcol
                color1 = (1 - w1) * gcol
                img[oy + r, ox + c] =
                    T <: Integer ? round(T, color0 + color1) : T(color0 + color1)
            end

            # draw background bounding box
            if bbox ≢ nothing && r2 > r1 && c2 > c1
                img[r1, c1:c2] .= bbox
                img[r2, c1:c2] .= bbox
                img[r1:r2, c1] .= bbox
                img[r1:r2, c2] .= bbox
            end
        end

        # draw glyph bounding box
        if bbox_glyph ≢ nothing
            r1, r2 = clamp(oy + row_lo, 1, imgh), clamp(oy + row_hi, 1, imgh)
            c1, c2 = clamp(ox + col_lo, 1, imgw), clamp(ox + col_hi, 1, imgw)
            if r2 > r1 && c2 > c1
                img[r1, c1:c2] .= bbox_glyph
                img[r2, c1:c2] .= bbox_glyph
                img[r1:r2, c1] .= bbox_glyph
                img[r1:r2, c2] .= bbox_glyph
            end
        end

        px += ax + incx
    end
    img
end

function ft_init()
    @lock LIB_LOCK begin
        FT_LIB[1] != C_NULL &&
            error("Freetype already initialized. init() called two times ?")
        FT_Init_FreeType(FT_LIB) == 0
    end
end

function ft_done()
    @lock LIB_LOCK begin
        FT_LIB[1] == C_NULL && error(
            "Library == CNULL. done() called before init(), or done called two times ?",
        )
        err = FT_Done_FreeType(FT_LIB[1])
        FT_LIB[1] = C_NULL
        err == 0
    end
end

add_recursive(result, path) =
    for p in readdir(path)
        if (pabs = joinpath(path, p)) |> isdir
            push!(result, pabs)
            add_recursive(result, pabs)
        end
    end

function __init__()
    ft_init()
    atexit(ft_done)
    # this method of finding fonts might not work for exotic platforms,
    # so we supply a way to help it with an environment variable.
    font_paths = if Sys.isapple()  # COV_EXCL_LINE
        [
            "/Library/Fonts",  # additional fonts that can be used by all users: this is generally where fonts go if they are to be used by other applications
            joinpath(homedir(), "Library/Fonts"),  # fonts specific to each user
            "/Network/Library/Fonts",  # fonts shared for users on a network
            "/System/Library/Fonts",  # system specific fonts
            "/System/Library/Fonts/Supplemental",  # new location since Catalina
        ]
    elseif Sys.iswindows()  # COV_EXCL_LINE
        [
            joinpath(get(ENV, "SYSTEMROOT", "C:\\Windows"), "Fonts"),
            joinpath(homedir(), "AppData", "Local", "Microsoft", "Windows", "Fonts"),
        ]
    else
        result = String[]
        for p in (
            "/usr/share/fonts",
            joinpath(homedir(), ".fonts"),
            joinpath(homedir(), ".local/share/fonts"),
            "/usr/local/share/fonts",
        )
            if isdir(p)
                push!(result, p)
                add_recursive(result, p)
            end
        end
        result  # COV_EXCL_LINE
    end
    env_path = get(ENV, "UP_FONT_PATH", nothing)
    env_path ≡ nothing || push!(font_paths, env_path)
    append!(VALID_FONTPATHS, filter(isdir, font_paths))
    nothing
end

function UnicodePlots.get_font_face(font = nothing, fallback = fallback_fonts())
    face = nothing
    for name ∈ filter(!isnothing, (font, "JuliaMono", fallback...))
        if (face = get(FT_FONTS, name, nothing)) ≡ nothing
            if (ft = find_font(name)) ≢ nothing
                face = FT_FONTS[name] = ft
                break  # found new font, cache and return it
            end
        else
            break  # found in cache
        end
    end
    face
end

UnicodePlots.save_image(fn::AbstractString, args...; kw...) =
    FileIO.save(fn, args...; kw...)

# compat for Plots
UnicodePlots.save_image(io::IO, args...; kw...) =
    FileIO.save(FileIO.Stream{FileIO.format"PNG"}(io), args...; kw...)

end  # module
