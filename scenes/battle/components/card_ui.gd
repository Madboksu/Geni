extends Control

signal card_clicked(card_ui)
signal card_inspect_requested(card_data)

@export var card_data: CardData

@onready var panel: PanelContainer = $PanelContainer
@onready var lbl_title: Label = %LblTitle
@onready var lbl_cost: Label = %LblCost
@onready var lbl_type: Label = %LblType
@onready var lbl_description: RichTextLabel = %LblDescription
@onready var type_badge: Panel = %TypeBadge
@onready var card_texture: TextureRect = %CardTexture

var is_hovered: bool = false
var is_in_queue: bool = false
var queue_index: int = -1

func setup(p_card_data: CardData) -> void:
	card_data = p_card_data
	_update_ui()

func _ready() -> void:
	pivot_offset = Vector2(custom_minimum_size.x * 0.5, custom_minimum_size.y * 0.5)
	if card_data:
		_update_ui()

func _update_ui() -> void:
	if not is_inside_tree() or not card_data:
		return
	lbl_title.text = card_data.name
	lbl_cost.text = str(card_data.cost)
	lbl_type.text = card_data.get_type_name().to_upper()
	lbl_description.text = _format_description(card_data.description)
	
	# Cek apakah kartu punya gambar
	var has_image: bool = card_data.texture_path != ""
	
	if has_image:
		card_texture.texture = load(card_data.texture_path)
		card_texture.visible = true
	else:
		card_texture.visible = false
	
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
		
	if has_image:
		style_box.bg_color.a = 0.0
		style_box.border_width_left = 0
		style_box.border_width_top = 0
		style_box.border_width_right = 0
		style_box.border_width_bottom = 0
			
	panel.add_theme_stylebox_override("panel", style_box)

func _format_description(raw_text: String) -> String:
	var formatted = raw_text
	formatted = formatted.replace("[Wet]", "[color=#38bdf8][Wet][/color]")
	formatted = formatted.replace("[Muddy]", "[color=#fb923c][Muddy][/color]")
	formatted = formatted.replace("[Stun]", "[color=#facc15][Stun][/color]")
	return "[center]" + formatted + "[/center]"

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			card_inspect_requested.emit(card_data)
			accept_event()

func _on_mouse_entered() -> void:
	is_hovered = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", -14.0, 0.1)

func _on_mouse_exited() -> void:
	is_hovered = false
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0.0, 0.1)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not card_data:
		return null
		
	var preview_ui = preload("res://scenes/battle/components/card_ui.tscn").instantiate()
	preview_ui.setup(card_data)
	preview_ui.modulate.a = 0.6
	var control = Control.new()
	control.add_child(preview_ui)
	preview_ui.position = -custom_minimum_size / 2.0
	set_drag_preview(control)
	
	return card_data

func make_zoomed() -> void:
	custom_minimum_size = Vector2(320, 480)
	size = Vector2(320, 480)
	
	lbl_cost.add_theme_font_size_override("font_size", 28)
	lbl_cost.position = Vector2(-100, 16)
	lbl_cost.size = Vector2(236, 40)
	
	lbl_title.add_theme_font_size_override("font_size", 22)
	lbl_title.position = Vector2(36, 300)
	lbl_title.size = Vector2(248, 40)
	
	lbl_description.add_theme_font_size_override("normal_font_size", 16)
	lbl_description.add_theme_font_size_override("bold_font_size", 16)
	lbl_description.position = Vector2(56, 360)
	lbl_description.size = Vector2(208, 68)
	
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)
