extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	
	var in_gap = true
	var gap_start = 0
	
	var frame_bounds = []
	var current_min = -1
	var current_max = -1
	
	for x in range(w):
		var is_empty = true
		for y in range(h):
			if img.get_pixel(x, y).a > 0.1:
				is_empty = false
				break
				
		if is_empty and not in_gap:
			in_gap = true
			gap_start = x
			if x - current_min > 50: # If it's a small gap (particle), ignore. If it's a real frame end, the gap will be large.
				pass
		elif not is_empty and in_gap:
			in_gap = false
			if gap_start > 0 and (x - gap_start) > 25: # Gap is large enough to be a frame separator!
				if current_min != -1:
					frame_bounds.append([current_min, current_max])
				current_min = x
				current_max = x
			else:
				if current_min == -1: current_min = x
				current_max = x
		elif not is_empty:
			current_max = x
			
	if current_min != -1:
		frame_bounds.append([current_min, current_max])
		
	print("Found ", frame_bounds.size(), " frames: ", frame_bounds)
	
	for i in range(frame_bounds.size()):
		var bounds = frame_bounds[i]
		var frame_w = bounds[1] - bounds[0] + 1
		
		# We want all frames to be exactly 430x360
		var final_img = Image.create(430, 360, false, img.get_format())
		
		# Paste the frame exactly in the middle of 430
		var paste_x = (430 - frame_w) / 2
		final_img.blit_rect(img, Rect2(bounds[0], 0, frame_w, 360), Vector2(paste_x, 0))
		
		final_img.save_png("res://assets/monsters/burn_tree_boss/frame_%d.png" % i)
		print("Saved frame ", i, " width ", frame_w, " at x=", paste_x)
		
	quit()
