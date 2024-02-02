extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var hitbox = $Area2D/Hitbox


var max_speed = 100
var speed = max_speed
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var strength = 75

var player = null
var is_attacking = false

func _ready():
	player = get_tree().get_first_node_in_group('player')

func _physics_process(delta):
	# Add the gravity.
	
	if !is_attacking:
		animated_sprite_2d.animation = 'walk'
		
	if not is_on_floor():
		velocity.y += gravity * delta

	locate_player()
	velocity.x = speed
	move_and_slide()


func locate_player():
	if player.position.x > position.x:
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
		if position.x - player.position.x < 175:
			speed = 0
			animated_sprite_2d.animation = 'idle'
		else:
			animated_sprite_2d.animation = 'walk'
			speed = max_speed
			speed = abs(speed) * -1
			animated_sprite_2d.flip_h = false
			hitbox.position.x = -120

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		attack_timer.start()
		is_attacking = true
		speed = 0



func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'attack':
		is_attacking = false
		speed = max_speed


func _on_attack_timer_timeout():
	animated_sprite_2d.animation = 'attack'
	player.attacked()
	player.health -= strength
