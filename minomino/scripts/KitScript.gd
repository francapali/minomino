extends Node2D

# Definizione globale della classe
class_name Kit

#Attributi
var kit_name: String
var items: Array

# Imposta i parametri del kit in base al quello selezionato
func initialize_kit(name: String) -> void:
	kit_name = name
	items.resize(3)
	
	# Assegna gli item relativi al kit specifico selezionato
	match kit_name:
		"SafetyButton":
			items[0] = Item.new()
			items[0].initialize_item("PotOfCourage")
			items[1] = Item.new()
			items[1].initialize_item("IgeaInfusion")
			items[2] = Item.new()
			items[2].initialize_item("DivineCurtain")
			
		"RageButton":
			items[0] = Item.new()
			items[0].initialize_item("AresWrath")
			items[1] = Item.new()
			items[1].initialize_item("FearlessHeart")
			items[2] = Item.new()
			items[2].initialize_item("PhantomBlade")

# Dato l'indice dell'item del kit, usa l'item sul player in questione
func use_item(player: Player, item_index: int) -> void:
	items[item_index].use_item(player)
	
# Ricarica tutti gli item del kit
func recharge_kit() -> void:
	items[0].was_used_up = false
	items[1].was_used_up = false
	items[2].was_used_up = false
