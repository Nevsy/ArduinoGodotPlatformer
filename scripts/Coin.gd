extends Area2D

var triggered = false

func _on_body_entered(body):
	if !triggered:
		if body.has_method("GetCoin"):
			body.GetCoin()
		$"../AnimatedSprite2D".visible = false
		triggered = true
