class_name Checkpoint
extends Node2D

@export var spawnpoint = false

var activated = false

func activate():
	GameManager.current_checkpoint = self
	activated = true
	$AnimatedSprite2D.play("Activate")



func _on_area_2d_body_entered(body):
	if body.is_in_group("player") && !activated:
		activate()
