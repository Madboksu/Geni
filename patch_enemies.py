import re

with open("scenes/battle/battle_scene.gd", "r") as f:
    content = f.read()

new_config = """func _get_level_enemy_config(act: int, level: int) -> Array:
	if act == 1:
		match level:
			1: # Level 1: 1 Grunt
				return [
					{"name": "Tree Grunt", "hp": 25, "texture": avatar_boss1_tex, "is_small": true}
				]
			2: # Level 2: 2 Grunts
				return [
					{"name": "Tree Grunt A", "hp": 25, "texture": avatar_boss1_tex, "is_small": true},
					{"name": "Tree Grunt B", "hp": 25, "texture": avatar_boss1_tex, "is_small": true}
				]
			3: # Level 3: 3 Grunts
				return [
					{"name": "Tree Grunt A", "hp": 25, "texture": avatar_boss1_tex, "is_small": true},
					{"name": "Tree Grunt B", "hp": 30, "texture": avatar_boss1_tex, "is_small": true},
					{"name": "Tree Grunt C", "hp": 25, "texture": avatar_boss1_tex, "is_small": true}
				]
			4: # Level 4: 1 Mini Boss (Tidak berapi)
				return [
					{"name": "Grown Tree Beast (MINI BOSS)", "hp": 100, "texture": avatar_boss1_tex, "is_boss": true}
				]
			5: # Level 5: 1 Boss (Berapi, Darah Lebih Banyak)
				return [
					{"name": "Ember Beast (BOSS)", "hp": 250, "sprite_frames": anim_burn_tree_boss, "is_boss": true}
				]
"""
# Replace the old func up to `else:`
import re
content = re.sub(r"func _get_level_enemy_config\(act: int, level: int\) -> Array:.*?else:", new_config + "\telse:", content, flags=re.DOTALL)

with open("scenes/battle/battle_scene.gd", "w") as f:
    f.write(content)
