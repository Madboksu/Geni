extends SceneTree

func _init():
	var dir = DirAccess.open("res://assets/")
	if not dir.dir_exists("monsters/burn_tree_boss"):
		dir.make_dir_recursive("monsters/burn_tree_boss")
		
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	var frames_count = 8
	var fw = w / frames_count
	
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 4.0)
	
	for i in range(frames_count):
		var frame_img = Image.create(fw, h, false, img.get_format())
		frame_img.blit_rect(img, Rect2(i * fw, 0, fw, h), Vector2.ZERO)
		var frame_path = "res://assets/monsters/burn_tree_boss/frame_%d.png" % i
		frame_img.save_png(frame_path)
		
		# Create an external texture resource instead of embedding the image data
		var tex = ImageTexture.create_from_image(frame_img)
		ResourceSaver.save(tex, "res://assets/monsters/burn_tree_boss/frame_%d.tex" % i) # Optional, or just use the png
		
		var atlas = AtlasTexture.new()
		# Wait, we can just point to the png file after saving it!
		
	print("Extracted to PNGs")
	quit()
