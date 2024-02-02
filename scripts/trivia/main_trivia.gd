extends Control

# =============== OY OY OY ===============
# setiap sesi ada 3 pertanyaan
# nilai minimal 60% biar dapet bonus health
# belum ada variabel health
# pertanyaan ditaro di json
# path json ->../ script/trivia/soal.json
# kalo mo nambah soal edit json-nya
# =============== OY OY OY ===============

@onready var Soal = $Soal
@onready var Submit = $Submit
@onready var health = $Health
@onready var bg = $TextureRect2

@onready var label0 = $Label_0
@onready var label1 = $Label_1
@onready var label2 = $Label_2

@onready var teacher_question = $TeacherQuestion
@onready var teacher_right = $TeacherRight
@onready var teacher_wrong = $TeacherWrong

@onready var r0 = $ButtonRight
@onready var r1 = $ButtonRight2
@onready var r2 = $ButtonRight3

@onready var w0 = $ButtonWrong
@onready var w1 = $ButtonWrong2
@onready var w2 = $ButtonWrong3

var items : Array = read_json_file("res://scripts/trivia/soal.json")
var item : Dictionary
var index_item : int = randi_range(0,items.size()-1)
var correct :float = 0
var count : int = 0
var n : int 

# refresh scene  -> biar muncul soal baru
func refresh_scene():
	teacher_right.hide()
	teacher_wrong.hide()
	teacher_question.show()
	
	r0.hide()
	r1.hide()
	r2.hide()
	
	w0.hide()
	w1.hide()
	w2.hide()
	
	show_question()
	if count == 3:
		show_result()

# sesuai nama
func show_question():
	item = items[index_item]
	Soal.text = item.Soal
	show_opsi()

# sesuai nama
func show_opsi():
	label0.text = item.Opsi[0]
	label1.text = item.Opsi[1]
	label2.text = item.Opsi[2]

# sesuai nama
func show_result():
	bg.show()
	var score = round(correct/count*100)
	var greet
	if score >= 60:
		greet = "congrat"
		health.show()
		Stats.max_health += 10
	else:
		greet = "nice try"
	Soal.text = "{greet} ! your score is {score}".format({"greet" = greet, "score" = score})

# fungsi awal , kebanyakan buat hide
func _ready():
	show_question()
	health.hide()
	teacher_question.show()
	teacher_right.hide()
	teacher_wrong.hide()
	bg.hide()
	
	r0.hide()
	r1.hide()
	r2.hide()
	
	w0.hide()
	w1.hide()
	w2.hide()

# baca json
func read_json_file(src):
	var text = FileAccess.get_file_as_string("res://scripts/trivia/soal.json")
	var json_data = JSON.parse_string(text)
	print(json_data)
	return json_data
	

# ======== LOGIC ===========

func _on_opsi_0_pressed():
	if item.Jawaban == 0:
		r0.show()
		
		correct += 1
		teacher_right.show()
	else:
		w0.show()
		teacher_wrong.show()
	count += 1

	n = index_item
	index_item = randi_range(0,items.size()-1)
	while n == index_item:
		index_item = randi_range(0,items.size()-1)
		
	await get_tree().create_timer(3).timeout
	refresh_scene()

func _on_opsi_1_pressed():
	if item.Jawaban == 1:
		r1.show()
		correct += 1
		teacher_right.show()
	else:
		w1.show()
		
		teacher_wrong.show()
	count += 1
	
	n = index_item
	index_item = randi_range(0,items.size()-1)
	while n == index_item:
		index_item = randi_range(0,items.size()-1)
		
	await get_tree().create_timer(3).timeout
	refresh_scene()


func _on_opsi_2_pressed():
	if item.Jawaban == 2:
		r2.show()
		correct += 1
		teacher_right.show()
	else:
		w2.show()
		teacher_wrong.show()
	count += 1
	
	n = index_item
	index_item = randi_range(0,items.size()-1)
	while n == index_item:
		index_item = randi_range(0,items.size()-1)
		
	await get_tree().create_timer(3).timeout
	refresh_scene()
