extends Node

# Visual Effects Manager - Screen shake, damage numbers, particles, etc.

class_name VisualEffects

static func screen_shake(camera: Camera2D, intensity: float = 5.0, duration: float = 0.3):
	var original_offset = camera.offset
	var shake_timer = 0.0
	
	while shake_timer < duration:
		var shake_amount = intensity * (1.0 - shake_timer / duration)
		camera.offset = original_offset + Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		shake_timer += 0.016  # ~60fps
		await camera.get_tree().create_timer(0.016).timeout
	
	camera.offset = original_offset

static func spawn_damage_number(parent: Node, position: Vector2, amount: int, is_crit: bool = false):
	var label = Label.new()
	label.text = str(amount)
	label.position = position
	label.z_index = 100
	
	# Styling
	if is_crit:
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.0))
	else:
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.8))
	
	parent.add_child(label)
	
	# Animate
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 50, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free).set_delay(1.0)

static func spawn_text_popup(parent: Node, position: Vector2, text: String, color: Color = Color.WHITE):
	var label = Label.new()
	label.text = text
	label.position = position
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", color)
	
	parent.add_child(label)
	
	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 40, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free).set_delay(0.8)

static func create_explosion_particles(parent: Node, position: Vector2, color: Color = Color.ORANGE):
	var particles = GPUParticles2D.new()
	particles.position = position
	particles.amount = 30
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 5.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 0, 0)
	material.spread = 180.0
	material.initial_velocity_min = 80.0
	material.initial_velocity_max = 150.0
	material.gravity = Vector3(0, 200, 0)
	material.color = color
	material.scale_min = 2.0
	material.scale_max = 5.0
	particles.process_material = material
	
	parent.add_child(particles)
	
	await parent.get_tree().create_timer(1.0).timeout
	particles.queue_free()

static func create_heal_particles(parent: Node, position: Vector2):
	var particles = GPUParticles2D.new()
	particles.position = position
	particles.amount = 20
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.5
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 10.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, -1, 0)
	material.spread = 30.0
	material.initial_velocity_min = 30.0
	material.initial_velocity_max = 60.0
	material.gravity = Vector3(0, -50, 0)
	material.color = Color(0.3, 1.0, 0.3, 0.8)
	material.scale_min = 1.5
	material.scale_max = 3.0
	particles.process_material = material
	
	parent.add_child(particles)
	
	await parent.get_tree().create_timer(1.5).timeout
	particles.queue_free()

static func create_level_up_effect(parent: Node, position: Vector2):
	var particles = GPUParticles2D.new()
	particles.position = position
	particles.amount = 50
	particles.lifetime = 1.5
	particles.one_shot = true
	particles.explosiveness = 0.3
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	material.emission_ring_axis = Vector3(0, 0, 1)
	material.emission_ring_height = 1.0
	material.emission_ring_radius = 20.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0, -30, 0)
	material.color = Color(1.0, 0.9, 0.3)
	material.scale_min = 2.0
	material.scale_max = 4.0
	particles.process_material = material
	
	parent.add_child(particles)
	
	await parent.get_tree().create_timer(2.0).timeout
	particles.queue_free()

static func flash_sprite(sprite: Node, color: Color = Color.WHITE, duration: float = 0.1):
	var original = sprite.modulate
	sprite.modulate = color
	await sprite.get_tree().create_timer(duration).timeout
	sprite.modulate = original
