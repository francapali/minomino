extends Node

var last_scene_path: String = ""

func go_to_settings():
	# Salva il path della scena corrente
	last_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")
