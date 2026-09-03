extends Control

@onready var btn_continue:        Button         = %BtnContinue
@onready var btn_new_game:        Button         = %BtnNewGame
@onready var btn_credit:          Button         = %BtnCredit
@onready var btn_settings:        Button         = %BtnSettings
@onready var btn_quit:            Button         = %BtnQuit

@onready var popup_saves:         PanelContainer = %PopupSaves
@onready var popup_credits:       PanelContainer = %PopupCredits
@onready var popup_settings:      PanelContainer = %PopupSettings

@onready var btn_save_slot1:      Button         = %BtnSaveSlot1
@onready var btn_save_slot2:      Button         = %BtnSaveSlot2
@onready var btn_save_slot3:      Button         = %BtnSaveSlot3
@onready var btn_close_saves:     Button         = %BtnCloseSaves
@onready var btn_close_credits:   Button         = %BtnCloseCredits
@onready var btn_close_settings:  Button         = %BtnCloseSettings

# true = pilih slot untuk New Game | false = pilih slot untuk Continue
var _selecting_new_game: bool = false


func _ready() -> void:
	_hide_all_popups()

	btn_continue.pressed.connect(_on_btn_continue_pressed)
	btn_new_game.pressed.connect(_on_btn_new_game_pressed)
	btn_credit.pressed.connect(_on_btn_credit_pressed)
	btn_settings.pressed.connect(_on_btn_settings_pressed)
	btn_quit.pressed.connect(_on_btn_quit_pressed)

	btn_save_slot1.pressed.connect(func(): _handle_slot(1))
	btn_save_slot2.pressed.connect(func(): _handle_slot(2))
	btn_save_slot3.pressed.connect(func(): _handle_slot(3))

	btn_close_saves.pressed.connect(_hide_all_popups)
	btn_close_credits.pressed.connect(_hide_all_popups)
	btn_close_settings.pressed.connect(_hide_all_popups)


func _hide_all_popups() -> void:
	popup_saves.visible   = false
	popup_credits.visible = false
	popup_settings.visible = false


func _on_btn_continue_pressed() -> void:
	_selecting_new_game = false
	_refresh_save_slots_ui()
	popup_saves.visible = true


func _on_btn_new_game_pressed() -> void:
	_selecting_new_game = true
	_refresh_save_slots_ui()
	popup_saves.visible = true


func _refresh_save_slots_ui() -> void:
	var slots := [btn_save_slot1, btn_save_slot2, btn_save_slot3]
	for i in range(3):
		var slot_num := i + 1
		var btn: Button = slots[i]
		if SaveManager.has_save(slot_num):
			var info := _read_save_time(slot_num)
			if _selecting_new_game:
				btn.text = "Slot %d: Ada Save\n⚠️ Akan ditimpa!\n%s" % [slot_num, info]
			else:
				btn.text = "Slot %d: Lanjutkan\n%s" % [slot_num, info]
			btn.disabled = false
		else:
			if _selecting_new_game:
				btn.text = "Slot %d: Kosong\n(Mulai Baru)" % slot_num
				btn.disabled = false
			else:
				# Lanjutkan → slot kosong tidak bisa dipilih
				btn.text = "Slot %d: Kosong" % slot_num
				btn.disabled = true


func _read_save_time(slot: int) -> String:
	var path := SaveManager.get_save_path(slot)
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		var json := JSON.new()
		if json.parse(content) == OK:
			var data = json.get_data()
			return str(data.get("save_time", ""))
	return ""


func _handle_slot(slot: int) -> void:
	StoryData.active_save_slot = slot
	_hide_all_popups()

	if _selecting_new_game:
		# New Game: reset semua lalu mulai dari cutscene
		GameManager.reset_to_act1_starter_deck()
		SaveManager.save_game(slot)
		GameManager.load_scene("res://scenes/cutscene/story_cutscene.tscn")
	else:
		# Continue: muat save — slot kosong tidak seharusnya sampai sini (disabled),
		# tapi tambah guard kalau-kalau ada edge case
		if SaveManager.load_game(slot):
			GameManager.load_scene("res://scenes/level_select/level_select.tscn")
		else:
			# Slot tiba-tiba tidak bisa dibaca (corrupt/hilang) — refresh UI saja
			_refresh_save_slots_ui()
			popup_saves.visible = true


func _on_btn_credit_pressed() -> void:
	_hide_all_popups()
	popup_credits.visible = true


func _on_btn_settings_pressed() -> void:
	_hide_all_popups()
	popup_settings.visible = true


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
