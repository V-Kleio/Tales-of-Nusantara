extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var hitbox = $Hitbox/CollisionShape2D
@onready var hurtbox = $Hurtbox
@onready var wall_check = $WallCheck

var health_item = preload("res://scene/health_collectible.tscn")
var health_drop_chance = 20

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
			ray_cast_2d.position.x = 80
			wall_check.rotation_degrees = 270
			hitbox.position.x = 60
			hurtbox.position.x = -5
		else:
			speed = abs(speed) * -1
			ray_cast_2d.position.x = -70
			wall_check.rotation_degrees = 90
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
		wall_check.rotation_degrees = 270
		hitbox.position.x = 60
		hurtbox.position.x = -5
	else:
		speed = abs(speed) * -1
		ray_cast_2d.position.x = -70
		wall_check.rotation_degrees = 90
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
		if randi_range(1, 100) <= health_drop_chance:
			var health_drop = health_item.instantiate()
			health_drop.position = position
			get_parent().add_child(health_drop)
		queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.attacked()
		body.health -= strength
