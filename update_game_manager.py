import re

with open("scripts/autoload/game_manager.gd", "r") as f:
    content = f.read()

# Replace black_souls.ogg with main_menu.ogg
content = content.replace("res://assets/black_souls.ogg", "res://assets/main_menu.ogg")

# Add SFX logic
sfx_logic = """
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}

func _ready() -> void:
	sfx_streams["click"] = preload("res://assets/click.ogg")
	sfx_streams["hover"] = preload("res://assets/hover.ogg")
	sfx_streams["hit"] = preload("res://assets/hit.ogg")
	sfx_streams["inspect"] = preload("res://assets/inspect_card.ogg")
	sfx_streams["game_over"] = preload("res://assets/game_over.ogg")
	sfx_streams["monster_scream"] = preload("res://assets/monster_scream.ogg")
	
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
"""

content = content.replace("var bgm_player: AudioStreamPlayer", "var bgm_player: AudioStreamPlayer\n" + sfx_logic)

play_sfx_func = """
func play_sfx(sfx_name: String, volume: float = 0.0) -> void:
	if not sfx_streams.has(sfx_name): return
	for p in sfx_players:
		if not p.playing:
			p.stream = sfx_streams[sfx_name]
			p.volume_db = volume
			p.play()
			return
	# If all full, force first one
	sfx_players[0].stream = sfx_streams[sfx_name]
	sfx_players[0].volume_db = volume
	sfx_players[0].play()
"""
content += "\n" + play_sfx_func

with open("scripts/autoload/game_manager.gd", "w") as f:
    f.write(content)
