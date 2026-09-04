extends SceneTree

func _init():
	var sf = ResourceLoader.load("res://assets/burn-tree-boss.tres")
	sf.set_animation_speed("idle", 4.0)
	ResourceSaver.save(sf, "res://assets/burn-tree-boss.tres")
	print("Changed speed to 4.0")
	quit()
