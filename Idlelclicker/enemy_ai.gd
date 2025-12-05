extends CharacterBody3D

# Enemy AI States
enum State {
	PATROL,
	CHASE,
	ATTACK,
	DEAD
}

# Export variables for easy tweaking
@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.0
@export var detection_range: float = 10.0
@export var attack_range: float = 2.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.5
@export var waypoint_reach_distance: float = 0.5
@export var max_health: float = 50.0

# Waypoint system
@export var waypoints: Array[Node3D] = []
var current_waypoint_index: int = 0

# State management
var current_state: State = State.PATROL
var player: Node3D = null
var attack_timer: float = 0.0
var current_health: float = max_health

# References
@onready var detection_area: Area3D = $DetectionArea
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	# Add to enemies group
	add_to_group("enemies")
	
	# Find all waypoints if not manually assigned
	if waypoints.is_empty():
		var waypoint_parent = get_tree().root.find_child("Waypoints", true, false)
		if waypoint_parent:
			for child in waypoint_parent.get_children():
				if child is Marker3D or child is Node3D:
					waypoints.append(child)
	
	# Connect detection area signals
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered_detection)
		detection_area.body_exited.connect(_on_body_exited_detection)

func _physics_process(delta: float):
	if current_state == State.DEAD:
		return
	
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
	
	# State machine
	match current_state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)
		State.ATTACK:
			_attack(delta)
	
	# Apply movement
	move_and_slide()

func _patrol(delta: float):
	if waypoints.is_empty():
		return
	
	# Check if player is in range
	if player and is_instance_valid(player) and global_position.distance_to(player.global_position) <= detection_range:
		_change_state(State.CHASE)
		return
	
	# Move towards current waypoint
	var target_waypoint = waypoints[current_waypoint_index]
	var direction = (target_waypoint.global_position - global_position).normalized()
	
	# Only move in XZ plane (ignore Y for ground-based movement)
	direction.y = 0
	direction = direction.normalized()
	
	velocity = direction * patrol_speed
	
	# Look at target
	if direction.length() > 0:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	
	# Check if reached waypoint
	var distance_to_waypoint = global_position.distance_to(target_waypoint.global_position)
	if distance_to_waypoint < waypoint_reach_distance:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()

func _chase(delta: float):
	if not player or not is_instance_valid(player):
		_change_state(State.PATROL)
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player is out of detection range
	if distance_to_player > detection_range * 1.5:  # Add hysteresis
		_change_state(State.PATROL)
		return
	
	# Check if in attack range
	if distance_to_player <= attack_range:
		_change_state(State.ATTACK)
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	direction = direction.normalized()
	
	velocity = direction * chase_speed
	
	# Look at player
	if direction.length() > 0:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)

func _attack(delta: float):
	if not player or not is_instance_valid(player):
		_change_state(State.PATROL)
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if player moved out of attack range
	if distance_to_player > attack_range * 1.2:  # Add hysteresis
		_change_state(State.CHASE)
		return
	
	# Stop moving during attack
	velocity = Vector3.ZERO
	
	# Look at player
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	if direction.length() > 0:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	
	# Perform attack if cooldown is ready
	if attack_timer <= 0:
		_perform_attack()
		attack_timer = attack_cooldown

func _perform_attack():
	print("Enemy attacks player for ", attack_damage, " damage!")
	
	# Flash red when attacking
	if mesh_instance:
		_flash_color(Color.WHITE)
	
	# Try to call damage function on player if it exists
	if player and is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(attack_damage)

func take_damage(damage: float):
	if current_state == State.DEAD:
		return
	
	current_health -= damage
	print("Enemy took ", damage, " damage! Health: ", current_health, "/", max_health)
	
	# Flash when taking damage
	_flash_color(Color.YELLOW)
	
	# Force chase player when hit
	if player and current_state == State.PATROL:
		_change_state(State.CHASE)
	
	# Check if dead
	if current_health <= 0:
		_die()

func _die():
	print("Enemy died!")
	_change_state(State.DEAD)
	
	# Notify game manager
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("enemy_defeated"):
		game_manager.enemy_defeated()
	
	# Change color to black
	if mesh_instance and mesh_instance.get_surface_override_material(0):
		var mat = mesh_instance.get_surface_override_material(0)
		mat.albedo_color = Color(0.2, 0.2, 0.2, 1)
	
	# Disable collision
	collision_layer = 0
	collision_mask = 0
	
	# Remove from enemies group
	remove_from_group("enemies")
	
	# Remove after delay
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _flash_color(color: Color):
	if not mesh_instance:
		return
	
	var original_mat = mesh_instance.get_surface_override_material(0)
	if original_mat:
		var original_color = original_mat.albedo_color
		original_mat.albedo_color = color
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(mesh_instance) and mesh_instance.get_surface_override_material(0):
			mesh_instance.get_surface_override_material(0).albedo_color = original_color

func _change_state(new_state: State):
	if current_state == new_state:
		return
	
	current_state = new_state

func _on_body_entered_detection(body: Node3D):
	# Check if the body is the player
	if body.is_in_group("player") and current_state != State.DEAD:
		player = body
		if current_state == State.PATROL:
			_change_state(State.CHASE)

func _on_body_exited_detection(body: Node3D):
	if body == player:
		# Let state machine handle losing player
		pass
