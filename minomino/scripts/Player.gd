extends Node

# Definizione globale della classe
class_name Player

# Definizione di enum per le tipologie di mosse
enum Move {NONE, ATTACK, DEFEND, SPECIAL}

# Statistiche del personaggio
var p_name: String
var hp: int
var atk: int
var def: int
var max_theater_points: int
var cur_theater_points: int

# Attributi per la gestione delle mosse nel turno
var move: Move
var move_selected_time: float

# Imposta i parametri del giocatore in base al personaggio che ha selezionato
func initialize_player(name: String) -> void:
	p_name = name
	cur_theater_points = 0
	
	# Per ogni personaggio imposta i parametri unici definiti in fase di game design
	match p_name:
		"Teseo": 
			hp = 50
			max_theater_points = 3
		"Minotauro": 
			hp = 50
			max_theater_points = 2
		# Altri personaggi coming soon...
