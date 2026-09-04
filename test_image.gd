extends SceneTree

func _init():
	var img = Image.new()
	img.load("res://assets/tree-bos.png")

	var width = img.get_width()
	var height = img.get_height()
	
	var non_transparent_cols = []
	for x in range(width):
		var has_pixels = false
		for y in range(height):
			if img.get_pixel(x, y).a > 0.1:
				has_pixels = true
				break
		if has_pixels:
			non_transparent_cols.append(x)
	
	var segments = []
	if non_transparent_cols.size() > 0:
		var start = non_transparent_cols[0]
		var prev = start
		for i in range(1, non_transparent_cols.size()):
			var col = non_transparent_cols[i]
			if col > prev + 5: # Gap
				segments.append([start, prev])
				start = col
			prev = col
		segments.append([start, prev])
	
	var max_width = 0
	for seg in segments:
		var w = seg[1] - seg[0] + 1
		if w > max_width:
			max_width = w
	
	# Let's make the canvas max_width + 10 x height
	var canvas_width = max_width + 20
	print("Max width is ", max_width, ", canvas will be ", canvas_width)
	
	var dir = DirAccess.open("res://assets/monsters/tree_boss")
	if not dir:
		DirAccess.make_dir_absolute("res://assets/monsters/tree_boss")
		
	for i in range(segments.size()):
		var s = segments[i][0]
		var e = segments[i][1]
		var w = e - s + 1
		
		# Create new image
		var frame_img = Image.create(canvas_width, height, false, img.get_format())
		
		# Copy region
		var src_rect = Rect2i(s, 0, w, height)
		var dst_x = (canvas_width - w) / 2
		frame_img.blit_rect(img, src_rect, Vector2i(dst_x, 0))
		
		var out_path = "res://assets/monsters/tree_boss/frame_" + str(i) + ".png"
		frame_img.save_png(out_path)
		print("Saved ", out_path)
		
	quit()
