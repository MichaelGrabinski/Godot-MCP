extends CanvasLayer

# Mobile Touch Controls - Virtual Joystick & Buttons
# FIXED: Extends CanvasLayer!

signal move_pressed(direction: Vector2i)
signal ability_pressed(ability_index: int)
signal item_pressed

var touch_start_pos = Vector2.ZERO
var is_touching = false
var joystick_center = Vector2.ZERO
var joystick_radius = 80.0

var joystick_base = null
var joystick_knob = null
var ability1_button = null
var ability2_button = null
var item_button = null

func _ready():
	# Set layer to always be on top
	layer = 100
	
	# Get nodes
	joystick_base = $JoystickBase
	joystick_knob = $JoystickBase/JoystickKnob
	ability1_button = $AbilityButtons/Ability1
	ability2_button = $AbilityButtons/Ability2
	item_button = $ItemButton
	
	# Wait for viewport to be ready
	await get_tree().process_frame
	
	# Position controls
	var viewport_size = get_viewport().get_visible_rect().size
	joystick_base.position = Vector2(100, viewport_size.y - 150)
	joystick_center = joystick_base.position + Vector2(joystick_radius, joystick_radius)
	
	# Ability buttons on right side
	var button_y = viewport_size.y - 150
	ability1_button.position = Vector2(viewport_size.x - 200, button_y)
	ability2_button.position = Vector2(viewport_size.x - 120, button_y)
	item_button.position = Vector2(viewport_size.x - 160, button_y - 100)
	
	# Connect button signals
	ability1_button.pressed.connect(func(): ability_pressed.emit(0))
	ability2_button.pressed.connect(func(): ability_pressed.emit(1))
	item_button.pressed.connect(func(): item_pressed.emit())
	
	print("✅ Mobile controls ready!")

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if touch is in joystick area
			var touch_pos = event.position
			var dist = touch_pos.distance_to(joystick_center)
			if dist < joystick_radius * 2:
				is_touching = true
				touch_start_pos = touch_pos
				update_joystick(touch_pos)
		else:
			if is_touching:
				# Touch released - move in direction
				var direction = get_joystick_direction()
				if direction != Vector2i.ZERO:
					move_pressed.emit(direction)
				reset_joystick()
				is_touching = false
	
	elif event is InputEventScreenDrag:
		if is_touching:
			update_joystick(event.position)

func update_joystick(touch_pos: Vector2):
	if not joystick_knob:
		return
		
	# Calculate offset from center
	var offset = touch_pos - joystick_center
	
	# Clamp to radius
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	
	# Move knob
	joystick_knob.position = Vector2(joystick_radius, joystick_radius) + offset

func reset_joystick():
	if joystick_knob:
		joystick_knob.position = Vector2(joystick_radius, joystick_radius)

func get_joystick_direction() -> Vector2i:
	if not joystick_knob:
		return Vector2i.ZERO
		
	var offset = joystick_knob.position - Vector2(joystick_radius, joystick_radius)
	
	# Dead zone
	if offset.length() < 20:
		return Vector2i.ZERO
	
	# Convert to cardinal directions
	var angle = offset.angle()
	
	# Up: -90° ±45°
	if angle > -2.356 and angle < -0.785:
		return Vector2i(0, -1)
	# Down: 90° ±45°
	elif angle > 0.785 and angle < 2.356:
		return Vector2i(0, 1)
	# Left: 180° ±45°
	elif angle > 2.356 or angle < -2.356:
		return Vector2i(-1, 0)
	# Right: 0° ±45°
	else:
		return Vector2i(1, 0)
