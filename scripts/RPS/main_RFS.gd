extends Control

# =============== OY OY OY ===============
# sesi selesai waktu poin menang + kalah == 3
# kalo draw mereka bakalan main terus sampe poin 1 terpenuhi
# kalo player menang crit chance naik
# belum ada variabel crit chance
# gerakan bot random
# kebanyakan fungsi cuma buat animasi
# =============== OY OY OY ===============

@onready var pinky = $pinky_button
@onready var index = $index_button
@onready var thumb = $thumb_button
@onready var back_button = $BackButton

@onready var pinky_hover = $"pinky_button/Pinky-hover"
@onready var index_hover = $"index_button/Index-hover"
@onready var thumb_hover = $"thumb_button/Thumb-hover"

@onready var won = $Won
@onready var lost = $Lost
@onready var seri = $Seri

@onready var luke_idle = $"Luke-default"
@onready var luke_index = $"Luke-index"
@onready var luke_pinky = $"Luke-pinky"
@onready var luke_thumb = $"Luke-thumb"

@onready var nisa_idle = $"Nisa-default"
@onready var nisa_index = $"Nisa-index"
@onready var nisa_pinky = $"Nisa-pinky"
@onready var nisa_thumb = $"Nisa-thumb"

@onready var critChance = $Critchance

var player_move = 4
var bot_move : int = 4
var win_count :int = 0
var lose_count : int = 0


func hide_button():
	pinky.hide()
	thumb.hide()
	index.hide()
	
	
func show_button():
	pinky.show()
	thumb.show()
	index.show()
	
	
func refresh():

	luke_idle.show()
	luke_pinky.hide()
	luke_thumb.hide()
	luke_index.hide()
	
	nisa_idle.show()
	nisa_pinky.hide()
	nisa_thumb.hide()
	nisa_index.hide()
	
	won.hide()
	lost.hide()
	seri.hide()
	
	if win_count + lose_count == 3:
		end_scene()

# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.hide()
	luke_idle.show()
	luke_pinky.hide()
	luke_thumb.hide()
	luke_index.hide()
	
	nisa_idle.show()
	nisa_pinky.hide()
	nisa_thumb.hide()
	nisa_index.hide()
	
	critChance.hide()
	won.hide()
	lost.hide()
	seri.hide()
	
	pinky_hover.hide()
	thumb_hover.hide()
	index_hover.hide()
	
	bot_move = randi_range(0,2)
	
	
func win_con():
	if player_move == bot_move:
		seri.show()
	elif player_move == 2 and bot_move == 0:
		lost.show()
		lose_count += 1
	elif player_move == 0 and bot_move == 2:
		won.show()
		win_count += 1
	elif player_move > bot_move:
		won.show()
		win_count += 1
	else:
		lost.show()
		lose_count += 1
	print(win_count)

func ai_anim(val):
	if val == 0:
		nisa_idle.hide()
		nisa_pinky.show()
		
	elif val == 1:
		nisa_idle.hide()
		nisa_index.show()
		
	elif val == 2:
		nisa_idle.hide()
		nisa_thumb.show()
		
func end_scene():
	back_button.show()
	pinky.disabled = true
	index.disabled = true
	thumb.disabled = true
	if win_count >= 2:
		critChance.show()
		Stats.crit_chance += 10
	else :
		lost.show()

func _on_pinky_button_pressed():
	hide_button()
	await get_tree().create_timer(2.0).timeout
	refresh()
	player_move = 0
	ai_anim(bot_move)
	win_con()
	
	luke_idle.hide()
	luke_pinky.show()
	await get_tree().create_timer(2.0).timeout
	show_button()
	refresh()
	bot_move = randi_range(0,2)
	
func _on_index_button_pressed():
	hide_button()
	await get_tree().create_timer(2.0).timeout
	refresh()
	player_move = 1
	ai_anim(bot_move)
	win_con()
	
	luke_idle.hide()
	luke_index.show()
	
	await get_tree().create_timer(2.0).timeout
	show_button()
	refresh()
	
	bot_move = randi_range(0,2)
	
	
func _on_thumb_button_pressed():
	hide_button()
	await get_tree().create_timer(2.0).timeout
	refresh()
	player_move = 2
	ai_anim(bot_move)
	win_con()
	
	luke_idle.hide()
	luke_thumb.show()
	
	await get_tree().create_timer(2.0).timeout
	show_button()
	refresh()
	
	bot_move = randi_range(0,2)
	


func _on_index_button_mouse_entered():
	index_hover.show()
	

func _on_index_button_mouse_exited():
	index_hover.hide()

func _on_pinky_button_mouse_entered():
	pinky_hover.show()

func _on_pinky_button_mouse_exited():
	pinky_hover.hide()

func _on_thumb_button_mouse_entered():
	thumb_hover.show()

func _on_thumb_button_mouse_exited():
	thumb_hover.hide()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scene/IRL/Hall2.tscn")
