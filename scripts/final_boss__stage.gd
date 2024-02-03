extends Node2D

@onready var bgm = $BGM
@onready var collision_shape_2d = $Ayu/CollisionShape2D
@onready var sprite_2d = $Ayu/Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	bgm.play()
	collision_shape_2d.disabled = true
	sprite_2d.visible = false
