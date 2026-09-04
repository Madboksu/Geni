with open("scenes/battle/components/entity_ui.gd", "r") as f: content = f.read()

# Variables
vars = """
var block_bar: ProgressBar
"""
content = content.replace("var current_sprite_frames: SpriteFrames", "var current_sprite_frames: SpriteFrames\n" + vars)

# Setup in _ready
setup = """
func _ready() -> void:
	block_bar = ProgressBar.new()
	block_bar.custom_minimum_size = Vector2(0, 8)
	block_bar.show_percentage = false
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = Color(0.4, 0.6, 0.9, 1.0)
	block_bar.add_theme_stylebox_override("background", style_bg)
	block_bar.add_theme_stylebox_override("fill", style_fill)
	
	# Add below hp_bar
	if get_node_or_null("VBoxContainer/HpBar"):
		get_node("VBoxContainer").add_child(block_bar)
		get_node("VBoxContainer").move_child(block_bar, get_node("VBoxContainer/HpBar").get_index() + 1)
	elif hp_bar:
		hp_bar.get_parent().add_child(block_bar)
	
	_update_ui()
"""
content = content.replace("func _ready() -> void:\n\t_update_ui()", setup)

# Update UI
content = content.replace("lbl_block.text = \"Block: %d\" % entity_data.current_block", "lbl_block.text = \"Block: %d\" % entity_data.current_block\n\tif block_bar:\n\t\tblock_bar.max_value = entity_data.max_hp\n\t\tblock_bar.value = entity_data.current_block")

# Block Changed sound
block_changed = """func _on_block_changed(new_block: int) -> void:
	if block_bar: block_bar.value = new_block
	if new_block > 0 and lbl_block.text != ("Block: %d" % new_block):
		GameManager.play_sfx("click", -5.0) # Sound for gaining shield
	lbl_block.text = "Block: %d" % new_block
"""
content = content.replace("func _on_block_changed(new_block: int) -> void:\n\tlbl_block.text = \"Block: %d\" % new_block", block_changed)

with open("scenes/battle/components/entity_ui.gd", "w") as f: f.write(content)
