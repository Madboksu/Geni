extends Control

signal reward_selected(card_id)

@onready var container_cards: HBoxContainer = %ContainerCards

var card_ui_scene = preload("res://scenes/battle/components/card_ui.tscn")

func show_reward() -> void:
	visible = true
	var all_cards = CardDatabase.get_all_cards()
	all_cards.shuffle()
	var selected_cards = [all_cards[0], all_cards[1], all_cards[2]]
	setup(selected_cards)

func setup(cards: Array) -> void:
	for child in container_cards.get_children():
		child.queue_free()
		
	for card_data in cards:
		var card_inst = card_ui_scene.instantiate()
		container_cards.add_child(card_inst)
		card_inst.setup(card_data)
		card_inst.card_clicked.connect(_on_card_chosen)

func _on_card_chosen(card_ui) -> void:
	if card_ui and card_ui.card_data:
		reward_selected.emit(card_ui.card_data.id)
