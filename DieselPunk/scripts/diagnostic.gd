extends Node

# 🔍 DIAGNOSTIC SCRIPT - Run this to help debug issues!
# This will collect info about fog positioning and map rendering

func _ready():
	print("\n" + "="*60)
	print("🔍 DIESELPUNK DIAGNOSTIC SCRIPT")
	print("="*60 + "\n")
	
	await get_tree().process_frame
	
	# Get the game node
	var game = get_tree().root.get_node_or_null("Game")
	if not game:
		print("❌ Could not find Game node!")
		print("Searching for game-like nodes...")
		search_for_game_node(get_tree().root)
		return
	
	print("✅ Found Game node\n")
	
	# Check fog layer
	print("--- FOG OF WAR CHECK ---")
	var fog = game.get_node_or_null("FogOfWar")
	if fog:
		print("✅ Fog layer exists: " + str(fog))
		print("  Type: " + fog.get_class())
		print("  Position: " + str(fog.position))
		print("  Z-Index: " + str(fog.z_index))
		print("  Children count: " + str(fog.get_child_count()))
		
		if fog.get_child_count() > 0:
			var first_fog = fog.get_child(0)
			print("  First fog tile: " + first_fog.name)
			print("  First fog position: " + str(first_fog.position))
			print("  First fog size: " + str(first_fog.size if first_fog.has_method("get_size") or "size" in first_fog else "N/A"))
			print("  First fog visible: " + str(first_fog.visible))
		
		# Check if fog tiles match explored tiles
		var explored_count = 0
		var hidden_count = 0
		for child in fog.get_children():
			if not child.visible:
				explored_count += 1
			else:
				hidden_count += 1
		print("  Explored tiles (fog hidden): " + str(explored_count))
		print("  Unexplored tiles (fog visible): " + str(hidden_count))
	else:
		print("❌ Fog layer NOT FOUND!")
		print("Looking for fog in game children...")
		for child in game.get_children():
			if "fog" in child.name.to_lower():
				print("  Found fog-like node: " + child.name)
	
	print("\n--- MAP/TILEMAP CHECK ---")
	
	# Check tilemaps
	var tilemap = game.get_node_or_null("DungeonMap")
	if tilemap:
		print("✅ DungeonMap exists")
		print("  Type: " + tilemap.get_class())
		print("  Position: " + str(tilemap.position))
		print("  Scale: " + str(tilemap.scale))
		print("  Z-Index: " + str(tilemap.z_index))
	else:
		print("❌ DungeonMap NOT FOUND")
	
	var dungeon_tilemap = game.get_node_or_null("DungeonTileMap")
	if dungeon_tilemap:
		print("✅ DungeonTileMap (pixel art) exists")
		print("  Type: " + dungeon_tilemap.get_class())
		print("  Position: " + str(dungeon_tilemap.position))
		print("  Scale: " + str(dungeon_tilemap.scale))
		print("  Z-Index: " + str(dungeon_tilemap.z_index))
		print("  Tile set: " + ("Yes" if dungeon_tilemap.tile_set else "No"))
		
		if dungeon_tilemap.tile_set:
			print("  Tile size: " + str(dungeon_tilemap.tile_set.tile_size))
	else:
		print("❌ DungeonTileMap (pixel art) NOT FOUND")
	
	print("\n--- PLAYER CHECK ---")
	var player = game.get_node_or_null("Player")
	if player:
		print("✅ Player exists")
		print("  Position: " + str(player.position))
		print("  Grid position: " + str(game.world_to_grid(player.position)))
		print("  Z-Index: " + str(player.z_index))
	else:
		print("❌ Player NOT FOUND")
	
	print("\n--- SCENE TREE ---")
	print("Game children:")
	for child in game.get_children():
		print("  - " + child.name + " (" + child.get_class() + ")")
		if child.get_child_count() > 0 and child.get_child_count() < 20:
			for subchild in child.get_children():
				print("    - " + subchild.name + " (" + subchild.get_class() + ")")
	
	print("\n--- CAMERA/VIEWPORT INFO ---")
	var viewport = get_viewport()
	if viewport:
		print("✅ Viewport size: " + str(viewport.get_visible_rect().size))
		var camera = viewport.get_camera_2d()
		if camera:
			print("✅ Camera exists")
			print("  Position: " + str(camera.position))
			print("  Zoom: " + str(camera.zoom))
		else:
			print("⚠ No Camera2D found")
	
	print("\n--- DUNGEON DATA ---")
	if "dungeon_map" in game:
		print("✅ Dungeon map exists")
		print("  Size: " + str(game.MAP_WIDTH) + "x" + str(game.MAP_HEIGHT))
		print("  Current floor: " + str(game.current_floor))
	
	if "explored_tiles" in game:
		var explored = 0
		for x in range(game.MAP_WIDTH):
			for y in range(game.MAP_HEIGHT):
				if game.explored_tiles[x][y]:
					explored += 1
		print("  Explored tiles: " + str(explored) + "/" + str(game.MAP_WIDTH * game.MAP_HEIGHT))
	
	print("\n" + "="*60)
	print("📊 DIAGNOSTIC COMPLETE!")
	print("="*60)
	print("\nPlease copy ALL the output above and send it to Claude!")
	print("This will help diagnose the fog and map issues.\n")

func search_for_game_node(node):
	for child in node.get_children():
		if child.has_method("world_to_grid") or "game" in child.name.to_lower():
			print("  Found potential game node: " + child.name + " (" + child.get_class() + ")")
		search_for_game_node(child)
