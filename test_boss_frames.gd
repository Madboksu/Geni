extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	print("Size: ", w, "x", h)
	
	for count in range(4, 15):
		if w % count != 0:
			continue
		var slice_w = w / count
		print("Trying ", count, " frames (width ", slice_w, "):")
		
		for i in range(count):
			var left = i * slice_w
			var min_x = slice_w
			var max_x = -1
			for y in range(h):
				for x in range(slice_w):
					var c = img.get_pixel(left + x, y)
					if c.a > 0.1:
						if x < min_x: min_x = x
						if x > max_x: max_x = x
			if max_x >= 0:
				var center = float(min_x + max_x) / 2.0
				print("  Frame ", i, ": center=", center, " [", min_x, ",", max_x, "]")
			else:
				print("  Frame ", i, ": empty")
	quit()
