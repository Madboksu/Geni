extends Node

const SAVE_PATH_FORMAT = "user://save_slot_%d.json"

func get_save_path(slot: int) -> String:
	return SAVE_PATH_FORMAT % slot

func save_game(slot: int) -> bool:
	var data = {
		"player_name":    GameManager.player_name,
		"current_act":    GameManager.current_act,
		"current_level":  GameManager.current_level,
		"act1_max_level": GameManager.act1_max_level_unlocked,
		"act2_max_level": GameManager.act2_max_level_unlocked,
		"player_max_hp":  GameManager.player_max_hp,
		"player_hp":      GameManager.player_current_hp,
		"player_deck":    GameManager.player_deck,
		"save_time":      Time.get_datetime_string_from_system()
	}

	var file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		return true
	return false

func load_game(slot: int) -> bool:
	var path = get_save_path(slot)
	if not FileAccess.file_exists(path):
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(content) == OK:
			var data = json.get_data()
			GameManager.player_name               = data.get("player_name",    "Banyu")
			GameManager.current_act               = int(data.get("current_act",    1))
			GameManager.current_level             = int(data.get("current_level",  1))
			GameManager.act1_max_level_unlocked   = int(data.get("act1_max_level", 1))
			GameManager.act2_max_level_unlocked   = int(data.get("act2_max_level", 1))
			GameManager.player_max_hp             = int(data.get("player_max_hp",  50))
			# current_hp: gunakan nilai tersimpan, atau fallback ke max HP
			GameManager.player_current_hp = int(data.get("player_hp", GameManager.player_max_hp))
			if data.has("player_deck"):
				GameManager.player_deck = Array(data.get("player_deck"))
			return true
	return false

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))

func delete_save(slot: int) -> void:
	var path = get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
