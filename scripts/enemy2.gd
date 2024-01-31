extends CharacterBody2D

@onready var player_tracker = $PlayerTrackerPivot/PlayerTracker
@onready var player_tracker_pivot = $PlayerTrackerPivot
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var speed = 300
@export var strength = 25
@export var health = 100

var player = null
var player_position: Vector2
var is_attacked = false
var is_death = false

func _ready():
	player = get_tree().get_first_node_in_group('player')

func _physics_process(delta):
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
		is_death = true
		die()

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
			chase()

func chase():
	player_position = (player.position - position).normalized()
	velocity = Vector2(player_position * speed)
	move_and_slide()

func attacked():
	is_attacked = true

func die():
	hitbox.disabled = true
	animated_sprite_2d.animation = 'die'


func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'hit':
		is_attacked = false
		hitbox.disabled = false
	if animated_sprite_2d.animation == 'die':
		queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.attacked()
		body.health -= strength
