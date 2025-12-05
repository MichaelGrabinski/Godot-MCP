extends Area2D

# Trap System - FIXED VISIBILITY AND Z-INDEX

enum TrapType {
	SPIKE,
	STEAM_VENT,
	OIL_SLICK,
	ELECTRIC_GRID,
	CRUSHING_GEARS
}

var trap_type = TrapType.SPIKE
var damage = 10
var is_active = true
var triggered = false

func get_game():
	var node = get_parent()
	while node:
		if node.name == "Game" or node.has_method("world_to_grid"):
			return node
		node = node.get_parent()
	return null

func _ready():
	# CRITICAL: Render above tilemap!
	z_index = 5
	
	body_entered.connect(_on_body_entered)
	
	trap_type = randi() % 5
	
	match trap_type:
		TrapType.SPIKE:
			damage = 15
			$Sprite.texture = create_trap_texture(Color(0.7, 0.7, 0.7), "spike")
		TrapType.STEAM_VENT:
			damage = 12
			$Sprite.texture = create_trap_texture(Color(0.9, 0.9, 1.0), "steam")
		TrapType.OIL_SLICK:
			damage = 8
			$Sprite.texture = create_trap_texture(Color(0.2, 0.2, 0.2), "oil")
		TrapType.ELECTRIC_GRID:
			damage = 20
			$Sprite.texture = create_trap_texture(Color(0.3, 0.6, 1.0), "electric")
		TrapType.CRUSHING_GEARS:
			damage = 25
			$Sprite.texture = create_trap_texture(Color(0.7, 0.5, 0.3), "gears")
	
	# Make sprite more visible
	$Sprite.modulate = Color(1, 1, 1, 0.8)
	
	animate_trap()
	
	print("✅ Trap spawned at " + str(position) + " (z_index: " + str(z_index) + ")")

func create_trap_texture(color: Color, type: String) -> ImageTexture:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	# Make traps MUCH more visible!
	var bright_color = color.lightened(0.3)
	
	match type:
		"spike":
			# Multiple spikes
			for spike_x in [8, 16, 24]:
				for y in range(16, 28):
					var width = max(1, 28 - y)
					for dx in range(-width, width + 1):
						if spike_x + dx >= 0 and spike_x + dx < 32:
							img.set_pixel(spike_x + dx, y, bright_color)
		
		"steam":
			# Cloud pattern
			for i in range(4):
				for j in range(4):
					var cx = 8 + i * 6
					var cy = 8 + j * 6
					for x in range(cx - 3, cx + 4):
						for y in range(cy - 3, cy + 4):
							var dist = Vector2(x - cx, y - cy).length()
							if dist < 3 and x >= 0 and x < 32 and y >= 0 and y < 32:
								img.set_pixel(x, y, bright_color)
		
		"oil":
			# Puddle
			for x in range(4, 28):
				for y in range(10, 22):
					if randf() > 0.2:
						img.set_pixel(x, y, bright_color)
		
		"electric":
			# Grid pattern
			for i in range(0, 32, 4):
				for j in range(32):
					img.set_pixel(i, j, bright_color)
					img.set_pixel(j, i, bright_color)
			# Extra bright center
			for x in range(14, 18):
				for y in range(14, 18):
					img.set_pixel(x, y, Color.YELLOW)
		
		"gears":
			# Gear teeth
			for angle in range(0, 360, 20):
				var rad = deg_to_rad(angle)
				var x = 16 + int(cos(rad) * 14)
				var y = 16 + int(sin(rad) * 14)
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						if x + dx >= 0 and x + dx < 32 and y + dy >= 0 and y + dy < 32:
							img.set_pixel(x + dx, y + dy, bright_color)
	
	return ImageTexture.create_from_image(img)

func animate_trap():
	var tween = create_tween()
	tween.set_loops()
	
	match trap_type:
		TrapType.STEAM_VENT:
			tween.tween_property($Sprite, "modulate:a", 0.6, 0.5)
			tween.tween_property($Sprite, "modulate:a", 1.0, 0.5)
		TrapType.ELECTRIC_GRID:
			tween.tween_property($Sprite, "modulate", Color(0.7, 0.8, 1.0), 0.3)
			tween.tween_property($Sprite, "modulate", Color.WHITE, 0.3)
		_:
			tween.tween_property($Sprite, "scale", Vector2(1.1, 1.1), 1.0)
			tween.tween_property($Sprite, "scale", Vector2(1.0, 1.0), 1.0)

func _on_body_entered(body):
	if body.name == "Player" and is_active and not triggered:
		print("⚠ Trap triggered by player!")
		trigger_trap(body)

func trigger_trap(player):
	var game = get_game()
	if not game:
		return
	
	triggered = true
	
	match trap_type:
		TrapType.SPIKE:
			game.add_message("[color=red]Spike trap! -" + str(damage) + " HP[/color]")
			player.take_damage(damage)
		
		TrapType.STEAM_VENT:
			game.add_message("[color=cyan]Steam vent! -" + str(damage) + " HP[/color]")
			player.take_damage(damage)
			create_steam_particles()
		
		TrapType.OIL_SLICK:
			game.add_message("[color=gray]Oil slick! -" + str(damage) + " HP[/color]")
			player.take_damage(damage)
		
		TrapType.ELECTRIC_GRID:
			game.add_message("[color=blue]Electric shock! -" + str(damage) + " HP[/color]")
			player.take_damage(damage)
			create_electric_particles()
		
		TrapType.CRUSHING_GEARS:
			game.add_message("[color=orange]Crushing gears! -" + str(damage) + " HP[/color]")
			player.take_damage(damage)
	
	var tween = create_tween()
	tween.tween_property($Sprite, "modulate", Color(1.5, 0.5, 0.5), 0.1)
	tween.tween_property($Sprite, "modulate", Color.WHITE, 0.2)
	
	await get_tree().create_timer(2.0).timeout
	triggered = false

func create_steam_particles():
	var particles = GPUParticles2D.new()
	add_child(particles)
	particles.amount = 30
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 16.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, -1, 0)
	material.spread = 30.0
	material.initial_velocity_min = 40.0
	material.initial_velocity_max = 80.0
	material.gravity = Vector3(0, -50, 0)
	material.color = Color(0.9, 0.9, 1.0, 0.8)
	particles.process_material = material
	
	await get_tree().create_timer(1.5).timeout
	particles.queue_free()

func create_electric_particles():
	var particles = GPUParticles2D.new()
	add_child(particles)
	particles.amount = 50
	particles.lifetime = 0.3
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 20.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 150.0
	material.gravity = Vector3.ZERO
	material.color = Color(0.3, 0.6, 1.0)
	material.scale_min = 2.0
	material.scale_max = 4.0
	particles.process_material = material
	
	await get_tree().create_timer(0.5).timeout
	particles.queue_free()
