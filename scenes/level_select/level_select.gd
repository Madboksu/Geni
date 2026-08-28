extends Control

@onready var lbl_act_title: Label = %LblActTitle
@onready var container_levels: HBoxContainer = %ContainerLevels
@onready var btn_act1: Button = %BtnAct1
@onready var btn_act2: Button = %BtnAct2
@onready var btn_back: Button = %BtnBack
@onready var lbl_deck_summary: Label = %LblDeckSummary

var selected_act: int = 1

func _ready() -> void:
	selected_act = GameManager.current_act
	btn_act1.pressed.connect(func(): _switch_act(1))
	btn_act2.pressed.connect(func(): _switch_act(2))
	btn_back.pressed.connect(_on_btn_back_pressed)
	
	_update_ui()

func _switch_act(act: int) -> void:
	selected_act = act
	_update_ui()

func _update_ui() -> void:
	if selected_act == 1:
		lbl_act_title.text = "ACT 1: Lost On The Fire (Hilang Dalam Lalapan Api)"
	else:
		lbl_act_title.text = "ACT 2: Hunt the Flame (Mengejar Sang Pembakar)"
		
	# Update deck summary label
	lbl_deck_summary.text = "Deck Active (%d kartu): %s" % [GameManager.player_deck.size(), ", ".join(GameManager.player_deck)]
	
	# Render level buttons
	for child in container_levels.get_children():
		child.queue_free()
		
	var max_levels = 4 if selected_act == 1 else 8
	var max_unlocked = GameManager.act1_max_level_unlocked if selected_act == 1 else GameManager.act2_max_level_unlocked
	
	for i in range(1, max_levels + 1):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(100, 100)
		var is_unlocked = (i <= max_unlocked)
		var level_num = i
		
		if selected_act == 1 and level_num == 4:
			btn.text = "Level %d\n[ BOSS ]" % level_num
		elif selected_act == 2 and (level_num == 4 or level_num == 8):
			btn.text = "Level %d\n[ BOSS ]" % level_num
		elif level_num == 1:
			btn.text = "Level %d\n(Tutorial)" % level_num
		else:
			btn.text = "Level %d" % level_num
			
		if not is_unlocked:
			btn.disabled = true
			btn.text += "\n[ Terkunci ]"
			
		btn.pressed.connect(func(): _start_level(level_num))
		container_levels.add_child(btn)

func _start_level(level_num: int) -> void:
	GameManager.current_act = selected_act
	GameManager.current_level = level_num
	GameManager.load_scene("res://scenes/battle/battle_scene.tscn")

func _on_btn_back_pressed() -> void:
	GameManager.load_scene("res://scenes/main_menu/main_menu.tscn")
