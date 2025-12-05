extends Node

# 🗺️ MAP DIAGNOSTIC TOOL
# Add this to your game scene and run to analyze map generation

func _ready():
	print("\n================================================================================")
	print("🗺️ MAP GENERATION DIAGNOSTIC")
	print("================================================================================\n")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Find the game node - try multiple names
	var game = null
	
	# Try common names
	var possible_names = ["Game", "DieselPunk", "Main", "GameScene", "Node2D"]
	
	for name in possible_names:
		game = get_tree().root.get_node_or_null(name)
		if game:
			print("✅ Found game node: " + name)
			break
	
	# If still not found, try to find parent
	if not game:
		game = get_parent()
		if game:
			print("✅ Using parent node: " + game.name)
	
	# Last resort - search entire tree
	if not game:
		print("⚠ Searching entire scene tree...")
		game = find_game_node(get_tree().root)
	
	if not game:
		print("❌ Could not find game node!")
		print("\n🔍 Scene tree structure:")
		print_scene_tree(get_tree().root, 0)
		return
	
	print("\n--- TILEMAP INFO ---")
	
	# Check DungeonTileMap (pixel art)
	var dungeon_tilemap = game.get_node_or_null("DungeonTileMap")
	if dungeon_tilemap:
		print("✅ DungeonTileMap found")
		print("  Position: " + str(dungeon_tilemap.position))
		print("  Scale: " + str(dungeon_tilemap.scale))
		print("  Z-Index: " + str(dungeon_tilemap.z_index))
		print("  Tile size: " + str(dungeon_tilemap.tile_set.tile_size if dungeon_tilemap.tile_set else "No tileset!"))
		
		# Count tiles
		var tile_count = 0
		var tiles_by_coord = {}
		for x in range(-10, game.MAP_WIDTH + 10):
			for y in range(-10, game.MAP_HEIGHT + 10):
				var tile = dungeon_tilemap.get_cell_atlas_coords(0, Vector2i(x, y))
				if tile != Vector2i(-1, -1):
					tile_count += 1
					var tile_key = str(tile)
					if not tiles_by_coord.has(tile_key):
						tiles_by_coord[tile_key] = 0
					tiles_by_coord[tile_key] += 1
		
		print("  Total tiles drawn: " + str(tile_count))
		print("\n  Tile usage breakdown:")
		for coord in tiles_by_coord.keys():
			print("    Tile " + coord + ": " + str(tiles_by_coord[coord]) + " times")
		
		# Sample some specific tiles
		print("\n  Sample tiles:")
		print("    Tile at (0,0): " + str(dungeon_tilemap.get_cell_atlas_coords(0, Vector2i(0, 0))))
		print("    Tile at (10,10): " + str(dungeon_tilemap.get_cell_atlas_coords(0, Vector2i(10, 10))))
		print("    Tile at (20,15): " + str(dungeon_tilemap.get_cell_atlas_coords(0, Vector2i(20, 15))))
	else:
		print("❌ DungeonTileMap NOT FOUND!")
	
	print("\n--- DUNGEON DATA ---")
	if "dungeon_map" in game:
		print("✅ Dungeon map data exists")
		print("  Map size: " + str(game.MAP_WIDTH) + "x" + str(game.MAP_HEIGHT))
		
		# Count tile types
		var walls = 0
		var floors = 0
		var stairs = 0
		for x in range(game.MAP_WIDTH):
			for y in range(game.MAP_HEIGHT):
				match game.dungeon_map[x][y]:
					game.TileType.WALL:
						walls += 1
					game.TileType.FLOOR:
						floors += 1
					game.TileType.STAIRS_DOWN:
						stairs += 1
		
		print("  Walls: " + str(walls))
		print("  Floors: " + str(floors))
		print("  Stairs: " + str(stairs))
		print("  Total: " + str(walls + floors + stairs))
		
		# Check rooms
		if "rooms" in game:
			print("\n  Rooms generated: " + str(game.rooms.size()))
			for i in range(min(5, game.rooms.size())):
				var room = game.rooms[i]
				print("    Room " + str(i) + ": pos=" + str(room.position) + " size=" + str(room.size))
	
	print("\n--- TILESET ANALYSIS ---")
	if dungeon_tilemap and dungeon_tilemap.tile_set:
		var tileset = dungeon_tilemap.tile_set
		print("✅ Tileset loaded")
		print("  Sources: " + str(tileset.get_source_count()))
		
		if tileset.get_source_count() > 0:
			var source = tileset.get_source(0)
			if source is TileSetAtlasSource:
				print("  Atlas size: " + str(source.texture.get_size()) + " pixels")
				print("  Tile size: " + str(source.texture_region_size))
				
				# Count available tiles
				var atlas_width = source.texture.get_width() / source.texture_region_size.x
				var atlas_height = source.texture.get_height() / source.texture_region_size.y
				print("  Atlas grid: " + str(atlas_width) + "x" + str(atlas_height) + " = " + str(atlas_width * atlas_height) + " tiles")
	
	print("\n--- VISUAL COMPARISON ---")
	print("Let's check if tilemap matches dungeon_map data:")
	
	# Sample 5 random positions
	for i in range(5):
		var x = randi() % game.MAP_WIDTH
		var y = randi() % game.MAP_HEIGHT
		var data_type = game.dungeon_map[x][y]
		var tile_coord = dungeon_tilemap.get_cell_atlas_coords(0, Vector2i(x, y)) if dungeon_tilemap else Vector2i(-1, -1)
		
		var type_name = "?"
		match data_type:
			game.TileType.WALL:
				type_name = "WALL"
			game.TileType.FLOOR:
				type_name = "FLOOR"
			game.TileType.STAIRS_DOWN:
				type_name = "STAIRS"
		
		print("  Position (" + str(x) + "," + str(y) + "): Data=" + type_name + " Tile=" + str(tile_coord))
	
	print("\n================================================================================")
	print("📊 DIAGNOSTIC COMPLETE!")
	print("================================================================================")
	print("\n💡 WHAT TO LOOK FOR:")
	print("1. Are floor tiles showing up? (Should be lots of them)")
	print("2. Is tile (0,0) being used everywhere? (That's the void/empty tile)")
	print("3. Do the tile coordinates match what's expected?")
	print("4. Is the tileset loading correctly?")
	print("\nPlease copy ALL output above and send to Claude!\n")

func find_game_node(node):
	# Check if this node has world_to_grid method (it's the game!)
	if node.has_method("world_to_grid"):
		return node
	
	# Check children
	for child in node.get_children():
		var result = find_game_node(child)
		if result:
			return result
	
	return null

func print_scene_tree(node, indent):
	var spaces = ""
	for i in range(indent):
		spaces += "  "
	print(spaces + "- " + node.name + " (" + node.get_class() + ")")
	
	if indent < 3:  # Don't go too deep
		for child in node.get_children():
			print_scene_tree(child, indent + 1)
