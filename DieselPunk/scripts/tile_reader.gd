extends Control

# Tile Reader - EXPANDED to read ALL tiles including out-of-bounds!

@onready var output_label = $Panel/ScrollContainer/OutputLabel

func _ready():
	print("\n=== READING ALL TILES (INCLUDING OUT-OF-BOUNDS) ===\n")
	
	var scene = load("res://DieselPunk/scenes/interactive_builder.tscn")
	if not scene:
		output_label.text = "ERROR: Could not load interactive_builder.tscn"
		return
	
	var root = scene.instantiate()
	var tilemap = root.get_node_or_null("EditableTileMap")
	
	if not tilemap:
		output_label.text = "ERROR: No EditableTileMap found"
		root.queue_free()
		return
	
	# Read ALL tiles (expanded range to include out-of-bounds)
	var all_tiles = {}
	
	# Read from -10 to 50 in both directions to catch everything
	for x in range(-10, 50):
		for y in range(-10, 40):
			var tile_data = tilemap.get_cell_atlas_coords(0, Vector2i(x, y))
			if tile_data != Vector2i(-1, -1):  # Valid tile
				var key = str(tile_data)
				if not all_tiles.has(key):
					all_tiles[key] = {
						"coord": tile_data,
						"positions": [],
						"count": 0
					}
				all_tiles[key]["positions"].append(Vector2i(x, y))
				all_tiles[key]["count"] += 1
	
	# Organize by region
	var in_bounds_tiles = {}
	var out_of_bounds_tiles = {}
	
	for key in all_tiles.keys():
		var tile_info = all_tiles[key]
		var coord = tile_info["coord"]
		
		for pos in tile_info["positions"]:
			# Check if position is in original game bounds (0-39, 0-29)
			if pos.x >= 0 and pos.x < 40 and pos.y >= 0 and pos.y < 30:
				if not in_bounds_tiles.has(key):
					in_bounds_tiles[key] = {"coord": coord, "positions": []}
				in_bounds_tiles[key]["positions"].append(pos)
			else:
				if not out_of_bounds_tiles.has(key):
					out_of_bounds_tiles[key] = {"coord": coord, "positions": []}
				out_of_bounds_tiles[key]["positions"].append(pos)
	
	# Build output
	var output = ""
	
	output += "=== TILES INSIDE GAME BOUNDS (0-39, 0-29) ===\n\n"
	for key in in_bounds_tiles.keys():
		var info = in_bounds_tiles[key]
		output += "Tile " + str(info["coord"]) + ": " + str(info["positions"].size()) + " uses\n"
		output += "  Positions: " + str(info["positions"]) + "\n\n"
	
	output += "\n=== TILES OUTSIDE BOUNDS (Out-of-bounds area) ===\n\n"
	for key in out_of_bounds_tiles.keys():
		var info = out_of_bounds_tiles[key]
		output += "Tile " + str(info["coord"]) + ": " + str(info["positions"].size()) + " uses\n"
		output += "  Sample positions: "
		var sample = info["positions"].slice(0, 5)  # Show first 5
		output += str(sample) + "\n\n"
	
	output += "\n=== SUMMARY ===\n"
	output += "Total unique tiles: " + str(all_tiles.size()) + "\n"
	output += "In-bounds unique tiles: " + str(in_bounds_tiles.size()) + "\n"
	output += "Out-of-bounds unique tiles: " + str(out_of_bounds_tiles.size()) + "\n"
	
	output_label.text = output
	print(output)
	
	root.queue_free()
