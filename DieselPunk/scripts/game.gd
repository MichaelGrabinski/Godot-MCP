extends Node2D

# Dieselpunk Roguelike - ULTIMATE EDITION - MINIMAP DISABLED!

const TILE_SIZE = 32
const MAP_WIDTH = 40
const MAP_HEIGHT = 30
const ROOM_MIN_SIZE = 5
const ROOM_MAX_SIZE = 10
const MAX_ROOMS = 15

var current_floor = 1
var player_turn = true
var game_over = false
var enemies_killed_total = 0
var damage_taken_this_floor = 0

enum TileType {
	WALL,
	FLOOR,
	STAIRS_DOWN
}

enum RoomType {
	NORMAL,
	TREASURE,
	BOSS
}

var dungeon_map = []
var rooms = []
var room_types = []
var enemies = []
var items_on_floor = []
var traps = []
var explored_tiles = []
var fog_layer: Node2D

@onready var tilemap = $DungeonMap
@onready var player = $Player
@onready var enemies_node = $Enemies
@onready var health_bar = $UI/HealthBar
@onready var stats_label = $UI/StatsLabel
@onready var message_log = $UI/MessageLog
@onready var inventory_panel = $UI/InventoryPanel
@onready var inventory_label = $UI/InventoryPanel/InventoryLabel
@onready var minimap_canvas = $UI/MinimapCanvas
@onready var combo_label = $UI/ComboLabel
@onready var achievement_popup = $UI/AchievementPopup
@onready var achievement_text = $UI/AchievementPopup/AchievementText

var messages = []

const ItemSystem = preload("res://DieselPunk/scripts/item_system.gd")
const AudioManager = preload("res://DieselPunk/scripts/audio_manager.gd")
const AchievementManager = preload("res://DieselPunk/scripts/achievement_manager.gd")
const ComboTracker = preload("res://DieselPunk/scripts/combo_tracker.gd")
const DungeonVisuals = preload("res://DieselPunk/scripts/dungeon_visuals.gd")

var achievement_manager: AchievementManager
var combo_tracker: ComboTracker
var dungeon_tilemap: TileMap

func _ready():
	randomize()
	
	# ✅ DISABLE MINIMAP CANVAS
	if minimap_canvas:
		minimap_canvas.visible = false
	
	achievement_manager = AchievementManager.new()
	achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)
	add_child(achievement_manager)
	
	combo_tracker = ComboTracker.new()
	combo_tracker.combo_increased.connect(_on_combo_increased)
	combo_tracker.combo_broken.connect(_on_combo_broken)
	combo_tracker.combo_milestone.connect(_on_combo_milestone)
	add_child(combo_tracker)
	
	generate_dungeon()
	spawn_player()
	spawn_enemies()
	spawn_items()
	spawn_traps()
	
	fog_layer = DungeonVisuals.create_fog_overlay(self)
	add_child(fog_layer)
	
	update_ui()
	
	add_message("[color=yellow]╔═══════════════════════════════╗[/color]")
	add_message("[color=yellow]║ DIESELPUNK DEPTHS - ULTIMATE ║[/color]")
	add_message("[color=yellow]╚═══════════════════════════════╝[/color]")
	add_message("WASD=Move E=Item 1-2=Abilities")
	add_message("[color=orange]Floor " + str(current_floor) + " - " + str(achievement_manager.get_unlocked_count()) + "/" + str(achievement_manager.get_total_count()) + " Achievements[/color]")

func generate_dungeon():
	dungeon_map.clear()
	rooms.clear()
	room_types.clear()
	explored_tiles.clear()
	
	for x in range(MAP_WIDTH):
		dungeon_map.append([])
		explored_tiles.append([])
		for y in range(MAP_HEIGHT):
			dungeon_map[x].append(TileType.WALL)
			explored_tiles[x].append(false)
	
	for i in range(MAX_ROOMS):
		var w = randi() % (ROOM_MAX_SIZE - ROOM_MIN_SIZE) + ROOM_MIN_SIZE
		var h = randi() % (ROOM_MAX_SIZE - ROOM_MIN_SIZE) + ROOM_MIN_SIZE
		var x = randi() % (MAP_WIDTH - w - 1) + 1
		var y = randi() % (MAP_HEIGHT - h - 1) + 1
		
		var new_room = Rect2(x, y, w, h)
		var can_place = true
		
		for room in rooms:
			if new_room.intersects(room.grow(1)):
				can_place = false
				break
		
		if can_place:
			create_room(new_room)
			
			var room_type = RoomType.NORMAL
			if rooms.size() > 2 and randi() % 100 < 15:
				room_type = RoomType.TREASURE
			if i == MAX_ROOMS - 1 and current_floor % 5 == 0:
				room_type = RoomType.BOSS
			room_types.append(room_type)
			
			if rooms.size() > 0:
				var prev_center = rooms[-1].get_center()
				var new_center = new_room.get_center()
				
				if randi() % 2 == 0:
					create_h_tunnel(prev_center.x, new_center.x, prev_center.y)
					create_v_tunnel(prev_center.y, new_center.y, new_center.x)
				else:
					create_v_tunnel(prev_center.y, new_center.y, prev_center.x)
					create_h_tunnel(prev_center.x, new_center.x, new_center.y)
			
			rooms.append(new_room)
	
	if rooms.size() > 0:
		var last_room = rooms[-1]
		var stairs_x = int(last_room.position.x + last_room.size.x / 2)
		var stairs_y = int(last_room.position.y + last_room.size.y / 2)
		dungeon_map[stairs_x][stairs_y] = TileType.STAIRS_DOWN
	
	draw_tilemap()

func create_room(room: Rect2):
	for x in range(int(room.position.x), int(room.position.x + room.size.x)):
		for y in range(int(room.position.y), int(room.position.y + room.size.y)):
			dungeon_map[x][y] = TileType.FLOOR

func create_h_tunnel(x1, x2, y):
	for x in range(min(x1, x2), max(x1, x2) + 1):
		if x >= 0 and x < MAP_WIDTH and y >= 0 and y < MAP_HEIGHT:
			dungeon_map[x][int(y)] = TileType.FLOOR

func create_v_tunnel(y1, y2, x):
	for y in range(min(y1, y2), max(y1, y2) + 1):
		if x >= 0 and x < MAP_WIDTH and y >= 0 and y < MAP_HEIGHT:
			dungeon_map[int(x)][y] = TileType.FLOOR

func draw_tilemap():
	tilemap.clear()
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			var tile_pos = Vector2i(x, y)
			match dungeon_map[x][y]:
				TileType.WALL:
					tilemap.set_cell(tile_pos, 0, Vector2i(0, 0))
				TileType.FLOOR:
					tilemap.set_cell(tile_pos, 0, Vector2i(1, 0))
				TileType.STAIRS_DOWN:
					tilemap.set_cell(tile_pos, 0, Vector2i(2, 0))
	
	if dungeon_tilemap:
		dungeon_tilemap.queue_free()
	
	dungeon_tilemap = DungeonVisuals.create_tilemap(self)
	add_child(dungeon_tilemap)
	DungeonVisuals.draw_dungeon_tiles(dungeon_tilemap, self)
	DungeonVisuals.add_dungeon_props(self)

func spawn_player():
	if rooms.size() > 0:
		var first_room = rooms[0]
		var spawn_pos = first_room.get_center() * TILE_SIZE
		player.position = spawn_pos
		damage_taken_this_floor = 0

func spawn_enemies():
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	
	for i in range(1, rooms.size()):
		var room_type = room_types[i] if i < room_types.size() else RoomType.NORMAL
		
		var spawn_chance = 70
		if room_type == RoomType.TREASURE:
			spawn_chance = 40
		elif room_type == RoomType.BOSS:
			spawn_chance = 100
		
		if randi() % 100 < spawn_chance:
			var room = rooms[i]
			var enemy_count = 1
			
			if room_type == RoomType.NORMAL:
				enemy_count = randi() % 3 + 1
			elif room_type == RoomType.TREASURE:
				enemy_count = randi() % 2 + 1
			elif room_type == RoomType.BOSS:
				enemy_count = 1
			
			for j in range(enemy_count):
				var enemy = preload("res://DieselPunk/scenes/enemy.tscn").instantiate()
				var spawn_x = randi() % int(room.size.x) + int(room.position.x)
				var spawn_y = randi() % int(room.size.y) + int(room.position.y)
				enemy.position = Vector2(spawn_x, spawn_y) * TILE_SIZE
				enemies_node.add_child(enemy)
				enemies.append(enemy)

func spawn_items():
	for item_pickup in items_on_floor:
		if is_instance_valid(item_pickup):
			item_pickup.queue_free()
	items_on_floor.clear()
	
	for i in range(rooms.size()):
		var room = rooms[i]
		var room_type = room_types[i] if i < room_types.size() else RoomType.NORMAL
		
		var item_chance = 30
		if room_type == RoomType.TREASURE:
			item_chance = 90
			for j in range(2 + randi() % 3):
				spawn_item_in_room(room)
		elif room_type == RoomType.NORMAL and randi() % 100 < item_chance:
			spawn_item_in_room(room)

func spawn_traps():
	for trap in traps:
		if is_instance_valid(trap):
			trap.queue_free()
	traps.clear()
	
	var trap_count = 5 + current_floor
	for i in range(trap_count):
		var x = randi() % MAP_WIDTH
		var y = randi() % MAP_HEIGHT
		
		if dungeon_map[x][y] == TileType.FLOOR:
			var trap_scene = preload("res://DieselPunk/scenes/trap.tscn")
			var trap = trap_scene.instantiate()
			trap.position = Vector2(x, y) * TILE_SIZE
			add_child(trap)
			traps.append(trap)

func spawn_item_in_room(room: Rect2):
	var item = ItemSystem.get_random_item(current_floor)
	var spawn_x = randi() % int(room.size.x) + int(room.position.x)
	var spawn_y = randi() % int(room.size.y) + int(room.position.y)
	var world_pos = Vector2(spawn_x, spawn_y) * TILE_SIZE
	spawn_item_at_pos(world_pos, item)

func spawn_item_at(world_pos: Vector2):
	var item = ItemSystem.get_random_item(current_floor)
	spawn_item_at_pos(world_pos, item)

func spawn_item_at_pos(world_pos: Vector2, item):
	var pickup_scene = preload("res://DieselPunk/scenes/item_pickup.tscn")
	var pickup = pickup_scene.instantiate()
	pickup.position = world_pos
	add_child(pickup)
	pickup.setup_item(item)
	items_on_floor.append(pickup)

func player_pickup_item(item):
	add_message("[color=yellow]Found: " + item.name + "[/color]")
	AudioManager.play_pickup_sound(self)
	
	if item.type == 2:
		player.inventory.append(item)
		add_message("[color=green]Added to inventory[/color]")
		
		if player.inventory.size() >= 10:
			achievement_manager.check_achievement("hoarder")
	else:
		player.equip_item(item)
		
		if player.equipped_weapon and player.equipped_armor:
			achievement_manager.check_achievement("well_equipped")
	
	if item.rarity == 2:
		achievement_manager.check_achievement("collector")
	elif item.rarity == 3:
		achievement_manager.check_achievement("treasure_hunter")
	
	update_ui()

func enemy_killed(enemy):
	enemies_killed_total += 1
	combo_tracker.add_kill()
	
	if enemies_killed_total == 1:
		achievement_manager.check_achievement("first_blood")
	elif enemies_killed_total == 50:
		achievement_manager.check_achievement("slayer")
	elif enemies_killed_total == 100:
		achievement_manager.check_achievement("exterminator")
	
	if current_floor % 5 == 0:
		achievement_manager.check_achievement("boss_slayer")

func player_took_damage(amount: int):
	damage_taken_this_floor += amount
	combo_tracker.break_combo()
	
	if player.health > 0 and player.health <= player.max_health * 0.1:
		achievement_manager.check_achievement("survivor")

func is_walkable(grid_pos: Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= MAP_WIDTH or grid_pos.y < 0 or grid_pos.y >= MAP_HEIGHT:
		return false
	return dungeon_map[grid_pos.x][grid_pos.y] != TileType.WALL

func get_tile_at(grid_pos: Vector2i):
	if grid_pos.x < 0 or grid_pos.x >= MAP_WIDTH or grid_pos.y < 0 or grid_pos.y >= MAP_HEIGHT:
		return TileType.WALL
	return dungeon_map[grid_pos.x][grid_pos.y]

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))

func enemy_at_position(grid_pos: Vector2i):
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var enemy_grid = world_to_grid(enemy.position)
		if enemy_grid == grid_pos:
			return enemy
	return null

func take_turn():
	if game_over:
		return
	
	var player_grid = world_to_grid(player.position)
	for dx in range(-3, 4):
		for dy in range(-3, 4):
			var x = player_grid.x + dx
			var y = player_grid.y + dy
			if x >= 0 and x < MAP_WIDTH and y >= 0 and y < MAP_HEIGHT:
				explored_tiles[x][y] = true
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.take_turn()
	
	update_ui()
	
	if fog_layer:
		DungeonVisuals.update_fog(self, fog_layer)

func update_ui():
	health_bar.value = player.health
	health_bar.max_value = player.max_health
	
	var combo_text = ""
	if combo_tracker.combo_count > 0:
		combo_text = "COMBO x" + str(combo_tracker.combo_count) + "!"
	combo_label.text = combo_text
	combo_label.add_theme_color_override("font_color", combo_tracker.get_combo_color())
	combo_label.add_theme_font_size_override("font_size", 24 + combo_tracker.combo_count * 2)
	
	stats_label.text = "Floor: %d\nHealth: %d/%d\nAttack: %d (x%.1f)\nDefense: %d\nLevel: %d\nXP: %d/%d\nKills: %d" % [
		current_floor,
		player.health,
		player.max_health,
		player.attack,
		combo_tracker.damage_multiplier,
		player.defense,
		player.level,
		player.experience,
		player.experience_to_next,
		enemies_killed_total
	]
	
	var inv_text = "INVENTORY (E to use):\n\n"
	if player.equipped_weapon:
		inv_text += "[WEAPON] " + player.equipped_weapon.name + "\n"
	if player.equipped_armor:
		inv_text += "[ARMOR] " + player.equipped_armor.name + "\n"
	
	if player.inventory.size() > 0:
		inv_text += "\nConsumables:\n"
		for item in player.inventory:
			var rarity_color = ""
			match item.rarity:
				0: rarity_color = "gray"
				1: rarity_color = "green"
				2: rarity_color = "blue"
				3: rarity_color = "yellow"
			inv_text += "[color=" + rarity_color + "]• " + item.name + "[/color]\n"
	else:
		inv_text += "\nNo consumables"
	
	inv_text += "\n[color=orange]Achievements: " + str(achievement_manager.get_unlocked_count()) + "/" + str(achievement_manager.get_total_count()) + "[/color]"
	inventory_label.text = inv_text

# ✅ MINIMAP DISABLED - Remove _draw() function entirely
# The update_minimap() call remains but does nothing now

func update_minimap():
	pass  # Disabled

func add_message(msg: String):
	messages.append(msg)
	if messages.size() > 10:
		messages.pop_front()
	
	var log_text = ""
	for message in messages:
		log_text += message + "\n"
	message_log.text = log_text

func next_floor():
	current_floor += 1
	
	if current_floor == 5:
		achievement_manager.check_achievement("explorer")
	elif current_floor == 10:
		achievement_manager.check_achievement("deep_diver")
	elif current_floor == 20:
		achievement_manager.check_achievement("abyss_walker")
	
	if damage_taken_this_floor == 0 and current_floor > 1:
		achievement_manager.check_achievement("untouchable")
	
	generate_dungeon()
	
	if fog_layer:
		fog_layer.queue_free()
	fog_layer = DungeonVisuals.create_fog_overlay(self)
	add_child(fog_layer)
	
	spawn_player()
	spawn_enemies()
	spawn_items()
	spawn_traps()
	combo_tracker.reset()
	
	add_message("[color=orange]═══ Floor " + str(current_floor) + " ═══[/color]")
	if current_floor % 5 == 0:
		add_message("[color=red]⚠ BOSS FLOOR ⚠[/color]")

func player_died():
	game_over = true
	AudioManager.play_death_sound(self)
	
	add_message("[color=red]╔════════════════╗[/color]")
	add_message("[color=red]║   YOU  DIED    ║[/color]")
	add_message("[color=red]╚════════════════╝[/color]")
	add_message("Floor: " + str(current_floor))
	add_message("Level: " + str(player.level))
	add_message("Kills: " + str(enemies_killed_total))
	add_message("Max Combo: " + str(combo_tracker.max_combo))
	add_message("Achievements: " + str(achievement_manager.get_unlocked_count()) + "/" + str(achievement_manager.get_total_count()))
	add_message("[color=gray]Press ESC to restart[/color]")

func _input(event):
	if game_over and event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func _on_achievement_unlocked(achievement_name: String):
	add_message("[color=gold]★ ACHIEVEMENT: " + achievement_name + " ★[/color]")
	show_achievement_popup(achievement_name)
	AudioManager.play_level_up_sound(self)

func show_achievement_popup(achievement_name: String):
	achievement_text.text = "🏆 " + achievement_name
	achievement_text.add_theme_font_size_override("font_size", 20)
	achievement_text.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	
	var tween = create_tween()
	tween.tween_property(achievement_popup, "offset_top", 10, 0.5)
	tween.tween_interval(2.0)
	tween.tween_property(achievement_popup, "offset_top", -100, 0.5)

func _on_combo_increased(count: int):
	if count >= 5:
		add_message("[color=orange]COMBO x" + str(count) + "![/color]")

func _on_combo_broken():
	if combo_tracker.max_combo >= 3:
		add_message("[color=gray]Combo broken[/color]")

func _on_combo_milestone(count: int):
	if count == 5:
		achievement_manager.check_achievement("combo_master")
		add_message("[color=gold]★ 5X COMBO MASTER! ★[/color]")
