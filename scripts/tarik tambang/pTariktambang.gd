extends CharacterBody2D

# =============== OY OY OY ===============
# kalo menang nambah stregth
# belum ada variabel untuk nambahin stregth
# sori kalo berantakan , ini mah riil yang penting jadi
# =============== OY OY OY ===============

@onready var win = $Win
@onready var almost = $AlmostLosing
@onready var lost = $Lost
@onready var tutor = $Tutorial
@onready var str = $Strength

var speed = 0
var current_dir = "none"
var start = false


func _ready():
	win.hide()
	lost.hide()
	almost.hide()
	tutor.show()
	str.hide()

func _physics_process(delta):
	player_movement(delta)


func player_movement(delta):
	if Input.is_action_pressed("ui_accept"):
			start = true
			tutor.hide()
	
	if start == true:
		if Input.is_action_pressed("ui_accept"):
			current_dir = "left"
			speed += 1

		else:
			current_dir = "left"
			speed -= 1
			velocity.x = speed

	move_and_slide()



func _on_area_2d_area_entered(area):
	if area.is_in_group('block'):
		win.show()
		Stats.stregth += 1
		print('menang')
		str.show()
		get_tree().paused = true
		print(Stats.stregth)


	elif area.is_in_group('lose_block'):
		lost.show()
		almost.hide()
		print('kalah') 
		get_tree().paused = true
		
	elif area.is_in_group('almost_block'):
		almost.show()



