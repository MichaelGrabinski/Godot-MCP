extends Control

# Cross-Domain Synergies System
# Shows how domains benefit each other

var synergies = [
	{
		"name": "Industrial Efficiency",
		"from": "Tower",
		"to": "Mining",
		"formula": "Tower Level × 0.5% = Mining speed boost",
		"icon_from": "🏗️",
		"icon_to": "⛏️",
		"color": Color(0.8, 0.6, 0.3)
	},
	{
		"name": "Air Superiority",
		"from": "Airships",
		"to": "Tower",
		"formula": "Fleet Size × 1% = Tower production boost",
		"icon_from": "🛩️",
		"icon_to": "🏗️",
		"color": Color(0.5, 0.7, 0.9)
	},
	{
		"name": "Alchemical Transmutation",
		"from": "Alchemy",
		"to": "All",
		"formula": "Essence × 0.01% = All domains boost",
		"icon_from": "⚗️",
		"icon_to": "🌟",
		"color": Color(0.8, 0.5, 0.9)
	},
	{
		"name": "Deep Knowledge",
		"from": "Mining",
		"to": "Alchemy",
		"formula": "Depth ÷ 10 = Free element generators",
		"icon_from": "⛏️",
		"icon_to": "⚗️",
		"color": Color(0.7, 0.5, 0.3)
	},
	{
		"name": "Trade Network",
		"from": "Airships",
		"to": "Mining",
		"formula": "Active Routes × 5% = Ore value boost",
		"icon_from": "🛩️",
		"icon_to": "⛏️",
		"color": Color(0.6, 0.8, 0.7)
	},
	{
		"name": "Grand Synergy",
		"from": "All",
		"to": "Grand Prestige",
		"formula": "Combined progress = Faster prestige unlocks",
		"icon_from": "🌈",
		"icon_to": "⭐",
		"color": Color(1, 0.8, 0.3)
	}
]

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	_setup_ui()
	_calculate_bonuses()

func _setup_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Animated background elements
	for i in range(40):
		var particle = Label.new()
		particle.text = ["💫", "⚡", "🌟", "✨"][randi() % 4]
		particle.position = Vector2(randf() * 1080, randf() * 1920)
		particle.add_theme_font_size_override("font_size", 12 + randf() * 24)
		particle.modulate = Color(1, 1, 1, 0.1 + randf() * 0.3)
		add_child(particle)
	
	# Title
	var title = Label.new()
	title.text = "🌈 DOMAIN SYNERGIES 🌈"
	title.position = Vector2(200, 80)
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	add_child(title)
	
	# Description
	var desc = Label.new()
	desc.text = "Your domains work together to boost each other!"
	desc.position = Vector2(250, 170)
	desc.add_theme_font_size_override("font_size", 28)
	desc.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	add_child(desc)
	
	# Back button
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(50, 50)
	back_btn.size = Vector2(200, 70)
	back_btn.add_theme_font_size_override("font_size", 28)
	back_btn.pressed.connect(_on_back_pressed)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.3, 0.2, 0.15)
	btn_style.border_width_left = 3
	btn_style.border_width_right = 3
	btn_style.border_width_top = 3
	btn_style.border_width_bottom = 3
	btn_style.border_color = Color(0.6, 0.4, 0.2)
	back_btn.add_theme_stylebox_override("normal", btn_style)
	back_btn.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	add_child(back_btn)
	
	# Scroll container for synergies
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(80, 250)
	scroll.size = Vector2(920, 1600)
	add_child(scroll)
	
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	
	# Create synergy cards
	for syn in synergies:
		var card = _create_synergy_card(syn)
		vbox.add_child(card)
		
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 20)
		vbox.add_child(spacer)

func _create_synergy_card(syn: Dictionary) -> Panel:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(880, 200)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(syn.color.r * 0.3, syn.color.g * 0.3, syn.color.b * 0.3, 0.9)
	card_style.border_width_left = 4
	card_style.border_width_right = 4
	card_style.border_width_top = 4
	card_style.border_width_bottom = 4
	card_style.border_color = syn.color
	card_style.corner_radius_top_left = 12
	card_style.corner_radius_top_right = 12
	card_style.corner_radius_bottom_left = 12
	card_style.corner_radius_bottom_right = 12
	card.add_theme_stylebox_override("panel", card_style)
	
	# Name
	var name_label = Label.new()
	name_label.text = syn.name
	name_label.position = Vector2(30, 20)
	name_label.add_theme_font_size_override("font_size", 36)
	name_label.add_theme_color_override("font_color", syn.color)
	card.add_child(name_label)
	
	# From -> To
	var flow = Label.new()
	flow.text = syn.icon_from + " " + syn.from + "  →  " + syn.icon_to + " " + syn.to
	flow.position = Vector2(30, 70)
	flow.add_theme_font_size_override("font_size", 28)
	flow.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	card.add_child(flow)
	
	# Formula
	var formula = Label.new()
	formula.text = "📐 " + syn.formula
	formula.position = Vector2(30, 120)
	formula.add_theme_font_size_override("font_size", 24)
	formula.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	card.add_child(formula)
	
	# Current bonus (calculated)
	var bonus = _calculate_synergy_bonus(syn)
	var bonus_label = Label.new()
	bonus_label.text = "✨ Current Bonus: +" + str(snapped(bonus, 0.1)) + "%"
	bonus_label.position = Vector2(30, 160)
	bonus_label.add_theme_font_size_override("font_size", 26)
	bonus_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
	card.add_child(bonus_label)
	
	return card

func _calculate_bonuses():
	# This would apply bonuses in actual gameplay
	# For now just display them
	pass

func _calculate_synergy_bonus(syn: Dictionary) -> float:
	var bonus = 0.0
	
	match syn.name:
		"Industrial Efficiency":
			var tower_level = _get_tower_level()
			bonus = tower_level * 0.5
		
		"Air Superiority":
			var fleet_size = _get_fleet_size()
			bonus = fleet_size * 1.0
		
		"Alchemical Transmutation":
			var essence = _get_essence()
			bonus = essence * 0.01
		
		"Deep Knowledge":
			var depth = _get_depth()
			bonus = depth / 10.0
		
		"Trade Network":
			var routes = _get_active_routes()
			bonus = routes * 5.0
		
		"Grand Synergy":
			# Combined of all
			bonus = _get_tower_level() + _get_depth() + _get_fleet_size()
	
	return bonus

func _get_tower_level() -> int:
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			return data.get("tower_level", 0)
	return 0

func _get_fleet_size() -> int:
	if FileAccess.file_exists("user://airship_save.dat"):
		var file = FileAccess.open("user://airship_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			return data.get("fleet_size", 0)
	return 0

func _get_essence() -> float:
	if FileAccess.file_exists("user://alchemy_save.dat"):
		var file = FileAccess.open("user://alchemy_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			return data.get("essence", 0.0)
	return 0.0

func _get_depth() -> int:
	if FileAccess.file_exists("user://mining_save.dat"):
		var file = FileAccess.open("user://mining_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			return data.get("max_depth_reached", 0)
	return 0

func _get_active_routes() -> int:
	if FileAccess.file_exists("user://airship_save.dat"):
		var file = FileAccess.open("user://airship_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			return data.get("max_routes", 0)
	return 0

func _on_back_pressed():
	get_tree().change_scene_to_file("main_menu.tscn")
