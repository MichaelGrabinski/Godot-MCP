extends Control

var SCREEN_WIDTH: float
var SCREEN_HEIGHT: float
var FONT_TITLE: int
var FONT_LARGE: int
var FONT_MEDIUM: int

var settings = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"particles_enabled": true,
	"screen_shake": true,
	"show_damage_numbers": true,
}

func _ready():
	_setup_screen_size()
	_load_settings()
	_create_ui()

func _setup_screen_size():
	var viewport_size = get_viewport().get_visible_rect().size
	SCREEN_WIDTH = viewport_size.x
	SCREEN_HEIGHT = viewport_size.y
	
	var scale = min(SCREEN_WIDTH, SCREEN_HEIGHT) / 1080.0
	FONT_TITLE = int(44 * scale)
	FONT_LARGE = int(28 * scale)
	FONT_MEDIUM = int(22 * scale)
	
	FONT_TITLE = max(FONT_TITLE, 22)
	FONT_LARGE = max(FONT_LARGE, 16)
	FONT_MEDIUM = max(FONT_MEDIUM, 12)

func _create_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.05, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Back button
	var back_btn = Button.new()
	back_btn.text = "< BACK"
	back_btn.position = Vector2(20, 30)
	back_btn.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.2, 60)
	back_btn.pressed.connect(_on_back_pressed)
	_style_button(back_btn)
	add_child(back_btn)
	
	# Title
	var title = Label.new()
	title.text = "OPTIONS"
	title.position = Vector2(SCREEN_WIDTH * 0.38, 40)
	title.add_theme_font_size_override("font_size", FONT_TITLE)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	add_child(title)
	
	# Scroll container
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(30, 120)
	scroll.size = Vector2(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 200)
	add_child(scroll)
	
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 20)
	scroll.add_child(container)
	
	# Audio section
	_add_section(container, "AUDIO")
	_add_slider(container, "Master Volume", "master_volume")
	_add_slider(container, "Music Volume", "music_volume")
	_add_slider(container, "SFX Volume", "sfx_volume")
	
	# Visual section
	_add_section(container, "VISUAL")
	_add_toggle(container, "Particles", "particles_enabled")
	_add_toggle(container, "Screen Shake", "screen_shake")
	_add_toggle(container, "Damage Numbers", "show_damage_numbers")
	
	# Save button
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	container.add_child(spacer)
	
	var save_btn = Button.new()
	save_btn.text = "SAVE SETTINGS"
	save_btn.custom_minimum_size = Vector2(SCREEN_WIDTH - 100, 70)
	save_btn.pressed.connect(_save_settings)
	_style_button(save_btn, Color(0.2, 0.35, 0.2))
	container.add_child(save_btn)

func _style_button(button: Button, color: Color = Color(0.25, 0.18, 0.12)):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.lightened(0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	button.add_theme_stylebox_override("normal", style)
	
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.15)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	
	button.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	button.add_theme_font_size_override("font_size", FONT_MEDIUM)

func _add_section(parent: VBoxContainer, text: String):
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	parent.add_child(spacer)
	
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", FONT_LARGE)
	label.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
	parent.add_child(label)

func _add_slider(parent: VBoxContainer, label_text: String, key: String):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(SCREEN_WIDTH - 80, 60)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.35, 60)
	label.add_theme_font_size_override("font_size", FONT_MEDIUM)
	label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
	row.add_child(label)
	
	var slider = HSlider.new()
	slider.name = key
	slider.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.35, 60)
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.1
	slider.value = settings.get(key, 1.0)
	slider.value_changed.connect(func(v): settings[key] = v)
	row.add_child(slider)
	
	var value = Label.new()
	value.text = "%d%%" % int(settings.get(key, 1.0) * 100)
	value.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.15, 60)
	value.add_theme_font_size_override("font_size", FONT_MEDIUM)
	value.add_theme_color_override("font_color", Color(1, 0.95, 0.7))
	slider.value_changed.connect(func(v): value.text = "%d%%" % int(v * 100))
	row.add_child(value)

func _add_toggle(parent: VBoxContainer, label_text: String, key: String):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(SCREEN_WIDTH - 80, 70)
	parent.add_child(row)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.6, 70)
	label.add_theme_font_size_override("font_size", FONT_MEDIUM)
	label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
	row.add_child(label)
	
	var toggle = CheckButton.new()
	toggle.button_pressed = settings.get(key, true)
	toggle.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.2, 70)
	toggle.toggled.connect(func(v): settings[key] = v)
	row.add_child(toggle)

func _load_settings():
	if FileAccess.file_exists("user://settings.json"):
		var file = FileAccess.open("user://settings.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var data = json.get_data()
				for key in data:
					if settings.has(key):
						settings[key] = data[key]
			file.close()

func _save_settings():
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

func _on_back_pressed():
	_save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
