import re

with open("scenes/battle/battle_scene.gd", "r") as f:
    content = f.read()

ui_refs = """@onready var btn_winloss_restart: Button = %BtnWinLossRestart
@onready var btn_winloss_exit: Button = %BtnWinLossExit
@onready var btn_pause: Button = %BtnPause
@onready var pause_panel: PanelContainer = %PausePanel
@onready var btn_pause_resume: Button = %BtnPauseResume
@onready var btn_pause_restart: Button = %BtnPauseRestart
@onready var btn_pause_exit: Button = %BtnPauseExit
"""
content = content.replace("@onready var btn_continue: Button = %BtnContinue", "@onready var btn_continue: Button = %BtnContinue\n" + ui_refs)

connections = """
	btn_winloss_restart.pressed.connect(_on_btn_restart_pressed)
	btn_winloss_exit.pressed.connect(_on_btn_exit_pressed)
	
	btn_pause.pressed.connect(func(): 
		GameManager.play_sfx("click", -5.0)
		pause_panel.visible = true
	)
	btn_pause_resume.pressed.connect(func():
		GameManager.play_sfx("click", -5.0)
		pause_panel.visible = false
	)
	btn_pause_restart.pressed.connect(_on_btn_restart_pressed)
	btn_pause_exit.pressed.connect(_on_btn_exit_pressed)
"""
content = content.replace("btn_continue.pressed.connect(_on_btn_continue_pressed)", "btn_continue.pressed.connect(_on_btn_continue_pressed)\n" + connections)

functions = """
func _on_btn_restart_pressed() -> void:
	GameManager.play_sfx("click", -5.0)
	GameManager.load_scene("res://scenes/battle/battle_scene.tscn")

func _on_btn_exit_pressed() -> void:
	GameManager.play_sfx("click", -5.0)
	GameManager.load_scene("res://scenes/level_select/level_select.tscn")
"""
content = content.replace("func _on_btn_continue_pressed() -> void:", functions + "\nfunc _on_btn_continue_pressed() -> void:")

content = content.replace("func _on_btn_continue_pressed() -> void:\n\tif player_entity.current_hp > 0:\n\t\tGameManager.load_scene(\"res://scenes/level_select/level_select.tscn\")\n\telse:\n\t\tGameManager.reset_run()\n\t\tGameManager.load_scene(\"res://scenes/level_select/level_select.tscn\")", "func _on_btn_continue_pressed() -> void:\n\tGameManager.play_sfx(\"click\", -5.0)\n\tGameManager.load_scene(\"res://scenes/level_select/level_select.tscn\")")

with open("scenes/battle/battle_scene.gd", "w") as f:
    f.write(content)

