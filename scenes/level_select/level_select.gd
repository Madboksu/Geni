extends Control

@onready var header_label: Label = %HeaderLabel
@onready var btn_level1: Button = %BtnLevel1
@onready var btn_level2: Button = %BtnLevel2
@onready var btn_level3: Button = %BtnLevel3
@onready var btn_level4: Button = %BtnLevel4
@onready var btn_back: Button = %BtnBack

@onready var level1_card: Control = %Level1Card
@onready var level2_card: Control = %Level2Card
@onready var level3_card: Control = %Level3Card
@onready var level4_card: Control = %Level4Card

@onready var box1_tex: TextureRect = %Box1Texture
@onready var box2_tex: TextureRect = %Box2Texture
@onready var box3_tex: TextureRect = %Box3Texture
@onready var box4_tex: TextureRect = %Box4Texture

@onready var lbl_level1_status: Label = %LblLevel1Status
@onready var lbl_level2_status: Label = %LblLevel2Status
@onready var lbl_level3_status: Label = %LblLevel3Status
@onready var lbl_level4_status: Label = %LblLevel4Status

func _ready() -> void:
	_update_header()
	_update_level_states()

	btn_level1.pressed.connect(func(): _select_level(1))
	btn_level2.pressed.connect(func(): _select_level(2))
	btn_level3.pressed.connect(func(): _select_level(3))
	btn_level4.pressed.connect(func(): _select_level(4))
	btn_back.pressed.connect(_on_btn_back_pressed)
	
	_setup_hover_effect(btn_level1, level1_card)
	_setup_hover_effect(btn_level2, level2_card)
	_setup_hover_effect(btn_level3, level3_card)
	_setup_hover_effect(btn_level4, level4_card)

func _setup_hover_effect(btn: Button, card: Control) -> void:
	card.pivot_offset = Vector2(102, 107)
	btn.mouse_entered.connect(func():
		if not btn.disabled:
			var tw = create_tween()
			tw.tween_property(card, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	btn.mouse_exited.connect(func():
		var tw = create_tween()
		tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)

func _update_header() -> void:
	var act_num: int = GameManager.current_act
	match act_num:
		1:
			header_label.text = "ACT 1 - HUTAN MEMBARA"
		2:
			header_label.text = "ACT 2 - KOTA TERBAKAR"
		3:
			header_label.text = "ACT 3 - PABRIK BARA"
		_:
			header_label.text = "ACT " + str(act_num) + " - PILIH LEVEL"

func _update_level_states() -> void:
	var max_unlocked: int = GameManager.get_max_unlocked_level()

	_set_level_state(1, 1 <= max_unlocked, box1_tex, lbl_level1_status, btn_level1)
	_set_level_state(2, 2 <= max_unlocked, box2_tex, lbl_level2_status, btn_level2)
	_set_level_state(3, 3 <= max_unlocked, box3_tex, lbl_level3_status, btn_level3)
	_set_level_state(4, 4 <= max_unlocked, box4_tex, lbl_level4_status, btn_level4)

func _set_level_state(level_num: int, is_unlocked: bool, box_tex: TextureRect, lbl_status: Label, btn: Button) -> void:
	if is_unlocked:
		box_tex.modulate = Color(1.0, 1.0, 1.0, 1.0)
		lbl_status.text = "TERBUKA"
		lbl_status.add_theme_color_override("font_color", Color(0.1, 0.65, 0.15, 1.0))
		btn.disabled = false
	else:
		box_tex.modulate = Color(0.45, 0.45, 0.5, 0.75)
		lbl_status.text = "TERKUNCI"
		lbl_status.add_theme_color_override("font_color", Color(0.85, 0.25, 0.25, 1.0))
		btn.disabled = true

func _select_level(level: int) -> void:
	GameManager.start_battle(level)

func _on_btn_back_pressed() -> void:
	GameManager.load_scene("res://scenes/act_menu/act_menu.tscn")
