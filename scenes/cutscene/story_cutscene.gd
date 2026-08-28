extends Control

@onready var lbl_speaker: Label = %LblSpeaker
@onready var lbl_dialogue: Label = %LblDialogue
@onready var name_input_box: PanelContainer = %NameInputBox
@onready var input_name: LineEdit = %InputName
@onready var btn_confirm_name: Button = %BtnConfirmName
@onready var btn_next: Button = %BtnNext
@onready var btn_skip: Button = %BtnSkip

var current_dialogue_index: int = 0
var dialogues: Array = []

func _ready() -> void:
	name_input_box.visible = false
	dialogues = StoryData.PROLOGUE_DIALOGUES
	
	btn_next.pressed.connect(_on_btn_next_pressed)
	btn_skip.pressed.connect(_on_btn_skip_pressed)
	btn_confirm_name.pressed.connect(_on_btn_confirm_name_pressed)
	
	_show_dialogue(0)

func _show_dialogue(index: int) -> void:
	if index >= dialogues.size():
		_finish_cutscene()
		return
		
	var d = dialogues[index]
	var speaker_text = d["speaker"].replace("{PLAYER_NAME}", GameManager.player_name)
	var dialogue_text = d["text"].replace("{PLAYER_NAME}", GameManager.player_name)
	
	lbl_speaker.text = speaker_text
	lbl_dialogue.text = dialogue_text
	
	# Prompt player name input at character introduction (index 2)
	if index == 2 and GameManager.player_name == "Banyu":
		name_input_box.visible = true

func _on_btn_next_pressed() -> void:
	if name_input_box.visible:
		return # Wait for player name confirmation
	current_dialogue_index += 1
	_show_dialogue(current_dialogue_index)

func _on_btn_skip_pressed() -> void:
	_finish_cutscene()

func _on_btn_confirm_name_pressed() -> void:
	var typed_name = input_name.text.strip_edges()
	if typed_name != "":
		GameManager.player_name = typed_name
	name_input_box.visible = false
	_show_dialogue(current_dialogue_index)

func _finish_cutscene() -> void:
	GameManager.load_scene("res://scenes/level_select/level_select.tscn")
