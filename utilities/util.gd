class_name Util


static func get_random_edge_pos(pos: Vector2, vpr: Vector2) -> Vector2:
	var top_left = Vector2(pos.x - vpr.x/2, pos.y - vpr.y/2)
	var top_right = Vector2(pos.x + vpr.x/2, pos.y - vpr.y/2)
	var bottom_left = Vector2(pos.x - vpr.x/2, pos.y + vpr.y/2)
	var bottom_right = Vector2(pos.x + vpr.x/2, pos.y + vpr.y/2)
	
	var pos_side = ["top","bot","right","left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	match pos_side:
		"top":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"bot":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)
