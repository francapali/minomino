extends Node2D

# Definizione di enum per le tipologie di mosse
enum Move {NONE, ATTACK, DEFEND, SPECIAL}

# Istanze dei giocatori
var p1 = Player.new()
var p2 = Player.new()

# Variabili di utilità per l'UI
# Texture varie (il gioco è molto leggero, ci possiamo permettere di tenerle caricate per facilità d'accesso)
var texture_stars = [
	preload("res://assets/zerostars.png"),    # 0 Punti per Teseo
	preload("res://assets/onestar.png"),      # 1 Punto per Teseo
	preload("res://assets/twostars.png"),     # 2 Punti per Teseo
	preload("res://assets/threestars.png"),   # 3 Punti per Teseo
]

var texture_circles = [
	preload("res://assets/circle_empty.png"), # 0 Punti per Minotauro
	preload("res://assets/circle_full.png"),  # 1 Punto per Minotauro
]

var regions = [
	Rect2(1024, 0, 256, 720),  # 1
	Rect2(785, 0, 239, 720),   # 2
	Rect2(512, 0, 256, 720),   # 3
	Rect2(256, 0, 256, 720),   # 4
	Rect2(0, 0, 256, 720),     # 5
]
	
@onready var texture_numeri = preload("res://assets/numeri.png")
@onready var texture_tauro_exclamation = preload("res://assets/tauro_exclamation.png")
@onready var texture_mino_exclamation = preload("res://assets/minoballoon.png")
@onready var texture_minomino_exclamation = preload("res://assets/minomino.png")
@onready var teseo_texture = preload("res://assets/tesstd.png")
@onready var mosse_thes = preload("res://assets/MosseThes.png")
@onready var minotauro_texture = preload("res://assets/minostd.png")
@onready var mosse_mino = preload("res://assets/MosseMino.png")
@onready var safety_texture = preload("res://assets/SafetyItems.png")
@onready var rage_texture = preload("res://assets/RageItems.png")

# Sound effects
@onready var attack_sfx = preload("res://sfx/Attack.wav")
@onready var defense_sfx = preload("res://sfx/Defense.mp3")
@onready var special_sfx = preload("res://sfx/Special.mp3")
@onready var item_sfx = preload("res://sfx/Item.mp3")

# Timer ed effetti sonori
@onready var timer_display = $TimerDisplay
@onready var sound_effects = $SoundEffects

#Gestione UI P1
@onready var p1_sprite = $P1Sprite
@onready var p1_nome = $NomeP1
@onready var p1_mosse = $MosseP1
@onready var p1_kit = $KitP1
@onready var p1_HPbar = $HP_P1
@onready var P1_points = $P1Points
@onready var animation_p1 = $P1Sprite/AnimationPlayer

#Gestione UI P2
@onready var p2_sprite = $P2Sprite
@onready var p2_nome = $NomeP2
@onready var p2_mosse = $MosseP2
@onready var p2_kit = $KitP2
@onready var p2_HPbar = $HP_P2
@onready var P2_points = $P2Points
@onready var animation_p2 = $P2Sprite/AnimationPlayer

# Variabili per la gestione dei turni
var processing_turn = true
var turn_start_time = 0
var cur_turn = 0
var start = false

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
	# Inizializza i player sulla base dei personaggi e il kit che hanno scelto
	p1.initialize_player(GameState.player1, GameState.kitplayer1)
	p2.initialize_player(GameState.player2, GameState.kitplayer2)
	
	# Imposta i valori di flip, necessario per il mirroring delle mosse, nello specifico:
	# - Teseo P1: Non flippato
	# - Teseo P2: Flippato
	# - Minotauro P1: Flippato
	# - Minotauro P2: Non flippato
	if p1.p_name == "Mino":
		p1.flip = true
	if p2.p_name == "Thes":
		p2.flip = true
	
	# Inizializza la grafica e fa partire il countdown
	update_points_bar()
	
	update_health_bar()
	
	update_frames()
	
	await countdown()
	
	# Comincia la partita
	start_turn()

# Gestisce il countdown prima della partenza della partita
func countdown():
	start = false
	
	# Mostra il numero 3 e fa passare un secondo
	timer_display.region_enabled = true
	timer_display.scale = Vector2(0.381, 0.4)
	timer_display.texture = texture_numeri
	timer_display.position = Vector2(576, 200)
	timer_display.region_rect = regions[2]
	await get_tree().create_timer(1).timeout
	
	# Mostra il numero 2 e fa passare un secondo
	timer_display.region_rect = regions[1]
	await get_tree().create_timer(1).timeout
	
	# Mostra il numero 1 e fa passare un secondo
	timer_display.region_rect = regions[0]
	await get_tree().create_timer(1).timeout
	
	# Mostra "Tauro!", fa passare un secondo e fa partire il gioco
	timer_display.region_enabled = false
	timer_display.texture = texture_tauro_exclamation
	timer_display.scale = Vector2(0.35, 0.367)
	timer_display.position = Vector2(576, 200)
	await get_tree().create_timer(1).timeout
	
	start = true

# Chiamata all'inizio di un turno per inizializzare i valori e far partire il timer
func start_turn() -> void:
	cur_turn += 1;
	update_frames()
	print("Turno %d" % cur_turn)
	
	p1.move = Move.NONE
	p2.move = Move.NONE
	
	p1.move_selected_time = -1.0
	p2.move_selected_time = -1.0
	
	turn_start_time = Time.get_ticks_msec() / 1000.0
	
	processing_turn = false
	$Timer.start(TURN_DURATION)

# Chiamata quando scade il tempo, notifica i giocatori e passa al processing delle mosse
func _on_timer_timeout() -> void:
	$Timer.stop()
	
	await get_tree().create_timer(1).timeout
	
	processing_turn = true
	
	await get_tree().create_timer(3).timeout
	
	process_moves()
	
	if end_condition():
		end_match()
		get_tree().change_scene_to_file("res://scenes/Final.tscn")
	else:
		start_turn();

# Funzione che gestisce e processa gli input dei giocatori durante la partita
func _unhandled_input(event) -> void:
	# Controlla se l'input è rilevante per il gioco, se non lo è lo ignora
	if not event.is_pressed() or processing_turn:
		return
		
	if not (event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return
		
	# Input P1
	if p1.move == Move.NONE:
		if Input.is_action_just_pressed("P1_ingame_left"):
			p1.process_input("LEFT")
		elif Input.is_action_just_pressed("P1_ingame_right"):
			p1.process_input("RIGHT")
		elif Input.is_action_just_pressed("P1_ingame_down"):
			p1.process_input("DOWN")
	
	# Input P2
	if p2.move == Move.NONE:
		if Input.is_action_just_pressed("P2_ingame_left"):
			p2.process_input("LEFT")
		elif Input.is_action_just_pressed("P2_ingame_right"):
			p2.process_input("RIGHT")
		elif Input.is_action_just_pressed("P2_ingame_down"):
			p2.process_input("DOWN")
	
	# Input degli item, sia per P1 che per P2
	# Nota: Può essere usato un solo item per turno, quindi verrà preso quello che il player ha
	# scelto per ultimo. Questo spiega anche le particolari combinazioni degli array uses_item		
	if Input.is_action_just_pressed("P1_ingame_item_l"):
		p1_uses_item = [true, false, false]
	elif Input.is_action_just_pressed("P1_ingame_item_x"):
		p1_uses_item = [false, true, false]
	elif Input.is_action_just_pressed("P1_ingame_item_r"):
		p1_uses_item = [false, false, true]
	elif Input.is_action_just_pressed("P2_ingame_item_l"):
		p2_uses_item = [true, false, false]
	elif Input.is_action_just_pressed("P2_ingame_item_x"):
		p2_uses_item = [false, true, false]
	elif Input.is_action_just_pressed("P2_ingame_item_r"):
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
		print(p1.p_name + " ripete la stessa mossa!")
		
	if p2.last_move == p2.move and p2.move != Move.NONE:
		p2.move = Move.NONE
		print(p2.p_name + " ripete la stessa mossa!")
	
	# Controllo sul giocatore che non ha scelto una mossa
	if p1.move == Move.NONE:
		print(p1.p_name + " non fa nulla!")
		
	if p2.move == Move.NONE:
		print(p2.p_name + " non fa nulla!")
	
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
			animation_p2.play("damage")
		else:
			# Penalità: Riduce il danno inflitto del 20%
			p2.take_damage(round(p1.atk * PENALTY_PERCENTAGE) - p2_dmg_reduction)
			animation_p2.play("damage")
		
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
			animation_p1.play("damage")
		else:
			# Penalità: Riduce il danno inflitto del 20%
			p1.take_damage(round(p2.atk * PENALTY_PERCENTAGE) - p1_dmg_reduction)
			animation_p1.play("damage")
			
		# Controlla se Fearless Heart è attivo
		if p2.heal_while_attacking and p1.move == Move.ATTACK:
			p2.heal(HEAL_WHILE_ATTACKING)
			
	# Per le mosse speciali i check sono fatti nel metodo stesso
	# Mossa speciale P1 - Sarà gestita dal metodo apposito
	if p1.move == Move.SPECIAL:
		if p1.p_name == "Mino" and p1.cur_theater_points == 1:
			animation_p2.play("damage")
			
		p1.special_move(p2, p1_offset > PERFECT_WINDOW, p2_dmg_reduction)
		
	# Mossa speciale P2 - Sarà gestita dal metodo apposito
	if p2.move == Move.SPECIAL:
		if p2.p_name == "Mino" and p2.cur_theater_points == 1:
			animation_p1.play("damage")
			
		p2.special_move(p1, p2_offset > PERFECT_WINDOW, p1_dmg_reduction)
	
	# Aggiorna la barra dei punti dei player graficamente,
	# mettendola in linea con gli HP correnti dei player
	update_points_bar()
	
	# Aggiorna la barra della vita dei player graficamente,
	# mettendola in linea con gli HP correnti dei player
	update_health_bar()
	
	# Suona i sound effects appropriati
	# Viene riprodotto un solo sound effect per l'intero turno, così da non generare caos.
	# Gli item hanno la proprità, poi le mosse speciali, a seguito della difesa, infine l'attacco.
	# Se un player ha usato un item, riproduci il sound effect appropriato
	if p1_uses_item.has(true) or p2_uses_item.has(true):
		sound_effects.stream = item_sfx
		sound_effects.play()
	else:
		if p1.move == Move.SPECIAL or p2.move == Move.SPECIAL:
			play_sound(Move.SPECIAL)
		elif p1.move == Move.DEFEND or p2.move == Move.DEFEND:
			play_sound(Move.DEFEND)
		elif p1.move == Move.ATTACK or p2.move == Move.ATTACK:
			play_sound(Move.ATTACK)
	
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

# Aggiorna graficamente la barra della vita di entrambi i giocatori
func update_health_bar():
	p1_HPbar.get_child(1).value = (float(p1.hp) / float(p1.max_hp)) * 100 
	p2_HPbar.get_child(1).value = (float(p2.hp) / float(p2.max_hp)) * 100
	
# Aggiorna graficamente la barra dei punti teatro di entrambi i giocatori
func update_points_bar():
	if p1.p_name == "Thes":
		P1_points.flip_h = true
		P1_points.scale = Vector2(0.13, 0.13)
		P1_points.position = Vector2(265, 285)
		P1_points.texture = texture_stars[p1.cur_theater_points]
	else:
		P1_points.flip_h = true
		P1_points.scale = Vector2(0.36, 0.36)
		P1_points.position = Vector2(218, 285)
		P1_points.texture = texture_circles[p1.cur_theater_points]
		
	if p2.p_name == "Thes":
		P2_points.flip_h = false
		P2_points.scale = Vector2(0.13, 0.13)
		P2_points.position = Vector2(896, 285)
		P2_points.texture = texture_stars[p2.cur_theater_points]
	else:
		P2_points.flip_h = false
		P2_points.scale = Vector2(0.36, 0.36)
		P2_points.position = Vector2(943, 285)
		P2_points.texture = texture_circles[p2.cur_theater_points]
		

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
		
	await get_tree().create_timer(0.5).timeout
	
	# Al meglio di 5
	if p1_wins == 3 and p2_wins == 3:
		print("La partita finisce con un pareggio!")
		GameState.winner = null
		GameState.winner_number = 0
	elif p1_wins == 3:
		print ("Il giocatore 1 vince l'intera partita!")
		GameState.winner = p1
		GameState.winner_number = 1
	elif p2_wins == 3:
		print ("Il giocatore 2 vince l'intera partita!")
		GameState.winner = p2
		GameState.winner_number = 2
	else:
		processing_turn = false
		
		await countdown()
		
		# Prima di passare al match successivo, ricarica i kit, la vita dei
		# player, i punti teatro e reimposta il turno a 0, per poi aggiornare la grafica
		p1.restore()
		p2.restore()
		
		p1.kit.recharge_kit()
		p2.kit.recharge_kit()
		
		p1.cur_theater_points = 0
		p2.cur_theater_points = 0
		
		p1.last_move = Move.NONE
		p2.last_move = Move.NONE
		
		update_points_bar()
		update_health_bar()
		update_frames()
		
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
	if start:
		if not $Timer.is_stopped():
			var index = int($Timer.time_left)
			
			if index >= 4:
				timer_display.region_enabled = true
				timer_display.scale = Vector2(0.381, 0.4)
				timer_display.texture = texture_numeri
				timer_display.region_rect = regions[4]
			elif index < 4 and index > 1:
				timer_display.region_enabled = true
				timer_display.scale = Vector2(0.381, 0.4)
				timer_display.texture = texture_numeri
				timer_display.region_rect = regions[index]
			elif index == 1:
				timer_display.region_enabled = false
				timer_display.scale = Vector2(0.35, 0.367)
				timer_display.texture = texture_mino_exclamation
			elif index == 0:
				timer_display.region_enabled = false
				timer_display.scale = Vector2(0.35, 0.367)
				timer_display.texture = texture_minomino_exclamation
		else:
			timer_display.region_enabled = false
			timer_display.scale = Vector2(0.35, 0.367)
			timer_display.texture = texture_tauro_exclamation
		
func update_frames():
	# P1 sprite
	if p1.p_name == "Thes":  # Teseo
		p1_nome.text = "Theseus"
		p1_sprite.texture = teseo_texture
		p1_sprite.global_position = Vector2(367, 430)
		p1_sprite.scale = Vector2(0.335, 0.33)
		p1_sprite.flip_h = true
		
		p1_mosse.texture = mosse_thes
		p1_mosse.global_position = Vector2(70, 224)
		p1_mosse.size = Vector2(211, 407)
		p1_mosse.scale = Vector2(1, 1)
		p1_sprite.flip_h = true
		
	elif p1.p_name == "Mino":  # Minotauro
		p1_nome.text = "Minotaur"
		p1_sprite.texture = minotauro_texture
		p1_sprite.global_position = Vector2(382, 422)
		p1_sprite.scale = Vector2(0.36, 0.35)
		p1_sprite.flip_h = true
		
		p1_mosse.texture = mosse_mino
		p1_mosse.global_position = Vector2(72, 225)
		p1_mosse.size = Vector2(205, 394)
		p1_mosse.scale = Vector2(1, 1)
		p1_mosse.flip_h = true

	# P2 sprite
	if p2.p_name == "Thes":  # Teseo
		p2_nome.text = "Theseus"
		p2_sprite.texture = teseo_texture
		p2_sprite.global_position = Vector2(792, 423)
		p2_sprite.scale = Vector2(0.335, 0.33)
		p2_sprite.flip_h = false
		
		p2_mosse.texture = mosse_thes
		p2_mosse.global_position = Vector2(872, 224)
		p2_mosse.size = Vector2(211, 407)
		p2_mosse.scale = Vector2(1, 1)
		p2_mosse.flip_h = true
		
	elif p2.p_name == "Mino":  # Minotauro
		p2_nome.text = "Minotaur"
		p2_sprite.texture = minotauro_texture
		p2_sprite.global_position = Vector2(792, 418)
		p2_sprite.scale = Vector2(0.36, 0.35)
		p2_sprite.flip_h = false
		
		p2_mosse.texture = mosse_mino
		p2_mosse.global_position = Vector2(875, 229)
		p2_mosse.size = Vector2(205, 394)
		p2_mosse.scale = Vector2(1, 1)
		p2_mosse.flip_h = false
		
	# P1 Infografica Kit
	if p1.kit.kit_name == "SafetyButton":
		p1_kit.texture = safety_texture
	elif p1.kit.kit_name == "RageButton":
		p1_kit.texture = rage_texture

	p1_kit.visible = true
	p1_kit.modulate = Color(1,1,1,1)
	p1_kit.global_position = Vector2(360, 596)
	p1_kit.scale = Vector2(0.242, 0.242)
		
	# P2 Infografica Kit
	if p2.kit.kit_name == "SafetyButton":
		p2_kit.texture = safety_texture
	elif p2.kit.kit_name == "RageButton":
		p2_kit.texture = rage_texture

	p2_kit.visible = true
	p2_kit.modulate = Color(1,1,1,1)
	p2_kit.global_position = Vector2(800, 596)
	p2_kit.scale = Vector2(0.242, 0.242)

func play_sound(move: Move) -> void:
	match move:
		Move.ATTACK:
			sound_effects.stream = attack_sfx
			sound_effects.play()
		Move.DEFEND:
			sound_effects.stream = defense_sfx
			sound_effects.play()
		Move.SPECIAL:
			sound_effects.stream = special_sfx
			sound_effects.play()
	pass
