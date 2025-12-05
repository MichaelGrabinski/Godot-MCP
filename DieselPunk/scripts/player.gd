extends CharacterBody2D

# MOBILE-READY PLAYER with touch controls!

var max_health = 100
var health = 100
var base_attack = 10
var attack = 10
var base_defense = 5
var defense = 5
var level = 1
var experience = 0
var experience_to_next = 100

var inventory = []
var max_inventory_size = 10
var equipped_weapon = null
var equipped_armor = null

var poison_damage = 0
var poison_turns = 0
var damage_boost = 0
var damage_boost_turns = 0
var defense_boost = 0
var defense_boost_turns = 0

var abilities = []
var ability_cooldowns = {}

var game
var mobile_controls = null

const AudioManager = preload("res://DieselPunk/scripts/audio_manager.gd")

var animated_sprite: AnimatedSprite2D
var current_direction = "down"
var facing_left = false

func _ready():
	z_index = 10
	game = get_parent()
	
	# Setup mobile controls
	setup_mobile_controls()
	
	print("🎨 PLAYER: Loading all animations...")
	
	var all_animations = {}
	var anim_types = ["Idle", "Run", "Attack"]
	var directions = ["Down", "Up", "Side"]
	
	for anim in anim_types:
		for dir in directions:
			var frames = load_directional_frames(anim, dir)
			if frames.size() > 0:
				var anim_name = anim.to_lower() + "_" + dir.to_lower()
				all_animations[anim_name] = frames
				print("  ✅ Loaded " + anim_name + ": " + str(frames.size()) + " frames")
	
	if all_animations.size() > 0:
		var sprite_frames = SpriteFrames.new()
		
		for anim_name in all_animations.keys():
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, 8.0)
			
			if "attack" in anim_name:
				sprite_frames.set_animation_loop(anim_name, false)
			else:
				sprite_frames.set_animation_loop(anim_name, true)
			
			for frame in all_animations[anim_name]:
				sprite_frames.add_frame(anim_name, frame)
		
		animated_sprite = AnimatedSprite2D.new()
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.name = "AnimatedSprite2D"
		
		if has_node("Sprite"):
			$Sprite.queue_free()
		
		add_child(animated_sprite)
		animated_sprite.play("idle_down")
		
		print("✅ PLAYER: All animations loaded! Total: " + str(all_animations.size()))
	else:
		print("⚠ PLAYER: Using fallback")
		create_fallback_sprite()
	
	abilities.append("Power Strike")
	ability_cooldowns["Power Strike"] = 0

func setup_mobile_controls():
	# Check if mobile controls exist, if not create them
	var controls = game.get_node_or_null("MobileControls")
	if not controls:
		var mobile_scene = load("res://DieselPunk/scenes/mobile_controls.tscn")
		if mobile_scene:
			controls = mobile_scene.instantiate()
			game.add_child(controls)
	
	if controls:
		mobile_controls = controls
		controls.move_pressed.connect(_on_mobile_move)
		controls.ability_pressed.connect(_on_mobile_ability)
		controls.item_pressed.connect(_on_mobile_item)
		print("✅ Mobile controls connected!")

func _on_mobile_move(direction: Vector2i):
	if game.game_over or not game.player_turn:
		return
	update_animation_direction(direction)
	try_move(direction)

func _on_mobile_ability(ability_index: int):
	use_ability(ability_index)

func _on_mobile_item():
	use_consumable()

func load_directional_frames(anim_name: String, direction: String) -> Array:
	var frames = []
	var base_path = "res://DieselPunk/Dungeons and Pixels/Characters/Hero_Warrior/Frames/" + anim_name + "/" + direction + "/"
	
	for i in range(20):
		var path = base_path + str(i).pad_zeros(2) + ".png"
		var texture = load(path)
		if texture:
			frames.append(texture)
		else:
			break
	
	return frames

func create_fallback_sprite():
	if has_node("Sprite"):
		return
	
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.7, 0.9))
	sprite.texture = ImageTexture.create_from_image(img)
	
	add_child(sprite)

func update_animation_direction(move_direction: Vector2i):
	if not animated_sprite:
		return
	
	if move_direction.y < 0:
		current_direction = "up"
	elif move_direction.y > 0:
		current_direction = "down"
	elif move_direction.x != 0:
		current_direction = "side"
		animated_sprite.flip_h = move_direction.x < 0
		facing_left = move_direction.x < 0

func play_animation(anim_type: String):
	if not animated_sprite:
		return
	
	var anim_name = anim_type + "_" + current_direction
	
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)

func _input(event):
	if game.game_over or not game.player_turn:
		return
	
	# Keyboard controls (for desktop)
	var direction = Vector2i.ZERO
	var moved = false
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		direction = Vector2i(0, -1)
		moved = true
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		direction = Vector2i(0, 1)
		moved = true
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		direction = Vector2i(-1, 0)
		moved = true
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		direction = Vector2i(1, 0)
		moved = true
	
	if event.is_action_pressed("ability_1"):
		use_ability(0)
		return
	elif event.is_action_pressed("ability_2"):
		use_ability(1)
		return
	
	if event.is_action_pressed("use_item"):
		use_consumable()
		return
	
	if moved and direction != Vector2i.ZERO:
		update_animation_direction(direction)
		try_move(direction)

func try_move(direction: Vector2i):
	var current_grid = game.world_to_grid(position)
	var target_grid = current_grid + direction
	
	var enemy = game.enemy_at_position(target_grid)
	if enemy:
		play_animation("attack")
		await get_tree().create_timer(0.3).timeout
		
		attack_enemy(enemy)
		
		play_animation("idle")
		
		game.take_turn()
		process_status_effects()
		return
	
	if game.is_walkable(target_grid):
		play_animation("run")
		
		position = Vector2(target_grid) * game.TILE_SIZE
		
		await get_tree().create_timer(0.15).timeout
		
		play_animation("idle")
		
		var tile = game.get_tile_at(target_grid)
		if tile == game.TileType.STAIRS_DOWN:
			game.add_message("[color=yellow]Descending deeper...[/color]")
			game.next_floor()
		
		game.take_turn()
		process_status_effects()

func attack_enemy(enemy):
	var combo_multiplier = game.combo_tracker.damage_multiplier
	var final_attack = int((attack + damage_boost) * combo_multiplier)
	var damage = max(1, final_attack - enemy.defense)
	
	AudioManager.play_hit_sound(game)
	create_hit_particles(enemy.position, Color(1, 0.5, 0))
	
	enemy.take_damage(damage)
	
	var combo_text = ""
	if game.combo_tracker.combo_count > 1:
		combo_text = " [COMBO x" + str(game.combo_tracker.combo_count) + "]"
	
	game.add_message("Strike " + enemy.enemy_name + " for " + str(damage) + " damage!" + combo_text)
	
	if enemy.health <= 0:
		var xp_multiplier = game.combo_tracker.experience_multiplier
		var xp = int(enemy.experience_value * xp_multiplier)
		gain_experience(xp)
		game.enemy_killed(enemy)

func use_ability(index: int):
	if index >= abilities.size():
		return
	
	var ability = abilities[index]
	if ability_cooldowns.get(ability, 0) > 0:
		game.add_message("[color=gray]Cooldown: " + str(ability_cooldowns[ability]) + " turns[/color]")
		return
	
	match ability:
		"Power Strike":
			var enemy = get_adjacent_enemy()
			if enemy:
				play_animation("attack")
				await get_tree().create_timer(0.3).timeout
				
				AudioManager.play_ability_sound(game)
				var damage = attack * 2
				create_hit_particles(enemy.position, Color(1, 0.8, 0))
				enemy.take_damage(damage)
				game.add_message("[color=orange]⚡ POWER STRIKE! " + str(damage) + " damage![/color]")
				
				play_animation("idle")
				
				ability_cooldowns[ability] = 5
				game.take_turn()
			else:
				game.add_message("[color=gray]No target![/color]")
		
		"Steam Shield":
			AudioManager.play_steam_sound(game)
			defense_boost = 10
			defense_boost_turns = 3
			defense = base_defense + defense_boost
			game.add_message("[color=cyan]☁ Steam Shield! +10 Defense[/color]")
			create_hit_particles(position, Color(0.7, 0.9, 1.0))
			ability_cooldowns[ability] = 7
			game.take_turn()

func get_adjacent_enemy():
	var my_pos = game.world_to_grid(position)
	for direction in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var check_pos = my_pos + direction
		var enemy = game.enemy_at_position(check_pos)
		if enemy:
			return enemy
	return null

func use_consumable():
	for item in inventory:
		if item.type == 2:
			AudioManager.play_pickup_sound(game)
			consume_item(item)
			inventory.erase(item)
			game.update_ui()
			game.take_turn()
			return
	
	game.add_message("[color=gray]No consumables![/color]")

func consume_item(item):
	if item.heal_amount > 0:
		var healed = min(item.heal_amount, max_health - health)
		health += healed
		game.add_message("[color=green]♥ Restored " + str(healed) + " HP![/color]")
		create_hit_particles(position, Color(0, 1, 0))
	
	if item.damage_boost_turns > 0:
		damage_boost = 5
		damage_boost_turns = item.damage_boost_turns
		attack = base_attack + damage_boost
		game.add_message("[color=red]⚔ Attack increased![/color]")
	
	if item.defense_boost_turns > 0:
		defense_boost = 3
		defense_boost_turns = item.defense_boost_turns
		defense = base_defense + defense_boost
		game.add_message("[color=blue]🛡 Defense increased![/color]")

func equip_item(item):
	if item.type == 0:
		if equipped_weapon:
			inventory.append(equipped_weapon)
		equipped_weapon = item
		base_attack += item.attack_bonus
		attack = base_attack + damage_boost
		base_defense += item.defense_bonus
		defense = base_defense + defense_boost
		game.add_message("[color=yellow]⚔ Equipped " + item.name + "[/color]")
	
	elif item.type == 1:
		if equipped_armor:
			inventory.append(equipped_armor)
		equipped_armor = item
		max_health += item.health_bonus
		health += item.health_bonus
		base_defense += item.defense_bonus
		defense = base_defense + defense_boost
		game.add_message("[color=yellow]🛡 Equipped " + item.name + "[/color]")

func take_damage(amount: int):
	var final_defense = defense + defense_boost
	var reduced = max(1, amount - final_defense / 2)
	health -= reduced
	
	game.player_took_damage(reduced)
	create_hit_particles(position, Color(1, 0, 0))
	
	if health <= 0:
		health = 0
		game.player_died()
	
	game.update_ui()

func apply_poison(damage: int, turns: int):
	poison_damage = damage
	poison_turns = turns
	game.add_message("[color=green]☠ Poisoned![/color]")

func process_status_effects():
	if poison_turns > 0:
		health -= poison_damage
		game.add_message("[color=green]Poison: -" + str(poison_damage) + " HP[/color]")
		poison_turns -= 1
		if poison_turns == 0:
			game.add_message("[color=gray]Poison wears off[/color]")
	
	if damage_boost_turns > 0:
		damage_boost_turns -= 1
		if damage_boost_turns == 0:
			damage_boost = 0
			attack = base_attack
			game.add_message("[color=gray]Attack boost fades[/color]")
	
	if defense_boost_turns > 0:
		defense_boost_turns -= 1
		if defense_boost_turns == 0:
			defense_boost = 0
			defense = base_defense
			game.add_message("[color=gray]Defense boost fades[/color]")
	
	for ability in ability_cooldowns:
		if ability_cooldowns[ability] > 0:
			ability_cooldowns[ability] -= 1
	
	game.update_ui()

func create_hit_particles(pos: Vector2, color: Color):
	var particles = GPUParticles2D.new()
	game.add_child(particles)
	particles.position = pos
	particles.amount = 20
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = true
	
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 16.0
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0, 200, 0)
	material.color = color
	particles.process_material = material
	
	await get_tree().create_timer(1.0).timeout
	particles.queue_free()

func gain_experience(amount: int):
	experience += amount
	game.add_message("[color=green]+ " + str(amount) + " XP[/color]")
	
	if experience >= experience_to_next:
		level_up()

func level_up():
	level += 1
	experience -= experience_to_next
	experience_to_next = int(experience_to_next * 1.5)
	
	max_health += 20
	health = max_health
	base_attack += 3
	attack = base_attack + damage_boost
	base_defense += 2
	defense = base_defense + defense_boost
	
	AudioManager.play_level_up_sound(game)
	create_hit_particles(position, Color(1, 1, 0))
	
	if level == 5:
		game.achievement_manager.check_achievement("apprentice")
	elif level == 10:
		game.achievement_manager.check_achievement("journeyman")
	elif level == 15:
		game.achievement_manager.check_achievement("master")
	
	if level % 3 == 0 and abilities.size() < 2:
		abilities.append("Steam Shield")
		ability_cooldowns["Steam Shield"] = 0
		game.add_message("[color=gold]★ Learned: Steam Shield![/color]")
	
	game.add_message("[color=gold]★ LEVEL " + str(level) + "! ★[/color]")
	game.update_ui()
