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


func _on_btn_play_pressed() -> void:
	btn_group.visible      = false
	_refresh_save_slots_ui()
	popup_saves.visible    = true


func _on_btn_close_saves_pressed() -> void:
	popup_saves.visible    = false
	btn_group.visible      = true


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
	_hide_all_popups()
	popup_credits.visible = true


func _on_btn_settings_pressed() -> void:
	_hide_all_popups()
	popup_settings.visible = true


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
