extends Node2D

var player1_index = 0
var player2_index = 0
var player1_locked = false
var player2_locked = false

# Sicurezza: accediamo ai nodi con get_node e gestiamo errori
@onready var rage_button = $RageButton
@onready var safety_button = $SafetyButton
@onready var frame_p1 = $FrameP1
@onready var frame_p2 = $FrameP2
@onready var kits = [safety_button, rage_button]
@onready var settings_button = $SettingsButton

func _ready():
	# Anti-freeze: se il gioco era in pausa, sbloccala
	get_tree().paused = false
	update_frames()
	settings_button.pressed.connect(_on_settings_pressed)
	$AudioStreamPlayer2D.play(40.0)

func _unhandled_input(_event):
	# Player 1 input
	if not player1_locked:
		if Input.is_action_just_pressed("ui_left_p1"):
			player1_index = (player1_index - 1 + kits.size()) % kits.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_right_p1"):
			player1_index = (player1_index + 1) % kits.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_select_p1"):
			player1_locked = true


	# Player 2 input
	if not player2_locked:
		if Input.is_action_just_pressed("ui_left_p2"):
			player2_index = (player2_index - 1 + kits.size()) % kits.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_right_p2"):
			player2_index = (player2_index + 1) % kits.size()
			update_frames()
		elif Input.is_action_just_pressed("ui_select_p2"):
			player2_locked = true

	# Cambio scena se entrambi bloccati
	if player1_locked and player2_locked:
		var p1_char = kits[player1_index].name
		var p2_char = kits[player2_index].name
		GameState.kitplayer1 = p1_char
		GameState.kitplayer2 = p2_char

		var next_scene = preload("res://scenes/Battle.tscn")
		get_tree().change_scene_to_packed(next_scene)

func update_frames():
	frame_p1.global_position = Vector2(28, 241) if player1_index == 0 else Vector2(942,241)
	frame_p2.global_position = Vector2(56, 288) if player2_index == 0 else Vector2(970, 289)

func _on_settings_pressed():
	SceneManager.go_to_settings()
