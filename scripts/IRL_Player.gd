extends CharacterBody2D

@onready var all_interaction = []
var can_interact = false

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var camera_follow = $"../CameraFollow"

@onready var left_arrow = $"../../teleport hall1/leftarea/Sprite2D3"
@onready var right_arrow = $"../../teleport hall1/rightarea/Sprite2D"
@onready var libarrow = $"../../teleport hall1/library/Sprite2D2"

var trivia_count = 0


const MAX_SPEED: int = 400 # The max speed of the character
const ACCELERATION: int  = 50 # The step to reach the speed
const FRICTION: int = 25 # The step for the speed to reach 0
const JUMP_VELOCITY: int = -1800 # The height of the jump
const GRAVITY: int = 5000 # The acceleration of gravity

func _ready():
	$interactLabel.visible = false

func _process(delta):
	pass

func _physics_process(delta):
	set_animation()
	set_facing()
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	move_and_slide()

func _unhandled_input(_event: InputEvent) -> void:
	if can_interact:
		if Input.is_action_just_pressed("interact"):
			execute_interaction()
	
func apply_gravity(delta) -> void:
	velocity.y += GRAVITY * delta

func set_animation() -> void:
	if velocity.x > 1 || velocity.x < -1:
		animated_sprite_2d.animation = "Move"
	else:
		animated_sprite_2d.animation = "Idle"

func set_facing() -> void:
	if Input.is_action_just_pressed('left'):
		animated_sprite_2d.flip_h = true
	if Input.is_action_just_pressed('right'):
		animated_sprite_2d.flip_h = false

func change_scene(scene_path):
	if scene_path != "":
		get_tree().change_scene(scene_path)


func _on_rightarea_body_entered(body):
	pass


func _on_leftarea_body_entered(body):
	pass


func _on_library_body_entered(body):
	pass



func _on_actionable_finder_area_entered(area):
	all_interaction.insert(0, area)
	$interactLabel.visible = true
	can_interact = true



func _on_actionable_finder_area_exited(area):
	all_interaction.erase(area)
	$interactLabel.visible = false
	can_interact = false

func execute_interaction():
	if all_interaction:
		var cur_interaction = all_interaction[0]
		match cur_interaction.interact_value:
			"trivia" : 
				if GameManager.trivia_count < 1:
					get_tree().change_scene_to_file("res://scene/cutscene_trivia_1.tscn")
				elif GameManager.trivia_count < 4:
					get_tree().change_scene_to_file("res://scene/cutscene_trivia_2.tscn")
				else:
					get_tree().change_scene_to_file("res://scene/cutscene_post_trivia.tscn")
			"hall_1" : get_tree().change_scene_to_file("res://scene/IRL/Hall1.tscn")
			"TT" : 
				if GameManager.tt_count < 1:
					get_tree().change_scene_to_file("res://scene/cutscene_pre_tt.tscn")
				else:
					get_tree().change_scene_to_file("res://scene/cutscene_post_tt.tscn")
			"class_door" : get_tree().change_scene_to_file("res://scene/IRL/Classroom.tscn")
			"hall_2" : get_tree().change_scene_to_file("res://scene/IRL/Hall2.tscn")
