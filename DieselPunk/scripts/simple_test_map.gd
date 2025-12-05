extends Node2D

# SIMPLE TEST MAP - Color-coded walkable path, NO tileset
# This helps us understand the dungeon structure

const TILE_SIZE = 32
const MAP_WIDTH = 30
const MAP_HEIGHT = 20

enum TileType {
	WALL,
	FLOOR,
	STAIRS
}

var test_map = []

func _ready():
	generate_simple_dungeon()
	draw_debug_dungeon()

func generate_simple_dungeon():
	# Initialize
	for x in range(MAP_WIDTH):
		test_map.append([])
		for y in range(MAP_HEIGHT):
			test_map[x].append(TileType.WALL)
	
	# Create a simple room
	for x in range(5, 15):
		for y in range(5, 12):
			test_map[x][y] = TileType.FLOOR
	
	# Create a hallway
	for x in range(15, 20):
		for y in range(8, 10):
			test_map[x][y] = TileType.FLOOR
	
	# Another room
	for x in range(20, 28):
		for y in range(6, 14):
			test_map[x][y] = TileType.FLOOR
	
	# Add stairs
	test_map[25][10] = TileType.STAIRS

func draw_debug_dungeon():
	# Draw using simple colored rectangles
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			var rect = ColorRect.new()
			rect.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			rect.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			
			match test_map[x][y]:
				TileType.WALL:
					rect.color = Color(0.2, 0.2, 0.2, 0.5)  # Dark gray, semi-transparent
				TileType.FLOOR:
					rect.color = Color(0.3, 0.8, 0.3, 0.8)  # Green - WALKABLE
				TileType.STAIRS:
					rect.color = Color(1.0, 0.8, 0.0, 0.9)  # Gold - STAIRS
			
			add_child(rect)
			
			# Add coordinate labels
			var label = Label.new()
			label.text = str(x) + "," + str(y)
			label.position = Vector2(x * TILE_SIZE + 2, y * TILE_SIZE + 2)
			label.add_theme_font_size_override("font_size", 8)
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_constant_override("outline_size", 1)
			add_child(label)
	
	# Add legend
	var legend = VBoxContainer.new()
	legend.position = Vector2(10, MAP_HEIGHT * TILE_SIZE + 20)
	add_child(legend)
	
	var title = Label.new()
	title.text = "LEGEND:"
	title.add_theme_font_size_override("font_size", 16)
	legend.add_child(title)
	
	var wall_label = Label.new()
	wall_label.text = "■ Dark Gray = WALL (blocked)"
	wall_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	legend.add_child(wall_label)
	
	var floor_label = Label.new()
	floor_label.text = "■ Green = FLOOR (walkable)"
	floor_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	legend.add_child(floor_label)
	
	var stairs_label = Label.new()
	stairs_label.text = "■ Gold = STAIRS"
	stairs_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	legend.add_child(stairs_label)
	
	var instructions = Label.new()
	instructions.text = "\nNow you can manually place tiles from the tileset on top of this!\nGreen = walkable floor tiles\nDark = wall tiles"
	instructions.add_theme_font_size_override("font_size", 14)
	legend.add_child(instructions)

	print("=== TEST MAP GENERATED ===")
	print("Green areas = Where floor tiles should go")
	print("Dark areas = Where wall tiles should go")
	print("This map structure is visible - now overlay with tileset manually!")
