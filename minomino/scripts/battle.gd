extends Node2D

# Definizione di enum per le tipologie di mosse
enum Move {NONE, ATTACK, DEFEND, SPECIAL}

# Istanze dei giocatori
var p1 = Player.new()
var p2 = Player.new()

# Variabili per la gestione dei turni
var processing_turn = false
var turn_start_time = 0
var cur_turn = 0

# Costanti di gioco
const PENALTY_PERCENTAGE = 0.8
const TURN_DURATION = 5
const MAX_TURN = 5
const PERFECT_WINDOW = 0.9

# Called when the node enters the scene tree for the first time.
# Inizializza i parametri dei player e fa cominciare la partita.
func _ready() -> void:
	p1.initialize_player("Teseo")
	p2.initialize_player("Minotauro")
	
	$Player1.get_child(4).position = Vector2(100, 150)
	$Player2.get_child(4).position = Vector2(500, 150)
	
	$Label.position = Vector2(100, 100)
	$Label2.position = Vector2(500, 100)
	
	start_turn()

# Chiamata all'inizio di un turno per inizializzare i valori e far partire il timer
func start_turn() -> void:
	
	cur_turn += 1;
	$Label2.text = "Preparati..."
	
	p1.move = Move.NONE
	p2.move = Move.NONE
	
	p1.move_selected_time = -1.0
	p2.move_selected_time = -1.0
	
	turn_start_time = Time.get_ticks_msec() / 1000.0
	$Timer.start(TURN_DURATION)

# Chiamata quando scade il tempo, notifica i giocatori e passa al processing delle mosse
func _on_timer_timeout() -> void:
	$Label.text = "TAURO!"
	$Label2.text = "SELEZIONA LA MOSSA ORA!"
	await get_tree().create_timer(PERFECT_WINDOW).timeout
	$Label2.text = "TEMPO SCADUTO!"
	await get_tree().create_timer(1 - PERFECT_WINDOW).timeout
	processing_turn = true
	await get_tree().create_timer(3).timeout
	$Label2.text = "Preparati..."
	process_moves()
	
	if end_condition():
		end_match()
	else:
		processing_turn = false
		start_turn();

# Funzione che gestisce e processa gli input dei giocatori durante la partita
func _unhandled_input(event) -> void:
	if not event.is_pressed() or processing_turn:
		return
		
	var now = Time.get_ticks_msec() / 1000.0
	
	if p1.move == Move.NONE:
		match event.keycode:
			KEY_Q: 
				p1.move = Move.ATTACK
				p1.move_selected_time = now
			KEY_E: 
				p1.move = Move.DEFEND
				p1.move_selected_time = now
			KEY_W: 
				p1.move = Move.SPECIAL
				p1.move_selected_time = now
		
		
	if p2.move == Move.NONE:
		match event.keycode:
			KEY_A: 
				p2.move = Move.ATTACK
				p2.move_selected_time = now
			KEY_D: 
				p2.move = Move.DEFEND
				p2.move_selected_time = now
			KEY_S: 
				p2.move = Move.SPECIAL
				p2.move_selected_time = now
		
	# Inserire qui la gestione degli item

# Chiamata alla fine del turno, effettua le mosse selezionate dai player e aggiorna le statistiche
func process_moves() -> void:
	var target_time = turn_start_time + TURN_DURATION
	
	# Calcola la distanza in secondi tra l'input dell'utente e lo scadere del timer
	var p1_offset = abs(p1.move_selected_time - target_time)
	var p2_offset = abs(p2.move_selected_time - target_time)
	
	print(p1_offset < PERFECT_WINDOW)
	print(p2_offset < PERFECT_WINDOW)
	
	var p1_dmg_reduction = 0
	var p2_dmg_reduction = 0
	
	#if p1.last_move == p1.move:
	#if p2.last_move == p2.move:
	
	# Se P1 si difende guadagna una riduzione danni in base al tempismo
	if p1.move == Move.DEFEND:
		if p1_offset <= PERFECT_WINDOW:
			p1_dmg_reduction = p1.def
		else:
			# Penalità: Riduce la riduzione danni del 20%
			p1_dmg_reduction = round(p2.def * PENALTY_PERCENTAGE)
			
	# Se P2 si difende guadagna una riduzione danni in base al tempismo
	if p2.move == Move.DEFEND:
		if p2_offset <= PERFECT_WINDOW:
			p2_dmg_reduction = p1.def
		else:
			# Penalità: Riduce la riduzione danni del 20%
			p2_dmg_reduction = round(p2.def * PENALTY_PERCENTAGE)
			
	# Attacco P1 - Toglie danni a P2 pari all'attacco di P1 meno la riduzione danni di P2
	if p1.move == Move.ATTACK:
		if p1_offset <= PERFECT_WINDOW:
			p2.hp -= (p1.atk - p2_dmg_reduction)
		else:
			# Penalità: Riduce il danno inflitto del 20%
			p2.hp -= (round(p1.atk * 0.8) - p2_dmg_reduction)
			
	# Attacco P2 - Toglie danni a P1 pari all'attacco di P2 meno la riduzione danni di P1
	if p2.move == Move.ATTACK:
		if p2_offset <= PERFECT_WINDOW:
			p1.hp -= (p2.atk - p1_dmg_reduction)
		else:
			# Penalità: Riduce il danno inflitto del 20%
			p1.hp -= (round(p2.atk * 0.8) - p1_dmg_reduction)
			
	# Per le mosse speciali i check sono fatti nel metodo stesso
	
	# Mossa speciale P1 - Sarà gestita dal metodo apposito
	if p1.move == Move.SPECIAL:
		p1.special_move(p2, p1_offset > PERFECT_WINDOW, p2_dmg_reduction)
		
	# Mossa speciale P2 - Sarà gestita dal metodo apposito
	if p2.move == Move.SPECIAL:
		p2.special_move(p1, p2_offset > PERFECT_WINDOW, p1_dmg_reduction)
	
	#print("P1 - Mossa: %d - Offset di tempo: %f" % [p1.move, p1_offset])
	#print("P2 - Mossa: %d - Offset di tempo: %f" % [p2.move, p2_offset])

# Chiamata alla fine di ogni turno, verifica se il match è terminato o meno
func end_condition() -> bool:
	# Uno dei due player è arrivato a 0 di vita
	if p1.hp <= 0 or p2.hp <= 0:
		return true
	
	# Uno dei due player ha raggiunto il numero massimo di punti teatro
	if p1.cur_theater_points >= p1.max_theater_points or p2.cur_theater_points >= p2.max_theater_points:
		return true
	
	# Sono stati superati i turni massimi del match
	if cur_turn >= MAX_TURN:
		return true
	
	return false

# Gestisce la fine del match
func end_match():
	# Vince il player con più HP
	if p1.hp > p2.hp:
		print("Vince " + p1.p_name + "!")
	elif p2.hp > p1.hp:
		print("Vince " + p2.p_name + "!")
	else:
		print("Abbiamo un pareggio!")
	
	# Mettere qui il check sul numero di match e la partenza di un nuovo match

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $Timer.is_stopped():
		$Label.text = str(int($Timer.time_left) + 1)
		$Player1.get_child(4).text = p1.toString()
		$Player2.get_child(4).text = p2.toString()
