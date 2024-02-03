class_name Player
extends CharacterBody2D

signal healthChanged

@onready var all_interaction = []
var can_interact = false

@onready var jump_buffer_timer = $JumpBufferTimer
@onready var coyote_timer = $CoyoteTimer
@onready var double_jump_particles = $DoubleJumpParticle
@onready var critical_particle = $CriticalParticle
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var slash_shape = $SideAttack/SideAttackHitbox
@onready var iframe = $Iframe
@onready var death_particle = $DeathParticle

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
var count_key = 6

var cur_health = 100

func _ready():
	GameManager.player = self
	$interactLabel.visible = false

func _physics_process(delta):
	# Handle jump.
	if is_death:
		return
	
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
		
	
	if is_attacked:
		healthChanged.emit()
		cur_health = health
	if health > cur_health:
		healthChanged.emit()


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
		death()

func _unhandled_input(_event: InputEvent) -> void:
	if can_interact:
		if Input.is_action_just_pressed("interact"):
			execute_interaction()
	if Input.is_action_just_pressed('side_attack'):
		attack()

func _process(delta):
	if GameManager.room_open:
		var lockedRoom = get_node_or_null("../Locked_Room_1")

		if is_instance_valid(lockedRoom):
			lockedRoom.queue_free()
		else:
			return
	if GameManager.boss_room:
		var bossGate = get_node_or_null("../Boss_Door")
		if is_instance_valid(bossGate):
			bossGate.queue_free()
		else:
			return
	
	var gate_3 = get_node_or_null("../key3")
	if gate_3 == null:
		var GIM_Gate = get_node_or_null("../GIM Gate")
		if is_instance_valid(GIM_Gate):
			GIM_Gate.queue_free()
		else:
			return

func attack():
	is_attacking = true

func attacked():
	is_attacked = true
	is_iframe = true
	iframe.start()

func death():
	is_death = false
	is_attacked = false
	GameManager.respawn_player()
	health = 100
	healthChanged.emit()

func death_by_spikes():
	is_death = false
	is_attacked = false
	GameManager.respawn_player()
	health -= 0.4 * max_health
	healthChanged.emit()

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


func _on_side_attack_body_entered(body):
	if body.is_in_group("enemy"):
		body.attacked()
		if randi_range(1, 100) <= crit_chance:
			body.health = body.health - (strength * 2)
			critical_particle.emitting = true
		else:
			body.health -= strength



### Interaction Method
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
			"print" : print("hello")
			"locked_room" : DialogueManager.show_dialogue_balloon(load("res://dialogue/sign 1.dialogue"), "menyala")
			"sign" : 
				if count_key >= 7:
					DialogueManager.show_dialogue_balloon(load("res://dialogue/paduka.dialogue"), "paduka")
				else:
					DialogueManager.show_dialogue_balloon(load("res://dialogue/boss door.dialogue"), "boss")
