extends CharacterBody2D

const SPEED = 800

func _physics_process(delta):
	$AnimatedSprite2D.flip_h = true
	velocity.x = SPEED * delta
	move_and_slide()
