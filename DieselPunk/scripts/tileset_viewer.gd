extends Node2D

# Tileset Viewer Helper - Shows the tileset with grid coordinates
# Add this to a scene and run it to see all tiles labeled

var tileset_texture: Texture2D
var tile_size = 16
var scale_factor = 3  # Makes it easier to see

func _ready():
	# Load the dungeon tileset
	tileset_texture = load("res://DieselPunk/Dungeons and Pixels/Tilesets/Tileset_Dungeon.png")
	
	if not tileset_texture:
		print("ERROR: Could not load tileset!")
		return
	
	print("=== TILESET VIEWER ===")
	print("Tileset Size: " + str(tileset_texture.get_width()) + "x" + str(tileset_texture.get_height()))
	
	var tiles_wide = tileset_texture.get_width() / tile_size
	var tiles_tall = tileset_texture.get_height() / tile_size
	
	print("Tiles: " + str(tiles_wide) + "x" + str(tiles_tall))
	print("Total tiles: " + str(tiles_wide * tiles_tall))
	
	display_tileset()

func display_tileset():
	var tiles_wide = tileset_texture.get_width() / tile_size
	var tiles_tall = tileset_texture.get_height() / tile_size
	
	# Create a background
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2)
	bg.size = Vector2(tiles_wide * tile_size * scale_factor + 40, 
					  tiles_tall * tile_size * scale_factor + 40)
	bg.position = Vector2(-20, -20)
	add_child(bg)
	
	# Display each tile
	for y in range(tiles_tall):
		for x in range(tiles_wide):
			var sprite = Sprite2D.new()
			sprite.texture = tileset_texture
			sprite.region_enabled = true
			sprite.region_rect = Rect2(x * tile_size, y * tile_size, tile_size, tile_size)
			sprite.position = Vector2(x * tile_size * scale_factor + tile_size * scale_factor / 2,
									  y * tile_size * scale_factor + tile_size * scale_factor / 2)
			sprite.scale = Vector2(scale_factor, scale_factor)
			add_child(sprite)
			
			# Add coordinate label
			var label = Label.new()
			label.text = str(x) + "," + str(y)
			label.position = Vector2(x * tile_size * scale_factor, 
									 y * tile_size * scale_factor)
			label.add_theme_font_size_override("font_size", 10)
			label.add_theme_color_override("font_color", Color.YELLOW)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_constant_override("outline_size", 2)
			add_child(label)

func _input(event):
	# Press SPACE to print current mapping template
	if event.is_action_pressed("ui_accept"):
		print_mapping_template()

func print_mapping_template():
	print("\n=== COPY THIS TEMPLATE AND FILL IN ===")
	print("# Floor tiles (walkable):")
	print("FLOOR_1 = Vector2i(?, ?)")
	print("FLOOR_2 = Vector2i(?, ?)")
	print("FLOOR_3 = Vector2i(?, ?)")
	print("")
	print("# Wall tiles:")
	print("WALL_TOP = Vector2i(?, ?)")
	print("WALL_BOTTOM = Vector2i(?, ?)")
	print("WALL_LEFT = Vector2i(?, ?)")
	print("WALL_RIGHT = Vector2i(?, ?)")
	print("WALL_TOP_LEFT = Vector2i(?, ?)")
	print("WALL_TOP_RIGHT = Vector2i(?, ?)")
	print("WALL_BOTTOM_LEFT = Vector2i(?, ?)")
	print("WALL_BOTTOM_RIGHT = Vector2i(?, ?)")
	print("")
	print("# Special tiles:")
	print("STAIRS_DOWN = Vector2i(?, ?)")
	print("DOOR_CLOSED = Vector2i(?, ?)")
	print("DOOR_OPEN = Vector2i(?, ?)")
