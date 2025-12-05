@tool
extends Node2D

# BUILDER OVERLAY - Runs in editor!

const TILE_SIZE = 32

func _ready():
	queue_redraw()

func _draw():
	# Draw floor areas - GREEN
	draw_room(5, 5, 10, 7, Color(0.3, 0.8, 0.3, 0.5))
	draw_room(15, 8, 5, 2, Color(0.3, 0.8, 0.3, 0.5))
	draw_room(20, 6, 8, 8, Color(0.3, 0.8, 0.3, 0.5))
	
	# Draw stairs - GOLD
	draw_rect(Rect2(25 * TILE_SIZE, 10 * TILE_SIZE, TILE_SIZE, TILE_SIZE), Color(1.0, 0.8, 0.0, 0.7))
	
	# Draw grid lines
	for x in range(30):
		draw_line(Vector2(x * TILE_SIZE, 0), Vector2(x * TILE_SIZE, 20 * TILE_SIZE), Color(0.3, 0.3, 0.3, 0.3), 1)
	for y in range(20):
		draw_line(Vector2(0, y * TILE_SIZE), Vector2(30 * TILE_SIZE, y * TILE_SIZE), Color(0.3, 0.3, 0.3, 0.3), 1)

func draw_room(x: int, y: int, w: int, h: int, color: Color):
	for i in range(w):
		for j in range(h):
			var pos = Vector2((x + i) * TILE_SIZE, (y + j) * TILE_SIZE)
			draw_rect(Rect2(pos, Vector2(TILE_SIZE - 2, TILE_SIZE - 2)), color)
