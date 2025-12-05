extends Node

# Dungeon Tileset Configuration - Based on YOUR painted tiles!

class_name TilesetConfig

# FLOORS - All the tiles you painted on green areas (x2-9, y2-7)
const FLOOR_TILES = [
	Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4), Vector2i(2, 5), Vector2i(2, 6), Vector2i(2, 7),
	Vector2i(3, 2), Vector2i(3, 3), Vector2i(3, 4), Vector2i(3, 5), Vector2i(3, 6), Vector2i(3, 7),
	Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4), Vector2i(4, 5), Vector2i(4, 6), Vector2i(4, 7),
	Vector2i(5, 2), Vector2i(5, 3), Vector2i(5, 4), Vector2i(5, 5), Vector2i(5, 6), Vector2i(5, 7),
	Vector2i(6, 2), Vector2i(6, 3), Vector2i(6, 4), Vector2i(6, 5), Vector2i(6, 6), Vector2i(6, 7),
	Vector2i(7, 2), Vector2i(7, 3), Vector2i(7, 4), Vector2i(7, 5), Vector2i(7, 6), Vector2i(7, 7),
	Vector2i(8, 2), Vector2i(8, 3), Vector2i(8, 4), Vector2i(8, 5), Vector2i(8, 6), Vector2i(8, 7),
	Vector2i(9, 2), Vector2i(9, 3), Vector2i(9, 4), Vector2i(9, 5), Vector2i(9, 6), Vector2i(9, 7)
]

# WALLS - North walls (top parts and bottom parts)
const WALL_NORTH_TOPS = [
	Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), 
	Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0)
]

const WALL_NORTH_BOTTOMS = [
	Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
	Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1)
]

# WALLS - Left side (x1, various y)
const WALL_LEFT = [
	Vector2i(1, 2), Vector2i(1, 3), Vector2i(1, 4), Vector2i(1, 5),
	Vector2i(1, 6), Vector2i(1, 7), Vector2i(1, 8)
]

# WALLS - Right side (x10, various y)
const WALL_RIGHT = [
	Vector2i(10, 2), Vector2i(10, 3), Vector2i(10, 4), Vector2i(10, 5),
	Vector2i(10, 6), Vector2i(10, 7), Vector2i(10, 8)
]

# WALLS - Bottom (y8)
const WALL_BOTTOM = [
	Vector2i(2, 8), Vector2i(3, 8), Vector2i(4, 8), Vector2i(5, 8),
	Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8), Vector2i(9, 8)
]

# CORNERS
const CORNER_TOP_LEFT_TOP = Vector2i(1, 0)
const CORNER_TOP_LEFT_BOTTOM = Vector2i(1, 1)
const CORNER_TOP_RIGHT_TOP = Vector2i(10, 0)
const CORNER_TOP_RIGHT_BOTTOM = Vector2i(10, 1)

# STAIRS
const STAIRS = Vector2i(12, 6)

# Get random floor tile with variety
static func get_random_floor_tile() -> Vector2i:
	return FLOOR_TILES[randi() % FLOOR_TILES.size()]

# Get random north wall (returns array of [top, bottom])
static func get_random_north_wall() -> Array:
	var idx = randi() % WALL_NORTH_TOPS.size()
	return [WALL_NORTH_TOPS[idx], WALL_NORTH_BOTTOMS[idx]]

# Get random left wall
static func get_random_left_wall() -> Vector2i:
	return WALL_LEFT[randi() % WALL_LEFT.size()]

# Get random right wall
static func get_random_right_wall() -> Vector2i:
	return WALL_RIGHT[randi() % WALL_RIGHT.size()]

# Get random bottom wall
static func get_random_bottom_wall() -> Vector2i:
	return WALL_BOTTOM[randi() % WALL_BOTTOM.size()]
