extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/burn-tree-boss.png")
	var w = img.get_width()
	var h = img.get_height()
	
	var fw = 327
	var start_x = 95
	var count = 10
	
	for i in range(count):
		var left = start_x + i * fw
		var col_sums = []
		for x in range(fw):
			var sum = 0.0
			for y in range(h):
				if left + x < w:
					var a = img.get_pixel(left + x, y).a
					if a > 0.1:
						sum += 1.0
			col_sums.append(sum)
			
		var total_alpha = 0.0
		var weighted_sum = 0.0
		for x in range(fw):
			total_alpha += col_sums[x]
			weighted_sum += col_sums[x] * x
			
		var center = weighted_sum / total_alpha if total_alpha > 0 else fw / 2.0
		print("  Frame ", i, " center: ", center)
		
	quit()
