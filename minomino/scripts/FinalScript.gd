extends Control

@onready var winner_name = $Winner
@onready var winner_sprite = $WinnerSprite
@onready var hero_button = $HeroButton
@onready var main_menu_button = $MainMenuButton
@onready var quit_button = $QuitButton

var minowins_texture = preload("res://assets/minovince.png")
var theswins_texture = preload("res://assets/tesvince.png")
var twomino_texture = preload("res://assets/twomino.png")
var twothes_texture = preload("res://assets/twothes.png")
var winners_texture = preload("res://assets/winners.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_frame()
	hero_button.pressed.connect(_on_hero_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	

func update_frame():
	if GameState.winner_number == 1:
		GameState.player1 == winner_name
		if winner_name.text == "Thes":
			winner_name.text = "Theseus WINS!"
			winner_sprite.texture = theswins_texture
			winner_sprite.global_position = Vector2(580, 425)
			winner_sprite.scale = Vector2(0.549, 0.541)
			
		elif winner_name.name == "Mino":
			winner_name.text = "Minotaur WINS!"
			winner_sprite.texture = minowins_texture
			winner_sprite.global_position = Vector2(565, 421)
			winner_sprite.scale = Vector2(0.337, 0.334)
		
	elif GameState.winner_number == 2:
		GameState.player1 == winner_name
		if winner_name.text == "Thes":
			winner_name.text = "Theseus WINS!"
			winner_sprite.texture = theswins_texture
			winner_sprite.global_position = Vector2(580, 425)
			winner_sprite.scale = Vector2(0.549, 0.541)
					
		elif winner_name.name == "Mino":
			winner_name.text = "Minotaur WINS!"
			winner_sprite.texture = minowins_texture
			winner_sprite.global_position = Vector2(565, 421)
			winner_sprite.scale = Vector2(0.337, 0.334)
		
	elif GameState.winner_number == 0:
		if GameState.player1 == "Mino" && GameState.player2 == "Mino":
			winner_sprite.texture = twomino_texture
			winner_sprite.global_position = Vector2(565, 421)
			winner_sprite.scale = Vector2(0.337, 0.334)
		elif GameState.player1 == "Thes" && GameState.player2 == "Thes":
			winner_sprite.texture = twothes_texture
			winner_sprite.global_position = Vector2(565, 421)
			winner_sprite.scale = Vector2(0.337, 0.334)
		elif GameState.player1 != GameState.player2:
			winner_sprite.texture = winners_texture
			winner_sprite.global_position = Vector2(565, 421)
			winner_sprite.scale = Vector2(0.337, 0.334)
		winner_name.text = "TIE!"


func _on_hero_pressed():
	if SceneManager.last_scene_path != "":
		get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")
	else:
		print("Nessuna scena precedente salvata.")

# Va alla schermata principale (Home.tscn)
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/Home.tscn")

# Esce dal gioco
func _on_quit_pressed():
	get_tree().quit()
