extends Node2D


var current_checkpoint : Checkpoint

var player : Player


var room_open = false

var boss_room = false

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
