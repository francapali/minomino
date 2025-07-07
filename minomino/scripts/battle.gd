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

# Variabili per il conteggio dei match vinti dai player
var p1_wins = 0
var p2_wins = 0

# Booleani per l'uso degli item
var p1_uses_item: Array[bool] = [false, false, false]
var p2_uses_item: Array[bool] = [false, false, false]

# Costanti di gioco
const PENALTY_PERCENTAGE = 0.8
const TURN_DURATION = 5
const MAX_TURN = 5
const PERFECT_WINDOW = 0.9
const HEAL_WHILE_ATTACKING = 3

# Called when the node enters the scene tree for the first time.
# Inizializza i parametri dei player e fa cominciare la partita.
func _ready() -> void:
	p1.initialize_player("Teseo", "Safety")
	p2.initialize_player("Minotauro", "Rage")
	
	$Player1.get_child(4).position = Vector2(100, 150)
	$Player2.get_child(4).position = Vector2(500, 150)
	
	$Label.position = Vector2(100, 100)
	$Label2.position = Vector2(500, 100)
	
	start_turn()

# Chiamata all'inizio di un turno per inizializzare i valori e far partire il timer
func start_turn() -> void:
	cur_turn += 1;
	print("Turno %d" % cur_turn)
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
	
	if end_condition():
		end_match()
	else:
		processing_turn = false
		start_turn();

# Funzione che gestisce e processa gli input dei giocatori durante la partita
func _unhandled_input(event) -> void:
	# Controlla se l'input è rilevante per il gioco, se non lo è lo ignora
	if not event.is_pressed() or processing_turn or event is not InputEventKey:
		return
		
	var now = Time.get_ticks_msec() / 1000.0
	
	# Input P1
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
	
	# Input P2
	if p2.move == Move.NONE:
		match event.keycode:
			KEY_U:
				p2.move = Move.ATTACK
				p2.move_selected_time = now
			KEY_O: 
				p2.move = Move.DEFEND
				p2.move_selected_time = now
			KEY_I: 
				p2.move = Move.SPECIAL
				p2.move_selected_time = now
	
	# Input degli item, sia per P1 che per P2
	# Nota: Può essere usato un solo item per turno, quindi verrà preso quello che il player ha
	# scelto per ultimo. Questo spiega anche le particolari combinazioni degli array uses_item		
	match event.keycode:
		KEY_A:
			p1_uses_item = [true, false, false]
		KEY_S:
			p1_uses_item = [false, true, false]
		KEY_D:
			p1_uses_item = [false, false, true]
		KEY_J:
			p2_uses_item = [true, false, false]
		KEY_K:
			p2_uses_item = [false, true, false]
		KEY_L:
			p2_uses_item = [false, false, true]

# Chiamata alla fine del turno, effettua le mosse selezionate dai player e aggiorna le statistiche
func process_moves() -> void:
	var target_time = turn_start_time + TURN_DURATION
	
	# Calcola la distanza in secondi tra l'input dell'utente e lo scadere del timer
	var p1_offset = abs(p1.move_selected_time - target_time)
	var p2_offset = abs(p2.move_selected_time - target_time)
	
	var p1_dmg_reduction = 0
	var p2_dmg_reduction = 0
	
	# Controlla se i player stanno usando item e se sì li usa
	for i in 3:
		if p1_uses_item[i]:
			p1.kit.use_item(p1, i)
			
	for i in 3:
		if p2_uses_item[i]:
			p2.kit.use_item(p2, i)
	
	# Controllo sul giocatore che ripete la stessa mossa
	if p1.last_move == p1.move and p1.move != Move.NONE:
		p1.move = Move.NONE
		print("Teseo ripete la stessa mossa!")
		
	if p2.last_move == p2.move and p2.move != Move.NONE:
		p2.move = Move.NONE
		print("Minotauro ripete la stessa mossa!")
	
	# Controllo sul giocatore che non ha scelto una mossa
	if p1.move == Move.NONE:
		print("Teseo non fa nulla!")
		
	if p2.move == Move.NONE:
		print("Minotauro non fa nulla!")
	
	# Controlla se un player sta usando Divine Curtain e l'altro Phantom Sword (i due item si annullano a vicenda)
	if (not p1.can_take_damage and p2.attack_can_pierce):
		p1.can_take_damage = true
		p2.attack_can_pierce = false
		print("I due item si annullano!")
		
	if (not p2.can_take_damage and p1.attack_can_pierce):
		p2.can_take_damage = true
		p1.attack_can_pierce = false
		print("I due item si annullano!")
	
	# Se P1 si difende guadagna una riduzione danni in base al tempismo
	if p1.move == Move.DEFEND:
		if p1_offset <= PERFECT_WINDOW:
			p1_dmg_reduction = p1.def
			print("Teseo riduce i danni di %d HP!" % p1_dmg_reduction)
		else:
			# Penalità: Riduce la riduzione danni del 20%
			p1_dmg_reduction = round(p2.def * PENALTY_PERCENTAGE)
			print("Penalità: Teseo riduce i danni di %d HP!" % p1_dmg_reduction)
			
	# Se P2 si difende guadagna una riduzione danni in base al tempismo
	if p2.move == Move.DEFEND:
		if p2_offset <= PERFECT_WINDOW:
			p2_dmg_reduction = p1.def
			print("Minotauro riduce i danni di %d HP!" % p1_dmg_reduction)
		else:
			# Penalità: Riduce la riduzione danni del 20%
			p2_dmg_reduction = round(p2.def * PENALTY_PERCENTAGE)
			print("Penalità: Minotauro riduce i danni di %d HP!" % p1_dmg_reduction)
			
	# Attacco P1 - Toglie danni a P2 pari all'attacco di P1 meno la riduzione danni di P2
	if p1.move == Move.ATTACK:
		# Se P1 sta usando la phantom blade, la damage reduction di P2 è nulla
		if p1.attack_can_pierce:
			p2_dmg_reduction = 0
		
		if p1_offset <= PERFECT_WINDOW:
			p2.take_damage(p1.atk - p2_dmg_reduction)
		else:
			# Penalità: Riduce il danno inflitto del 20%
			p2.take_damage(round(p1.atk * PENALTY_PERCENTAGE) - p2_dmg_reduction)
		
		# Controlla se Fearless Heart è attivo
		if p1.heal_while_attacking and p2.move == Move.ATTACK:
			p1.heal(HEAL_WHILE_ATTACKING)
			
	# Attacco P2 - Toglie danni a P1 pari all'attacco di P2 meno la riduzione danni di P1
	if p2.move == Move.ATTACK:
		# Se P2 sta usando la phantom blade, la damage reduction di P1 è nulla
		if p2.attack_can_pierce:
			p1_dmg_reduction = 0
		
		if p2_offset <= PERFECT_WINDOW:
			p1.take_damage(p2.atk - p1_dmg_reduction)
		else:
			# Penalità: Riduce il danno inflitto del 20%
			p1.take_damage(round(p2.atk * PENALTY_PERCENTAGE) - p1_dmg_reduction)
			
		# Controlla se Fearless Heart è attivo
		if p2.heal_while_attacking and p1.move == Move.ATTACK:
			p2.heal(HEAL_WHILE_ATTACKING)
			
	# Per le mosse speciali i check sono fatti nel metodo stesso
	# Mossa speciale P1 - Sarà gestita dal metodo apposito
	if p1.move == Move.SPECIAL:
		p1.special_move(p2, p1_offset > PERFECT_WINDOW, p2_dmg_reduction)
		
	# Mossa speciale P2 - Sarà gestita dal metodo apposito
	if p2.move == Move.SPECIAL:
		p2.special_move(p1, p2_offset > PERFECT_WINDOW, p1_dmg_reduction)
	
	# Rimuove i buff dei player e imposta la mossa corrente alla mossa successiva
	p1.last_move = p1.move
	p2.last_move = p2.move
	
	# Rimuove i buff temporanei dovuti agli item
	p1.remove_buffs()
	p2.remove_buffs()
	
	# Reimposta gli array di utilizzo degli item a false per il prossimo turno
	p1_uses_item = [false, false, false]
	p2_uses_item = [false, false, false]
	
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
func end_match() -> void:
	# Vince il player con più HP o che ha raggiunto il numero massimo di TP
	# In caso di pareggio, nessun player guadagna un punto
	if check_parity():
		print("Abbiamo un pareggio!")
	elif winner() == 1:
		print("Vince " + p1.p_name + "!")
		p1_wins += 1
	else:
		print("Vince " + p2.p_name + "!")
		p2_wins += 1
	
	# Al meglio di 5
	if p1_wins == 3 and p2_wins == 3:
		print("La partita finisce con un pareggio!")
	elif p1_wins == 3:
		print ("Il giocatore 1 vince l'intera partita!")
	elif p2_wins == 3:
		print ("Il giocatore 2 vince l'intera partita!")
	else:
		processing_turn = false
		
		# Prima di passare al match successivo, ricarica i kit, la vita dei
		# player, i punti teatro e reimposta il turno a 0
		p1.restore()
		p2.restore()
		
		p1.kit.recharge_kit()
		p2.kit.recharge_kit()
		
		p1.cur_theater_points = 0
		p2.cur_theater_points = 0
		
		cur_turn = 0
		start_turn()

# Verifica se i giocatori hanno pareggiato il match. I player pareggiano in queste situazioni:
# -Arrivano entrambi a 0 HP (indipendentemente dai punti teatrali)
# -Hanno gli stessi HP ma o non hanno raggiunto i punti teatro entro i 5 turni o li hanno raggiunti entrambi contemp.
func check_parity() -> bool:
	if p1.hp == p2.hp:
		# Primo caso
		if p1.hp == 0:
			return true
			
		# Secondo caso (non hanno raggiunto i punti teatro)
		if p1.cur_theater_points != p1.max_theater_points and p2.cur_theater_points != p2.max_theater_points:
			return true
		
		# Secondo caso (hanno raggiunto contemporaneamente i punti teatro)
		if p1.cur_theater_points == p1.max_theater_points and p2.cur_theater_points == p2.max_theater_points:
			return true
	
	# Non c'è pareggio
	return false

# Richiamata quando il match finisce, restituisce il numero del player vincitore
# 1 per il player 1, 2 per il player 2
# Non vengono fatti controlli sul pareggio perché si assume che sono stati già fatti
func winner() -> int:
	# Check sul KO
	if p1.hp == 0:
		return 2
	elif p2.hp == 0:
		return 1
	
	# Controllo sui punti teatro
	if p1.cur_theater_points == p1.max_theater_points and p2.cur_theater_points != p2.max_theater_points:
		return 1
	elif p2.cur_theater_points == p2.max_theater_points and p1.cur_theater_points != p1.max_theater_points:
		return 2
	
	if p1.hp > p2.hp:
		return 1
	else:
		return 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $Timer.is_stopped():
		$Label.text = str(int($Timer.time_left) + 1)
		$Player1.get_child(4).text = p1.toString()
		$Player2.get_child(4).text = p2.toString()
