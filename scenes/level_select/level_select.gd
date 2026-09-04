extends Control

@onready var header_label: Label = %HeaderLabel
@onready var btn_level1: Button = %BtnLevel1
@onready var btn_level2: Button = %BtnLevel2
@onready var btn_level3: Button = %BtnLevel3
@onready var btn_level4: Button = %BtnLevel4
@onready var btn_level5: Button = %BtnLevel5
@onready var btn_back: Button = %BtnBack

@onready var trail_bar: ColorRect = %TrailBar

@onready var box_holder1: Control = %BoxHolder1
@onready var box_holder2: Control = %BoxHolder2
@onready var box_holder3: Control = %BoxHolder3
@onready var box_holder4: Control = %BoxHolder4
@onready var box_holder5: Control = %BoxHolder5

@onready var box1_tex: TextureRect = %Box1Texture
@onready var box2_tex: TextureRect = %Box2Texture
@onready var box3_tex: TextureRect = %Box3Texture
@onready var box4_tex: TextureRect = %Box4Texture
@onready var box5_tex: TextureRect = %Box5Texture

@onready var lbl_level1_num: Label = %LblLevel1Num
@onready var lbl_level2_num: Label = %LblLevel2Num
@onready var lbl_level3_num: Label = %LblLevel3Num
@onready var lbl_level4_num: Label = %LblLevel4Num
@onready var lbl_level5_num: Label = %LblLevel5Num

@onready var badge1: Label = %Badge1
@onready var badge2: Label = %Badge2
@onready var badge3: Label = %Badge3
@onready var badge4: Label = %Badge4
@onready var badge5: Label = %Badge5

@onready var lbl_preview_title: Label = %LblPreviewTitle
@onready var lbl_preview_desc: Label = %LblPreviewDesc
@onready var lbl_preview_status: Label = %LblPreviewStatus

const STAGE_INFOS = {
	1: {
		"title": "STAGE 1: Pinggiran Hutan",
		"enemy": "Musuh: Tree Grunt (HP 50) • Hadiah: Kartu Acak",
		"is_boss": false
	},
	2: {
		"title": "STAGE 2: Sarang Api",
		"enemy": "Musuh: Pyro Scavenger & Tree Grunt • Hadiah: Kartu Acak",
		"is_boss": false
	},
	3: {
		"title": "STAGE 3: Penjaga Bara",
		"enemy": "Musuh: Flame Guard Golem & Tree Grunt • Hadiah: Kartu Acak",
		"is_boss": false
	},
	4: {
		"title": "STAGE 4: Pusat Api",
		"enemy": "Musuh: Fire Elemental & Flame Guard Golem • Hadiah: Kartu Acak",
		"is_boss": false
	},
	5: {
		"title": "STAGE 5: EMBER BEAST (BOSS)",
		"enemy": "BOSS UTAMA: Ember Beast (HP 85) • Hadiah: Akses Gerbang Act 2",
		"is_boss": true
	}
}

var _holder_tweens: Dictionary = {}
var _pulse_tween: Tween
var _anim_time: float = 0.0
var _badge5_base_y: float = -8.0


func _ready() -> void:
	_update_header()
	_update_level_states()

	btn_level1.pressed.connect(func(): _select_level(1))
	btn_level2.pressed.connect(func(): _select_level(2))
	btn_level3.pressed.connect(func(): _select_level(3))
	btn_level4.pressed.connect(func(): _select_level(4))
	btn_level5.pressed.connect(func(): _select_level(5))
	btn_back.pressed.connect(_on_btn_back_pressed)
	
	_setup_stage_node(1, btn_level1, box_holder1)
	_setup_stage_node(2, btn_level2, box_holder2)
	_setup_stage_node(3, btn_level3, box_holder3)
	_setup_stage_node(4, btn_level4, box_holder4)
	_setup_stage_node(5, btn_level5, box_holder5)

	_setup_back_button_juice()
	_animate_trail_bar()
	
	if is_instance_valid(badge5):
		_badge5_base_y = badge5.position.y
	
	# Default preview to highest unlocked stage
	var active_stage = mini(GameManager.get_max_unlocked_level(), 5)
	_show_preview(active_stage)


func _process(delta: float) -> void:
	_anim_time += delta
	
	# Boss Crown floating animation
	if is_instance_valid(badge5) and badge5.visible:
		badge5.position.y = _badge5_base_y + sin(_anim_time * 3.5) * 3.0

	# Header subtle living glow
	if is_instance_valid(header_label):
		var glow_pulse = 0.9 + sin(_anim_time * 2.0) * 0.1
		header_label.modulate = Color(1.0, 0.95 + glow_pulse * 0.05, 0.85 + glow_pulse * 0.15, 1.0)


func _animate_trail_bar() -> void:
	if not is_instance_valid(trail_bar):
		return
	var tw = create_tween().set_loops()
	tw.tween_property(trail_bar, "modulate", Color(1.25, 0.9, 0.4, 1.0), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(trail_bar, "modulate", Color(0.8, 0.45, 0.15, 0.65), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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


func _setup_stage_node(stage_num: int, btn: Button, holder: Control) -> void:
	holder.pivot_offset = Vector2(64, 67)
	btn.mouse_entered.connect(func():
		_show_preview(stage_num)
		if not btn.disabled:
			if _holder_tweens.has(holder) and is_instance_valid(_holder_tweens[holder]):
				_holder_tweens[holder].kill()
			var tw = create_tween()
			GameManager.play_sfx("hover", -10.0)
			tw.tween_property(holder, "scale", Vector2(1.08, 1.08), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_holder_tweens[holder] = tw
	)
	btn.mouse_exited.connect(func():
		var active_stage = mini(GameManager.get_max_unlocked_level(), 5)
		_show_preview(active_stage)
		if _holder_tweens.has(holder) and is_instance_valid(_holder_tweens[holder]):
			_holder_tweens[holder].kill()
		var tw = create_tween()
		tw.tween_property(holder, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_holder_tweens[holder] = tw
		if stage_num == active_stage:
			tw.finished.connect(func():
				_start_pulse_effect(holder)
			)
	)


func _show_preview(stage_num: int) -> void:
	var info = STAGE_INFOS.get(stage_num, STAGE_INFOS[1])
	lbl_preview_title.text = info["title"]
	lbl_preview_desc.text = info["enemy"]
	
	var max_unlocked = GameManager.get_max_unlocked_level()
	if stage_num < max_unlocked:
		lbl_preview_status.text = "[SELESAI - Klik untuk Mengulang]"
		lbl_preview_status.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4, 1.0))
	elif stage_num == max_unlocked:
		lbl_preview_status.text = "[TERBUKA - Klik untuk Bertarung]"
		lbl_preview_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
	else:
		lbl_preview_status.text = "[TERKUNCI - Selesaikan Stage Sebelumnya]"
		lbl_preview_status.add_theme_color_override("font_color", Color(0.85, 0.3, 0.3, 1.0))


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

	_set_node_state(1, max_unlocked, box1_tex, lbl_level1_num, badge1, btn_level1, box_holder1, Color(0.15, 0.12, 0.1, 1.0))
	_set_node_state(2, max_unlocked, box2_tex, lbl_level2_num, badge2, btn_level2, box_holder2, Color(0.15, 0.12, 0.1, 1.0))
	_set_node_state(3, max_unlocked, box3_tex, lbl_level3_num, badge3, btn_level3, box_holder3, Color(0.15, 0.12, 0.1, 1.0))
	_set_node_state(4, max_unlocked, box4_tex, lbl_level4_num, badge4, btn_level4, box_holder4, Color(0.95, 0.25, 0.1, 1.0))
	_set_node_state(5, max_unlocked, box5_tex, lbl_level5_num, badge5, btn_level5, box_holder5, Color(0.95, 0.25, 0.1, 1.0))


func _set_node_state(
	stage_num: int,
	max_unlocked: int,
	box_tex: TextureRect,
	lbl_num: Label,
	badge: Label,
	btn: Button,
	holder: Control,
	active_color: Color
) -> void:
	if stage_num < max_unlocked:
		# Cleared stage
		box_tex.modulate = Color(1.0, 1.0, 1.0, 1.0)
		lbl_num.add_theme_color_override("font_color", active_color)
		badge.visible = true
		badge.text = "✓"
		badge.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3, 1.0))
		btn.disabled = false
	elif stage_num == max_unlocked:
		# Current active stage (glowing/pulse)
		box_tex.modulate = Color(1.0, 0.95, 0.75, 1.0)
		lbl_num.add_theme_color_override("font_color", active_color)
		badge.visible = (stage_num == 5)
		if stage_num == 5:
			badge.text = "👑"
		btn.disabled = false
		_start_pulse_effect(holder)
	else:
		# Locked stage
		box_tex.modulate = Color(0.35, 0.35, 0.4, 0.6)
		lbl_num.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.5))
		badge.visible = false
		btn.disabled = true


func _start_pulse_effect(holder: Control) -> void:
	if _pulse_tween and is_instance_valid(_pulse_tween):
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(holder, "scale", Vector2(1.05, 1.05), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(holder, "scale", Vector2(1.0, 1.0), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _select_level(level: int) -> void:
	GameManager.start_battle(level)


func _on_btn_back_pressed() -> void:
	GameManager.load_scene("res://scenes/act_menu/act_menu.tscn")
