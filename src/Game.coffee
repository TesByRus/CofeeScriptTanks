#coffee -o lib/ -cw src/

keyP1RotRight = false
keyP1RotLeft = false
keyP2RotRight = false
keyP2RotLeft = false


inRad = (num) ->
  return num * Math.PI / 180


class Player
  constructor: (@x, @y, @alpha, @color)->
    @x = x
    @y = y
    @alpha = alpha
    @dirX = Math.cos(inRad(alpha))
    @dirY = Math.sin(inRad(alpha))
    @color = color
    @bullets = []
    @XP = 3
    @speed = 0.8

  drawPlayer: ->
    canvas = document.getElementById("canvas")
    ctx = canvas.getContext('2d')
    ctx.save()
    ctx.translate(@x, @y)
    ctx.rotate(inRad(@alpha))

    ctx.fillStyle = @color
    ctx.fillRect(-10, -10, 20, 20)
    ctx.fillStyle = "#000"
    ctx.fillRect(10,-0.5,2,2)
    ctx.restore()

  rotateMe: (angle) ->
    @alpha+=angle
    @dirX = Math.cos(inRad(@alpha))
    @dirY = Math.sin(inRad(@alpha))

  moveMe: ->
    @x += @dirX*@speed
    @y += @dirY*@speed

    for i in @bullets
      i.moveBullet()
      i.drawBullet()

rotatePlayer = ->
  if keyP1RotRight
    player1.rotateMe(1.5)
  else if keyP1RotLeft
    player1.rotateMe(-1.5)

  if keyP2RotRight
    player2.rotateMe(1.5)
  else if keyP2RotLeft
    player2.rotateMe(-1.5)


player1 = new Player(100, 100, 0, "#FF0000")
player2 = new Player(700, 500, 180, "#0000FF")
players = [player1, player2]

lendir = (x, y) -> Math.sqrt(x*x+y*y)

class Bullet
  constructor: (@x, @y, @dirX, @dirY) ->
    @x = x
    @y = y
    @dirX = dirX/lendir(@dirX, @dirY)
    @dirY = dirY/lendir(@dirX, @dirY)

  drawBullet: ->
    canvas = document.getElementById('canvas');
    if (canvas.getContext)
      ctx = canvas.getContext('2d')
      ctx.strokeStyle = "#000"
      ctx.fillStyle = "#FF0000"
      ctx.beginPath()
      ctx.arc(@x,@y,1,0,Math.PI*2,true)
      ctx.closePath()
      ctx.stroke()
      ctx.fill()

  moveBullet: ->
    l = lendir(@dirX, @dirY)
    @x += 2*@dirX/l
    @y += 2*@dirY/l


checkIntersect = ->


  for p in players
    ind = []
    for i in p.bullets
      if i.x < 0 || i.x > 800
        ind.push(p.bullets.indexOf(i))
      else if i.y < 0 || i.y > 600
        ind.push(p.bullets.indexOf(i))
    for i in ind
      p.bullets.splice(i, 1)

  if player1.x + player1.dirX <= 0 || player1.x + player1.dirX  >= 800
    player1.dirX = 0
  if player1.y + player1.dirY <= 0 || player1.y + player1.dirY  >= 600
    player1.dirY = 0

  if player2.x + player2.dirX <= 0 || player2.x + player2.dirX  >= 800
    player2.dirX = 0
  if player2.y + player2.dirY <= 0 || player2.y + player2.dirY  >= 600
    player2.dirY = 0

  ind = []

  for i in player1.bullets
    if i.x >= player2.x-10 && i.x <= player2.x+10 && i.y >= player2.y-10 && i.y <= player2.y+10
      player2.XP -= 1
      player2.color = "#FFDE00"
      ind.push(player1.bullets.indexOf(i))
  for i in ind
    player1.bullets.splice(i, 1)

  ind = []
  for i in player2.bullets
    if i.x >= player1.x-10 && i.x <= player1.x+10 && i.y >= player1.y-10 && i.y <= player1.y+10
      player1.XP -= 1
      player1.color = "#FFDE00"
      ind.push(player2.bullets.indexOf(i))
  for i in ind
    player2.bullets.splice(i, 1)



interval = ->

@StartGame = ->
  startButton = document.getElementById("startButton")
  startButton.disabled = true
  interval = setInterval(Game, 1)

restart = ->
  player1 = new Player(100, 100, 0, "#FF0000")
  player2 = new Player(700, 500, 180, "#0000FF")
  startButton = document.getElementById("startButton")
  startButton.disabled = false
  drawStartArea()
  keyP1RotRight = false
  keyP1RotLeft = false
  keyP2RotRight = false
  keyP2RotLeft = false

@StopGame = ->
  clearInterval(interval)

bulTemp = 99

Game = ->
  drawArea()
  rotatePlayer()
  bulTemp+=1

  if bulTemp == 100
    bulTemp = 0
    b1 = new Bullet(player1.x, player1.y, player1.dirX, player1.dirY)
    b2 = new Bullet(player2.x, player2.y, player2.dirX, player2.dirY)
    player1.bullets.push(b1)
    player2.bullets.push(b2)
    player1.color = "#FF0000"
    player2.color = "#0000FF"

  checkIntersect()
  player1.moveMe()
  player1.drawPlayer()
  player2.moveMe()
  player2.drawPlayer()
  showLife()



showLife = () ->
  document.getElementById("p1").innerHTML = player1.XP.toString() + "xp"
  document.getElementById("p2").innerHTML = player2.XP.toString() + "xp"
  if player1.XP == 0 && player2.XP == 0
    StopGame()
    alert("DRAW!")
    restart()
  if player1.XP == 0
    StopGame()
    alert("Player2 WIN!")
    restart()
  else if player2.XP == 0
    StopGame()
    alert("Player1 WIN!")
    restart()


drawArea = ()->
  canvas = document.getElementById("canvas")
  if canvas.getContext
    ctx = canvas.getContext('2d')
    ctx.beginPath()
    ctx.clearRect(0,0,800,600)
    ctx.fillStyle="ABFCFF"
    ctx.fillRect(0,0,800,600)
    ctx.closePath();
    ctx.stroke();
    ctx.fill();

@drawStartArea = () ->
  drawArea()
  showLife()
  player1.drawPlayer()
  player2.drawPlayer()



@keyDown = (keyCode) ->
  if parseInt(keyCode)==68
    keyP1RotRight = true
  else if parseInt(keyCode)==65
    keyP1RotLeft = true

  if parseInt(keyCode)==39
    keyP2RotRight = true
  else if parseInt(keyCode)==37
    keyP2RotLeft = true


@keyUp = (keyCode) ->
  if parseInt(keyCode)==68
    keyP1RotRight = false
  else if parseInt(keyCode)==65
    keyP1RotLeft = false

  if parseInt(keyCode)==39
    keyP2RotRight = false
  else if parseInt(keyCode)==37
    keyP2RotLeft = false




