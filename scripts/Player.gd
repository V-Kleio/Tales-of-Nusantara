extends CharacterBody2D


@onready var jump_buffer_timer = $JumpBufferTimer
@onready var coyote_timer = $CoyoteTimer
@onready var double_jump_particles = $GPUParticles2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var slash_shape = $SideAttack/SideAttackHitbox
@onready var iframe = $Iframe

var MAX_SPEED: int = 600 # The max speed of the character
var FRICTION: int = 25 # The normal step for the speed to reach 0
var ACCELERATION = 50 # The normal step to reach the speed
var JUMP_VELOCITY: int = -1800 # The height of the jump
var GRAVITY: int = 5000 # The acceleration of gravity

@export var max_health: int = 100
@export var health: int = 100
@export var strength: int = 10
@export var crit_chance: int = 100

var double_jump: int = 1 # Count the number of jump when the player jump
var touch_ground: bool = true

var is_attacking = false
var side_attack_distance = 70

var is_attacked = false
var is_death = false
var is_iframe = false

var has_all_key = false
var count_key = 0

func _physics_process(delta):
	# Handle jump.
	if is_death:
		return
	
	if Input.is_action_just_pressed('side_attack'):
		attack()
	
	if is_attacking:
		slash_shape.disabled = false
	else:
		slash_shape.disabled = true
	
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
			double_jump_particles.emitting = true
			double_jump -= 1


	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	
	if is_iframe:
		$".".collision_layer = 4
	else:
		$".".collision_layer = 2
	
	if iframe.is_stopped():
		is_iframe = false
	
	set_animation()
	set_facing()
	move_and_slide()
	
	if health <= 0:
		is_death = true
		if is_death:
			animated_sprite_2d.animation = 'death'

func attack():
	is_attacking = true

func attacked():
	is_attacked = true
	is_iframe = true
	iframe.start()

func death():
	is_death = false
	is_attacked = false
	$".".position.x = 89
	$".".position.y = 368
	health = 100

func jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_buffer_timer.stop()
	coyote_timer.stop()

func apply_gravity(delta) -> void:
	velocity.y += GRAVITY * delta

func set_animation() -> void:
	if !is_death:
		if is_attacking:
			animated_sprite_2d.animation = 'side_attack'
		elif is_attacked:
			animated_sprite_2d.animation = 'hit'
		else:
			if velocity.x != 0:
				animated_sprite_2d.animation = 'run'
			else:
				animated_sprite_2d.animation = 'idle'
			if velocity.y != 0:
				animated_sprite_2d.animation = 'jump'
	
func set_facing() -> void:
	if Input.is_action_just_pressed('left'):
		animated_sprite_2d.flip_h = true
		slash_shape.position.x = -side_attack_distance
	if Input.is_action_just_pressed('right'):
		animated_sprite_2d.flip_h = false
		slash_shape.position.x = side_attack_distance


func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'side_attack':
		is_attacking = false
	elif animated_sprite_2d.animation == 'hit':
		is_attacked = false
	elif animated_sprite_2d.animation == 'death':
		death()


func _on_side_attack_body_entered(body):
	if body.is_in_group("enemy"):
		body.attacked()
		if randi_range(1, 100) <= crit_chance:
			body.health = body.health - (strength * 2)
		else:
			body.health -= strength
