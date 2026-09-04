extends Control

@onready var title_image:        TextureRect    = %TitleImage
@onready var btn_group:          VBoxContainer  = %BtnGroup
@onready var btn_play:           Button         = %BtnPlay
@onready var btn_credit:         Button         = %BtnCredit
@onready var btn_settings:       Button         = %BtnSettings
@onready var btn_quit:           Button         = %BtnQuit

@onready var popup_saves:        PanelContainer = %PopupSaves
@onready var popup_credits:      PanelContainer = %PopupCredits
@onready var popup_settings:     PanelContainer = %PopupSettings
@onready var btn_close_saves:    Button         = %BtnCloseSaves
@onready var btn_close_credits:  Button         = %BtnCloseCredits
@onready var btn_close_settings: Button         = %BtnCloseSettings

# Slot 1 Nodes
@onready var slot1_panel:          PanelContainer = %Slot1Panel
@onready var lbl_slot1_title:       Label          = %LblSlot1Title
@onready var center_empty1:         Label          = %CenterEmpty1
@onready var btn_delete_slot1:      Button         = %BtnDeleteSlot1
@onready var bottom_row1:           HBoxContainer  = %BottomRow1
@onready var lbl_slot1_last_opened: Label          = %LblSlot1LastOpened
@onready var lbl_slot1_created:     Label          = %LblSlot1Created
@onready var btn_slot1_click:       Button         = %BtnSlot1Click

# Slot 2 Nodes
@onready var slot2_panel:          PanelContainer = %Slot2Panel
@onready var lbl_slot2_title:       Label          = %LblSlot2Title
@onready var center_empty2:         Label          = %CenterEmpty2
@onready var btn_delete_slot2:      Button         = %BtnDeleteSlot2
@onready var bottom_row2:           HBoxContainer  = %BottomRow2
@onready var lbl_slot2_last_opened: Label          = %LblSlot2LastOpened
@onready var lbl_slot2_created:     Label          = %LblSlot2Created
@onready var btn_slot2_click:       Button         = %BtnSlot2Click

# Slot 3 Nodes
@onready var slot3_panel:          PanelContainer = %Slot3Panel
@onready var lbl_slot3_title:       Label          = %LblSlot3Title
@onready var center_empty3:         Label          = %CenterEmpty3
@onready var btn_delete_slot3:      Button         = %BtnDeleteSlot3
@onready var bottom_row3:           HBoxContainer  = %BottomRow3
@onready var lbl_slot3_last_opened: Label          = %LblSlot3LastOpened
@onready var lbl_slot3_created:     Label          = %LblSlot3Created
@onready var btn_slot3_click:       Button         = %BtnSlot3Click

var style_saved: StyleBoxFlat
var style_empty: StyleBoxFlat

var _anim_time: float = 0.0
var _title_base_pos: Vector2 = Vector2.ZERO
var _hovered_btn: Button = null
var _btn_tweens: Dictionary = {}


func _ready() -> void:
	_init_styles()
	_hide_all_popups()

	btn_play.pressed.connect(_on_btn_play_pressed)
	btn_credit.pressed.connect(_on_btn_credit_pressed)
	btn_settings.pressed.connect(_on_btn_settings_pressed)
	btn_quit.pressed.connect(_on_btn_quit_pressed)

	btn_close_saves.pressed.connect(_on_btn_close_saves_pressed)
	btn_close_credits.pressed.connect(_hide_all_popups)
	btn_close_settings.pressed.connect(_hide_all_popups)

	# Slot click bindings
	btn_slot1_click.pressed.connect(func(): _handle_slot(1))
	btn_slot2_click.pressed.connect(func(): _handle_slot(2))
	btn_slot3_click.pressed.connect(func(): _handle_slot(3))

	# Delete slot bindings
	btn_delete_slot1.pressed.connect(func(): _delete_slot(1))
	btn_delete_slot2.pressed.connect(func(): _delete_slot(2))
	btn_delete_slot3.pressed.connect(func(): _delete_slot(3))

	# Initialize visual juice
	_init_menu_juice()


func _init_menu_juice() -> void:
	# Cache base position for floating title
	if is_instance_valid(title_image):
		title_image.pivot_offset = title_image.size * 0.5
		_title_base_pos = title_image.position

	# Setup button micro-interactions
	_setup_button_juice(btn_play)
	_setup_button_juice(btn_credit)
	_setup_button_juice(btn_quit)

	# Setup settings button rotation
	if is_instance_valid(btn_settings):
		btn_settings.pivot_offset = btn_settings.size * 0.5
		btn_settings.mouse_entered.connect(func():
			var tw = create_tween().set_parallel(true)
			tw.tween_property(btn_settings, "rotation", deg_to_rad(60), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn_settings, "scale", Vector2(1.15, 1.15), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		)
		btn_settings.mouse_exited.connect(func():
			var tw = create_tween().set_parallel(true)
			tw.tween_property(btn_settings, "rotation", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(btn_settings, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		)

	# Setup close buttons hover
	for close_btn in [btn_close_saves, btn_close_credits, btn_close_settings]:
		if is_instance_valid(close_btn):
			close_btn.pivot_offset = close_btn.size * 0.5
			close_btn.mouse_entered.connect(func():
				var tw = create_tween()
				tw.tween_property(close_btn, "scale", Vector2(1.1, 1.1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			)
			close_btn.mouse_exited.connect(func():
				var tw = create_tween()
				tw.tween_property(close_btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			)

	# Setup audio slider in settings
	var h_slider: HSlider = popup_settings.find_child("HSlider", true, false)
	var audio_lbl: Label = popup_settings.find_child("AudioLabel", true, false)
	if h_slider and audio_lbl:
		h_slider.value_changed.connect(func(val: float):
			audio_lbl.text = "Volume Suara Master: %d%%" % int(val)
			var master_idx = AudioServer.get_bus_index("Master")
			if master_idx >= 0:
				if val <= 0.0:
					AudioServer.set_bus_mute(master_idx, true)
				else:
					AudioServer.set_bus_mute(master_idx, false)
					AudioServer.set_bus_volume_db(master_idx, linear_to_db(val / 100.0))
		)


func _setup_button_juice(btn: Button) -> void:
	if not is_instance_valid(btn):
		return
	btn.pivot_offset = btn.size * 0.5
	
	btn.mouse_entered.connect(func():
		_hovered_btn = btn
		if _btn_tweens.has(btn) and is_instance_valid(_btn_tweens[btn]):
			_btn_tweens[btn].kill()
		var tw = create_tween()
		tw.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_btn_tweens[btn] = tw
	)
	btn.mouse_exited.connect(func():
		if _hovered_btn == btn:
			_hovered_btn = null
		if _btn_tweens.has(btn) and is_instance_valid(_btn_tweens[btn]):
			_btn_tweens[btn].kill()
		var tw = create_tween()
		tw.tween_property(btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_btn_tweens[btn] = tw
	)
	btn.button_down.connect(func():
		if _btn_tweens.has(btn) and is_instance_valid(_btn_tweens[btn]):
			_btn_tweens[btn].kill()
		var tw = create_tween()
		tw.tween_property(btn, "scale", Vector2(0.96, 0.96), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_btn_tweens[btn] = tw
	)
	btn.button_up.connect(func():
		if _btn_tweens.has(btn) and is_instance_valid(_btn_tweens[btn]):
			_btn_tweens[btn].kill()
		var target_scale = Vector2(1.06, 1.06) if _hovered_btn == btn else Vector2.ONE
		var tw = create_tween()
		tw.tween_property(btn, "scale", target_scale, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_btn_tweens[btn] = tw
	)


func _process(delta: float) -> void:
	_anim_time += delta
	
	# Floating title animation (smooth sine hover & subtle hypnotic tilt)
	if is_instance_valid(title_image) and title_image.visible:
		title_image.position.y = _title_base_pos.y + sin(_anim_time * 1.8) * 5.0
		title_image.rotation = sin(_anim_time * 0.9) * 0.015

	# Subtle idle pulse on Primary CTA (Mulai Bermain) when not hovered
	if is_instance_valid(btn_play) and btn_play.visible and _hovered_btn != btn_play:
		var breathe = 1.0 + sin(_anim_time * 2.6) * 0.02
		btn_play.scale = Vector2(breathe, breathe)


func _init_styles() -> void:
	style_saved = StyleBoxFlat.new()
	style_saved.bg_color = Color(0.24, 0.08, 0.08, 0.88)
	style_saved.set_border_width_all(1)
	style_saved.border_color = Color(0.6, 0.22, 0.22, 0.75)
	style_saved.set_corner_radius_all(8)

	style_empty = StyleBoxFlat.new()
	style_empty.bg_color = Color(0.12, 0.12, 0.14, 0.88)
	style_empty.set_border_width_all(1)
	style_empty.border_color = Color(0.38, 0.38, 0.42, 0.55)
	style_empty.set_corner_radius_all(8)


func _hide_all_popups() -> void:
	popup_saves.visible    = false
	popup_credits.visible  = false
	popup_settings.visible = false
	if is_instance_valid(title_image):
		title_image.visible = true
	btn_group.visible      = true


func _show_popup_animated(popup: PanelContainer) -> void:
	_hide_all_popups()
	popup.visible = true
	popup.pivot_offset = popup.size * 0.5
	popup.scale = Vector2(0.92, 0.92)
	popup.modulate.a = 0.0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(popup, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(popup, "modulate:a", 1.0, 0.14)


func _on_btn_play_pressed() -> void:
	StoryData.active_save_slot = 1
	if SaveManager.has_save(1):
		SaveManager.load_game(1)
	else:
		GameManager.reset_to_act1_starter_deck()
		SaveManager.save_game(1)
	GameManager.load_scene("res://scenes/act_menu/act_menu.tscn")


func _on_btn_close_saves_pressed() -> void:
	_hide_all_popups()


func _refresh_save_slots_ui() -> void:
	_update_slot_display(1, slot1_panel, center_empty1, btn_delete_slot1, bottom_row1, lbl_slot1_last_opened, lbl_slot1_created)
	_update_slot_display(2, slot2_panel, center_empty2, btn_delete_slot2, bottom_row2, lbl_slot2_last_opened, lbl_slot2_created)
	_update_slot_display(3, slot3_panel, center_empty3, btn_delete_slot3, bottom_row3, lbl_slot3_last_opened, lbl_slot3_created)


func _format_time(raw: String) -> String:
	if raw.is_empty() or raw == "-":
		return "-"
	var s: String = raw.replace("T", " ")
	if s.length() >= 16:
		return s.substr(0, 16)
	return s


func _update_slot_display(
	slot: int,
	panel: PanelContainer,
	lbl_empty: Label,
	btn_delete: Button,
	bottom_row: HBoxContainer,
	lbl_last: Label,
	lbl_created: Label
) -> void:
	if SaveManager.has_save(slot):
		panel.add_theme_stylebox_override("panel", style_saved)
		lbl_empty.visible  = false
		btn_delete.visible = true
		bottom_row.visible = true

		var data: Dictionary = SaveManager.get_save_data(slot)
		var save_time: String    = _format_time(str(data.get("save_time", "-")))
		var created_time: String = _format_time(str(data.get("created_at", save_time)))

		lbl_last.text    = "Last opened at " + save_time
		lbl_created.text = "Created at " + created_time
	else:
		panel.add_theme_stylebox_override("panel", style_empty)
		lbl_empty.visible  = true
		btn_delete.visible = false
		bottom_row.visible = false
		lbl_empty.text     = "New Game"


func _handle_slot(slot: int) -> void:
	StoryData.active_save_slot = slot
	_hide_all_popups()

	if SaveManager.has_save(slot):
		if SaveManager.load_game(slot):
			GameManager.load_scene("res://scenes/act_menu/act_menu.tscn")
	else:
		GameManager.reset_to_act1_starter_deck()
		SaveManager.save_game(slot)
		GameManager.load_scene("res://scenes/act_menu/act_menu.tscn")


func _delete_slot(slot: int) -> void:
	SaveManager.delete_save(slot)
	_refresh_save_slots_ui()


func _on_btn_credit_pressed() -> void:
	_show_popup_animated(popup_credits)

func _on_btn_settings_pressed() -> void:
	_show_popup_animated(popup_settings)


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
