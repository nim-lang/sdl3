# SDL3_ttf bindings for Nim.
# Requires SDL_ttf 3.x (libSDL3_ttf.so / SDL3_ttf.dll)

import sdl3

when defined(windows):
  const TtfLibName* = "SDL3_ttf.dll"
elif defined(macosx):
  const TtfLibName* = "libSDL3_ttf.dylib"
else:
  const TtfLibName* = "libSDL3_ttf.so"

type
  FontObj {.incompletestruct.} = object
  Font* = ptr FontObj

proc init*(): bool {.importc: "TTF_Init", cdecl, dynlib: TtfLibName.}
proc quit*() {.importc: "TTF_Quit", cdecl, dynlib: TtfLibName.}

proc openFont*(file: cstring; ptsize: cfloat): Font {.importc: "TTF_OpenFont", cdecl, dynlib: TtfLibName.}
proc closeFont*(font: Font) {.importc: "TTF_CloseFont", cdecl, dynlib: TtfLibName.}

proc getFontAscent*(font: Font): cint {.importc: "TTF_GetFontAscent", cdecl, dynlib: TtfLibName.}
proc getFontDescent*(font: Font): cint {.importc: "TTF_GetFontDescent", cdecl, dynlib: TtfLibName.}
proc getFontLineSkip*(font: Font): cint {.importc: "TTF_GetFontLineSkip", cdecl, dynlib: TtfLibName.}

proc getStringSize*(font: Font; text: cstring; length: csize_t;
                    w, h: var cint): bool {.importc: "TTF_GetStringSize", cdecl, dynlib: TtfLibName.}

proc renderTextShaded*(font: Font; text: cstring; length: csize_t;
                       fg, bg: Color): ptr Surface {.importc: "TTF_RenderText_Shaded", cdecl, dynlib: TtfLibName.}

proc renderTextBlended*(font: Font; text: cstring; length: csize_t;
                        fg: Color): ptr Surface {.importc: "TTF_RenderText_Blended", cdecl, dynlib: TtfLibName.}

proc renderTextLCD*(font: Font; text: cstring; length: csize_t;
                    fg, bg: Color): ptr Surface {.importc: "TTF_RenderText_LCD", cdecl, dynlib: TtfLibName.}

const
  hintingNormal* = 0
  hintingLight* = 1
  hintingMono* = 2
  hintingNone* = 3
  hintingLightSubpixel* = 4

proc setFontHinting*(font: Font; hinting: cint) {.importc: "TTF_SetFontHinting", cdecl, dynlib: TtfLibName.}
proc getFontHinting*(font: Font): cint {.importc: "TTF_GetFontHinting", cdecl, dynlib: TtfLibName.}
proc setFontSDF*(font: Font; enabled: bool): bool {.importc: "TTF_SetFontSDF", cdecl, dynlib: TtfLibName.}
