extends Node2D

# DEBUG OVERLAY - Shows what tiles are being used WHERE

@tool

const TILE_SIZE = 32

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if not Engine.is_editor_hint():
		return
	
	# Draw a sample of how tiles will be placed
	var floor_color = Color(0.3, 0.8, 0.3, 0.4)
	var wall_color = Color(0.6, 0.3, 0.3, 0.4)
	
	# Sample room
	for x in range(5, 15):
		for y in range(5, 12):
			draw_rect(Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE-2, TILE_SIZE-2), floor_color)
	
	# North walls (should be 2 tiles high)
	for x in range(5, 15):
		draw_rect(Rect2(x * TILE_SIZE, 4 * TILE_SIZE, TILE_SIZE-2, TILE_SIZE-2), wall_color)
		draw_rect(Rect2(x * TILE_SIZE, 3 * TILE_SIZE, TILE_SIZE-2, TILE_SIZE-2), wall_color.darkened(0.2))
	
	# Side walls
	for y in range(5, 12):
		draw_rect(Rect2(4 * TILE_SIZE, y * TILE_SIZE, TILE_SIZE-2, TILE_SIZE-2), wall_color)
		draw_rect(Rect2(15 * TILE_SIZE, y * TILE_SIZE, TILE_SIZE-2, TILE_SIZE-2), wall_color)
	
	# Bottom wall
	for x in range(5, 15):
		draw_rect(Rect2(x * TILE_SIZE, 12 * TILE_SIZE, TILE_SIZE-2, TILE_SIZE-2), wall_color)
