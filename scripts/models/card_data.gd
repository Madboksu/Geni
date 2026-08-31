class_name CardData
extends Resource

enum CardType { ATTACK, DEFENSE, PRIMER, IGNITER, UTILITY, ULTIMATE, ITEM }
enum StatusType { NONE, WET, MUDDY, STUN }

@export var id: String = ""
@export var name: String = ""
@export var type: CardType = CardType.ATTACK
@export var cost: int = 1
@export var description: String = ""
@export var texture_path: String = ""

# Base Effects
@export var damage: int = 0
@export var block: int = 0
@export var applies_status: StatusType = StatusType.NONE
@export var heal: int = 0
@export var self_hp_cost: int = 0
@export var energy_gain: int = 0
@export var draw_cards: int = 0
@export var discard_cards: int = 0

# Igniter & Special Synergy Logic
@export var combo_req_status: StatusType = StatusType.NONE
@export var combo_damage: int = 0
@export var combo_applies_status: StatusType = StatusType.NONE
@export var combo_block: int = 0

# Special Flags
@export var is_consumable: bool = false # Single-use (hancur setelah dipakai)
@export var is_coin_flip: bool = false  # Drought's End logic
@export var coin_flip_fail_damage: int = 15

func get_type_name() -> String:
	match type:
		CardType.ATTACK: return "Attack"
		CardType.DEFENSE: return "Defense"
		CardType.PRIMER: return "Primer"
		CardType.IGNITER: return "Igniter"
		CardType.UTILITY: return "Utility"
		CardType.ULTIMATE: return "Ultimate"
		CardType.ITEM: return "Item"
	return "Card"
