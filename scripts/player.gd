extends CharacterBody2D

@onready var GameOver = $"../CanvasLayer2/GameOver"
@onready var Coin1 = $"../Coin/AnimatedSprite2D"
@onready var Score = $"../CanvasLayer3/Score"

@onready var arduinoCS = $".."

@export var gravity = 40
@export var JUMPFORCE = 700
@export var wallPushBack = 50
@export var maxFallSpeed = 250
@export var wallSlidingGravity = 30
@export var SpeedCoefficient = .6

signal healthChanged

var buttonValue : int
var potentioValue : int
var correctionbit : int

var speed : int
var absSpeed : int
var animationSpeed = 1
var wallJumpBuffer = 0
var wallJumpBufferValue = 50
# var wallJumpBufferValue = 15
var isWallSliding = false

var hearts = 3
var maxHealth = 3
var hitCoolDown = false
var hitCoolDownTime = 2.0

var score = 0

func addButtonValue(serialInt): # Activated from Arduino.cs
	# THERMOMETER -> IJS
	potentioValue = serialInt % 1024
	buttonValue = (serialInt >> 10) & 1  # Extracting the 11th bit
	correctionbit = (serialInt >> 11) & 1 # Extracting the 12th bit
	if correctionbit != 1:
		buttonValue = 0

func _physics_process(delta):
	#Input.get_axis takes in the names of the actions you put in the Project setting -> input map
	#var horizontal_direction = Input.get_axis("left", "right")
	checkHitCoolDown(delta)
	gravityFunc()
	horizontalMovement()
	wallSlide(delta)
	jump()
	
	move_and_slide()

func _ready():
	GameOver.visible = false

func gravityFunc():
	if !is_on_floor():
		if buttonValue == 0:
			velocity.y += 2*gravity # If button is not pressed, increase gravity
		else:
			velocity.y += gravity # Else apply normal gravity
			
		if velocity.y > 0: # Increase player horizontal speed when FALLING, decrease vertical speed a little
			$AnimatedSprite2D.play("Fall")
			velocity.x *= 1.4
			velocity.y *= .9
			if velocity.y > maxFallSpeed:
				velocity.y = maxFallSpeed
		elif velocity.y < 0:
			$AnimatedSprite2D.play("Jump")

func horizontalMovement():
	if correctionbit != 1: return
	if potentioValue > 300 and potentioValue < 724:
		speed = 0
	else:
		speed = snappedf(potentioValue / 2, 1) - 256

	if wallJumpBuffer <= 0:
		velocity.x = speed * SpeedCoefficient
	else:
		wallJumpBuffer -= 1
	
	# for the animation
	absSpeed = abs(speed)
	animationSpeed = absSpeed / 100
	
	if speed > 0:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("Run", animationSpeed)
	elif speed < 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("Run", animationSpeed)
	else:
		$AnimatedSprite2D.play("Idle")
	
func jump():
	if buttonValue == 1:
		if is_on_floor():
			velocity.y = -JUMPFORCE
		elif is_on_wall():
			if velocity.x > 0:
				velocity.x = -wallPushBack
			elif velocity.x < 0:
				velocity.x = wallPushBack
			velocity.y = -JUMPFORCE
			wallJumpBuffer = wallJumpBufferValue

func wallSlide(delta):
	if is_on_wall() and !is_on_floor():
		if velocity.x != 0:
			isWallSliding = true
		else:
			isWallSliding = false
	else:
		isWallSliding = false
	
	if isWallSliding:
		velocity.y += wallSlidingGravity * delta
		velocity.y = min(velocity.y, wallSlidingGravity)
				

func checkHitCoolDown(delta):
	if hitCoolDown:
		hitCoolDownTime -= delta
		if hitCoolDownTime <= 0:
			hitCoolDown = false
			hitCoolDownTime = 2.0  # Reset cooldown time


func _on_area_2d_area_entered(area): # activated whenever an area collides with player
	if area.is_in_group("enemy") && !hitCoolDown:
		loseHeart()
	elif area.is_in_group("spike") && !hitCoolDown:
		loseHeart()
	elif area.is_in_group("void"):
		hearts == 0
		healthChanged.emit(0)
		arduinoCS.healthLedUpdate(0)
		
		GameOver.visible = true
		get_tree().paused = true
	#elif area.is_in_group("coin"):
		#pickupCoin()

func loseHeart():
	if hearts <= 1:
		hearts == 0
		healthChanged.emit(0)
		arduinoCS.healthLedUpdate(0)
		GameOver.visible = true
		get_tree().paused = true
	else:
		hearts -= 1
		healthChanged.emit(hearts)
		arduinoCS.healthLedUpdate(hearts)
		hitCoolDown = true # Activate cooldown

func GetCoin():
	score += 1
	#var scoreString = str("Score: ", score)
	var scoreString = str(score)
	Score.changeText(scoreString)
	# Add sound effect?
