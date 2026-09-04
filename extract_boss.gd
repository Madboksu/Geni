extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	# Assuming 10 frames (344 width) or 8 frames (430 width)
	# Let's extract 430x360 just to be safe
	var frame = Image.create(430, 360, false, img.get_format())
	frame.blit_rect(img, Rect2(0, 0, 430, 360), Vector2(0, 0))
	frame.save_png("res://assets/burn-tree-boss-static.png")
	print("Saved static frame")
	quit()
