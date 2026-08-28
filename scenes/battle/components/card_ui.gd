extends Control

signal card_clicked(card_ui)

@export var card_data: CardData

@onready var panel: PanelContainer = $PanelContainer
@onready var lbl_title: Label = %LblTitle
@onready var lbl_cost: Label = %LblCost
@onready var lbl_type: Label = %LblType
@onready var lbl_description: Label = %LblDescription
@onready var type_badge: Panel = %TypeBadge

var is_hovered: bool = false
var is_in_queue: bool = false
var queue_index: int = -1

func setup(p_card_data: CardData) -> void:
	card_data = p_card_data
	_update_ui()

func _ready() -> void:
	if card_data:
		_update_ui()

func _update_ui() -> void:
	if not is_inside_tree() or not card_data:
		return
	lbl_title.text = card_data.name
	lbl_cost.text = str(card_data.cost)
	lbl_type.text = card_data.get_type_name().to_upper()
	lbl_description.text = card_data.description
	
	# Color styling based on Card Type
	var style_box = StyleBoxFlat.new()
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	
	match card_data.type:
		CardData.CardType.ATTACK:
			style_box.bg_color = Color("#2a1215")
			style_box.border_color = Color("#ef4444")
		CardData.CardType.DEFENSE:
			style_box.bg_color = Color("#0f172a")
			style_box.border_color = Color("#3b82f6")
		CardData.CardType.PRIMER:
			style_box.bg_color = Color("#082f49")
			style_box.border_color = Color("#06b6d4")
		CardData.CardType.IGNITER:
			style_box.bg_color = Color("#2e1065")
			style_box.border_color = Color("#a855f7")
		CardData.CardType.UTILITY:
			style_box.bg_color = Color("#064e3b")
			style_box.border_color = Color("#10b981")
		CardData.CardType.ULTIMATE:
			style_box.bg_color = Color("#451a03")
			style_box.border_color = Color("#f59e0b")
		CardData.CardType.ITEM:
			style_box.bg_color = Color("#18181b")
			style_box.border_color = Color("#a1a1aa")
			
	panel.add_theme_stylebox_override("panel", style_box)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(self)

func _on_mouse_entered() -> void:
	is_hovered = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", -12.0, 0.1)

func _on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0.0, 0.1)
