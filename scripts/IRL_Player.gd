extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var camera_follow = $"../CameraFollow"

@onready var left_arrow = $"../../teleport hall1/leftarea/Sprite2D3"
@onready var right_arrow = $"../../teleport hall1/rightarea/Sprite2D"
@onready var libarrow = $"../../teleport hall1/library/Sprite2D2"


const MAX_SPEED: int = 400 # The max speed of the character
const ACCELERATION: int  = 50 # The step to reach the speed
const FRICTION: int = 25 # The step for the speed to reach 0
const JUMP_VELOCITY: int = -1800 # The height of the jump
const GRAVITY: int = 5000 # The acceleration of gravity

func _ready():
	pass

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
