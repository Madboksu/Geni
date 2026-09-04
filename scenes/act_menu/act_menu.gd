extends Control

@onready var btn_act1: Button = %BtnAct1
@onready var btn_act2: Button = %BtnAct2
@onready var btn_act3: Button = %BtnAct3
@onready var btn_back: Button = %BtnBack

@onready var act1_card: Control = %Act1Card
@onready var act2_card: Control = %Act2Card
@onready var act3_card: Control = %Act3Card

@onready var gate1_tex: TextureRect = %Gate1Texture
@onready var gate2_tex: TextureRect = %Gate2Texture
@onready var gate3_tex: TextureRect = %Gate3Texture

@onready var lbl_act1_status: Label = %LblAct1Status
@onready var lbl_act2_status: Label = %LblAct2Status
@onready var lbl_act3_status: Label = %LblAct3Status

var tex_gerbang_buka = preload("res://assets/gate-buka.png")
var tex_gerbang_tutup = preload("res://assets/gate-tutup.png")

func _ready() -> void:
	_update_act_states()
	btn_act1.pressed.connect(func(): _select_act(1))
	btn_act2.pressed.connect(func(): _select_act(2))
	btn_act3.pressed.connect(func(): _select_act(3))
	btn_back.pressed.connect(_on_btn_back_pressed)
	
	_setup_hover_effect(btn_act1, act1_card)
	_setup_hover_effect(btn_act2, act2_card)
	_setup_hover_effect(btn_act3, act3_card)
	_setup_back_button_juice()

var _back_tw: Tween

func _kill_back_tw():
	if is_instance_valid(_back_tw) and _back_tw.is_valid():
		_back_tw.kill()

func _setup_back_button_juice() -> void:
	if not is_instance_valid(btn_back):
		return
	btn_back.pivot_offset = btn_back.size * 0.5
	
	if btn_back.has_theme_stylebox("normal"):
		var normal_style = btn_back.get_theme_stylebox("normal")
		var hover_style = normal_style.duplicate()
		if hover_style is StyleBoxFlat:
			hover_style.bg_color = hover_style.bg_color.lightened(0.1)
			hover_style.border_color = hover_style.border_color.lightened(0.2)
		btn_back.add_theme_stylebox_override("hover", hover_style)
		btn_back.add_theme_stylebox_override("pressed", hover_style)
		btn_back.add_theme_stylebox_override("focus", normal_style)
	btn_back.mouse_entered.connect(func():
		_kill_back_tw()
		_back_tw = create_tween()
		GameManager.play_sfx("hover", -10.0)
		_back_tw.tween_property(btn_back, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	btn_back.mouse_exited.connect(func():
		_kill_back_tw()
		_back_tw = create_tween()
		_back_tw.tween_property(btn_back, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn_back.button_down.connect(func():
		GameManager.play_sfx("click", -5.0)
		_kill_back_tw()
		_back_tw = create_tween()
		_back_tw.tween_property(btn_back, "scale", Vector2(0.96, 0.96), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn_back.button_up.connect(func():
		_kill_back_tw()
		_back_tw = create_tween()
		GameManager.play_sfx("hover", -10.0)
		_back_tw.tween_property(btn_back, "scale", Vector2(1.06, 1.06), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)

var _card_tweens: Dictionary = {}

func _setup_hover_effect(btn: Button, card: Control) -> void:
	card.pivot_offset = Vector2(125, 195)
	btn.mouse_entered.connect(func():
		if not btn.disabled:
			if _card_tweens.has(card) and is_instance_valid(_card_tweens[card]):
				_card_tweens[card].kill()
			var tw = create_tween()
			GameManager.play_sfx("hover", -10.0)
			tw.tween_property(card, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_card_tweens[card] = tw
	)
	btn.mouse_exited.connect(func():
		if _card_tweens.has(card) and is_instance_valid(_card_tweens[card]):
			_card_tweens[card].kill()
		var tw = create_tween()
		tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_card_tweens[card] = tw
	)

func _update_act_states() -> void:
	# Act 1 is always open
	gate1_tex.texture = tex_gerbang_buka
	lbl_act1_status.text = "TERBUKA"
	lbl_act1_status.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3, 1.0))
	btn_act1.disabled = false

	# Act 2 unlocked if Act 1 boss defeated (level > 5) or current_act >= 2
	var act2_unlocked: bool = true
	if act2_unlocked:
		gate2_tex.texture = tex_gerbang_buka
		gate2_tex.modulate = Color(1, 1, 1, 1)
		lbl_act2_status.text = "TERBUKA"
		lbl_act2_status.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3, 1.0))
		btn_act2.disabled = false
	else:
		gate2_tex.texture = tex_gerbang_tutup
		gate2_tex.modulate = Color(0.75, 0.75, 0.8, 1)
		lbl_act2_status.text = "TERKUNCI"
		lbl_act2_status.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3, 1.0))
		btn_act2.disabled = true

	# Act 3 is closed / Coming soon
	gate3_tex.texture = tex_gerbang_tutup
	gate3_tex.modulate = Color(0.5, 0.5, 0.55, 1)
	lbl_act3_status.text = "SEGERA HADIR"
	lbl_act3_status.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55, 1.0))
	btn_act3.disabled = true

func _select_act(act: int) -> void:
	GameManager.current_act = act
	GameManager.load_scene("res://scenes/level_select/level_select.tscn")

func _on_btn_back_pressed() -> void:
	GameManager.load_scene("res://scenes/main_menu/main_menu.tscn")
