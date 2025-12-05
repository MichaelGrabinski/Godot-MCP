extends CharacterBody3D

# Movement
@export var speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

# Combat
@export var max_health: float = 100.0
@export var attack_damage: float = 25.0
@export var attack_range: float = 3.0
@export var attack_cooldown: float = 0.5

var current_health: float = max_health
var attack_timer: float = 0.0
var is_alive: bool = true

# Camera
var camera_rotation: Vector2 = Vector2.ZERO

@onready var camera: Camera3D = $Camera3D

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Add to player group for enemy detection
	add_to_group("player")
	
	# Update health bar
	_update_health_bar()

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.x -= event.relative.y * mouse_sensitivity
		camera_rotation.y -= event.relative.x * mouse_sensitivity
		camera_rotation.x = clamp(camera_rotation.x, -PI/2, PI/2)
	
	# Toggle mouse capture
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if not is_alive:
		return
	
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta
	
	# Apply camera rotation
	rotation.y = camera_rotation.y
	if camera:
		camera.rotation.x = camera_rotation.x
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get input direction
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement
	var current_speed = sprint_speed if Input.is_action_pressed("ui_shift") else speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Attack
	if Input.is_action_pressed("ui_click") and attack_timer <= 0:
		_perform_attack()
		attack_timer = attack_cooldown
	
	move_and_slide()

func _perform_attack():
	print("Player attacks!")
	
	# Raycast to find enemies in front
	var space_state = get_world_3d().direct_space_state
	var from = global_position + Vector3(0, 1, 0)
	var to = from + (-transform.basis.z * attack_range)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider:
		var hit = result.collider
		# Check if hit enemy
		if hit.has_method("take_damage"):
			hit.take_damage(attack_damage)
			print("Hit enemy for ", attack_damage, " damage!")
	
	# Also check for enemies in range with area check
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= attack_range:
				var direction = (enemy.global_position - global_position).normalized()
				var forward = -transform.basis.z
				# Check if enemy is in front (dot product)
				if direction.dot(forward) > 0.5:
					if enemy.has_method("take_damage"):
						enemy.take_damage(attack_damage)

func take_damage(damage: float):
	if not is_alive:
		return
	
	current_health -= damage
	print("Player took ", damage, " damage! Health: ", current_health)
	
	# Update health bar
	_update_health_bar()
	
	# Check if dead
	if current_health <= 0:
		_die()

func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	_update_health_bar()
	print("Player healed for ", amount, ". Health: ", current_health)

func _update_health_bar():
	var health_bar = get_node_or_null("/root/UI/HealthBar")
	if health_bar:
		health_bar.value = current_health

func _die():
	is_alive = false
	print("Player died!")
	# Wait a moment then reload
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
