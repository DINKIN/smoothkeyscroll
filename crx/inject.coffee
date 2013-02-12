window.requestAnimationFrame ?= window.webkitRequestAnimationFrame
window.cancelAnimationFrame ?= window.webkitCancelAnimationFrame

speeds  =
  Normal: 5
  Control: 1
  Alt: 20
  Meta: 0

currentSpeed = 'Normal'

if chrome.storage
  # read options and update speeds
  chrome.storage.local.get null, (options) ->
    speeds[option] = parseInt(value) for option, value of options
  # update speeds as soon as options change
  chrome.storage.onChanged.addListener (options) ->
    speeds[option] = parseInt(value.newValue) for option, value of options
else
  window.SmoothKeyScrollSpeeds = speeds

oposite =
  Up: 'Down'
  Down: 'Up'
  Left: 'Right'
  Right: 'Left'

moving =
  Up: no
  Down: no
  Left: no
  Right: no

currentFrame = null

# Process all keyup and keydown events
processKeyEvent = (event) ->
  keyState = if event.type is 'keydown' then on else off
  switch event.keyIdentifier
    when 'Up', 'Down', 'Left', 'Right'
      if shouldScroll(event)
        direction = event.keyIdentifier
        if not moving[direction] and keyState is on
          startMoving(direction)
        else if keyState is off
          stopMoving(direction)
    when 'Control', 'Alt', 'Meta'
      currentSpeed = if keyState is on then event.keyIdentifier else 'Normal'
      event.preventDefault() if isMovingAny()

# Do not scroll if user is editing text, playing a game or something else
shouldScroll = (event) ->
  return no if event.target.isContentEditable
  return no if event.target.type is 'application/x-shockwave-flash'
  return no if event.defaultPrevented
  return no if /input|textarea|select|embed/i.test event.target.nodeName
  return no if currentSpeed is 'Meta'
  event.preventDefault() if currentSpeed is 'Normal'
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
  amount = speeds[currentSpeed]
  y = if moving.Down then amount else if moving.Up then -amount
  x = if moving.Right then amount else if moving.Left then -amount
  window.scrollBy(x, y) if x or y


# Setup event listeners
window.addEventListener('keydown', processKeyEvent, false)
window.addEventListener('keyup', processKeyEvent, false)


# Stop moving and reset speed when user changes to a different application or tab
window.onblur = ->
  stopMoving('Up')
  stopMoving('Down')
  stopMoving('Left')
  stopMoving('Right')
  currentSpeed = 'Normal'
