extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	
	var in_gap = true
	var gap_start = 0
	var frames = []
	
	for x in range(w):
		var is_empty = true
		for y in range(h):
			if img.get_pixel(x, y).a > 0.1:
				is_empty = false
				break
				
		if is_empty and not in_gap:
			in_gap = true
			gap_start = x
		elif not is_empty and in_gap:
			in_gap = false
			if gap_start > 0:
				print("Gap from ", gap_start, " to ", x - 1, " (width ", x - gap_start, ")")
			var frame_start = x
			frames.append(frame_start)
			
	print("Frames start at: ", frames)
	quit()
