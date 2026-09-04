class_name BattleEntity
extends Resource

signal hp_changed(new_hp, max_hp)
signal block_changed(new_block)
signal status_changed()

@export var entity_name: String = "Entity"
@export var max_hp: int = 50
@export var current_hp: int = 50
@export var current_block: int = 0
@export var is_player: bool = false
var is_boss: bool = false

# Statuses
@export var is_wet: bool = false
@export var is_muddy: bool = false
@export var is_stunned: bool = false

func take_damage(amount: int) -> int:
	var damage_after_block = max(0, amount - current_block)
	current_block = max(0, current_block - amount)
	current_hp = max(0, current_hp - damage_after_block)
	block_changed.emit(current_block)
	hp_changed.emit(current_hp, max_hp)
	return damage_after_block

func add_block(amount: int) -> void:
	current_block += amount
	block_changed.emit(current_block)

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)

func apply_status_wet() -> void:
	is_wet = true
	is_muddy = false # Muddy & Wet replace each other or coexist as needed
	status_changed.emit()

func apply_status_muddy() -> void:
	is_muddy = true
	is_wet = false
	status_changed.emit()

func apply_status_stun() -> void:
	is_stunned = true
	status_changed.emit()

func clear_statuses() -> void:
	is_wet = false
	is_muddy = false
	is_stunned = false
	status_changed.emit()

func reset_turn() -> void:
	current_block = 0
	block_changed.emit(current_block)
