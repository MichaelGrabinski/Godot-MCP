extends Area2D

# Item Pickup - Collectible items in the dungeon

var item: Object = null  # ItemSystem.Item
var item_setup_complete = false

# Get game reference - traverse up to find the Game node
func get_game():
	var node = get_parent()
	while node:
		if node.name == "Game" or node.has_method("world_to_grid"):
			return node
		node = node.get_parent()
	return null

func setup_item(item_data):
	item = item_data
	# Wait for node to be fully in tree
	await get_tree().process_frame
	
	if item and has_node("Sprite") and has_node("Particles"):
		$Sprite.texture = create_item_texture()
		setup_particles()
		item_setup_complete = true

func _ready():
	body_entered.connect(_on_body_entered)

func create_item_texture() -> ImageTexture:
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	var color = item.sprite_color if item else Color.WHITE
	
	match item.type:
		0:  # WEAPON
			for x in range(6, 18):
				for y in range(10, 14):
					img.set_pixel(x, y, color)
			for x in range(10, 14):
				for y in range(6, 18):
					img.set_pixel(x, y, color)
		1:  # ARMOR
			for x in range(8, 16):
				for y in range(6, 18):
					var dist = abs(x - 12) + abs(y - 12)
					if dist < 8:
						img.set_pixel(x, y, color)
		2:  # CONSUMABLE
			for x in range(9, 15):
				for y in range(8, 16):
					img.set_pixel(x, y, color)
			for x in range(10, 14):
				for y in range(6, 10):
					img.set_pixel(x, y, color.darkened(0.3))
		_:
			for x in range(24):
				for y in range(24):
					var dist = Vector2(x - 12, y - 12).length()
					if dist < 6:
						img.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(img)

func setup_particles():
	var particles = $Particles
	particles.amount = 10
	particles.lifetime = 1.0
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 8.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, -1, 0)
	material.spread = 45.0
	material.initial_velocity_min = 10.0
	material.initial_velocity_max = 20.0
	material.gravity = Vector3(0, -20, 0)
	material.scale_min = 1.0
	material.scale_max = 2.0
	
	if item:
		material.color = item.sprite_color
	
	particles.process_material = material

func _on_body_entered(body):
	if body.name == "Player":
		var game = get_game()
		if game:
			game.player_pickup_item(item)
		queue_free()
