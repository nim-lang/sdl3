# This example code looks for joystick input in the event handler, and
# reports any changes as a flood of info.
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

import ../src/sdl3
import std/random

# We will use this renderer to draw into this window every frame.
var window: Window
var renderer: Renderer
var colors: array[64, Color]

const MOTION_EVENT_COOLDOWN = 40

type EventMessage = object
  str: string
  color: Color
  start_ticks: uint64

var messages: seq[EventMessage]

proc hat_state_string(state: uint8): string =
  return case state.uint:
    of HAT_CENTERED:  "CENTERED"
    of HAT_UP:        "UP"
    of HAT_RIGHT:     "RIGHT"
    of HAT_DOWN:      "DOWN"
    of HAT_LEFT:      "LEFT"
    of HAT_RIGHTUP:   "RIGHT+UP"
    of HAT_RIGHTDOWN: "RIGHT+DOWN"
    of HAT_LEFTUP:    "LEFT+UP"
    of HAT_LEFTDOWN:  "LEFT+DOWN"
    else:                 "UNKNOWN"

proc battery_state_string(state: PowerState): string =
  return case state:
    of POWERSTATE_ERROR:      "ERROR"
    of POWERSTATE_UNKNOWN:    "UNKNOWN"
    of POWERSTATE_ON_BATTERY: "ON BATTERY"
    of POWERSTATE_NO_BATTERY: "NO BATTERY"
    of POWERSTATE_CHARGING:   "CHARGING"
    of POWERSTATE_CHARGED:    "CHARGED"

proc add_message(jid: JoystickID, msg: string) =
  messages.add EventMessage(
    str: msg,
    color: colors[jid.int mod colors.len],
    start_ticks: getTicks(),
  )


# -----------------------------------------------------------------------------
# Initialization
# -----------------------------------------------------------------------------

if not setAppMetadata("Example Input Joystick Events", "1.0", "com.example.input-joystick-events"):
  echo "Can't set metadata: ", getError()
  quit(QuitFailure)

if not init(INIT_VIDEO or INIT_JOYSTICK):
  echo "Can't init SDL: ", getError()
  quit(QuitFailure)

if not createWindowAndRenderer("examples/input/joystick-events", 640, 480, 0, window, renderer):
  echo "Can't create window & renderer: ", getError()
  quit(QuitFailure)

assert setRenderVSync(renderer, 1)

colors[0] = Color(r: 255, g: 255, b: 255, a: 255)
for i in 1..<colors.len:
  colors[i].r = rand(255).uint8
  colors[i].g = rand(255).uint8
  colors[i].b = rand(255).uint8
  colors[i].a = 255

add_message(0, "Please plug in a joystick.")


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
      # This event is sent for each hotplugged stick, but also each already-connected joystick during Init().
      let
        which: JoystickID = event.jdevice.which
        joystick: Joystick = openJoystick(which)
      if joystick == nil:
          add_message(which, "Joystick #" & $which & " add, but not opened: " & $getError())
      else:
          add_message(which, "Joystick #" & $which & "(" & $getJoystickName(joystick) & ") added")
    elif event.type == EVENT_JOYSTICK_REMOVED:
      let
        which = event.jdevice.which
        joystick = getJoystickFromID(which)
      if joystick != nil:
        closeJoystick(joystick)  # The joystick was unplugged.
      add_message(which, "Joystick #" & $which & " removed")
    elif event.type == EVENT_JOYSTICK_AXIS_MOTION:
      var axis_motion_cooldown_time {.global.}: uint64 = 0  # These are spammy, only show every X milliseconds.
      let now = getTicks()
      if now >= axis_motion_cooldown_time:
        let which = event.jaxis.which
        axis_motion_cooldown_time = now + MOTION_EVENT_COOLDOWN
        add_message(which, "Joystick #" & $which & " axis " & $event.jaxis.axis & " . " & $event.jaxis.value)
    elif event.type == EVENT_JOYSTICK_BALL_MOTION:
      var ball_motion_cooldown_time {.global.}: uint64 = 0  # These are spammy, only show every X milliseconds.
      let now = getTicks()
      if now >= ball_motion_cooldown_time:
        let which = event.jball.which
        ball_motion_cooldown_time = now + MOTION_EVENT_COOLDOWN
        add_message(which, "Joystick #" & $which & " ball " & $event.jball.ball & " . " & $event.jball.xrel & ", " & $event.jball.yrel)
    elif event.type == EVENT_JOYSTICK_HAT_MOTION:
      let which = event.jhat.which
      add_message(which, "Joystick #" & $which & " hat " & $event.jhat.hat & " . " & hat_state_string(event.jhat.value))
    elif event.type in [EVENT_JOYSTICK_BUTTON_UP, EVENT_JOYSTICK_BUTTON_DOWN]:
      let which = event.jbutton.which
      add_message(which, "Joystick #" & $which & " button " & $event.jbutton.button & " . " & (if event.jbutton.down: "PRESSED" else: "RELEASED"))
    elif event.type == EVENT_JOYSTICK_BATTERY_UPDATED:
      let which = event.jbattery.which
      add_message(which, "Joystick #" & $which & " battery . " & battery_state_string(event.jbattery.state) & " - " & $event.jbattery.percent & "%")

  # App update
  assert setRenderDrawColor(renderer, 0, 0, 0, 255)
  assert renderClear(renderer)

  var winw, winh: cint
  discard getWindowSize(window, winw, winh)

  const msg_lifetime = 3500  # Milliseconds a message lives for.
  let now = getTicks()

  for i in countdown(messages.high, 0):
    let msg = messages[i]
    if now - msg.start_ticks >= msg_lifetime:
      messages.delete(i) # 'del' would do a swap-delete and reorder things!

  var prev_y = 0.0'f32
  for msg in messages.mitems:
    let
      life_percent = min(1, (now - msg.start_ticks).float32 / msg_lifetime)
      x = (winw - msg.str.len*DEBUG_TEXT_FONT_CHARACTER_SIZE).float32 / 2
      y = winh.float32 * life_percent

    if prev_y != 0 and (prev_y - y) < DEBUG_TEXT_FONT_CHARACTER_SIZE.float32:
      msg.start_ticks = now
      break  # Wait for the previous message to tick up a little.

    assert setRenderDrawColor(renderer, msg.color.r, msg.color.g, msg.color.b, (msg.color.a.float32 * (1-life_percent)).uint8)
    assert renderDebugText(renderer, x, y, msg.str.cstring)
    prev_y = y

  assert renderPresent(renderer)


#------------------------------------------------------------------------------
# Shutdown
#------------------------------------------------------------------------------

# We don't call "closeJoystick", letting them "leak" here,  because they will be cleaned up anyway.

destroyRenderer(renderer)
destroyWindow(window)
sdl3.quit()
