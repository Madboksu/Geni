extends Node

var player_name: String = "Banyu"
var current_act: int = 1
var current_level: int = 1

var act1_max_level_unlocked: int = 5
var act2_max_level_unlocked: int = 5

var player_max_hp: int = 50
var player_current_hp: int = 50

# Player's current active deck list (array of card IDs)
var player_deck: Array = []

var bgm_player: AudioStreamPlayer
var battle_bgm: AudioStream = preload("res://assets/lawan_monster.ogg")
var boss_bgm: AudioStream = preload("res://assets/boss.ogg")
var menu_bgm: AudioStream = preload("res://assets/main_menu.ogg")

var sfx_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}

func _ready() -> void:
	sfx_streams["click"] = preload("res://assets/click.ogg")
	sfx_streams["hover"] = preload("res://assets/hover.ogg")
	sfx_streams["hit"] = preload("res://assets/hit.ogg")
	sfx_streams["get_hit"] = preload("res://assets/get_hit.ogg")
	sfx_streams["inspect"] = preload("res://assets/inspect_card.ogg")
	sfx_streams["game_over"] = preload("res://assets/game_over.ogg")
	sfx_streams["monster_scream"] = preload("res://assets/monster_scream.ogg")
	
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

	reset_to_act1_starter_deck()
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = preload("res://assets/main_menu.ogg")
	bgm_player.volume_db = -80.0 # Start silent
	bgm_player.autoplay = true
	add_child(bgm_player)
	
	# Fade in from -80 dB to -10 dB over 3.5 seconds
	var tw = create_tween()
	tw.tween_property(bgm_player, "volume_db", -10.0, 3.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func reset_to_act1_starter_deck() -> void:
	# Starter deck according to Act 1 GDD specification + new test cards
	player_deck = [
		"dewblade", "dewblade",
		"root_shield", "root_shield",
		"douse", "douse",
		"cooling_mud", "cooling_mud",
		"gale_wind",
		"thunder_strike",
		"whirlwind",
		"rain_dance",
		"blood_pact",
		"droughts_end",
		"broken_axe",
		"medkit"
	]
	player_max_hp = 50
	player_current_hp = 50
	current_act = 1
	current_level = 1
	act1_max_level_unlocked = 5
	act2_max_level_unlocked = 5

## Reset HP saja setelah kalah — deck dan unlock TETAP tersimpan
func reset_run() -> void:
	player_current_hp = player_max_hp

func add_card_to_deck(card_id: String) -> void:
	player_deck.append(card_id)

func unlock_next_level() -> void:
	if current_act == 1:
		act1_max_level_unlocked = max(act1_max_level_unlocked, current_level + 1)
		if act1_max_level_unlocked > 5:
			# Act 1 Complete -> Unlock Act 2
			current_act = 2
			act2_max_level_unlocked = max(act2_max_level_unlocked, 1)
	elif current_act == 2:
		act2_max_level_unlocked = max(act2_max_level_unlocked, current_level + 1)

	if StoryData.active_save_slot > 0:
		SaveManager.save_game(StoryData.active_save_slot)

func get_max_unlocked_level() -> int:
	return 5

func start_battle(level: int) -> void:
	current_level = level
	if level == 1:
		reset_run()
	load_scene("res://scenes/battle/battle_scene.tscn")

func load_scene(scene_path: String) -> void:
	if "battle_scene" in scene_path:
		play_battle_bgm(current_level == 3) # level 3 is boss
	elif "cutscene" in scene_path:
		stop_menu_bgm()
	else:
		play_menu_bgm()
		
	get_tree().change_scene_to_file(scene_path)

func play_menu_bgm() -> void:
	if bgm_player.stream != menu_bgm:
		bgm_player.stream = menu_bgm
		bgm_player.play()
	elif not bgm_player.playing:
		bgm_player.play()
	
	var tw = create_tween()
	tw.tween_property(bgm_player, "volume_db", -10.0, 2.0).set_trans(Tween.TRANS_QUAD)

func stop_menu_bgm() -> void:
	if bgm_player.playing:
		var tw = create_tween()
		tw.tween_property(bgm_player, "volume_db", -80.0, 1.5).set_trans(Tween.TRANS_QUAD)
		tw.tween_callback(bgm_player.stop)

func play_battle_bgm(is_boss: bool) -> void:
	var target_stream = boss_bgm if is_boss else battle_bgm
	if bgm_player.stream != target_stream:
		bgm_player.stream = target_stream
		bgm_player.play()
	elif not bgm_player.playing:
		bgm_player.play()
	
	var tw = create_tween()
	tw.tween_property(bgm_player, "volume_db", -10.0, 2.0).set_trans(Tween.TRANS_QUAD)


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
