extends Node

# Advanced Polish System - Particles, trails, weather, dynamic effects

class_name PolishEffects

# Player movement trail
static func create_player_trail(player: Node2D) -> GPUParticles2D:
	var trail = GPUParticles2D.new()
	trail.amount = 20
	trail.lifetime = 0.5
	trail.emitting = true
	trail.process_material = create_steam_trail_material()
	player.add_child(trail)
	return trail

static func create_steam_trail_material() -> ParticleProcessMaterial:
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 5.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 1, 0)
	material.spread = 30.0
	material.initial_velocity_min = 10.0
	material.initial_velocity_max = 20.0
	material.gravity = Vector3(0, -10, 0)
	material.color = Color(0.9, 0.9, 1.0, 0.5)
	material.scale_min = 1.0
	material.scale_max = 2.0
	return material

# Enemy death explosion with debris
static func create_enemy_death_explosion(parent: Node, position: Vector2, enemy_color: Color):
	# Main explosion
	VisualEffects.create_explosion_particles(parent, position, enemy_color)
	
	# Gear debris
	for i in range(5):
		var debris = create_gear_debris(position, enemy_color)
		parent.add_child(debris)
		animate_debris(debris, parent)

static func create_gear_debris(position: Vector2, color: Color) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.position = position
	sprite.texture = create_gear_texture(color)
	sprite.scale = Vector2(0.5, 0.5)
	return sprite

static func create_gear_texture(color: Color) -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	# Simple gear shape
	for angle in range(0, 360, 45):
		var rad = deg_to_rad(angle)
		var x = 8 + int(cos(rad) * 6)
		var y = 8 + int(sin(rad) * 6)
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if x + dx >= 0 and x + dx < 16 and y + dy >= 0 and y + dy < 16:
					img.set_pixel(x + dx, y + dy, color)
	
	return ImageTexture.create_from_image(img)

static func animate_debris(debris: Sprite2D, parent: Node):
	var target_x = debris.position.x + randf_range(-50, 50)
	var target_y = debris.position.y + randf_range(-50, 50)
	
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(debris, "position:x", target_x, 0.8)
	tween.tween_property(debris, "position:y", target_y, 0.8)
	tween.tween_property(debris, "rotation", randf_range(-PI, PI), 0.8)
	tween.tween_property(debris, "modulate:a", 0.0, 0.8)
	tween.tween_callback(debris.queue_free).set_delay(0.8)

# Weather system
class WeatherEffect:
	var type: String  # "steam_fog", "oil_rain", "electric_storm", "none"
	var intensity: float = 1.0
	var duration: int = 10  # turns
	
	func _init(t: String, i: float, d: int):
		type = t
		intensity = i
		duration = d

static func create_weather_particles(parent: Node, weather: WeatherEffect) -> GPUParticles2D:
	var particles = GPUParticles2D.new()
	particles.amount = int(50 * weather.intensity)
	particles.lifetime = 2.0
	particles.emitting = true
	particles.position = Vector2(640, 0)  # Top center of screen
	
	var material = ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	
	match weather.type:
		"steam_fog":
			material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			material.emission_box_extents = Vector3(640, 10, 0)
			material.direction = Vector3(0, 1, 0)
			material.spread = 10.0
			material.initial_velocity_min = 20.0
			material.initial_velocity_max = 40.0
			material.gravity = Vector3(0, 50, 0)
			material.color = Color(0.9, 0.9, 1.0, 0.3)
			material.scale_min = 3.0
			material.scale_max = 6.0
		
		"oil_rain":
			material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			material.emission_box_extents = Vector3(640, 10, 0)
			material.direction = Vector3(0, 1, 0)
			material.spread = 5.0
			material.initial_velocity_min = 200.0
			material.initial_velocity_max = 300.0
			material.gravity = Vector3(0, 400, 0)
			material.color = Color(0.1, 0.1, 0.1, 0.6)
			material.scale_min = 1.0
			material.scale_max = 2.0
		
		"electric_storm":
			material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			material.emission_box_extents = Vector3(640, 360, 0)
			material.direction = Vector3(0, 0, 0)
			material.spread = 180.0
			material.initial_velocity_min = 50.0
			material.initial_velocity_max = 100.0
			material.gravity = Vector3.ZERO
			material.color = Color(0.9, 0.9, 0.3, 0.7)
			material.scale_min = 2.0
			material.scale_max = 5.0
	
	particles.process_material = material
	parent.add_child(particles)
	return particles

static func get_random_weather(floor: int) -> WeatherEffect:
	var chance = randi() % 100
	
	if chance < 70:  # 70% no weather
		return WeatherEffect.new("none", 0.0, 0)
	
	var weather_types = ["steam_fog", "oil_rain", "electric_storm"]
	var weather_type = weather_types[randi() % weather_types.size()]
	var intensity = randf_range(0.5, 1.5)
	var duration = randi() % 10 + 5  # 5-15 turns
	
	return WeatherEffect.new(weather_type, intensity, duration)

static func apply_weather_effects(weather: WeatherEffect, player, enemies: Array, game) -> String:
	if weather.type == "none" or weather.duration <= 0:
		return ""
	
	var message = ""
	
	match weather.type:
		"steam_fog":
			# Reduce visibility (could affect minimap)
			message = "[color=cyan]Steam fog reduces visibility...[/color]"
		
		"oil_rain":
			# Slippery, chance to slip
			if randi() % 100 < 20:
				message = "[color=gray]You slip in the oil rain![/color]"
				# Player loses turn (would need game integration)
		
		"electric_storm":
			# Random lightning strikes
			if randi() % 100 < 30:
				var damage = int(10 * weather.intensity)
				player.take_damage(damage)
				message = "[color=yellow]Lightning strikes you for " + str(damage) + " damage![/color]"
			
			# Can also hit enemies
			for enemy in enemies:
				if is_instance_valid(enemy) and randi() % 100 < 15:
					enemy.take_damage(int(15 * weather.intensity))
	
	weather.duration -= 1
	return message

# Combo hit streak visual
static func create_combo_indicator(parent: Node, combo_count: int, position: Vector2):
	var label = Label.new()
	label.text = "x" + str(combo_count) + " COMBO!"
	label.position = position
	label.z_index = 100
	
	var font_size = 20 + combo_count * 2
	label.add_theme_font_size_override("font_size", min(font_size, 48))
	
	# Color based on combo
	var color = Color.WHITE
	if combo_count >= 10:
		color = Color(1.0, 0.3, 1.0)  # Purple for huge combos
	elif combo_count >= 5:
		color = Color(1.0, 0.8, 0.0)  # Gold
	else:
		color = Color(1.0, 0.5, 0.0)  # Orange
	
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 80, 1.5)
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.3)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(1.0)
	tween.tween_callback(label.queue_free).set_delay(1.5)

# Critical hit special effect
static func create_crit_effect(parent: Node, position: Vector2):
	# Flash
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 0.0, 0.5)
	flash.size = Vector2(100, 100)
	flash.position = position - Vector2(50, 50)
	parent.add_child(flash)
	
	var tween = parent.create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	tween.tween_callback(flash.queue_free)
	
	# Explosion particles
	VisualEffects.create_explosion_particles(parent, position, Color(1.0, 0.8, 0.0))
	
	# Star particles
	var stars = GPUParticles2D.new()
	stars.position = position
	stars.amount = 20
	stars.lifetime = 0.5
	stars.one_shot = true
	stars.explosiveness = 1.0
	stars.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 5.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 200.0
	material.gravity = Vector3.ZERO
	material.color = Color(1.0, 0.9, 0.3)
	material.scale_min = 3.0
	material.scale_max = 6.0
	stars.process_material = material
	
	parent.add_child(stars)
	
	await parent.get_tree().create_timer(1.0).timeout
	stars.queue_free()

# Level up fanfare
static func create_level_up_fanfare(parent: Node, position: Vector2):
	# Existing level up effect
	VisualEffects.create_level_up_effect(parent, position)
	
	# Add rays of light
	for i in range(8):
		var ray = create_light_ray(position, i * 45)
		parent.add_child(ray)
		animate_light_ray(ray, parent)

static func create_light_ray(position: Vector2, angle: float) -> Line2D:
	var ray = Line2D.new()
	ray.width = 3.0
	ray.default_color = Color(1.0, 0.9, 0.3, 0.8)
	
	var rad = deg_to_rad(angle)
	ray.add_point(position)
	ray.add_point(position + Vector2(cos(rad), sin(rad)) * 100)
	
	return ray

static func animate_light_ray(ray: Line2D, parent: Node):
	var tween = parent.create_tween()
	tween.tween_property(ray, "default_color:a", 0.0, 1.0)
	tween.tween_callback(ray.queue_free)
