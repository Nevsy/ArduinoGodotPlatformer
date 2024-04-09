extends CharacterBody2D

const SPEED = 20

func _physics_process(delta):
	$AnimatedSprite2D.flip_h = true
	velocity.x = SPEED
	move_and_slide()
