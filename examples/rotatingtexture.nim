# This example creates an SDL window and renderer, and then draws some
# rotated textures to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!
# Code adapted from Transmutrix' repo - https://github.com/transmutrix/nim-sdl3/blob/main/examples/renderer/08-rotating-textures/rotating_textures.nim
# Requires SDL3.dll to run

import std/os
import ../src/sdl3

# We will use this renderer to draw into this window every frame.
var
  window: Window
  renderer: Renderer
  texture: Texture
  textureWidth: int
  textureHeight: int
  quit: bool

const WINDOW_WIDTH = 640
const WINDOW_HEIGHT = 480

assert setAppMetadata("Example Renderer Rotating Textures", "1.0", "com.example.renderer-rotating-textures")

if not init(INIT_VIDEO):
  echo "Couldn't initialize SDL: ", getError()
  quit(QuitFailure)

if not createWindowAndRenderer("examples/renderer/rotating-textures", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", getError()
  quit(QuitFailure)

block:
  # Textures are pixel data that we upload to the video hardware for fast drawing. Lots of 2D
  # engines refer to these as "sprites." We'll do a static texture (upload once, draw many
  # times) with data from a bitmap file.

  # Surface is pixel data the CPU can access. Texture is pixel data the GPU can access.
  # Load a .bmp into a surface, move it to a texture from there.
  let
    path = os.getCurrentDir() & "/test.bmp"
    surface = loadBMP(cstring path)
  if surface == nil:
    echo "Couldn't load bitmap: ", getError()
    quit(QuitFailure)

  textureWidth = surface.w
  textureHeight = surface.h

  texture = createTextureFromSurface(renderer, surface)
  if texture == nil:
    echo "Couldn't create static texture: ", getError()
    quit(QuitFailure)

  destroySurface(surface)  # done with this, the texture has a copy of the pixels now.


# Main loop.
while not quit:
  var event: Event
  while pollEvent(event):
    if event.type == EVENT_QUIT:
      quit = true

  let now = getTicks()

  # we'll have a texture rotate around over 2 seconds (2000 milliseconds). 360 degrees in a circle!
  let rotation = (now.int64 mod 2000).float / 2000 * 360

  # as you can see from this, rendering draws over whatever was drawn before it.
  assert setRenderDrawColor(renderer, 0, 0, 0, ALPHA_OPAQUE)  # black, full alpha
  assert renderClear(renderer)  # start with a blank canvas.

  # Center this one, and draw it with some rotation so it spins!
  let dstRect = FRect(
    x: (WINDOW_WIDTH - textureWidth).float / 2,
    y: (WINDOW_HEIGHT - textureHeight).float / 2,
    w: textureWidth.float,
    h: textureHeight.float,
  )
  # rotate it around the center of the texture--you can rotate it from a different point, too!
  let center = FPoint(
    x: textureWidth / 2,
    y: textureHeight / 2,
  )
  assert renderTextureRotated(renderer, texture, nil, dstRect.addr, rotation, center.addr, FLIP_NONE)

  assert renderPresent(renderer)  # put it all on the screen!


sdl3.quit()
