extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var hurtbox = $Hurtbox

@export var health: int = 20
@export var strength: int = 50
@export var normal_speed = -100

var speed = normal_speed
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_facing_right = false
var is_attacked = false
var is_death = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if !ray_cast_2d.is_colliding() and is_on_floor():
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
			ray_cast_2d.position.x = 80
			hitbox.position.x = 60
			hurtbox.position.x = -5
		else:
			speed = abs(speed) * -1
			ray_cast_2d.position.x = -70
			hurtbox.position.x = 15
			hitbox.position.x = -52
	
	if health <= 0:
		is_death = true
		die()


func flip():
	is_facing_right = !is_facing_right
	
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	if is_facing_right:
		speed = abs(speed)
		ray_cast_2d.position.x = 80
		hitbox.position.x = 60
		hurtbox.position.x = -5
	else:
		speed = abs(speed) * -1
		ray_cast_2d.position.x = -70
		hurtbox.position.x = 15
		hitbox.position.x = -52

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
