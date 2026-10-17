# This example code looks for the current joystick state once per frame,
# and draws a visual representation of it.
#
# This code is public domain. Feel free to use it for any purpose!

# Joysticks are low-level interfaces: there's something with a bunch of
# buttons, axes and hats, in no understood order or position. This is
# a flexible interface, but you'll need to build some sort of configuration
# UI to let people tell you what button, etc, does what. On top of this
# interface, SDL offers the "gamepad" API, which works with lots of devices,
# and knows how to map arbitrary buttons and such to look like an
# Xbox/PlayStation/etc gamepad. This is easier, and better, for many games,
# but isn't necessarily a good fit for complex apps and hardware. A flight
# simulator, a realistic racing game, etc, might want this interface instead
# of gamepads.

# SDL can handle multiple joysticks, but for simplicity, this program only
# deals with the first stick it sees.

import ../src/sdl3
import std/random

# Code adapted from https://github.com/transmutrix/nim-sdl3/blob/main/examples/input/01-joystick-polling/joystick_polling.nim

# We will use this renderer to draw into this window every frame.
var window: Window
var renderer: Renderer
var joystick: Joystick
var colors: array[64, Color]


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

if not setAppMetadata("Example Input Joystick Polling", "1.0", "com.example.input-joystick-polling"):
  echo "Can't set metadata: ", getError()
  quit(QuitFailure)

if not init(INIT_VIDEO or INIT_JOYSTICK):
  echo "Can't init SDL: ", getError()
  quit(QuitFailure)

if not createWindowAndRenderer("examples/input/joystick-polling", 640, 480, 0, window, renderer):
  echo "Can't create window & renderer: ", getError()
  quit(QuitFailure)

assert setRenderVSync(renderer, 1)

for i in 0..<colors.len:
  colors[i].r = rand(1..255).uint8
  colors[i].g = rand(1..255).uint8
  colors[i].b = rand(1..255).uint8
  colors[i].a = 255


# -----------------------------------------------------------------------------
# Main Loop
# -----------------------------------------------------------------------------

var quit = false
while not quit:

  # Since we can't use the callbacks, we check for incoming events here.
  var event: Event
  while pollEvent(event):
    if event.type == EVENT_QUIT:
      quit = true
    elif event.type == EVENT_JOYSTICK_ADDED:
      # This event is sent for each hotplugged stick, but also each
      # already-connected joystick during Init().
      if joystick == nil:
        joystick = openJoystick(event.jdevice.which)
        if joystick == nil:
          echo "Failed to open joystick ID ", event.jdevice.which, ": ", getError()
    elif event.type == EVENT_JOYSTICK_REMOVED:
      if joystick != nil and (getJoystickID(joystick) == event.jdevice.which):
        closeJoystick(joystick)  # Our joystick was unplugged.
        joystick = nil

  # Game update.

  let text = if joystick != nil:  $getJoystickName(joystick)
                           else:  "Plug in a joystick, please."

  var winw, winh: cint
  discard getWindowSize(window, winw, winh)

  assert setRenderDrawColor(renderer, 0, 0, 0, 255)
  assert renderClear(renderer)

  # Note that you can get input as events, instead of polling, which is
  # better since it won't miss button presses if the system is lagging,
  # but often times checking the current state per-frame is good enough,
  # and maybe better if you'd rather _drop_ inputs due to lag.

  if joystick != nil: # We have a stick opened.
    # Draw axes as bars going across middle of screen. We don't know if it's
    # an X or Y or whatever axis, so we can't do more than this.
    const size = 30.0'f32
    var
      total = getNumJoystickAxes(joystick)
      y: float32 = (winh.float32 - total.float32 * size) / 2
      x: float32 = winw.float32 / 2
    for i in 0..<total:
      let
        color: ptr Color = addr colors[i mod colors.len]
        val: float32 = getJoystickAxis(joystick, i).float32 / 32767.0  # Make it -1.0 to 1.0
        dx: float32 = val*x + x
        dst = FRect( x: dx, y: y, w: x - abs(dx), h: size )
      assert setRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
      assert renderFillRect(renderer, dst)
      y += size

    # Fraw buttons as blocks across top of window. We only know the button
    # numbers, but not where they are on the device.
    total = getNumJoystickButtons(joystick)
    x = (winw.float32 - (total.float32 * size)) / 2
    for i in 0..<total:
      let
        color: ptr Color = addr colors[i mod colors.len]
        dst = FRect( x: x, y: 0.0, w: size, h: size )
      if getJoystickButton(joystick, i):
        assert setRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
      else:
        assert setRenderDrawColor(renderer, 0, 0, 0, 255)
      assert renderFillRect(renderer, dst)
      assert setRenderDrawColor(renderer, 255, 255, 255, color.a)
      assert renderRect(renderer, dst)  # Outline it
      x += size

    # Draw hats across the bottom of the screen.
    total = getNumJoystickHats(joystick)
    x = (winw.float32 - total.float32*size*2 + size) / 2
    y = winh.float32 - size
    for i in 0..<total:
      let
        color = addr colors[i mod colors.len]
        thirdsize = size / 3
        cross = [
          FRect( x: x,             y: y + thirdsize, w: size,      h: thirdsize ),
          FRect( x: x + thirdsize, y: y,             w: thirdsize, h: size ),
        ]
        hat = getJoystickHat(joystick, i)

      assert setRenderDrawColor(renderer, 90, 90, 90, 255)
      assert renderFillRects(renderer, cross)
      assert setRenderDrawColor(renderer, color.r, color.g, color.b, color.a)

      if (hat and HAT_UP) != 0:
        let dst = FRect( x: x + thirdsize, y: y, w: thirdsize, h: thirdsize )
        assert renderFillRect(renderer, dst)

      if (hat and HAT_RIGHT) != 0:
        let dst = FRect( x: x + (thirdsize * 2), y: y + thirdsize, w: thirdsize, h: thirdsize )
        assert renderFillRect(renderer, dst)

      if (hat and HAT_DOWN) != 0:
        let dst = FRect( x: x + thirdsize, y: y + (thirdsize * 2), w: thirdsize, h: thirdsize )
        assert renderFillRect(renderer, dst)

      if (hat and HAT_LEFT) != 0:
        let dst = FRect( x: x, y: y + thirdsize, w: thirdsize, h: thirdsize )
        assert renderFillRect(renderer, dst)

      x += size * 2

  let
    x = (winw - text.len*DEBUG_TEXT_FONT_CHARACTER_SIZE).float32 / 2
    y = (winh - DEBUG_TEXT_FONT_CHARACTER_SIZE).float32 / 2
  assert setRenderDrawColor(renderer, 255, 255, 255, 255)
  assert renderDebugText(renderer, x, y, text.cstring)
  assert renderPresent(renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

if joystick != nil:
  closeJoystick(joystick)

destroyRenderer(renderer)
destroyWindow(window)
sdl3.quit()
