extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.start("res://dialogic/after_boss1.dtl")
	Dialogic.timeline_ended.connect(ended)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ended():
	Dialogic.timeline_ended.disconnect(ended)
	get_tree().change_scene_to_file("res://scene/IRL/Hall1.tscn")
