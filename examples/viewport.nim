# This example creates an SDL window and renderer, and then draws some
# textures to it every frame, adjusting the viewport.
#
# This code is public domain. Feel free to use it for any purpose!

import std/os
import .../src/sdl3

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

discard setAppMetadata("Example renderer Viewport", "1.0", "com.example.renderer-viewport")

if not init(INIT_VIDEO):
  echo "Couldn't initialize SDL: ", getError()
  quit(QuitFailure)

if not createWindowAndRenderer("examples/renderer/viewport", WINDOW_WIDTH, WINDOW_HEIGHT, 0, window, renderer):
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

  var
    dstRect = FRect( x: 0, y: 0, w: textureWidth.float, h: textureHeight.float )
    viewport: Rect
    outline: FRect

  # setting a viewport has the effect of limiting the area that rendering
  # can happen, and making coordinate (0, 0) live somewhere else in the
  # window. It does _not_ scale rendering to fit the viewport.

  # as you can see from this, rendering draws over whatever was drawn before it.
  assert setRenderDrawColor(renderer, 0, 0, 0, ALPHA_OPAQUE)  # black, full alpha
  assert renderClear(renderer)  # start with a blank canvas.

  assert setRenderDrawColor(renderer, 255, 0, 255, ALPHA_OPAQUE) # magenta, to outline the viewports

  # Draw once with the whole window as the viewport.
  assert setRenderViewport(renderer, nil)  # nil means "use the whole window"
  assert renderTexture(renderer, texture, nil, addr dstRect)

  # top right quarter of the window.
  viewport.x = WINDOW_WIDTH div 2
  viewport.y = WINDOW_HEIGHT div 2
  viewport.w = WINDOW_WIDTH div 2
  viewport.h = WINDOW_HEIGHT div 2
  assert setRenderViewport(renderer, addr viewport)
  assert renderTexture(renderer, texture, nil, addr dstRect)

  # draw an outline of the viewport.
  assert setRenderViewport(renderer, nil)
  rectToFRect(addr viewport, addr outline)
  assert renderRect(renderer, outline)


  # bottom 20% of the window. Note it clips the width!
  viewport.x = 0
  viewport.y = WINDOW_HEIGHT - (WINDOW_HEIGHT div 5)
  viewport.w = WINDOW_WIDTH div 5
  viewport.h = WINDOW_HEIGHT div 5
  assert setRenderViewport(renderer, addr viewport)
  assert renderTexture(renderer, texture, nil, addr dstRect)

  # draw an outline of the viewport.
  assert setRenderViewport(renderer, nil)
  rectToFRect(addr viewport, addr outline)
  assert renderRect(renderer, outline)


  # what happens if you try to draw above the viewport? It should clip!
  viewport.x = 100
  viewport.y = 200
  viewport.w = WINDOW_WIDTH
  viewport.h = WINDOW_HEIGHT
  assert setRenderViewport(renderer, addr viewport)
  dstRect.y = -50
  assert renderTexture(renderer, texture, nil, addr dstRect)

  # draw an outline of the viewport.
  assert setRenderViewport(renderer, nil)
  rectToFRect(addr viewport, addr outline)
  assert renderRect(renderer, outline)

  assert renderPresent(renderer)  # put it all on the screen!


destroyTexture(texture)
sdl3.quit()
