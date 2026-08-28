extends Control

@onready var btn_continue: Button = %BtnContinue
@onready var btn_new_game: Button = %BtnNewGame
@onready var btn_credit: Button = %BtnCredit
@onready var btn_settings: Button = %BtnSettings
@onready var btn_quit: Button = %BtnQuit

@onready var popup_saves: PanelContainer = %PopupSaves
@onready var popup_credits: PanelContainer = %PopupCredits
@onready var popup_settings: PanelContainer = %PopupSettings

@onready var btn_save_slot1: Button = %BtnSaveSlot1
@onready var btn_save_slot2: Button = %BtnSaveSlot2
@onready var btn_save_slot3: Button = %BtnSaveSlot3
@onready var btn_close_saves: Button = %BtnCloseSaves
@onready var btn_close_credits: Button = %BtnCloseCredits
@onready var btn_close_settings: Button = %BtnCloseSettings

var selecting_save_for_new_game: bool = false

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
	popup_saves.visible = false
	popup_credits.visible = false
	popup_settings.visible = false

func _on_btn_continue_pressed() -> void:
	selecting_save_for_new_game = false
	_refresh_save_slots_ui()
	popup_saves.visible = true

func _on_btn_new_game_pressed() -> void:
	selecting_save_for_new_game = true
	_refresh_save_slots_ui()
	popup_saves.visible = true

func _refresh_save_slots_ui() -> void:
	btn_save_slot1.text = "Slot 1: " + ("Ada Progress" if SaveManager.has_save(1) else "Kosong")
	btn_save_slot2.text = "Slot 2: " + ("Ada Progress" if SaveManager.has_save(2) else "Kosong")
	btn_save_slot3.text = "Slot 3: " + ("Ada Progress" if SaveManager.has_save(3) else "Kosong")

func _handle_slot(slot: int) -> void:
	StoryData.active_save_slot = slot
	if selecting_save_for_new_game:
		GameManager.reset_to_act1_starter_deck()
		SaveManager.save_game(slot)
		GameManager.load_scene("res://scenes/cutscene/story_cutscene.tscn")
	else:
		if SaveManager.load_game(slot):
			GameManager.load_scene("res://scenes/level_select/level_select.tscn")
		else:
			# If slot empty, start new game cutscene
			GameManager.reset_to_act1_starter_deck()
			SaveManager.save_game(slot)
			GameManager.load_scene("res://scenes/cutscene/story_cutscene.tscn")

func _on_btn_credit_pressed() -> void:
	_hide_all_popups()
	popup_credits.visible = true

func _on_btn_settings_pressed() -> void:
	_hide_all_popups()
	popup_settings.visible = true

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
