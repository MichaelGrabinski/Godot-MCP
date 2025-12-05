extends CharacterBody2D

# SUPER FIXED - Can only die ONCE!

enum EnemyType {
	RUST_DRONE,
	STEAM_GOLEM,
	OIL_WRAITH,
	GEAR_SPIDER,
	COAL_FURNACE,
	ELECTRIC_SENTINEL,
	PLAGUE_MECHANIC,
	BRASS_COMMANDER
}

var enemy_type = EnemyType.RUST_DRONE
var enemy_name = "Rust Drone"
var max_health = 30
var health = 30
var attack = 5
var defense = 2
var experience_value = 25
var special_ability = ""

var ai_state = "idle"
var turns_until_special = 0
var initialized = false
var is_dying = false
var is_dead = false  # NEW: Track if already dead

var animated_sprite: AnimatedSprite2D

func get_game():
	var node = get_parent()
	while node:
		if node.name == "Game" or node.has_method("world_to_grid"):
			return node
		node = node.get_parent()
	return null

func _ready():
	z_index = 10
	await get_tree().process_frame
	_initialize()

func _initialize():
	if initialized:
		return
	initialized = true
	
	var game = get_game()
	if not game:
		return
	
	var floor = game.current_floor if game else 1
	var type_pool = min(floor / 2 + 2, 8)
	enemy_type = randi() % type_pool
	
	match enemy_type:
		EnemyType.RUST_DRONE:
			enemy_name = "Rust Drone"
			max_health = 25
			health = 25
			attack = 5
			defense = 2
			experience_value = 20
			setup_pixel_art("Rat", Color(0.8, 0.4, 0.2))
			
		EnemyType.STEAM_GOLEM:
			enemy_name = "Steam Golem"
			max_health = 50
			health = 50
			attack = 8
			defense = 5
			experience_value = 50
			setup_pixel_art("Slime", Color(0.6, 0.6, 0.6))
			
		EnemyType.OIL_WRAITH:
			enemy_name = "Oil Wraith"
			max_health = 20
			health = 20
			attack = 10
			defense = 1
			experience_value = 35
			setup_pixel_art("Ghost", Color(0.2, 0.2, 0.2))
			
		EnemyType.GEAR_SPIDER:
			enemy_name = "Gear Spider"
			max_health = 30
			health = 30
			attack = 7
			defense = 3
			experience_value = 40
			setup_pixel_art("Spider", Color(0.5, 0.5, 0.4))
			
		EnemyType.COAL_FURNACE:
			enemy_name = "Coal Furnace"
			max_health = 70
			health = 70
			attack = 6
			defense = 7
			experience_value = 65
			setup_pixel_art("Slime", Color(0.9, 0.3, 0.1))
			
		EnemyType.ELECTRIC_SENTINEL:
			enemy_name = "Electric Sentinel"
			max_health = 35
			health = 35
			attack = 12
			defense = 2
			experience_value = 55
			setup_pixel_art("Skeleton", Color(0.3, 0.5, 1.0))
			
		EnemyType.PLAGUE_MECHANIC:
			enemy_name = "Plague Mechanic"
			max_health = 40
			health = 40
			attack = 9
			defense = 4
			experience_value = 70
			setup_pixel_art("Skeleton", Color(0.4, 0.7, 0.3))
			
		EnemyType.BRASS_COMMANDER:
			enemy_name = "Brass Commander"
			max_health = 80
			health = 80
			attack = 15
			defense = 8
			experience_value = 100
			setup_pixel_art("Skeleton", Color(0.9, 0.7, 0.3))
	
	print("✅ Enemy spawned: " + enemy_name + " at " + str(position))

func setup_pixel_art(asset_name: String, fallback_color: Color):
	if has_node("Sprite"):
		$Sprite.queue_free()
	
	var all_animations = {}
	var anim_types = ["Idle", "Run", "Attack", "Death"]
	
	for anim in anim_types:
		var frames = load_enemy_frames(asset_name, anim)
		if frames.size() > 0:
			all_animations[anim.to_lower()] = frames
	
	if all_animations.size() > 0:
		var sprite_frames = SpriteFrames.new()
		
		for anim_name in all_animations.keys():
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, 8.0)
			
			if anim_name == "attack" or anim_name == "death":
				sprite_frames.set_animation_loop(anim_name, false)
			else:
				sprite_frames.set_animation_loop(anim_name, true)
			
			for frame in all_animations[anim_name]:
				sprite_frames.add_frame(anim_name, frame)
		
		animated_sprite = AnimatedSprite2D.new()
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.name = "AnimatedSprite2D"
		add_child(animated_sprite)
		animated_sprite.play("idle")
	else:
		create_fallback_sprite(fallback_color)

func load_enemy_frames(enemy_name: String, anim_name: String) -> Array:
	var frames = []
	var base_path = "res://DieselPunk/Dungeons and Pixels/Enemies/" + enemy_name + "/Frames/" + anim_name + "/"
	
	for i in range(20):
		var path = base_path + str(i).pad_zeros(2) + ".png"
		var texture = load(path)
		if texture:
			frames.append(texture)
		else:
			break
	
	return frames

func create_fallback_sprite(color: Color):
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	for x in range(32):
		for y in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist < 12:
				img.set_pixel(x, y, color)
	
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)

func play_animation(anim_name: String):
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)

func take_turn():
	# CRITICAL: Don't do ANYTHING if dead
	if is_dying or is_dead:
		return
	
	var game = get_game()
	if not game or not is_instance_valid(game.player):
		return
	
	var player_pos = game.world_to_grid(game.player.position)
	var my_pos = game.world_to_grid(position)
	var distance = (player_pos - my_pos).length()
	
	if distance <= 1.5:
		play_animation("attack")
		await get_tree().create_timer(0.3).timeout
		if not is_dead:  # Check again after wait
			attack_player()
			play_animation("idle")
		return
	
	if distance < 8:
		play_animation("run")
		move_towards_player(player_pos, my_pos)
		await get_tree().create_timer(0.2).timeout
		if not is_dead:  # Check again after wait
			play_animation("idle")
	else:
		play_animation("idle")

func move_towards_player(player_pos: Vector2i, my_pos: Vector2i):
	if is_dead:
		return
		
	var game = get_game()
	if not game:
		return
	
	var direction = Vector2i.ZERO
	
	var dx = player_pos.x - my_pos.x
	var dy = player_pos.y - my_pos.y
	
	if abs(dx) > abs(dy):
		direction.x = sign(dx)
	else:
		direction.y = sign(dy)
	
	var target_pos = my_pos + direction
	
	if game.is_walkable(target_pos):
		var other_enemy = game.enemy_at_position(target_pos)
		if not other_enemy or other_enemy == self:
			position = Vector2(target_pos) * game.TILE_SIZE

func attack_player():
	if is_dead:
		return
		
	var game = get_game()
	if not game:
		return
	
	var damage = max(1, attack - game.player.defense)
	game.player.take_damage(damage)
	game.add_message("[color=red]The " + enemy_name + " attacks for " + str(damage) + " damage![/color]")

func take_damage(amount: int):
	# CRITICAL: Can't take damage if already dead!
	if is_dying or is_dead:
		print("⚠ Enemy already dead, ignoring damage")
		return
	
	health -= amount
	print("Enemy took " + str(amount) + " damage. Health: " + str(health) + "/" + str(max_health))
	
	if animated_sprite:
		animated_sprite.modulate = Color(1.5, 0.5, 0.5)
	else:
		modulate = Color(1.5, 0.5, 0.5)
	
	await get_tree().create_timer(0.1).timeout
	
	if is_dying or is_dead:
		return
	
	if animated_sprite:
		animated_sprite.modulate = Color.WHITE
	else:
		modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# CRITICAL: Only die once!
	if is_dying or is_dead:
		print("⚠ Die called but already dying/dead!")
		return
	
	print("💀 Enemy dying: " + enemy_name)
	is_dying = true
	is_dead = true  # Mark as dead IMMEDIATELY
	
	# Disable collision immediately
	set_physics_process(false)
	set_process(false)
	
	var game = get_game()
	
	# Remove from game arrays IMMEDIATELY
	if game:
		game.enemies.erase(self)
	
	# Play death animation
	if animated_sprite and animated_sprite.sprite_frames.has_animation("death"):
		play_animation("death")
		await animated_sprite.animation_finished
	
	# Show message and award XP
	if game:
		game.add_message("[color=gray]The " + enemy_name + " is destroyed![/color]")
		
		# Drop items
		if randi() % 100 < 30 + game.current_floor * 2:
			game.spawn_item_at(position)
		
		# Update stats
		game.enemy_killed(self)
	
	# Delete node
	print("🗑 Enemy freed: " + enemy_name)
	queue_free()
