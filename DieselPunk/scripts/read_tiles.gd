extends Node

# Reads what tiles you painted in interactive_builder

func read_painted_tiles():
	var scene = load("res://DieselPunk/scenes/interactive_builder.tscn")
	if not scene:
		print("ERROR: Could not load scene")
		return
	
	var root = scene.instantiate()
	var tilemap = root.get_node_or_null("EditableTileMap")
	
	if not tilemap:
		print("ERROR: No EditableTileMap found")
		return
	
	print("=== READING YOUR PAINTED TILES ===")
	print("")
	
	var floor_tiles = {}
	var wall_tiles = {}
	var stairs_tiles = {}
	
	# Check the test area coordinates
	# Floors: (5-15, 5-12), (15-20, 8-10), (20-28, 6-14)
	# Stairs: (25, 10)
	
	for x in range(40):
		for y in range(30):
			var cell = tilemap.get_cell_atlas_coords(0, Vector2i(x, y))
			
			if cell != Vector2i(-1, -1):
				var coord_str = "(" + str(cell.x) + "," + str(cell.y) + ")"
				
				# Check if it's in a floor area
				var is_floor_area = false
				if (x >= 5 and x < 15 and y >= 5 and y < 12):
					is_floor_area = true
				elif (x >= 15 and x < 20 and y >= 8 and y < 10):
					is_floor_area = true
				elif (x >= 20 and x < 28 and y >= 6 and y < 14):
					is_floor_area = true
				
				# Check if it's stairs
				if x == 25 and y == 10:
					if stairs_tiles.has(coord_str):
						stairs_tiles[coord_str] += 1
					else:
						stairs_tiles[coord_str] = 1
				elif is_floor_area:
					if floor_tiles.has(coord_str):
						floor_tiles[coord_str] += 1
					else:
						floor_tiles[coord_str] = 1
				else:
					if wall_tiles.has(coord_str):
						wall_tiles[coord_str] += 1
					else:
						wall_tiles[coord_str] = 1
	
	print("FLOOR TILES (painted on green areas):")
	for tile in floor_tiles.keys():
		print("  " + tile + " used " + str(floor_tiles[tile]) + " times")
	
	print("\nWALL TILES (painted on gray areas):")
	for tile in wall_tiles.keys():
		print("  " + tile + " used " + str(wall_tiles[tile]) + " times")
	
	print("\nSTAIRS TILES (painted on gold area):")
	for tile in stairs_tiles.keys():
		print("  " + tile + " used " + str(stairs_tiles[tile]) + " times")
	
	print("\n=== SUMMARY ===")
	print("Tell Claude:")
	print("FLOOR = " + str(floor_tiles.keys()))
	print("WALL = " + str(wall_tiles.keys()))
	print("STAIRS = " + str(stairs_tiles.keys()))
