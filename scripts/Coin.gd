extends Area2D

var triggered = false
@onready var sprite = $"../AnimatedSprite2D"

func _on_body_entered(body):
	if !triggered:
		if body.has_method("GetCoin"):
			if sprite != null:
				sprite.visible = false
				triggered = true
				body.GetCoin()
