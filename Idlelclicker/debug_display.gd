extends Label

@onready var player = get_node_or_null("/root/Player")

func _process(_delta):
	if player:
		var pos = player.global_position
		var vel = player.velocity
		var on_floor = player.is_on_floor()
		
		text = "Player Pos: (%.1f, %.1f, %.1f)\n" % [pos.x, pos.y, pos.z]
		text += "Velocity: (%.1f, %.1f, %.1f)\n" % [vel.x, vel.y, vel.z]
		text += "On Floor: %s\n" % str(on_floor)
		text += "Mouse Mode: %s" % ("CAPTURED" if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else "VISIBLE")
	else:
		text = "Waiting for player..."
