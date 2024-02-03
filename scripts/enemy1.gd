extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var hurtbox = $Hurtbox
@onready var wall_check = $WallCheck
@onready var spawn_particle = $SpawnParticle
@onready var death_particle = $DeathParticle
@onready var death_sound = $DeathSound

var health_item = preload("res://scene/health_collectible.tscn")
var health_drop_chance = 20

@export var health: int = 75
@export var strength: int = 20
@export var normal_speed = -100

var speed = normal_speed
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_facing_right = true
var is_attacked = false
var is_death = false
var is_event = false

func _ready():
	is_event = true
	animated_sprite_2d.visible = false
	spawn_particle.emitting = true


func _physics_process(delta):
	if is_event:
		hurtbox.disabled = true
		hitbox.disabled = true
		return
	
	if is_death:
		die()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !ray_cast_2d.is_colliding() and is_on_floor():
		flip()
	
	if wall_check.is_colliding():
		flip()
	
	velocity.x = speed
	
	move_and_slide()
	
	
	if is_attacked and !is_death:
		animated_sprite_2d.animation = 'hit'
		speed = 0
		hitbox.disabled = true
	elif !is_death:
		animated_sprite_2d.animation = 'walk'
		speed = normal_speed
		if is_facing_right:
			speed = abs(speed)
			ray_cast_2d.position.x = 35
			wall_check.rotation_degrees = 270
		else:
			speed = abs(speed) * -1
			ray_cast_2d.position.x = -35
			wall_check.rotation_degrees = 90
	
	if health <= 0:
		death_particle.emitting = true
		death_sound.play()
		is_death = true


func flip():
	is_facing_right = !is_facing_right
	
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	if is_facing_right:
		speed = abs(speed)
		ray_cast_2d.position.x = 35
		wall_check.rotation_degrees = 270
	else:
		speed = abs(speed) * -1
		ray_cast_2d.position.x = -35
		wall_check.rotation_degrees = 90

func attacked():
	is_attacked = true

func die():
	hitbox.disabled = true
	
	
func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'hit':
		is_attacked = false
		hitbox.disabled = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.attacked()
		body.health -= strength


func _on_spawn_particle_finished():
	is_event = false
	animated_sprite_2d.visible = true
	hurtbox.disabled = false
	hitbox.disabled = false


func _on_death_particle_finished():
	if randi_range(1, 100) <= health_drop_chance:
		var health_drop = health_item.instantiate()
		health_drop.position = position
		get_parent().add_child(health_drop)
	queue_free()
