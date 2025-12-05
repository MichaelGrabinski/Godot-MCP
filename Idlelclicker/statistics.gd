extends Control

var SCREEN_WIDTH: float
var SCREEN_HEIGHT: float
var FONT_TITLE: int
var FONT_LARGE: int
var FONT_MEDIUM: int

func _ready():
	_setup_screen_size()
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
	title.text = "STATISTICS"
	title.position = Vector2(SCREEN_WIDTH * 0.35, 40)
	title.add_theme_font_size_override("font_size", FONT_TITLE)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	add_child(title)
	
	# Scroll container
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 120)
	scroll.size = Vector2(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 150)
	add_child(scroll)
	
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	scroll.add_child(container)
	
	var stats = _load_stats()
	
	_add_section(container, "CLOCKWORK TOWER", Color(0.85, 0.65, 0.35))
	_add_stat(container, "Tower Level", str(stats.tower_level))
	_add_stat(container, "Total Cogs", _format_number(stats.total_cogs))
	_add_stat(container, "Total Clicks", _format_number(stats.total_clicks))
	_add_stat(container, "Cogs/Second", "%.1f" % stats.cps)
	_add_stat(container, "Prestige Level", str(stats.prestige))
	_add_stat(container, "Multiplier", "%.1fx" % stats.multiplier)
	_add_stat(container, "Golden Cogs", str(stats.golden_cogs))
	_add_stat(container, "Playtime", _format_time(stats.playtime))
	
	_add_section(container, "EMPIRE RATING", Color(1, 0.85, 0.35))
	var rating = _calculate_rating(stats.total_cogs, stats.prestige)
	_add_stat(container, "Your Rank", rating)

func _style_button(button: Button):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.18, 0.12)
	style.border_color = Color(0.6, 0.45, 0.25)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	button.add_theme_stylebox_override("normal", style)
	
	var hover = style.duplicate()
	hover.bg_color = Color(0.35, 0.25, 0.18)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	
	button.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	button.add_theme_font_size_override("font_size", FONT_MEDIUM)

func _add_section(parent: VBoxContainer, text: String, color: Color):
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	parent.add_child(spacer)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(SCREEN_WIDTH - 60, 50)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color.darkened(0.7)
	style.border_color = color
	style.border_width_left = 5
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	
	var label = Label.new()
	label.text = text
	label.position = Vector2(20, 10)
	label.add_theme_font_size_override("font_size", FONT_LARGE)
	label.add_theme_color_override("font_color", color)
	panel.add_child(label)

func _add_stat(parent: VBoxContainer, stat_name: String, value: String):
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(SCREEN_WIDTH - 60, 40)
	parent.add_child(row)
	
	var name_label = Label.new()
	name_label.text = stat_name + ":"
	name_label.custom_minimum_size = Vector2(SCREEN_WIDTH * 0.5, 40)
	name_label.add_theme_font_size_override("font_size", FONT_MEDIUM)
	name_label.add_theme_color_override("font_color", Color(0.75, 0.65, 0.55))
	row.add_child(name_label)
	
	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", FONT_MEDIUM)
	value_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	row.add_child(value_label)

func _load_stats() -> Dictionary:
	var stats = {
		"tower_level": 0,
		"total_cogs": 0.0,
		"total_clicks": 0,
		"cps": 0.0,
		"prestige": 0,
		"multiplier": 1.0,
		"golden_cogs": 0,
		"playtime": 0.0,
	}
	
	if FileAccess.file_exists("user://steampunk_save.json"):
		var file = FileAccess.open("user://steampunk_save.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var d = json.get_data()
				stats.tower_level = d.get("tower_level", 0)
				stats.total_cogs = d.get("total_cogs_earned", 0.0)
				stats.total_clicks = d.get("total_clicks", 0)
				stats.cps = d.get("cogs_per_second", 0.0)
				stats.prestige = d.get("prestige_level", 0)
				stats.multiplier = d.get("prestige_multiplier", 1.0)
				stats.golden_cogs = d.get("golden_cogs", 0)
				stats.playtime = d.get("playtime", 0.0)
			file.close()
	
	return stats

func _calculate_rating(wealth: float, prestige: int) -> String:
	var score = log(wealth + 1) * 10 + prestige * 50
	
	if score >= 500: return "LEGENDARY"
	elif score >= 300: return "MASTER"
	elif score >= 150: return "EXPERT"
	elif score >= 50: return "JOURNEYMAN"
	elif score >= 10: return "APPRENTICE"
	else: return "NOVICE"

func _format_number(num: float) -> String:
	if num < 1000: return "%.0f" % num
	elif num < 1000000: return "%.1fK" % (num / 1000.0)
	elif num < 1000000000: return "%.1fM" % (num / 1000000.0)
	else: return "%.1fB" % (num / 1000000000.0)

func _format_time(seconds: float) -> String:
	var h = int(seconds) / 3600
	var m = (int(seconds) % 3600) / 60
	if h > 0: return "%dh %dm" % [h, m]
	else: return "%dm" % m

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
