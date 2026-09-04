import re

with open("scenes/battle/battle_scene.gd", "r") as f:
    content = f.read()

particles = """
func _setup_particles() -> void:
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
"""

content = content.replace("func _setup_combat_log() -> void:", particles + "\nfunc _setup_combat_log() -> void:")
content = content.replace("\t_setup_combat_log()", "\t_setup_particles()\n\t_setup_combat_log()")

with open("scenes/battle/battle_scene.gd", "w") as f:
    f.write(content)
