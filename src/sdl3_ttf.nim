# SDL3_ttf bindings for Nim.
# Based on SDL_ttf 3.2.2
# Requires SDL_ttf 3.x (libSDL3_ttf.so / SDL3_ttf.dll / SDL3_ttf.dylib)

import sdl3

when defined(windows):
  const TtfLibName* = "SDL3_ttf.dll"
elif defined(macosx):
  const TtfLibName* = "libSDL3_ttf.dylib"
else:
  const TtfLibName* = "libSDL3_ttf.so"

{.push callConv: cdecl, dynlib: TtfLibName.}


type
  Font* = ptr object
  TextEngine* = ptr object
  TextData* = ptr object

  HintingFlags* {.size: sizeof(cint).} = enum
    hintingInvalid = -1,
    hintingNormal,
    hintingLight,
    hintingMono,
    hintingNone,
    hintingLightSubpixel

  HorizontalAlignment* {.size: sizeof(cint).} = enum
    horizontalAlignInvalid = -1,
    horizontalAlignLeft,
    horizontalAlignCenter,
    horizontalAlignRight

  Direction* {.size: sizeof(cint).} = enum   # values match hb_direction_t
    directionInvalid = 0,
    directionLtr = 4,
    directionRtl,
    directionTtb,
    directionBtt

  ImageType* {.size: sizeof(cint).} = enum
    imageInvalid,
    imageAlpha,
    imageColor,
    imageSdf

  GPUTextEngineWinding* {.size: sizeof(cint).} = enum
    gpuTextengineWindingInvalid = -1,
    gpuTextengineWindingClockwise,
    gpuTextengineWindingCounterClockwise

  FontStyleFlags* = uint32
  SubStringFlags* = uint32

  Text* {.bycopy.} = object
    text*: cstring
    num_lines*: cint
    refcount*: cint
    internal*: TextData

  GPUAtlasDrawSequence* {.bycopy.} = object
    atlas_texture*: GPUTexture
    xy*: ptr UncheckedArray[FPoint]
    uv*: ptr UncheckedArray[FPoint]
    num_vertices*: cint
    indices*: ptr UncheckedArray[cint]
    num_indices*: cint
    image_type*: ImageType
    next*: ptr GPUAtlasDrawSequence

  SubString* {.bycopy.} = object
    flags*: SubStringFlags
    offset*: cint
    length*: cint
    line_index*: cint
    cluster_index*: cint
    rect*: Rect

const STYLE_NORMAL*: uint32 = 0x00
const STYLE_BOLD*: uint32 = 0x01
const STYLE_ITALIC*: uint32 = 0x02
const STYLE_UNDERLINE*: uint32 = 0x04
const STYLE_STRIKETHROUGH*: uint32 = 0x08

const SUBSTRING_DIRECTION_MASK*: uint32 = 0x000000FF
const SUBSTRING_TEXT_START*: uint32 = 0x00000100
const SUBSTRING_LINE_START*: uint32 = 0x00000200
const SUBSTRING_LINE_END*: uint32 = 0x00000400
const SUBSTRING_TEXT_END*: uint32 = 0x00000800


proc version*(): cint {.importc: "TTF_Version".}
proc getFreeTypeVersion*(major, minor, patch: var cint) {.importc: "TTF_GetFreeTypeVersion".}
proc getHarfBuzzVersion*(major, minor, patch: var cint) {.importc: "TTF_GetHarfBuzzVersion".}


proc init*(): bool {.importc: "TTF_Init".}
proc openFont*(file: cstring, ptsize: cfloat): Font {.importc: "TTF_OpenFont".}
proc openFontIO*(src: IOStream, closeio: bool, ptsize: cfloat): Font {.importc: "TTF_OpenFontIO".}
proc openFontWithProperties*(props: PropertiesID): Font {.importc: "TTF_OpenFontWithProperties".}
proc copyFont*(existing_font: Font): Font {.importc: "TTF_CopyFont".}
proc getFontProperties*(font: Font): PropertiesID {.importc: "TTF_GetFontProperties".}
proc getFontGeneration*(font: Font): uint32 {.importc: "TTF_GetFontGeneration".}
proc addFallbackFont*(font: Font, fallback: Font): bool {.importc: "TTF_AddFallbackFont".}
proc removeFallbackFont*(font: Font, fallback: Font) {.importc: "TTF_RemoveFallbackFont".}
proc clearFallbackFonts*(font: Font) {.importc: "TTF_ClearFallbackFonts".}
proc setFontSize*(font: Font, ptsize: cfloat): bool {.importc: "TTF_SetFontSize".}
proc setFontSizeDPI*(font: Font, ptsize: cfloat, hdpi, vdpi: cint): bool {.importc: "TTF_SetFontSizeDPI".}
proc getFontSize*(font: Font): cfloat {.importc: "TTF_GetFontSize".}
proc getFontDPI*(font: Font, hdpi, vdpi: var cint): bool {.importc: "TTF_GetFontDPI".}

const PROP_FONT_CREATE_FILENAME_STRING* = "SDL_ttf.font.create.filename"
const PROP_FONT_CREATE_IOSTREAM_POINTER* = "SDL_ttf.font.create.iostream"
const PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER* = "SDL_ttf.font.create.iostream.offset"
const PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN* = "SDL_ttf.font.create.iostream.autoclose"
const PROP_FONT_CREATE_SIZE_FLOAT* = "SDL_ttf.font.create.size"
const PROP_FONT_CREATE_FACE_NUMBER* = "SDL_ttf.font.create.face"
const PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER* = "SDL_ttf.font.create.hdpi"
const PROP_FONT_CREATE_VERTICAL_DPI_NUMBER* = "SDL_ttf.font.create.vdpi"
const PROP_FONT_CREATE_EXISTING_FONT* = "SDL_ttf.font.create.existing_font"

const PROP_FONT_OUTLINE_LINE_CAP_NUMBER* = "SDL_ttf.font.outline.line_cap"
const PROP_FONT_OUTLINE_LINE_JOIN_NUMBER* = "SDL_ttf.font.outline.line_join"
const PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER* = "SDL_ttf.font.outline.miter_limit"


proc setFontStyle*(font: Font, style: FontStyleFlags) {.importc: "TTF_SetFontStyle".}
proc getFontStyle*(font: Font): FontStyleFlags {.importc: "TTF_GetFontStyle".}
proc setFontOutline*(font: Font, outline: cint): bool {.importc: "TTF_SetFontOutline".}
proc getFontOutline*(font: Font): cint {.importc: "TTF_GetFontOutline".}
proc setFontHinting*(font: Font, hinting: HintingFlags) {.importc: "TTF_SetFontHinting".}
proc getNumFontFaces*(font: Font): cint {.importc: "TTF_GetNumFontFaces".}
proc getFontHinting*(font: Font): HintingFlags {.importc: "TTF_GetFontHinting".}
proc setFontSDF*(font: Font, enabled: bool): bool {.importc: "TTF_SetFontSDF".}
proc getFontSDF*(font: Font): bool {.importc: "TTF_GetFontSDF".}
proc getFontWeight*(font: Font): cint {.importc: "TTF_GetFontWeight".}
proc setFontWrapAlignment*(font: Font, align: HorizontalAlignment) {.importc: "TTF_SetFontWrapAlignment".}
proc getFontWrapAlignment*(font: Font): HorizontalAlignment {.importc: "TTF_GetFontWrapAlignment".}
proc getFontHeight*(font: Font): cint {.importc: "TTF_GetFontHeight".}
proc getFontAscent*(font: Font): cint {.importc: "TTF_GetFontAscent".}
proc getFontDescent*(font: Font): cint {.importc: "TTF_GetFontDescent".}
proc setFontLineSkip*(font: Font, lineskip: cint) {.importc: "TTF_SetFontLineSkip".}
proc getFontLineSkip*(font: Font): cint {.importc: "TTF_GetFontLineSkip".}
proc setFontKerning*(font: Font, enabled: bool) {.importc: "TTF_SetFontKerning".}
proc getFontKerning*(font: Font): bool {.importc: "TTF_GetFontKerning".}
proc fontIsFixedWidth*(font: Font): bool {.importc: "TTF_FontIsFixedWidth".}
proc fontIsScalable*(font: Font): bool {.importc: "TTF_FontIsScalable".}
proc getFontFamilyName*(font: Font): cstring {.importc: "TTF_GetFontFamilyName".}
proc getFontStyleName*(font: Font): cstring {.importc: "TTF_GetFontStyleName".}
proc setFontDirection*(font: Font, direction: Direction): bool {.importc: "TTF_SetFontDirection".}
proc getFontDirection*(font: Font): Direction {.importc: "TTF_GetFontDirection".}
proc stringToTag*(str: cstring): uint32 {.importc: "TTF_StringToTag".}
proc tagToString*(tag: uint32, str: cstring, size: csize_t) {.importc: "TTF_TagToString".}
proc setFontScript*(font: Font, script: uint32): bool {.importc: "TTF_SetFontScript".}
proc getFontScript*(font: Font): uint32 {.importc: "TTF_GetFontScript".}
proc getGlyphScript*(ch: uint32): uint32 {.importc: "TTF_GetGlyphScript".}
proc setFontLanguage*(font: Font, language_bcp47: cstring): bool {.importc: "TTF_SetFontLanguage".}
proc fontHasGlyph*(font: Font, ch: uint32): bool {.importc: "TTF_FontHasGlyph".}

const fontWeightThin* = 100
const fontWeightExtraLight* = 200
const fontWeightLight* = 300
const fontWeightNormal* = 400
const fontWeightMedium* = 500
const fontWeightSemiBold* = 600
const fontWeightBold* = 700
const fontWeightExtraBold* = 800
const fontWeightBlack* = 900
const fontWeightExtraBlack* = 950


proc getGlyphImage*(font: Font, ch: uint32, image_type: var ImageType): ptr Surface {.importc: "TTF_GetGlyphImage".}
proc getGlyphImageForIndex*(font: Font, glyph_index: uint32, image_type: var ImageType): ptr Surface {.importc: "TTF_GetGlyphImageForIndex".}
proc getGlyphMetrics*(font: Font, ch: uint32, minx, maxx, miny, maxy, advance: var cint): bool {.importc: "TTF_GetGlyphMetrics".}
proc getGlyphKerning*(font: Font, previous_ch, ch: uint32, kerning: var cint): bool {.importc: "TTF_GetGlyphKerning".}


proc getStringSize*(font: Font, text: cstring, length: csize_t, w, h: var cint): bool {.importc: "TTF_GetStringSize".}
proc getStringSizeWrapped*(font: Font, text: cstring, length: csize_t, wrap_width: cint, w, h: var cint): bool {.importc: "TTF_GetStringSizeWrapped".}
proc measureString*(font: Font, text: cstring, length: csize_t, max_width: cint, measured_width: var cint, measured_length: var csize_t): bool {.importc: "TTF_MeasureString".}


proc renderTextSolid*(font: Font, text: cstring, length: csize_t, fg: Color): ptr Surface {.importc: "TTF_RenderText_Solid".}
proc renderTextSolidWrapped*(font: Font, text: cstring, length: csize_t, fg: Color, wrapLength: cint): ptr Surface {.importc: "TTF_RenderText_Solid_Wrapped".}
proc renderGlyphSolid*(font: Font, ch: uint32, fg: Color): ptr Surface {.importc: "TTF_RenderGlyph_Solid".}
proc renderTextShaded*(font: Font, text: cstring, length: csize_t, fg, bg: Color): ptr Surface {.importc: "TTF_RenderText_Shaded".}
proc renderTextShadedWrapped*(font: Font, text: cstring, length: csize_t, fg, bg: Color, wrap_width: cint): ptr Surface {.importc: "TTF_RenderText_Shaded_Wrapped".}
proc renderGlyphShaded*(font: Font, ch: uint32, fg, bg: Color): ptr Surface {.importc: "TTF_RenderGlyph_Shaded".}
proc renderTextBlended*(font: Font, text: cstring, length: csize_t, fg: Color): ptr Surface {.importc: "TTF_RenderText_Blended".}
proc renderTextBlendedWrapped*(font: Font, text: cstring, length: csize_t, fg: Color, wrap_width: cint): ptr Surface {.importc: "TTF_RenderText_Blended_Wrapped".}
proc renderGlyphBlended*(font: Font, ch: uint32, fg: Color): ptr Surface {.importc: "TTF_RenderGlyph_Blended".}
proc renderTextLCD*(font: Font, text: cstring, length: csize_t, fg, bg: Color): ptr Surface {.importc: "TTF_RenderText_LCD".}
proc renderTextLCDWrapped*(font: Font, text: cstring, length: csize_t, fg, bg: Color, wrap_width: cint): ptr Surface {.importc: "TTF_RenderText_LCD_Wrapped".}
proc renderGlyphLCD*(font: Font, ch: uint32, fg, bg: Color): ptr Surface {.importc: "TTF_RenderGlyph_LCD".}


proc createSurfaceTextEngine*(): TextEngine {.importc: "TTF_CreateSurfaceTextEngine".}
proc drawSurfaceText*(text: ptr Text, x, y: cint, surface: ptr Surface): bool {.importc: "TTF_DrawSurfaceText".}
proc destroySurfaceTextEngine*(engine: TextEngine) {.importc: "TTF_DestroySurfaceTextEngine".}
proc createRendererTextEngine*(renderer: Renderer): TextEngine {.importc: "TTF_CreateRendererTextEngine".}
proc createRendererTextEngineWithProperties*(props: PropertiesID): TextEngine {.importc: "TTF_CreateRendererTextEngineWithProperties".}
proc drawRendererText*(text: ptr Text, x, y: cfloat): bool {.importc: "TTF_DrawRendererText".}
proc destroyRendererTextEngine*(engine: TextEngine) {.importc: "TTF_DestroyRendererTextEngine".}
proc createGPUTextEngine*(device: GPUDevice): TextEngine {.importc: "TTF_CreateGPUTextEngine".}
proc createGPUTextEngineWithProperties*(props: PropertiesID): TextEngine {.importc: "TTF_CreateGPUTextEngineWithProperties".}
proc getGPUTextDrawData*(text: ptr Text): ptr GPUAtlasDrawSequence {.importc: "TTF_GetGPUTextDrawData".}
proc destroyGPUTextEngine*(engine: TextEngine) {.importc: "TTF_DestroyGPUTextEngine".}
proc setGPUTextEngineWinding*(engine: TextEngine, winding: GPUTextEngineWinding) {.importc: "TTF_SetGPUTextEngineWinding".}
proc getGPUTextEngineWinding*(engine: TextEngine): GPUTextEngineWinding {.importc: "TTF_GetGPUTextEngineWinding".}

const PROP_RENDERER_TEXT_ENGINE_RENDERER* = "SDL_ttf.renderer_text_engine.create.renderer"
const PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE* = "SDL_ttf.renderer_text_engine.create.atlas_texture_size"
const PROP_GPU_TEXT_ENGINE_DEVICE* = "SDL_ttf.gpu_text_engine.create.device"
const PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE* = "SDL_ttf.gpu_text_engine.create.atlas_texture_size"


proc createText*(engine: TextEngine, font: Font, text: cstring, length: csize_t): ptr Text {.importc: "TTF_CreateText".}
proc getTextProperties*(text: ptr Text): PropertiesID {.importc: "TTF_GetTextProperties".}
proc setTextEngine*(text: ptr Text, engine: TextEngine): bool {.importc: "TTF_SetTextEngine".}
proc getTextEngine*(text: ptr Text): TextEngine {.importc: "TTF_GetTextEngine".}
proc setTextFont*(text: ptr Text, font: Font): bool {.importc: "TTF_SetTextFont".}
proc getTextFont*(text: ptr Text): Font {.importc: "TTF_GetTextFont".}
proc setTextDirection*(text: ptr Text, direction: Direction): bool {.importc: "TTF_SetTextDirection".}
proc getTextDirection*(text: ptr Text): Direction {.importc: "TTF_GetTextDirection".}
proc setTextScript*(text: ptr Text, script: uint32): bool {.importc: "TTF_SetTextScript".}
proc getTextScript*(text: ptr Text): uint32 {.importc: "TTF_GetTextScript".}
proc setTextColor*(text: ptr Text, r, g, b, a: uint8): bool {.importc: "TTF_SetTextColor".}
proc setTextColorFloat*(text: ptr Text, r, g, b, a: cfloat): bool {.importc: "TTF_SetTextColorFloat".}
proc getTextColor*(text: ptr Text, r, g, b, a: var uint8): bool {.importc: "TTF_GetTextColor".}
proc getTextColorFloat*(text: ptr Text, r, g, b, a: var cfloat): bool {.importc: "TTF_GetTextColorFloat".}
proc setTextPosition*(text: ptr Text, x, y: cint): bool {.importc: "TTF_SetTextPosition".}
proc getTextPosition*(text: ptr Text, x, y: var cint): bool {.importc: "TTF_GetTextPosition".}
proc setTextWrapWidth*(text: ptr Text, wrap_width: cint): bool {.importc: "TTF_SetTextWrapWidth".}
proc getTextWrapWidth*(text: ptr Text, wrap_width: var cint): bool {.importc: "TTF_GetTextWrapWidth".}
proc setTextWrapWhitespaceVisible*(text: ptr Text, visible: bool): bool {.importc: "TTF_SetTextWrapWhitespaceVisible".}
proc textWrapWhitespaceVisible*(text: ptr Text): bool {.importc: "TTF_TextWrapWhitespaceVisible".}
proc setTextString*(text: ptr Text, str: cstring, length: csize_t): bool {.importc: "TTF_SetTextString".}
proc insertTextString*(text: ptr Text, offset: cint, str: cstring, length: csize_t): bool {.importc: "TTF_InsertTextString".}
proc appendTextString*(text: ptr Text, str: cstring, length: csize_t): bool {.importc: "TTF_AppendTextString".}
proc deleteTextString*(text: ptr Text, offset, length: cint): bool {.importc: "TTF_DeleteTextString".}
proc getTextSize*(text: ptr Text, w, h: var cint): bool {.importc: "TTF_GetTextSize".}
proc getTextSubString*(text: ptr Text, offset: cint, substring: var SubString): bool {.importc: "TTF_GetTextSubString".}
proc getTextSubStringForLine*(text: ptr Text, line: cint, substring: var SubString): bool {.importc: "TTF_GetTextSubStringForLine".}
proc getTextSubStringsForRange*(text: ptr Text, offset, length: cint, count: var cint): ptr UncheckedArray[ptr SubString] {.importc: "TTF_GetTextSubStringsForRange".}
proc getTextSubStringForPoint*(text: ptr Text, x, y: cint, substring: var SubString): bool {.importc: "TTF_GetTextSubStringForPoint".}
proc getPreviousTextSubString*(text: ptr Text, substring: ptr SubString, previous: var SubString): bool {.importc: "TTF_GetPreviousTextSubString".}
proc getNextTextSubString*(text: ptr Text, substring: ptr SubString, next: var SubString): bool {.importc: "TTF_GetNextTextSubString".}
proc updateText*(text: ptr Text): bool {.importc: "TTF_UpdateText".}
proc destroyText*(text: ptr Text) {.importc: "TTF_DestroyText".}


proc closeFont*(font: Font) {.importc: "TTF_CloseFont".}
proc quit*() {.importc: "TTF_Quit".}
proc wasInit*(): cint {.importc: "TTF_WasInit".}

{.pop.}
