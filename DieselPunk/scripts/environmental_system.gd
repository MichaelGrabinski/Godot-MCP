extends Node

# Environmental System - Secret rooms, breakable walls, hazards

class_name EnvironmentalSystem

enum EnvironmentType {
	SECRET_ROOM,
	BREAKABLE_WALL,
	LAVA_POOL,
	SPIKE_FLOOR,
	HEALING_FOUNTAIN,
	SHRINE,
	CURSED_ALTAR
}

class EnvironmentFeature:
	var type: EnvironmentType
	var position: Vector2i
	var discovered: bool = false
	var used: bool = false
	var data: Dictionary = {}
	
	func _init(t: EnvironmentType, pos: Vector2i):
		type = t
		position = pos

static func generate_secret_room_position(rooms: Array) -> Vector2i:
	if rooms.size() < 2:
		return Vector2i(-1, -1)
	
	# Pick a random room
	var room = rooms[randi() % rooms.size()]
	
	# Place secret room adjacent to a wall
	var walls = [
		Vector2i(int(room.position.x - 1), int(room.position.y + room.size.y / 2)),  # Left
		Vector2i(int(room.position.x + room.size.x), int(room.position.y + room.size.y / 2)),  # Right
		Vector2i(int(room.position.x + room.size.x / 2), int(room.position.y - 1)),  # Top
		Vector2i(int(room.position.x + room.size.x / 2), int(room.position.y + room.size.y)),  # Bottom
	]
	
	return walls[randi() % walls.size()]

static func create_breakable_wall(map: Array, rooms: Array) -> EnvironmentFeature:
	# Find a wall between two floor tiles
	for x in range(1, map.size() - 1):
		for y in range(1, map[0].size() - 1):
			if map[x][y] == 0:  # Wall
				var neighbors = 0
				if map[x-1][y] == 1: neighbors += 1  # Floor to left
				if map[x+1][y] == 1: neighbors += 1  # Floor to right
				if map[x][y-1] == 1: neighbors += 1  # Floor above
				if map[x][y+1] == 1: neighbors += 1  # Floor below
				
				if neighbors >= 2 and randi() % 100 < 15:  # 15% chance
					var feature = EnvironmentFeature.new(EnvironmentType.BREAKABLE_WALL, Vector2i(x, y))
					feature.data["health"] = 3
					return feature
	
	return null

static func create_hazard_pool(room: Rect2, hazard_type: EnvironmentType) -> Array:
	var pools = []
	var pool_count = randi() % 3 + 1
	
	for i in range(pool_count):
		var x = int(room.position.x) + randi() % int(room.size.x)
		var y = int(room.position.y) + randi() % int(room.size.y)
		
		var feature = EnvironmentFeature.new(hazard_type, Vector2i(x, y))
		
		match hazard_type:
			EnvironmentType.LAVA_POOL:
				feature.data["damage"] = 10
				feature.data["color"] = Color(1.0, 0.3, 0.0)
			EnvironmentType.SPIKE_FLOOR:
				feature.data["damage"] = 8
				feature.data["color"] = Color(0.5, 0.5, 0.5)
		
		pools.append(feature)
	
	return pools

static func create_healing_fountain(room: Rect2) -> EnvironmentFeature:
	var x = int(room.position.x + room.size.x / 2)
	var y = int(room.position.y + room.size.y / 2)
	
	var feature = EnvironmentFeature.new(EnvironmentType.HEALING_FOUNTAIN, Vector2i(x, y))
	feature.data["heal_amount"] = 50
	feature.data["uses"] = 1
	feature.data["color"] = Color(0.3, 0.7, 1.0)
	
	return feature

static func create_shrine(room: Rect2, floor: int) -> EnvironmentFeature:
	var x = int(room.position.x + room.size.x / 2)
	var y = int(room.position.y + room.size.y / 2)
	
	var feature = EnvironmentFeature.new(EnvironmentType.SHRINE, Vector2i(x, y))
	feature.data["blessing_type"] = randi() % 5  # 5 different blessings
	feature.data["color"] = Color(1.0, 0.9, 0.6)
	
	return feature

static func create_cursed_altar(room: Rect2) -> EnvironmentFeature:
	var x = int(room.position.x + room.size.x / 2)
	var y = int(room.position.y + room.size.y / 2)
	
	var feature = EnvironmentFeature.new(EnvironmentType.CURSED_ALTAR, Vector2i(x, y))
	feature.data["curse_power"] = randi() % 3 + 1  # Risk/reward level
	feature.data["color"] = Color(0.6, 0.1, 0.8)
	
	return feature

static func get_shrine_blessing_description(blessing_type: int) -> String:
	match blessing_type:
		0:
			return "Blessing of Strength: +5 Attack permanently"
		1:
			return "Blessing of Vitality: +30 Max HP permanently"
		2:
			return "Blessing of Protection: +3 Defense permanently"
		3:
			return "Blessing of Fortune: Find better loot"
		4:
			return "Blessing of Experience: +100% XP for next 5 floors"
		_:
			return "Unknown Blessing"

static func get_cursed_altar_description(power: int) -> String:
	match power:
		1:
			return "Minor Curse: -10 HP, Gain +3 Attack"
		2:
			return "Moderate Curse: -20 HP, Gain Rare Item"
		3:
			return "Major Curse: -30 HP, Gain Legendary Item"
		_:
			return "Unknown Curse"
