extends Node

# Dungeon Visual Builder - ONLY NORTH WALLS ARE 2-TILES!

class_name DungeonVisuals

const AssetLoader = preload("res://DieselPunk/scripts/asset_loader.gd")
const TilesetConfig = preload("res://DieselPunk/scripts/tileset_config.gd")

static func create_tilemap(game) -> TileMap:
	var tilemap = TileMap.new()
	tilemap.name = "DungeonTileMap"
	tilemap.tile_set = create_tileset()
	tilemap.z_index = -10
	tilemap.scale = Vector2(2, 2)
	return tilemap

static func create_tileset() -> TileSet:
	var tileset = TileSet.new()
	var texture = AssetLoader.load_tileset()
	if not texture:
		print("⚠ Could not load dungeon tileset!")
		return tileset
	
	tileset.tile_size = Vector2i(16, 16)
	
	var atlas = TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(16, 16)
	
	var atlas_width = texture.get_width() / 16
	var atlas_height = texture.get_height() / 16
	
	for y in range(atlas_height):
		for x in range(atlas_width):
			atlas.create_tile(Vector2i(x, y))
	
	tileset.add_source(atlas, 0)
	print("✅ Tileset created: " + str(atlas_width) + "x" + str(atlas_height) + " tiles")
	return tileset

static func draw_dungeon_tiles(tilemap: TileMap, game):
	if not tilemap or not tilemap.tile_set:
		print("⚠ No tilemap or tileset!")
		return
	
	tilemap.clear()
	print("🎨 Drawing dungeon...")
	
	# Fill outside bounds with void
	for x in range(-5, game.MAP_WIDTH + 5):
		for y in range(-5, game.MAP_HEIGHT + 5):
			if x < 0 or x >= game.MAP_WIDTH or y < 0 or y >= game.MAP_HEIGHT:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	
	# Draw floors first
	for x in range(game.MAP_WIDTH):
		for y in range(game.MAP_HEIGHT):
			var tile_type = game.dungeon_map[x][y]
			
			if tile_type == game.TileType.FLOOR:
				var floor_tile = TilesetConfig.get_random_floor_tile()
				tilemap.set_cell(0, Vector2i(x, y), 0, floor_tile)
			elif tile_type == game.TileType.STAIRS_DOWN:
				tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.STAIRS)
	
	# Draw walls second
	for x in range(game.MAP_WIDTH):
		for y in range(game.MAP_HEIGHT):
			var tile_type = game.dungeon_map[x][y]
			
			if tile_type == game.TileType.WALL:
				draw_wall_at_position(tilemap, game, x, y)
	
	print("✅ Dungeon drawn - Only north walls are 2-tiles!")

# ✅ FIXED: Only north walls use 2 tiles, all others are single tiles!
static func draw_wall_at_position(tilemap: TileMap, game, x: int, y: int):
	var north = get_tile_type(game, x, y - 1)
	var south = get_tile_type(game, x, y + 1)
	var east = get_tile_type(game, x + 1, y)
	var west = get_tile_type(game, x - 1, y)
	
	var floor_below = (south == game.TileType.FLOOR or south == game.TileType.STAIRS_DOWN)
	var floor_above = (north == game.TileType.FLOOR or north == game.TileType.STAIRS_DOWN)
	var floor_right = (east == game.TileType.FLOOR or east == game.TileType.STAIRS_DOWN)
	var floor_left = (west == game.TileType.FLOOR or west == game.TileType.STAIRS_DOWN)
	
	# ============== NORTH WALLS (2-TILES ONLY!) ==============
	# Check if this is part of a north wall (has floor below somewhere)
	if floor_below:
		# This wall has floor directly below it - it's a north wall!
		var wall_above = (y > 0 and game.dungeon_map[x][y - 1] == game.TileType.WALL)
		var north_wall = TilesetConfig.get_random_north_wall()
		
		if wall_above:
			# We're the BOTTOM part of a 2-tile north wall
			tilemap.set_cell(0, Vector2i(x, y), 0, north_wall[1])
		else:
			# We're a single-tile north wall, use top part
			tilemap.set_cell(0, Vector2i(x, y), 0, north_wall[0])
		return
	
	# Check if we're the TOP part of a 2-tile north wall
	var tile_below_has_floor = false
	if y < game.MAP_HEIGHT - 1:
		var tile_2_below = get_tile_type(game, x, y + 2)
		tile_below_has_floor = (tile_2_below == game.TileType.FLOOR or tile_2_below == game.TileType.STAIRS_DOWN)
	
	if tile_below_has_floor:
		# We're the TOP part of a 2-tile north wall
		var north_wall = TilesetConfig.get_random_north_wall()
		tilemap.set_cell(0, Vector2i(x, y), 0, north_wall[0])
		return
	
	# ============== OTHER WALLS (SINGLE TILE ONLY!) ==============
	
	# BOTTOM WALL (floor above) - SINGLE TILE
	if floor_above:
		tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.get_random_bottom_wall())
		return
	
	# LEFT WALL (floor to right) - SINGLE TILE
	if floor_right and not floor_left:
		tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.get_random_left_wall())
		return
	
	# RIGHT WALL (floor to left) - SINGLE TILE  
	if floor_left and not floor_right:
		tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.get_random_right_wall())
		return
	
	# Check 2 tiles away for nearby rooms
	var floor_2_below = get_tile_type(game, x, y + 2) == game.TileType.FLOOR
	var floor_2_above = get_tile_type(game, x, y - 2) == game.TileType.FLOOR
	var floor_2_right = get_tile_type(game, x + 2, y) == game.TileType.FLOOR
	var floor_2_left = get_tile_type(game, x - 2, y) == game.TileType.FLOOR
	
	# These are all SINGLE TILES (no 2-tile stacking for non-north walls!)
	if floor_2_above:
		tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.get_random_bottom_wall())
		return
	if floor_2_right:
		tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.get_random_left_wall())
		return
	if floor_2_left:
		tilemap.set_cell(0, Vector2i(x, y), 0, TilesetConfig.get_random_right_wall())
		return
	
	# Interior wall - use void tile
	tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

static func get_tile_type(game, x: int, y: int):
	if x < 0 or x >= game.MAP_WIDTH or y < 0 or y >= game.MAP_HEIGHT:
		return game.TileType.WALL
	return game.dungeon_map[x][y]

static func add_dungeon_props(game):
	var props_texture = AssetLoader.load_props_tileset()
	if not props_texture:
		return
	
	var props_added = 0
	for x in range(game.MAP_WIDTH):
		for y in range(game.MAP_HEIGHT):
			if game.dungeon_map[x][y] == game.TileType.FLOOR:
				if randf() < 0.02:
					add_prop_sprite(game, Vector2(x, y) * game.TILE_SIZE, props_texture)
					props_added += 1
	
	print("✅ Added " + str(props_added) + " props")

static func add_prop_sprite(game, position: Vector2, texture: Texture2D):
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = position + Vector2(16, 16)
	sprite.z_index = -5
	
	var region_size = 16
	var regions_x = max(1, texture.get_width() / region_size)
	var regions_y = max(1, texture.get_height() / region_size)
	
	var random_x = randi() % int(regions_x)
	var random_y = randi() % int(regions_y)
	
	sprite.region_enabled = true
	sprite.region_rect = Rect2(random_x * region_size, random_y * region_size, region_size, region_size)
	sprite.scale = Vector2(2, 2)
	
	game.add_child(sprite)

static func create_fog_overlay(game) -> Node2D:
	var fog_container = Node2D.new()
	fog_container.name = "FogOfWar"
	fog_container.z_index = 50
	
	print("🌫️ Creating fog overlay...")
	
	var fog_image = Image.create(game.TILE_SIZE, game.TILE_SIZE, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color(0, 0, 0, 1.0))
	var fog_texture = ImageTexture.create_from_image(fog_image)
	
	for x in range(game.MAP_WIDTH):
		for y in range(game.MAP_HEIGHT):
			var fog_tile = Sprite2D.new()
			fog_tile.name = "Fog_" + str(x) + "_" + str(y)
			fog_tile.texture = fog_texture
			fog_tile.position = Vector2(x * game.TILE_SIZE + game.TILE_SIZE/2, y * game.TILE_SIZE + game.TILE_SIZE/2)
			fog_tile.z_index = 50
			fog_container.add_child(fog_tile)
	
	print("✅ Fog of war created with " + str(game.MAP_WIDTH * game.MAP_HEIGHT) + " tiles (FULL DENSITY)")
	return fog_container

static func update_fog(game, fog_container: Node2D):
	if not fog_container:
		return
	
	for x in range(game.MAP_WIDTH):
		for y in range(game.MAP_HEIGHT):
			var fog_tile = fog_container.get_node_or_null("Fog_" + str(x) + "_" + str(y))
			if fog_tile:
				if game.explored_tiles[x][y]:
					fog_tile.visible = false
				else:
					fog_tile.visible = true
