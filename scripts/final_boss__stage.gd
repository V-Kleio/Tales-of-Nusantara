extends Node2D

@onready var bgm = $BGM

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm.play()
