extends Node

var player1_index = 0
var player2_index = 0
var player1_locked = false
var player2_locked = false

@onready var characters = $CharacterButtons.get_children()
@onready var frame_p1 = $FrameP1
@onready var frame_p2 = $FrameP2
@onready var p1_sprite = $P1Sprite
@onready var p2_sprite = $P2Sprite
var teseo_texture = preload("res://assets/tesstd.png")
var minotauro_texture = preload("res://assets/minostd.png")


func _ready():
	update_frames()

func _unhandled_input(event):
	if not player1_locked:
		if Input.is_action_just_pressed("ui_left_p1"):
			player1_index = (player1_index - 1 + characters.size()) % characters.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_right_p1"):
			player1_index = (player1_index + 1) % characters.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_select_p1"):
			player1_locked = true
			characters[player1_index].modulate = Color(1, 1, 1, 0.5)
	if not player2_locked:
		if Input.is_action_just_pressed("ui_left_p2"):
			player2_index = (player2_index - 1 + characters.size()) % characters.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_right_p2"):
			player2_index = (player2_index + 1) % characters.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_select_p2"):
			player2_locked = true
			characters[player2_index].modulate = Color(1, 1, 1, 0.5)

	if player1_locked and player2_locked:
		var p1_char = characters[player1_index].name
		var p2_char = characters[player2_index].name
		GameState.player1 = p1_char
		GameState.player2 = p2_char
		get_tree().change_scene_to_file("res://scenes/SelectKit.tscn")

func update_frames():
	# Frame movement
	if player1_index == 0:
		frame_p1.global_position = Vector2(383, 418)
	else:
		frame_p1.global_position = Vector2(525, 418)

	if player2_index == 0:
		frame_p2.global_position = Vector2(416, 447)
	else:
		frame_p2.global_position = Vector2(558, 447)

	# P1 sprite
	if player1_index == 0:  # Teseo
		p1_sprite.texture = teseo_texture
		p1_sprite.global_position = Vector2(210, 185)
		p1_sprite.scale = Vector2(0.345, 0.333)
		p1_sprite.flip_h = true
	else:  # Minotauro
		p1_sprite.texture = minotauro_texture
		p1_sprite.global_position = Vector2(226, 195)
		p1_sprite.scale = Vector2(0.313, 0.302)
		p1_sprite.flip_h = true

	# P2 sprite
	if player2_index == 0:  # Teseo
		p2_sprite.texture = teseo_texture
		p2_sprite.global_position = Vector2(939, 185)
		p2_sprite.scale = Vector2(0.345, 0.333)
		p2_sprite.flip_h = false
	else:  # Minotauro
		p2_sprite.texture = minotauro_texture
		p2_sprite.global_position = Vector2(928, 195)
		p2_sprite.scale = Vector2(0.313, 0.302)
		p2_sprite.flip_h = false
