extends CharacterBody2D

@onready var player_tracker = $PlayerTrackerPivot/PlayerTracker
@onready var player_tracker_pivot = $PlayerTrackerPivot
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detect_particle = $DetectParticle
@onready var spawn_particle = $SpawnParticle
@onready var death_particle = $DeathParticle
@onready var hurtbox = $Hurtbox

var health_item = preload("res://scene/health_collectible.tscn")
var health_drop_chance = 20

@export var speed = 300
@export var strength = 25
@export var health = 125

var player = null
var player_position: Vector2
var is_attacked = false
var is_death = false
var is_event = false

func _ready():
	player = get_tree().get_first_node_in_group('player')
	is_event = true
	animated_sprite_2d.visible = false
	spawn_particle.emitting = true
	

func _physics_process(_delta):
	if is_event:
		hitbox.disabled = true
		hurtbox.disabled = true
		return
	
	if is_death:
		die()
		return
	
	track_player()
	vision()
	
	if is_attacked and !is_death:
		animated_sprite_2d.animation = 'hit'
		speed = 0
		hitbox.disabled = true
	elif !is_death:
		animated_sprite_2d.animation = 'fly'
		speed = 300
	
	if health <= 0:
		death_particle.emitting = true
		is_death = true

func track_player():
	if player == null:
		return
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y - 8) - player_tracker.position
	
	player_tracker_pivot.look_at(direction_to_player)

func vision():
	if player_tracker.is_colliding():
		if player_tracker.get_collider() != player:
			return
		else:
			detect_particle.emitting = true
			chase()

func chase():
	player_position = (player.position - position).normalized()
	velocity = Vector2(player_position * speed)
	move_and_slide()

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
	animated_sprite_2d.visible = true
	is_event = false
	hitbox.disabled = false
	hurtbox.disabled = false


func _on_death_particle_finished():
	if randi_range(1, 100) <= health_drop_chance:
		var health_drop = health_item.instantiate()
		health_drop.position = position
		get_parent().add_child(health_drop)
	queue_free()
