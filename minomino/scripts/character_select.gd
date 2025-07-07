extends Control

func _ready():
	# Collega ogni bottone
	$HBoxContainer/VBoxContainer/Button.connect("pressed", Callable(self, "_on_p1_teseo_pressed"))
	$HBoxContainer/VBoxContainer/Button2.connect("pressed", Callable(self, "_on_p1_minotauro_pressed"))
	$HBoxContainer/VBoxContainer2/Button.connect("pressed", Callable(self, "_on_p2_teseo_pressed"))
	$HBoxContainer/VBoxContainer2/Button2.connect("pressed", Callable(self, "_on_p2_minotauro_pressed"))
	$Button.connect("pressed", Callable(self, "_on_avvia_pressed"))

func _on_p1_teseo_pressed():
	GameState.player1 = "Teseo"
	print("Giocatore 1 ha scelto Teseo")

func _on_p1_minotauro_pressed():
	GameState.player1 = "Minotauro"
	print("Giocatore 1 ha scelto Minotauro")

func _on_p2_teseo_pressed():
	GameState.player2 = "Teseo"
	print("Giocatore 2 ha scelto Teseo")

func _on_p2_minotauro_pressed():
	GameState.player2 = "Minotauro"
	print("Giocatore 2 ha scelto Minotauro")

#func _on_avvia_pressed():
	#if GameState.player1 == "" or GameState.player2 == "":
		#print("Entrambi devono scegliere un personaggio!")
		#return
	#get_tree().change_scene("res://scenes/Battle.tscn")
 #

func _on_avvia_pressed():
	if GameState.player1 == "" or GameState.player2 == "":
		print("Entrambi devono scegliere un personaggio!")
		return
	print("Partiamo con: ", GameState.player1, " vs ", GameState.player2)
	get_tree().change_scene("res://scenes/Battle.tscn")
