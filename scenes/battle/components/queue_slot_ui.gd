extends Control

signal slot_clicked(slot_index)

@export var slot_index: int = 0
var queued_card_data: CardData = null

@onready var lbl_slot: Label = %LblSlot
@onready var card_container: MarginContainer = %CardContainer
@onready var lbl_card_name: Label = %LblCardName
@onready var lbl_card_cost: Label = %LblCardCost

func setup(p_index: int) -> void:
	slot_index = p_index
	lbl_slot.text = "Slot " + str(slot_index + 1)
	clear_slot()

func set_queued_card(card: CardData) -> void:
	queued_card_data = card
	if card:
		card_container.visible = true
		lbl_card_name.text = card.name
		lbl_card_cost.text = "Cost: " + str(card.cost)
	else:
		clear_slot()

func clear_slot() -> void:
	queued_card_data = null
	card_container.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(slot_index)
