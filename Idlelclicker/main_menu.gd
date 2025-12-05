extends Control

var SCREEN_WIDTH: float
var SCREEN_HEIGHT: float
var FONT_TITLE: int
var FONT_LARGE: int
var FONT_MEDIUM: int
var BUTTON_HEIGHT: int

var gears: Array = []
var title_pulse: float = 0.0

func _ready():
	_setup_screen_size()
	_create_ui()

func _setup_screen_size():
	var viewport_size = get_viewport().get_visible_rect().size
	SCREEN_WIDTH = viewport_size.x
	SCREEN_HEIGHT = viewport_size.y
	
	# Scale fonts
	var scale = min(SCREEN_WIDTH, SCREEN_HEIGHT) / 1080.0
	FONT_TITLE = int(56 * scale)
	FONT_LARGE = int(32 * scale)
	FONT_MEDIUM = int(26 * scale)
	BUTTON_HEIGHT = int(90 * scale)
	
	FONT_TITLE = max(FONT_TITLE, 28)
	FONT_LARGE = max(FONT_LARGE, 18)
	FONT_MEDIUM = max(FONT_MEDIUM, 14)
	BUTTON_HEIGHT = max(BUTTON_HEIGHT, 50)
	
	print("Main menu - Screen: ", SCREEN_WIDTH, "x", SCREEN_HEIGHT)

func _create_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Animated gears
	_create_gears()
	
	# Title
	var title = Label.new()
	title.name = "Title"
	title.text = "STEAMPUNK\nCLICKER"
	title.position = Vector2(SCREEN_WIDTH * 0.15, SCREEN_HEIGHT * 0.1)
	title.add_theme_font_size_override("font_size", FONT_TITLE)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.5))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.text = "Build Your Clockwork Empire"
	subtitle.position = Vector2(SCREEN_WIDTH * 0.15, SCREEN_HEIGHT * 0.1 + FONT_TITLE * 2.5)
	subtitle.add_theme_font_size_override("font_size", FONT_MEDIUM)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))
	add_child(subtitle)
	
	# Button container
	var button_container = VBoxContainer.new()
	button_container.position = Vector2(SCREEN_WIDTH * 0.1, SCREEN_HEIGHT * 0.35)
	button_container.size = Vector2(SCREEN_WIDTH * 0.8, SCREEN_HEIGHT * 0.6)
	button_container.add_theme_constant_override("separation", 15)
	add_child(button_container)
	
	var has_save = FileAccess.file_exists("user://steampunk_save.json")
	
	# Continue button
	if has_save:
		var continue_btn = _create_button("CONTINUE")
		continue_btn.pressed.connect(_on_continue_pressed)
		button_container.add_child(continue_btn)
	
	# New Game button
	var new_btn = _create_button("NEW GAME" if not has_save else "NEW GAME")
	new_btn.pressed.connect(_on_new_game_pressed)
	button_container.add_child(new_btn)
	
	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 20)
	button_container.add_child(spacer1)
	
	# Statistics
	var stats_btn = _create_button("STATISTICS", Color(0.2, 0.25, 0.2))
	stats_btn.pressed.connect(_on_stats_pressed)
	button_container.add_child(stats_btn)
	
	# Achievements
	var ach_btn = _create_button("ACHIEVEMENTS", Color(0.25, 0.22, 0.15))
	ach_btn.pressed.connect(_on_achievements_pressed)
	button_container.add_child(ach_btn)
	
	# Options
	var opt_btn = _create_button("OPTIONS", Color(0.2, 0.2, 0.25))
	opt_btn.pressed.connect(_on_options_pressed)
	button_container.add_child(opt_btn)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	button_container.add_child(spacer2)
	
	# Exit button
	var exit_btn = _create_button("EXIT", Color(0.3, 0.15, 0.15))
	exit_btn.pressed.connect(_on_exit_pressed)
	button_container.add_child(exit_btn)

func _create_button(text: String, color: Color = Color(0.2, 0.15, 0.1)) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.8, BUTTON_HEIGHT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.lightened(0.4)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", style)
	
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.15)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	
	button.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	button.add_theme_font_size_override("font_size", FONT_LARGE)
	
	return button

func _create_gears():
	var gear_data = [
		{"x": 0.1, "y": 0.08, "size": 60, "speed": 0.4},
		{"x": 0.9, "y": 0.06, "size": 45, "speed": -0.3},
		{"x": 0.05, "y": 0.4, "size": 70, "speed": 0.35},
		{"x": 0.95, "y": 0.35, "size": 55, "speed": -0.45},
		{"x": 0.08, "y": 0.7, "size": 50, "speed": 0.3},
		{"x": 0.92, "y": 0.65, "size": 65, "speed": -0.4},
	]
	
	for data in gear_data:
		var gear = _create_gear(data.size)
		gear.position = Vector2(SCREEN_WIDTH * data.x, SCREEN_HEIGHT * data.y)
		gear.set_meta("speed", data.speed)
		gear.modulate = Color(0.2, 0.15, 0.12, 0.3)
		add_child(gear)
		move_child(gear, 1)
		gears.append(gear)

func _create_gear(size: float) -> Node2D:
	var gear = Node2D.new()
	var teeth = int(size / 12)
	
	var center = ColorRect.new()
	center.size = Vector2(size * 0.4, size * 0.4)
	center.position = -center.size / 2
	center.color = Color(0.4, 0.3, 0.22)
	gear.add_child(center)
	
	for i in range(teeth):
		var angle = (2 * PI / teeth) * i
		var tooth = ColorRect.new()
		tooth.size = Vector2(size * 0.14, size * 0.26)
		tooth.position = Vector2(cos(angle) * size * 0.35, sin(angle) * size * 0.35) - tooth.size / 2
		tooth.rotation = angle + PI/2
		tooth.color = Color(0.4, 0.3, 0.22)
		gear.add_child(tooth)
	
	return gear

func _process(delta):
	for gear in gears:
		if is_instance_valid(gear):
			gear.rotation += delta * gear.get_meta("speed", 0.3)
	
	title_pulse += delta
	var title = get_node_or_null("Title")
	if title:
		var pulse = 1.0 + sin(title_pulse * 2) * 0.02
		title.scale = Vector2(pulse, pulse)

func _transition(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))

func _on_continue_pressed():
	_transition("res://scenes/steampunk_clicker.tscn")

func _on_new_game_pressed():
	if FileAccess.file_exists("user://steampunk_save.json"):
		DirAccess.remove_absolute("user://steampunk_save.json")
	_transition("res://scenes/steampunk_clicker.tscn")

func _on_stats_pressed():
	_transition("res://scenes/statistics.tscn")

func _on_achievements_pressed():
	_transition("res://scenes/achievements.tscn")

func _on_options_pressed():
	_transition("res://scenes/options.tscn")

func _on_exit_pressed():
	get_tree().quit()
