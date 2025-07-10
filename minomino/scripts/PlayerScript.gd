extends Node2D

# Definizione globale della classe
class_name Player

# Definizione di enum per le tipologie di mosse
enum Move {NONE, ATTACK, DEFEND, SPECIAL}

# Statistiche del personaggio
var p_name: String
var max_hp: int
var hp: int
var atk: int
var def: int
var max_theater_points: int
var cur_theater_points: int
var kit: Kit

# Attributi per i buff/debuff del personaggio
var can_take_damage: bool
var heal_while_attacking: bool
var attack_can_pierce: bool

# Definizione dei comandi del personaggio
var command_attack: String
var command_defense: String
var command_special: String

# Booleano che indica se lo sprite delle mosse è stato specchiato (se il personaggio è P2)
var flip = false

# Attributi per la gestione delle mosse nel turno
var move: Move
var last_move: Move
var move_selected_time: float

# Imposta i parametri del giocatore in base al personaggio che ha selezionato
func initialize_player(name: String, kit_name: String) -> void:
	p_name = name
	cur_theater_points = 0
	
	# Inizializza il kit selezionato dal giocatore
	kit = Kit.new()
	kit.initialize_kit(kit_name)
	
	# Per ogni personaggio imposta i parametri unici definiti in fase di game design
	match p_name:
		"Thes":
			max_hp = 50
			atk = 10
			def = 10
			max_theater_points = 3
			can_take_damage = true
			command_attack = "RIGHT"
			command_defense = "DOWN"
			command_special = "LEFT"
		"Mino": 
			max_hp = 50
			atk = 10
			def = 10
			max_theater_points = 2
			can_take_damage = true
			command_attack = "LEFT"
			command_defense = "RIGHT"
			command_special = "DOWN"
		# Altri personaggi coming soon...
	hp = max_hp

# Funzione che imposta gli HP del personaggio quando prende danno
func take_damage(damage: int) -> String:
	# Se il personaggio è protetto da un buff non prende danni
	var output = ""
	
	if not can_take_damage:
		damage = 0
		output = p_name + " takes %d damage!" % damage
	else:
		if hp > damage:
			hp -= damage
			output = p_name + " takes %d damage!" % damage
		else:
			hp = 0
			output = p_name + " is lying on the floor!"
			
	return output

# Funzione che imposta gli HP del personaggio quando si cura
func heal(recover: int) -> void:
	# Se la cura supera la vita massima, non superarla
	if recover + hp < max_hp:
		hp += recover
	else:
		hp = max_hp

# Effettua la mossa speciale del personaggio.  La mossa speciale varia in base al personaggio scelto.
# Prende come parametro il nemico e qualche sua info che può essere utile in base all'attacco,
# oltre a un booleano che indica se il giocatore ha azzeccato il tempismo o meno.
func special_move(enemy: Player, penalty: bool, dmg_reduction: int) -> String:
	var output = ""
	
	match p_name:
		
		# Mossa speciale di Teseo - Gomitolo: Guadagna un punto teatrale. Se l'avversario
		# attacca e Teseo non è difeso da Divine Curtain non guadagna un punto e dovrà ricaricare il gomitolo
		"Thes":
			var sp_fail: bool = enemy.move == Move.ATTACK
			sp_fail = sp_fail or (enemy.p_name == "Mino" and enemy.cur_theater_points == 1 and enemy.move == Move.SPECIAL)
			sp_fail = sp_fail and can_take_damage
	
			if sp_fail:
				output = "Theseus was attacked during his special move! He lost his thread!"
			elif not penalty:
				cur_theater_points += 1
				output = "Theseus rewinds the ball of yarn! He gains one bonus star!"
			else:
				output = "Time Penalty: Theseus gains no points!"
				
			
		# Mossa speciale del Minotauro - Artigli: Attacco potenziato che fa il 50% dei danni in più,
		# però deve essere caricata per un turno prima di usarla
		"Mino":
			if cur_theater_points == 0:
				if not penalty:
					cur_theater_points = 1
					output = "Minotaur recharges his special move..."
			else:
				if not penalty:
					enemy.take_damage(round(atk * 1.5) - dmg_reduction)
					output = "Minotaur attacks with his claws! Theseus takes %d damage!" % (round(atk * 1.5) - dmg_reduction)
				else:
					enemy.take_damage(atk - dmg_reduction)
					output = "Time Penalty: Minotaur attacks with his claws! Theseus takes %d damage!" % (atk - dmg_reduction)
				cur_theater_points = 0

	return output

# Metodo che rimuove i buff del player, generalmente viene richiamato a fine turno
func remove_buffs() -> void:
	can_take_damage = true
	heal_while_attacking = false
	attack_can_pierce = false
	
	reset_stats()

# Metodo che viene richiamato per riportare allo stato naturale le stats del personaggio
func reset_stats() -> void:
	match p_name:
		"Thes":
			atk = 10
			def = 10
		"Mino":
			atk = 10
			def = 10
		# Altri personaggi coming soon...

# Riporta i player a metà vita se sono sotto quel treshold di HP, richiamato tra un match e l'altro
func restore() -> void:
	if hp < round(max_hp / 2):
		hp = round(max_hp / 2)

# Assegna il tempismo e la mossa che il personaggio sta effettuando in base all'input ricevuto
func process_input(input: String) -> void:
	# Imposta il tempismo
	move_selected_time = Time.get_ticks_msec() / 1000.0
	
	# Inverte destra e sinistra se il personaggio è flippato
	if flip:
		if input == "RIGHT":
			input = "LEFT"
		elif input == "LEFT":
			input = "RIGHT"
	
	# Compara l'input con i comandi del personaggio per scegliere la mossa da fare
	match input:
		command_attack: move = Move.ATTACK
		command_defense: move = Move.DEFEND
		command_special: move = Move.SPECIAL

# Restituisce una stringa contenente le statistiche del player (utile più per debugging)
func toString() -> String:
	return "Nome: %s, HP: %d, Punti teatro: %d" % [p_name, hp, cur_theater_points]
