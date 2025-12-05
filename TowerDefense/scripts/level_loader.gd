# res://TowerDefense/scripts/level_loader.gd
extends RefCounted
class_name LevelLoader

# Helper to robustly extract a Vector2 from different JSON shapes
static func _extract_vec2(data: Dictionary, key: String, default: Vector2) -> Vector2:
	if not data.has(key):
		return default

	var v = data[key]
	var t = typeof(v)

	# 1) [x, y]
	if t == TYPE_ARRAY:
		var arr = v
		if arr.size() >= 2:
			return Vector2(float(arr[0]), float(arr[1]))
		return default

	# 2) {"x": ..., "y": ...}
	if t == TYPE_DICTIONARY:
		var dict: Dictionary = v
		var x = dict.get("x", default.x)
		var y = dict.get("y", default.y)
		return Vector2(float(x), float(y))

	# 3) scalar → treat as x and keep default.y
	if t == TYPE_FLOAT or t == TYPE_INT:
		return Vector2(float(v), default.y)

	# Fallback
	return default


static func load_level(json_path: String, parent: Node) -> void:
	# Open JSON file
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("LevelLoader: Could not open level JSON at: %s" % json_path)
		return

	var text := file.get_as_text()
	var data = JSON.parse_string(text)

	if typeof(data) != TYPE_DICTIONARY:
		push_error("LevelLoader: JSON root is not a dictionary")
		return

	# ----- Tower spots -----
	if data.has("tower_spots"):
		var tower_spots_data = data["tower_spots"]

		# Ensure a TowerSpots node exists under the parent
		var tower_spots_node := parent.get_node_or_null("TowerSpots")
		if tower_spots_node == null:
			tower_spots_node = Node2D.new()
			tower_spots_node.name = "TowerSpots"
			parent.add_child(tower_spots_node)

		for spot_dict in tower_spots_data:
			if typeof(spot_dict) != TYPE_DICTIONARY:
				continue

			var pos := _extract_vec2(spot_dict, "position", Vector2.ZERO)
			var size := _extract_vec2(spot_dict, "size", Vector2(64, 64))

			# Also support "width"/"height" instead of "size"
			if spot_dict.has("width") or spot_dict.has("height"):
				var w = float(spot_dict.get("width", size.x))
				var h = float(spot_dict.get("height", size.y))
				size = Vector2(w, h)

			var spot := ColorRect.new()
			spot.position = pos
			spot.size = size
			spot.color = Color(0.2, 0.8, 0.2, 0.4)  # semi-transparent green for debug
			tower_spots_node.add_child(spot)

		print("LevelLoader: Created ", tower_spots_node.get_child_count(), " tower spots from JSON")

	# TODO: Add more sections (paths, waves, etc.) as you expand your JSON
