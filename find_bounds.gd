extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	
	var min_x = w
	var max_x = -1
	for x in range(w):
		for y in range(h):
			if img.get_pixel(x, y).a > 0.1:
				if x < min_x: min_x = x
				if x > max_x: max_x = x
				
	print("Image bounds: [", min_x, ", ", max_x, "]")
	quit()
