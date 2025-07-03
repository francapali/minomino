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
var last_move: Move
var move_selected_time: float

# Booleano che indica se la mossa speciale può essere eseguita
var can_make_special_move: bool

# Imposta i parametri del giocatore in base al personaggio che ha selezionato
func initialize_player(name: String) -> void:
	p_name = name
	cur_theater_points = 0
	
	# Per ogni personaggio imposta i parametri unici definiti in fase di game design
	match p_name:
		"Teseo": 
			hp = 50
			atk = 10
			def = 10
			max_theater_points = 3
			can_make_special_move = true
		"Minotauro": 
			hp = 50
			atk = 10
			def = 10
			max_theater_points = 2
			can_make_special_move = false
		# Altri personaggi coming soon...

# Effettua la mossa speciale del personaggio.  La mossa speciale varia in base al personaggio scelto.
# Prende come parametro il nemico e qualche sua info che può essere utile in base all'attacco,
# oltre a un booleano che indica se il giocatore ha azzeccato il tempismo o meno.
func special_move(enemy: Player, penalty: bool, dmg_reduction: int) -> void:
	match p_name:
		
		# Mossa speciale di Teseo - Gomitolo: Guadagna un punto teatrale. Se l'avversario
		# attacca, però, non guadagna un punto e dovrà ricaricare il gomitolo
		"Teseo":
			if enemy.last_move == Move.ATTACK:
				can_make_special_move = false
			elif not penalty:
				if can_make_special_move == false:
					can_make_special_move = true
				else:
					cur_theater_points += 1
				
			
		# Mossa speciale del Minotauro - Artigli: Attacco potenziato che fa il 50% dei danni in più,
		# però deve essere caricata per un turno prima di usarla
		"Minotauro":
			if can_make_special_move == false:
				if not penalty:
					can_make_special_move = true
			else:
				if not penalty:
					enemy.hp -= (round(atk * 1.5) - dmg_reduction)
				else:
					enemy.hp -= (atk - dmg_reduction)
				can_make_special_move = false

func toString() -> String:
	return "Nome: %s, HP: %d, Punti teatro: %d" % [p_name, hp, cur_theater_points]
