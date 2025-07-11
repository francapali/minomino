extends Control

func _ready():
	# Riferimento ai pulsanti
	$VBoxContainer/ButtonPlay.connect("pressed", Callable(self, "_on_gioca_pressed"))
	$VBoxContainer/ButtonSettings.connect("pressed", Callable(self, "_on_opzioni_pressed"))
	$VBoxContainer/ButtonEsc.connect("pressed", Callable(self, "_on_esci_pressed"))

func _on_gioca_pressed():
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")

func _on_opzioni_pressed():
	SceneManager.go_to_settings()

func _on_esci_pressed():
	get_tree().quit()
