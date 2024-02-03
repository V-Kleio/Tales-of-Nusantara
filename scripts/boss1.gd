extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var wall_detector = $WallDetector
@onready var hitbox = $hitbox/CollisionShape2D
@onready var ground_time = $GroundTime
@onready var summon_timer = $SummonTimer
@onready var death_particle = $DeathParticle
@onready var landing_sound = $LandingSound
@onready var death_sound = $DeathSound

var key = preload("res://scene/key.tscn")
var enemy1 = preload("res://scene/enemy1.tscn")
var enemy2 = preload("res://scene/enemy2.tscn")

@export var normal_speed = -500
@export var normal_jump = -2000
@export var health = 10
@export var strength = 100
var speed = normal_speed
var jump = normal_jump
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_facing_right = true
var is_attacked = false
var is_death = false

@export var enemy1_spawn_position: Vector2
@export var enemy2_spawn_position: Vector2
@export var enemy1_spawn_spread: int
@export var enemy2_spawn_spread: int

func _ready():
	summon_timer.start()

func _physics_process(delta):
	
	if is_death:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if wall_detector.is_colliding():
		flip()
	
	
	if is_attacked and !is_death:
		animated_sprite_2d.animation = 'hit'
		speed = 0
		jump = 0
		hitbox.disabled = true
	elif !is_death:
		animated_sprite_2d.animation = 'idle'
		speed = normal_speed
		jump = normal_jump
		if is_facing_right:
			speed = abs(speed)
			wall_detector.rotation_degrees = 270
		else:
			wall_detector.rotation_degrees = 90
			speed = abs(speed) * -1
	
	if !ground_time.is_stopped():
		speed = 0
		jump = 0
	
	if is_on_floor():
		velocity.y = jump
	
	velocity.x = speed

	move_and_slide()
	
	if health <= 0:
		is_death = true
		animated_sprite_2d.animation = "death"
		death_sound.play()
		die()

func flip():
	is_facing_right = !is_facing_right
	
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	if is_facing_right:
		speed = abs(speed)
		wall_detector.rotation_degrees = 270
	else:
		wall_detector.rotation_degrees = 90
		speed = abs(speed) * -1

func attacked():
	is_attacked = true
	print(health)

func die():
	hitbox.disabled = true
	death_particle.emitting = true

func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'hit':
		is_attacked = false
		hitbox.disabled = false
		


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.attacked()
		body.health -= strength

func summon():
	var enemy1_spawn_1 = enemy1.instantiate()
	var enemy1_spawn_2 = enemy1.instantiate()
	enemy1_spawn_1.position.x = 12868
	enemy1_spawn_1.position.y = 1037
	enemy1_spawn_2.position.x = 14385
	enemy1_spawn_2.position.y = 1037
	get_parent().add_child(enemy1_spawn_1)
	get_parent().add_child(enemy1_spawn_2)
	
	var enemy2_spawn_1 = enemy2.instantiate()
	var enemy2_spawn_2 = enemy2.instantiate()
	enemy2_spawn_1.position.x = 13970
	enemy2_spawn_1.position.y = 236
	enemy2_spawn_2.position.x = 13449
	enemy2_spawn_2.position.y = 236
	get_parent().add_child(enemy2_spawn_1)
	get_parent().add_child(enemy2_spawn_2)



func _on_landing_check_body_entered(body):
	landing_sound.play()
	ground_time.start()


func _on_summon_timer_timeout():
	summon()
	summon_timer.start()


func _on_death_particle_finished():
	var key_drop = key.instantiate()
	key_drop.position = position
	get_parent().add_child(key_drop)
	queue_free()
