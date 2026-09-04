extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	print("W: ", w, " H: ", h)
	
	# Let's check typical frame counts: 8, 9, 10
	print("w/8 = ", float(w)/8)
	print("w/9 = ", float(w)/9)
	print("w/10 = ", float(w)/10)
	print("w/12 = ", float(w)/12)
	quit()
