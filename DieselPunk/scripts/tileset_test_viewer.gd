extends Node2D

# TILESET TEST SCENE - Shows the actual tileset with coordinates
# This will help us see what tiles are where!

func _ready():
	# Load the tileset
	var texture = load("res://DieselPunk/Dungeons and Pixels/Tilesets/Tileset_Dungeon.png")
	
	if not texture:
		print("ERROR: Could not load tileset!")
		return
	
	var tile_size = 16
	var scale_factor = 4  # Make it big so we can see
	
	var tiles_wide = texture.get_width() / tile_size
	var tiles_tall = texture.get_height() / tile_size
	
	print("=== TILESET VIEWER ===")
	print("Texture: " + str(texture.get_width()) + "x" + str(texture.get_height()))
	print("Tiles: " + str(tiles_wide) + "x" + str(tiles_tall))
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1)
	bg.size = Vector2(tiles_wide * tile_size * scale_factor + 40, 
					  tiles_tall * tile_size * scale_factor + 40)
	bg.position = Vector2(10, 10)
	add_child(bg)
	
	# Display each tile with coordinates
	for y in range(tiles_tall):
		for x in range(tiles_wide):
			# Create sprite for this tile
			var sprite = Sprite2D.new()
			sprite.texture = texture
			sprite.region_enabled = true
			sprite.region_rect = Rect2(x * tile_size, y * tile_size, tile_size, tile_size)
			sprite.position = Vector2(
				20 + x * tile_size * scale_factor + (tile_size * scale_factor / 2),
				20 + y * tile_size * scale_factor + (tile_size * scale_factor / 2)
			)
			sprite.scale = Vector2(scale_factor, scale_factor)
			add_child(sprite)
			
			# Add grid lines
			var line_h = ColorRect.new()
			line_h.color = Color(0.3, 0.3, 0.3)
			line_h.size = Vector2(tile_size * scale_factor, 1)
			line_h.position = Vector2(20 + x * tile_size * scale_factor, 
									  20 + y * tile_size * scale_factor)
			add_child(line_h)
			
			var line_v = ColorRect.new()
			line_v.color = Color(0.3, 0.3, 0.3)
			line_v.size = Vector2(1, tile_size * scale_factor)
			line_v.position = Vector2(20 + x * tile_size * scale_factor,
									  20 + y * tile_size * scale_factor)
			add_child(line_v)
			
			# Add coordinate label
			var label = Label.new()
			label.text = str(x) + "," + str(y)
			label.position = Vector2(
				20 + x * tile_size * scale_factor + 2,
				20 + y * tile_size * scale_factor + 2
			)
			label.add_theme_font_size_override("font_size", 12)
			label.add_theme_color_override("font_color", Color.YELLOW)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_constant_override("outline_size", 3)
			add_child(label)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "TILESET VIEWER - Note the coordinates of tiles you want to use\nPress SPACE to print a template"
	instructions.position = Vector2(20, tiles_tall * tile_size * scale_factor + 50)
	instructions.add_theme_font_size_override("font_size", 16)
	instructions.add_theme_color_override("font_color", Color.WHITE)
	add_child(instructions)

func _input(event):
	if event.is_action_pressed("ui_accept"):  # SPACE key
		print("\n=== COPY THIS AND FILL IN THE COORDINATES ===")
		print("# FLOORS (walkable tiles):")
		print("FLOOR_1 = Vector2i(?, ?)")
		print("FLOOR_2 = Vector2i(?, ?)")
		print("")
		print("# WALLS:")
		print("WALL_TOP = Vector2i(?, ?)")
		print("WALL_BOTTOM = Vector2i(?, ?)")
		print("WALL_LEFT = Vector2i(?, ?)")
		print("WALL_RIGHT = Vector2i(?, ?)")
		print("")
		print("# CORNERS:")
		print("CORNER_TOP_LEFT = Vector2i(?, ?)")
		print("CORNER_TOP_RIGHT = Vector2i(?, ?)")
		print("")
		print("# SPECIAL:")
		print("STAIRS = Vector2i(?, ?)")
