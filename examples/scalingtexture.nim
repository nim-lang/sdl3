# This example creates an SDL window and renderer, and then draws some
# textures to it every frame.
#
# This code is public domain. Feel free to use it for any purpose!
# Code adapted from Transmutrix's repo https://github.com/transmutrix/nim-sdl3/blob/main/examples/renderer/09-scaling-textures/scaling_textures.nim

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

discard setAppMetadata("Example Renderer Scaling Textures", "1.0", "com.example.renderer-scaling-textures")

if not init(INIT_VIDEO):
  echo "Couldn't initialize SDL: ", getError()
  quit(QuitFailure)

if not createWindowAndRenderer("examples/renderer/scaling-textures", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
  echo "Couldn't create window/renderer: ", getError()
  quit(QuitFailure)

block:
  # Textures are pixel data that we upload to the video hardware for fast drawing. Lots of 2D
  # engines refer to these as "sprites." We'll do a static texture (upload once, draw many
  # times) with data from a bitmap file.

  # surface is pixel data the CPU can access. Texture is pixel data the GPU can access.
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

  # we'll have the texture grow and shrink over a few seconds.
  let now = getTicks()
  let direction = if now mod 2000 >= 1000: 1.0 else: -1.0
  let scale = (now.int64 mod 1000 - 500).float / 500 * direction

  # as you can see from this, rendering draws over whatever was drawn before it.
  assert setRenderDrawColor(renderer, 0, 0, 0, ALPHA_OPAQUE)  # black, full alpha
  assert renderClear(renderer)  # start with a blank canvas.

  # center this one and make it grow and shrink.
  var dstRect: FRect
  dstRect.w = textureWidth.float + textureWidth.float*scale
  dstRect.h = textureHeight.float + textureHeight.float*scale
  dstRect.x = (WINDOW_WIDTH - dstRect.w).float / 2
  dstRect.y = (WINDOW_HEIGHT - dstRect.h).float / 2
  assert renderTexture(renderer, texture, nil, dstRect.addr)

  assert renderPresent(renderer)  # put it all on the screen!

sdl3.quit()
