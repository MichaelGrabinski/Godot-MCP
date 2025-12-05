extends Node2D

# Animate decorative gears

var rotation_speeds = [0.5, -0.7, 0.3, -0.4]

func _process(delta):
	for i in range(get_child_count()):
		var gear = get_child(i)
		if i < rotation_speeds.size():
			gear.rotation += rotation_speeds[i] * delta
