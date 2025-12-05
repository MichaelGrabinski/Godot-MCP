extends Node

## Spawns waves of enemies along the path

@export var spawn_interval: float = 1.0

var game_manager
var enemy_path
var enemy_scene = preload("res://TowerDefense/scenes/enemy_animated.tscn")

func _ready():
	# Find game manager in multiple possible locations
	game_manager = get_node_or_null("/root/test_level/GameManager")
	if not game_manager:
		game_manager = get_node_or_null("/root/level_from_json/GameManager")
	if not game_manager:
		# Try to find it as a sibling
		game_manager = get_parent().get_node_or_null("GameManager")
	
	# Find enemy path - try multiple locations
	await get_tree().process_frame  # Wait for level to load
	
	enemy_path = get_node_or_null("/root/test_level/PathLayer/EnemyPath")
	if not enemy_path:
		enemy_path = get_node_or_null("/root/level_from_json/PathLayer/EnemyPath")
	if not enemy_path:
		# Try to find it from parent
		var parent = get_parent()
		var path_layer = parent.get_node_or_null("PathLayer")
		if path_layer:
			enemy_path = path_layer.get_node_or_null("EnemyPath")
	
	if not enemy_path:
		print("ERROR: Could not find EnemyPath! Checking tree...")
		_debug_print_tree(get_tree().root)
	else:
		print("✓ Enemy spawner found path: " + enemy_path.get_path())
	
	if game_manager:
		game_manager.wave_started.connect(_on_wave_started)
		print("✓ Enemy spawner connected to game manager")

func _debug_print_tree(node, indent = ""):
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		if indent.length() < 20:  # Limit depth
			_debug_print_tree(child, indent + "  ")

func _on_wave_started(wave_number: int):
	if not enemy_path:
		print("ERROR: No enemy path when wave started!")
		return
	spawn_wave(wave_number)

func spawn_wave(wave_number: int):
	var enemy_count = game_manager.enemies_in_wave
	
	for i in range(enemy_count):
		await get_tree().create_timer(spawn_interval).timeout
		spawn_enemy(wave_number)

func spawn_enemy(wave_number: int):
	if not enemy_path:
		print("Error: No enemy path found!")
		return
	
	# Instantiate the animated enemy scene
	var enemy = enemy_scene.instantiate()
	
	# Scale enemy stats with wave number
	enemy.health = 100 + (wave_number - 1) * 20
	enemy.max_health = enemy.health
	enemy.speed = 100 + (wave_number - 1) * 5
	enemy.gold_reward = 10 + (wave_number - 1) * 2
	
	enemy_path.add_child(enemy)
	
	if game_manager:
		game_manager.enemy_spawned()
