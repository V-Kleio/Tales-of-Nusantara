extends Node2D


var current_checkpoint : Checkpoint

var player : Player

var is_cutscene = false
var room_open = false

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
