window.requestAnimationFrame ?= window.webkitRequestAnimationFrame
window.cancelAnimationFrame ?= window.webkitCancelAnimationFrame

speeds = 
  Normal: 5
  Control: 1
  Alt: 20
  Meta: 9999999

speed = speeds.Normal

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

processKeyEvent = (event) ->
  keyState = if event.type == "keydown" then on else off
  switch event.keyIdentifier
    when "Up", "Down", "Left", "Right"
      if isTryingToScroll(event)
        direction = event.keyIdentifier
        if not moving[direction] and keyState is on 
          startMoving(direction)
        else if keyState is off
          stopMoving(direction)
    when "Control", "Alt", "Meta"
      speed = if keyState is on then speeds[event.keyIdentifier] else speeds.Normal

isTryingToScroll = (event) ->
  return no if event.target.isContentEditable 
  return no if event.defaultPrevented
  return no if /input|textarea|select|embed/i.test event.target.nodeName
  event.preventDefault()
  yes

isScrolling = -> moving.Up or moving.Down or moving.Left or moving.Right

startMoving = (direction) ->
  moving[direction] = true
  moving[oposite[direction]] = false
  currentFrame ?= requestAnimationFrame(scroll)
  # currentFrame ?= setInterval(scroll, 15) o

stopMoving = (direction) ->
  moving[direction] = false 
  currentFrame = cancelAnimationFrame(currentFrame) unless isScrolling()
  # currentFrame = cancelInterval(currentFrame) unless isScrolling()

scroll = (timestamp) ->
  currentFrame = requestAnimationFrame(scroll)
  y = if moving.Down then speed else if moving.Up then -speed
  x = if moving.Right then speed else if moving.Left then -speed
  window.scrollBy(x, y) if x or y

window.addEventListener("keydown", processKeyEvent, false)
window.addEventListener("keyup", processKeyEvent, false)

window.onblur = ->
  stopMoving("Up")
  stopMoving("Down")
  stopMoving("Left")
  stopMoving("Right")
  speed = speeds.Normal
