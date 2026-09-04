import re

with open("scenes/battle/battle_scene.gd", "r") as f:
    content = f.read()

# Define functions
funcs = """
func _setup_particles() -> void:
	var dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0, 0, 0, 0.4)
	dimmer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dimmer)
	move_child(dimmer, 0)

	var p = CPUParticles2D.new()
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(640, 10)
	p.position = Vector2(640, -20)
	p.direction = Vector2(0, 1)
	p.spread = 20.0
	p.gravity = Vector2(0, 50)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 60.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 3.0
	p.color = Color(1.0, 0.5, 0.2, 0.6)
	
	if GameManager.current_level == 5:
		p.amount = 150
		p.color = Color(1.0, 0.3, 0.1, 0.8)
		p.gravity = Vector2(0, 80)
		p.scale_amount_max = 5.0
	else:
		p.amount = 40
		
	# Add smoke
	var s = CPUParticles2D.new()
	s.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	s.emission_rect_extents = Vector2(640, 10)
	s.position = Vector2(640, -20)
	s.direction = Vector2(0, 1)
	s.gravity = Vector2(0, 30)
	s.initial_velocity_min = 10.0
	s.initial_velocity_max = 30.0
	s.scale_amount_min = 4.0
	s.scale_amount_max = 12.0
	s.color = Color(0.2, 0.2, 0.2, 0.3)
	if GameManager.current_level == 5:
		s.amount = 80
	else:
		s.amount = 20
		
	add_child(p)
	add_child(s)
	move_child(p, 0)
	move_child(s, 0)

func _setup_combat_log() -> void:
	if get_node_or_null("%LblBattleLog"): get_node("%LblBattleLog").visible = false
	
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
	
	combat_log_panel.custom_minimum_size = Vector2(250, 150)
	combat_log_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	combat_log_panel.position = Vector2(get_viewport_rect().size.x - 260, 10)
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
		combat_log_text.add_theme_font_size_override("normal_font_size", 10)
	margin.add_child(combat_log_text)
	
	add_child(combat_log_panel)

func _log(msg: String) -> void:
	print(msg)
	if combat_log_text:
		combat_log_text.append_text(msg + "\\n")
"""

content = content.replace("func _log(msg: String) -> void:\n\tlbl_battle_log.text = msg", funcs)

with open("scenes/battle/battle_scene.gd", "w") as f:
    f.write(content)
