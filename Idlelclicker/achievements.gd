extends Control

var SCREEN_WIDTH: float
var SCREEN_HEIGHT: float
var FONT_TITLE: int
var FONT_LARGE: int
var FONT_MEDIUM: int

var achievements = [
	{"id": "first_click", "name": "First Steps", "desc": "Click once", "icon": "1", "reward": 10, "unlocked": false},
	{"id": "hundred_cogs", "name": "Pocket Change", "desc": "Earn 100 cogs", "icon": "$", "reward": 25, "unlocked": false},
	{"id": "thousand_cogs", "name": "Getting Rich", "desc": "Earn 1,000 cogs", "icon": "$$", "reward": 50, "unlocked": false},
	{"id": "millionaire", "name": "Millionaire", "desc": "Earn 1M cogs", "icon": "$$$", "reward": 500, "unlocked": false},
	{"id": "tower_5", "name": "Foundation", "desc": "Tower Level 5", "icon": "T5", "reward": 50, "unlocked": false},
	{"id": "tower_10", "name": "Rising Tower", "desc": "Tower Level 10", "icon": "T10", "reward": 100, "unlocked": false},
	{"id": "first_upgrade", "name": "Investor", "desc": "Buy first upgrade", "icon": "+", "reward": 15, "unlocked": false},
	{"id": "ten_upgrades", "name": "Factory Owner", "desc": "Own 10 upgrades", "icon": "++", "reward": 75, "unlocked": false},
	{"id": "prestige_1", "name": "Rebirth", "desc": "Prestige once", "icon": "*", "reward": 200, "unlocked": false},
	{"id": "fever", "name": "Fever Time!", "desc": "Trigger fever", "icon": "!", "reward": 75, "unlocked": false},
	{"id": "combo_10", "name": "Combo!", "desc": "10x combo", "icon": "x10", "reward": 50, "unlocked": false},
	{"id": "critical", "name": "Critical Hit!", "desc": "Land a crit", "icon": "!!", "reward": 25, "unlocked": false},
]

func _ready():
	_setup_screen_size()
	_load_achievements()
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
	title.text = "ACHIEVEMENTS"
	title.position = Vector2(SCREEN_WIDTH * 0.3, 40)
	title.add_theme_font_size_override("font_size", FONT_TITLE)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.35))
	add_child(title)
	
	# Progress
	var unlocked = achievements.filter(func(a): return a.unlocked).size()
	var progress = Label.new()
	progress.text = "Unlocked: %d / %d" % [unlocked, achievements.size()]
	progress.position = Vector2(SCREEN_WIDTH * 0.35, 90)
	progress.add_theme_font_size_override("font_size", FONT_LARGE)
	progress.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	add_child(progress)
	
	# Scroll container
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 140)
	scroll.size = Vector2(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 170)
	add_child(scroll)
	
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 15)
	scroll.add_child(container)
	
	for ach in achievements:
		_create_achievement_card(container, ach)

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

func _create_achievement_card(parent: VBoxContainer, ach: Dictionary):
	var card = Panel.new()
	card.custom_minimum_size = Vector2(SCREEN_WIDTH - 60, 100)
	
	var color = Color(1, 0.85, 0.35) if ach.unlocked else Color(0.4, 0.35, 0.3)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.1, 0.08) if ach.unlocked else Color(0.08, 0.07, 0.06)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	card.add_theme_stylebox_override("panel", style)
	parent.add_child(card)
	
	# Icon
	var icon = Label.new()
	icon.text = "[" + ach.icon + "]" if ach.unlocked else "[?]"
	icon.position = Vector2(15, 30)
	icon.add_theme_font_size_override("font_size", FONT_LARGE)
	icon.modulate = Color(1, 1, 1) if ach.unlocked else Color(0.4, 0.4, 0.4)
	card.add_child(icon)
	
	# Name
	var name_label = Label.new()
	name_label.text = ach.name if ach.unlocked else "???"
	name_label.position = Vector2(90, 15)
	name_label.add_theme_font_size_override("font_size", FONT_LARGE)
	name_label.add_theme_color_override("font_color", color)
	card.add_child(name_label)
	
	# Description
	var desc = Label.new()
	desc.text = ach.desc
	desc.position = Vector2(90, 50)
	desc.add_theme_font_size_override("font_size", FONT_MEDIUM)
	desc.add_theme_color_override("font_color", Color(0.7, 0.65, 0.55) if ach.unlocked else Color(0.4, 0.35, 0.3))
	card.add_child(desc)
	
	# Reward
	var reward = Label.new()
	reward.text = "+%d" % ach.reward
	reward.position = Vector2(SCREEN_WIDTH - 150, 35)
	reward.add_theme_font_size_override("font_size", FONT_LARGE)
	reward.add_theme_color_override("font_color", Color(1, 0.9, 0.4) if ach.unlocked else Color(0.35, 0.3, 0.25))
	card.add_child(reward)

func _load_achievements():
	if FileAccess.file_exists("user://steampunk_save.json"):
		var file = FileAccess.open("user://steampunk_save.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK:
				var data = json.get_data()
				var saved = data.get("achievements", {})
				for ach in achievements:
					if saved.has(ach.id):
						var val = saved[ach.id]
						if typeof(val) == TYPE_DICTIONARY:
							ach.unlocked = val.get("unlocked", false)
						else:
							ach.unlocked = val
			file.close()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
