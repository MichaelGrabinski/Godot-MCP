extends Node2D

# INTERACTIVE TILESET BUILDER
# You can actually place tiles and test them!

const TILE_SIZE = 32
const MAP_WIDTH = 30
const MAP_HEIGHT = 20

var debug_overlay: Node2D

enum TileType {
	WALL,
	FLOOR,
	STAIRS
}

var test_map = []

func _ready():
	# The TileMap already exists in the scene!
	# Just generate the debug overlay
	generate_simple_dungeon()
	draw_debug_overlay()
	
	print("=== INTERACTIVE BUILDER READY ===")
	print("✅ TileMap node is ready - look in Scene tree!")
	print("")
	print("HOW TO USE:")
	print("1. Select 'EditableTileMap' node in the Scene tree (left panel)")
	print("2. Click 'TileMap' tab at the BOTTOM of the screen")
	print("3. Select tiles from the tileset and paint!")
	print("   - GREEN overlay = use floor tiles")
	print("   - GRAY overlay = use wall tiles")
	print("   - GOLD overlay = use stairs tile")
	print("")
	print("CONTROLS:")
	print("- ESC = Toggle overlay visibility")
	print("- Left click = Paint selected tile")
	print("- Right click = Erase tile")
	print("")
	print("When done painting, look at the console to see what tiles you used!")

func generate_simple_dungeon():
	for x in range(MAP_WIDTH):
		test_map.append([])
		for y in range(MAP_HEIGHT):
			test_map[x].append(TileType.WALL)
	
	# Simple room
	for x in range(5, 15):
		for y in range(5, 12):
			test_map[x][y] = TileType.FLOOR
	
	# Hallway
	for x in range(15, 20):
		for y in range(8, 10):
			test_map[x][y] = TileType.FLOOR
	
	# Another room
	for x in range(20, 28):
		for y in range(6, 14):
			test_map[x][y] = TileType.FLOOR
	
	# Stairs
	test_map[25][10] = TileType.STAIRS

func draw_debug_overlay():
	debug_overlay = Node2D.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.z_index = 100  # On top
	add_child(debug_overlay)
	
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			var rect = ColorRect.new()
			rect.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			rect.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block clicks
			
			match test_map[x][y]:
				TileType.WALL:
					rect.color = Color(0.2, 0.2, 0.2, 0.3)
				TileType.FLOOR:
					rect.color = Color(0.3, 0.8, 0.3, 0.4)
				TileType.STAIRS:
					rect.color = Color(1.0, 0.8, 0.0, 0.5)
			
			debug_overlay.add_child(rect)
	
	# Add legend
	var legend = Label.new()
	legend.text = "GREEN=Floor | GRAY=Wall | GOLD=Stairs | Press ESC to toggle overlay"
	legend.position = Vector2(10, MAP_HEIGHT * TILE_SIZE + 10)
	legend.add_theme_font_size_override("font_size", 16)
	legend.add_theme_color_override("font_color", Color.WHITE)
	legend.add_theme_color_override("font_outline_color", Color.BLACK)
	legend.add_theme_constant_override("outline_size", 2)
	debug_overlay.add_child(legend)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		debug_overlay.visible = !debug_overlay.visible
		var state = "VISIBLE" if debug_overlay.visible else "HIDDEN"
		print("Overlay: " + state)
