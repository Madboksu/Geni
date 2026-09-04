extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	if not img:
		print("Failed to load image")
		quit()
		return
		
	var tex = ImageTexture.create_from_image(img)
	
	var h = img.get_height()
	var w = img.get_width()
	var frames_count = w / h
	
	print("Size: ", w, "x", h, " -> frames: ", frames_count)
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 8.0)
	
	for i in range(frames_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * h, 0, h, h)
		sprite_frames.add_frame("idle", atlas)
		
	var err = ResourceSaver.save(sprite_frames, "res://assets/burn-tree-boss.tres")
	if err == OK:
		print("Saved burn-tree-boss.tres")
	else:
		print("Error saving: ", err)
		
	quit()
