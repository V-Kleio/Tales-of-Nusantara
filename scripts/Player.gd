extends CharacterBody2D


@onready var jump_buffer_timer = $JumpBufferTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTimer

const MAX_SPEED: int = 600 # The max speed of the character
const ACCELERATION: int  = 50 # The step to reach the speed
const FRICTION: int = 25 # The step for the speed to reach 0
const JUMP_VELOCITY: int = -1800 # The height of the jump
const GRAVITY: int = 5000 # The acceleration of gravity

var double_jump: int = 1 # Count the number of jump when the player jump
var touch_ground: bool = true

func _physics_process(delta):
	set_animation()
	set_facing()
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

	if is_on_floor():
		touch_ground = true
		double_jump = 1
		coyote_timer.start()
		if !jump_buffer_timer.is_stopped():
			jump()
	else:
		if coyote_timer.is_stopped():
			apply_gravity(delta)
			touch_ground = false
		elif !jump_buffer_timer.is_stopped():
			jump()
		
		if Input.is_action_just_pressed("jump") and double_jump > 0 and !touch_ground:
			jump()
			double_jump -= 1


	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)

	move_and_slide()
	



func jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_buffer_timer.stop()
	coyote_timer.stop()

func apply_gravity(delta) -> void:
	velocity.y += GRAVITY * delta
	animated_sprite_2d.animation = "jump"

func set_animation() -> void:
	if velocity.x > 1 || velocity.x < -1:
		animated_sprite_2d.animation = "run"
	else:
		animated_sprite_2d.animation = "idle"

func set_facing() -> void:
	if Input.is_action_just_pressed('left'):
		animated_sprite_2d.flip_h = true
	if Input.is_action_just_pressed('right'):
		animated_sprite_2d.flip_h = false
