import re

with open("scenes/battle/battle_scene.gd", "r") as f:
    content = f.read()

# Add combat log variables
log_vars = """
var combat_log_panel: PanelContainer
var combat_log_text: RichTextLabel
"""
content = content.replace("var is_executing: bool = false", "var is_executing: bool = false\n" + log_vars)

# Add setup_combat_log in _ready
setup_call = "\t_setup_combat_log()\n\t_start_player_turn()"
content = content.replace("\t_start_player_turn()", setup_call, 1) # Only first occurrence in _ready

# Inject _setup_combat_log
log_setup = """
func _setup_combat_log() -> void:
	if lbl_info: lbl_info.visible = false
	
	combat_log_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.14, 0.85)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.6, 0.2, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	combat_log_panel.add_theme_stylebox_override("panel", style)
	
	combat_log_panel.custom_minimum_size = Vector2(200, 150)
	combat_log_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	combat_log_panel.position = Vector2(get_viewport_rect().size.x - 210, 10)
	combat_log_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	combat_log_panel.add_child(margin)
	
	combat_log_text = RichTextLabel.new()
	combat_log_text.scroll_following = true
	combat_log_text.bbcode_enabled = true
	combat_log_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font:
		combat_log_text.add_theme_font_override("normal_font", font)
		combat_log_text.add_theme_font_size_override("normal_font_size", 9)
	margin.add_child(combat_log_text)
	
	# Add on top of background but behind UI
	add_child(combat_log_panel)

func _log(msg: String) -> void:
	print(msg)
	if combat_log_text:
		combat_log_text.append_text(msg + "\\n")
"""
content = content.replace("func _log(msg: String) -> void:\n\tprint(msg)\n\tif lbl_info:\n\t\tlbl_info.text = msg", log_setup)

with open("scenes/battle/battle_scene.gd", "w") as f:
    f.write(content)
