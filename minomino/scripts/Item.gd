extends Node2D

# Definizione globale della classe
class_name Item

# Costanti per i valori degli item
const POT_OF_COURAGE_HEAL: int = 5
const IGEA_INFUSION_HEAL: int = 10
const ARES_WRATH_BONUS: int = 3

#Attributi
var item_name: String
var was_used_up: bool

# Imposta i parametri dell'item in base a quello selezionato
func initialize_item(name: String) -> void:
	item_name = name
	was_used_up = false

# Usa l'item sul player passato come parametro
func use_item(player: Player) -> void:
	# Può usare l'item solo se non è stato già usato
	if not was_used_up:
		# In base all'item l'effetto sarà diverso
		match item_name:
			"PotOfCourage":
				player.heal(POT_OF_COURAGE_HEAL)
			"IgeaInfusion":
				player.heal(IGEA_INFUSION_HEAL)
			"DivineCurtain":
				player.can_take_damage = false
			"AresWrath":
				player.atk += ARES_WRATH_BONUS
			"FearlessHeart":
				player.heal_while_attacking = true
			"PhantomBlade":
				player.attack_can_pierce = true
		
		# Dopo il primo utilizzo, l'item non si può più usare
		# THE ICE KEY WAS USED UP
		# SHE WAS USED UP
		# YOU WERE USED UP
		was_used_up = true

# You... you said I could trust you!! You said you were a GAMER!!
#
# Berdly
# I Only Play Mobile Games
#
# NOOOOOOOO!!!!!!
