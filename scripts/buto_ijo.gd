extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var hitbox = $Area2D/Hitbox
@onready var down_time_timer = $DownTimeTimer
@onready var player_detector = $PlayerDetector
@onready var hurtbox = $Hurtbox
@onready var attack = $Attack
@onready var death_particle = $DeathParticle
@onready var attack_sound = $AttackSound
@onready var death_sound = $DeathSound


var max_speed = 100
var speed = max_speed
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var health = 2000
@export var strength = 75

var player = null
var is_attacking = false
var is_death = false

func _ready():
	player = get_tree().get_first_node_in_group('player')

func _physics_process(delta):
	
	if is_death:
		die()
		return
	
	if !is_attacking:
		locate_player()
		
	if not is_on_floor():
		velocity.y += gravity * delta

	
	velocity.x = speed
	move_and_slide()
	
	if health <= 0:
		death_sound.play()
		death_particle.emitting = true
		is_death = true


func locate_player():
	if player == null:
		return
	if player.position.x > position.x:
		player_detector.rotation_degrees = 270
		hurtbox.position.x = -29
		if player.position.x - position.x < 175:
			speed = 0
			animated_sprite_2d.animation = "idle"
		else:
			animated_sprite_2d.animation = "walk"
			speed = max_speed
			speed = abs(speed)
			animated_sprite_2d.flip_h = true
			hitbox.position.x = 120
	elif player.position.x < position.x:
		player_detector.rotation_degrees = 90
		hurtbox.position.x = 29
		if position.x - player.position.x < 175:
			speed = 0
			animated_sprite_2d.animation = 'idle'
		else:
			animated_sprite_2d.animation = 'walk'
			speed = max_speed
			speed = abs(speed) * -1
			animated_sprite_2d.flip_h = false
			hitbox.position.x = -120


func attacked():
	pass
	
func die():
	hitbox.disabled = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		hitbox.disabled = true
		attack_timer.start()
		is_attacking = true
		attack.emitting = true
		animated_sprite_2d.animation = 'attack_cue'
		speed = 0



func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'attack':
		hitbox.disabled = true
		down_time_timer.start()
		attack_sound.play()
		animated_sprite_2d.animation = 'downtime'


func _on_attack_timer_timeout():
	animated_sprite_2d.animation = 'attack'
	if player_detector.get_collider() == player:
		hitbox.disabled = false
		player.attacked()
		player.health -= strength


func _on_down_time_timer_timeout():
	hitbox.disabled = false
	is_attacking = false
	speed = max_speed


func _on_death_particle_finished():
	queue_free()
