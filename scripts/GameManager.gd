extends Node2D


var current_checkpoint : Checkpoint

var player : Player

var is_cutscene = false
var room_open = false
var trivia_count = 0
var tt_count = 0
var rps_count = 0

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
