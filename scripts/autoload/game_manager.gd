extends Node

var player_name: String = "Banyu"
var current_act: int = 1
var current_level: int = 1

var act1_max_level_unlocked: int = 1
var act2_max_level_unlocked: int = 1

var player_max_hp: int = 50
var player_current_hp: int = 50

# Player's current active deck list (array of card IDs)
var player_deck: Array = []

func _ready() -> void:
	reset_to_act1_starter_deck()

func reset_to_act1_starter_deck() -> void:
	# Starter deck according to Act 1 GDD specification
	player_deck = [
		"dewblade", "dewblade",
		"root_shield", "root_shield",
		"douse", "douse",
		"cooling_mud", "cooling_mud",
		"gale_wind",
		"thunder_strike",
		"whirlwind",
		"rain_dance",
		"blood_pact",
		"droughts_end",
		"broken_axe",
		"medkit"
	]
	player_max_hp = 50
	player_current_hp = 50

func add_card_to_deck(card_id: String) -> void:
	player_deck.append(card_id)

func unlock_next_level() -> void:
	if current_act == 1:
		act1_max_level_unlocked = max(act1_max_level_unlocked, current_level + 1)
		if act1_max_level_unlocked > 4:
			# Act 1 Complete -> Unlock Act 2
			current_act = 2
			act2_max_level_unlocked = max(act2_max_level_unlocked, 1)
	elif current_act == 2:
		act2_max_level_unlocked = max(act2_max_level_unlocked, current_level + 1)

func load_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
