extends Control

@onready var volume_bar = $VBoxContainer/ProgressBar
@onready var volume_up_button = $VBoxContainer/HBoxContainer/VolumeUpButton
@onready var volume_down_button = $VBoxContainer/HBoxContainer/VolumeDownButton
@onready var return_button = $HBoxContainer/ReturnButton
@onready var main_menu_button = $HBoxContainer/MainMenuButton
@onready var quit_button = $HBoxContainer/QuitButton

var volume_step_db := 2.0
var bus_name := "Master"

func _ready():
	volume_up_button.pressed.connect(_on_volume_up)
	volume_down_button.pressed.connect(_on_volume_down)
	update_volume_bar()
	return_button.pressed.connect(_on_return_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_volume_up():
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(bus_idx)
	var new_db = clamp(current_db + volume_step_db, -80, 0)
	AudioServer.set_bus_volume_db(bus_idx, new_db)
	update_volume_bar()

func _on_volume_down():
	var bus_idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(bus_idx)
	var new_db = clamp(current_db - volume_step_db, -80, 0)
	AudioServer.set_bus_volume_db(bus_idx, new_db)
	update_volume_bar()

func update_volume_bar():
	var db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
	var percent = db_to_percent(db)
	volume_bar.value = percent

# Conversione da decibel (logaritmico) a valore lineare 0..100%
func db_to_percent(db: float) -> float:
	# db in range -80..0
	# volume lineare = 10^(db/20)
	# moltiplichiamo per 100 per percentuale
	return clamp(pow(10, db / 20) * 100, 0, 100)

# Torna alla scena precedente (quella che ha aperto i settings)
func _on_return_pressed():
	if SceneManager.last_scene_path != "":
		get_tree().change_scene_to_file(SceneManager.last_scene_path)
	else:
		print("Nessuna scena precedente salvata.")

# Va alla schermata principale (Home.tscn)
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/Home.tscn")

# Esce dal gioco
func _on_quit_pressed():
	get_tree().quit()
