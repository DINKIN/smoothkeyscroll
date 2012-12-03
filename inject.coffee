window.requestAnimationFrame ?= window.webkitRequestAnimationFrame
window.cancelAnimationFrame ?= window.webkitCancelAnimationFrame

speeds =
  Normal: 5
  Control: 1
  Alt: 20
  Meta: 0

currentSpeed = speeds.Normal

# read options and update speeds
chrome.storage.local.get(null, (options) ->
  speeds[option] = parseInt(value) for option, value of options
  currentSpeed = speeds.Normal
)

# update speeds as soon as options change
chrome.storage.onChanged.addListener((options) ->
  speeds[option] = parseInt(value.newValue) for option, value of options
  currentSpeed = speeds.Normal
)

oposite =
  Up: "Down"
  Down: "Up"
  Left: "Right"
  Right: "Left"

moving =
  Up: no
  Down: no
  Left: no
  Right: no

currentFrame = null

# Process all keyup and keydown events
processKeyEvent = (event) ->
  keyState = if event.type is "keydown" then on else off
  switch event.keyIdentifier
    when "Up", "Down", "Left", "Right"
      if shouldScroll(event)
        direction = event.keyIdentifier
        if not moving[direction] and keyState is on
          startMoving(direction)
        else if keyState is off
          stopMoving(direction)
    when "Control", "Alt", "Meta"
      currentSpeed = if keyState is on then speeds[event.keyIdentifier] else speeds.Normal

# Do not scroll if user is editing text, playing a game or something else
shouldScroll = (event) ->
  return no if event.target.isContentEditable
  return no if event.target.type is 'application/x-shockwave-flash'
  return no if event.defaultPrevented
  return no if /input|textarea|select|embed/i.test event.target.nodeName
  return no if currentSpeed is 0
  event.preventDefault()
  yes

isMovingAny = -> moving.Up or moving.Down or moving.Left or moving.Right

startMoving = (direction) ->
  moving[direction] = true
  moving[oposite[direction]] = false
  currentFrame ?= requestAnimationFrame(move)

stopMoving = (direction) ->
  moving[direction] = false
  currentFrame = cancelAnimationFrame(currentFrame) unless isMovingAny()

move = ->
  currentFrame = requestAnimationFrame(move)
  y = if moving.Down then currentSpeed else if moving.Up then -currentSpeed
  x = if moving.Right then currentSpeed else if moving.Left then -currentSpeed
  window.scrollBy(x, y) if x or y


# Setup event listeners
window.addEventListener("keydown", processKeyEvent, false)
window.addEventListener("keyup", processKeyEvent, false)


# Stop moving and reset speed when user changes to a different application or tab
window.onblur = ->
  stopMoving("Up")
  stopMoving("Down")
  stopMoving("Left")
  stopMoving("Right")
  currentSpeed = speeds.Normal
