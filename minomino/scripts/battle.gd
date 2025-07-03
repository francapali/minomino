extends Node2D

# Definizione di enum per le tipologie di mosse
enum Move {NONE, ATTACK, DEFEND, SPECIAL}

# Istanze dei giocatori
var p1 = Player.new();
var p2 = Player.new();

# Variabili per la gestione dei turni
var processing_turn = false;
var turn_start_time = 0;
var cur_turn = 0;

const TURN_DURATION = 5;
const PERFECT_WINDOW = 0.5;

# Called when the node enters the scene tree for the first time.
# Inizializza i parametri dei player e fa cominciare la partita.
func _ready() -> void:
	p1.initialize_player("Teseo")
	p2.initialize_player("Minotauro")
	
	$Label.position = Vector2(100, 100)
	$Label2.position = Vector2(300, 100)
	
	$Background.position = Vector2(400, 400)
	
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
	$Timer.stop()
	$Label.text = "TAURO!"
	$Label2.text = "SELEZIONA LA MOSSA ORA!"
	await get_tree().create_timer(PERFECT_WINDOW).timeout
	$Label2.text = "TEMPO SCADUTO!"
	await get_tree().create_timer(1 - PERFECT_WINDOW).timeout
	processing_turn = true
	await get_tree().create_timer(3).timeout
	$Label2.text = "Preparati..."
	process_moves()
	processing_turn = false
	$Timer.start()

# Funzione che gestisce e processa gli input dei giocatori durante la partita
func _unhandled_input(event) -> void:
	if not event.is_pressed() or processing_turn:
		return
		
	var now = Time.get_ticks_msec() / 1000.0
	
	if p1.move == Move.NONE:
		match event.keycode:
			KEY_D: 
				p1.move = Move.ATTACK
				p1.move_selected_time = now
			KEY_S: 
				p1.move = Move.DEFEND
				p1.move_selected_time = now
			KEY_A: 
				p1.move = Move.SPECIAL
				p1.move_selected_time = now
		
		
	if p2.move == Move.NONE:
		match event.keycode:
			KEY_LEFT: 
				p2.move = Move.ATTACK
				p2.move_selected_time = now
			KEY_DOWN: 
				p2.move = Move.DEFEND
				p2.move_selected_time = now
			KEY_RIGHT: 
				p2.move = Move.SPECIAL
				p2.move_selected_time = now
		
	# Inserire qui la gestione degli item

# Chiamata alla fine del turno, effettua le mosse selezionate dai player e aggiorna le statistiche
func process_moves() -> void:
	var target_time = turn_start_time + TURN_DURATION

	var p1_offset = abs(p1.move_selected_time - target_time)
	var p2_offset = abs(p2.move_selected_time - target_time)
	
	print("P1 - Mossa: %d - Offset di tempo: %f" % [p1.move, p1_offset])
	print("P2 - Mossa: %d - Offset di tempo: %f" % [p2.move, p2_offset])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $Timer.is_stopped():
		$Label.text = str(int($Timer.time_left) + 1)
