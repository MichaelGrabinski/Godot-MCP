extends Node2D

## Basic tower that shoots at enemies

@export var damage: int = 20
@export var fire_rate: float = 1.0  # Shots per second
@export var range: float = 200.0
@export var projectile_speed: float = 400.0

var can_fire: bool = true
var current_target = null

func _ready():
	add_to_group("towers")
	
	# Create visual placeholder (you'll replace with your art)
	var base = ColorRect.new()
	base.size = Vector2(60, 60)
	base.position = Vector2(-30, -30)
	base.color = Color.BLUE
	add_child(base)
	
	# Range indicator (shows on selection)
	var range_circle = Polygon2D.new()
	range_circle.name = "RangeCircle"
	range_circle.color = Color(0.2, 0.5, 1.0, 0.2)
	range_circle.visible = false
	var points = []
	for i in range(32):
		var angle = i * PI * 2 / 32
		points.append(Vector2(cos(angle), sin(angle)) * range)
	range_circle.polygon = PackedVector2Array(points)
	add_child(range_circle)
	
	# Turret visual
	var turret = ColorRect.new()
	turret.name = "Turret"
	turret.size = Vector2(40, 15)
	turret.position = Vector2(0, -7.5)
	turret.pivot_offset = Vector2(0, 7.5)
	turret.color = Color.DARK_BLUE
	add_child(turret)

func _process(delta):
	find_target()
	
	if current_target:
		aim_at_target()
		
		if can_fire:
			shoot()

func find_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy = null
	var closest_distance = range
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	current_target = closest_enemy

func aim_at_target():
	if current_target and is_instance_valid(current_target):
		var turret = get_node_or_null("Turret")
		if turret:
			var direction = (current_target.global_position - global_position).angle()
			turret.rotation = direction

func shoot():
	if not current_target or not is_instance_valid(current_target):
		return
	
	can_fire = false
	
	# Create projectile
	var projectile = preload("res://TowerDefense/scripts/projectile.gd").new()
	projectile.damage = damage
	projectile.speed = projectile_speed
	projectile.target = current_target
	projectile.global_position = global_position
	
	# Add to projectiles layer
	var projectiles_layer = get_node("/root/test_level/Projectiles")
	projectiles_layer.add_child(projectile)
	
	# Reset fire timer
	await get_tree().create_timer(1.0 / fire_rate).timeout
	can_fire = true

func show_range():
	var range_circle = get_node_or_null("RangeCircle")
	if range_circle:
		range_circle.visible = true

func hide_range():
	var range_circle = get_node_or_null("RangeCircle")
	if range_circle:
		range_circle.visible = false
