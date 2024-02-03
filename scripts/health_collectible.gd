extends Area2D

const HEALTH_VALUE = 25

func _on_body_entered(body):
	if body.is_in_group("player"):
		if (body.health + HEALTH_VALUE) < body.max_health:
			body.health += HEALTH_VALUE
		else:
			body.health = body.health + (body.max_health - body.health)
	queue_free()
