extends Area2D



func _on_body_entered(body):
	if body.is_in_group("player"):
		body.count_key += 1
		if body.count_key >= 5:
			body.has_all_key = true
		else:
			body.has_all_key = false
	print(body.count_key)
	print(body.has_all_key)
	queue_free()
