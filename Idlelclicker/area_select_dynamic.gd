extends Control

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	var bg = ColorRect.new()
	bg.color = Color(0.12, 0.08, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var title = Label.new()
	title.text = "SELECT YOUR DOMAIN"
	title.position = Vector2(250, 100)
	title.add_theme_font_size_override("font_size", 60)
	title.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	add_child(title)
	
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
	
	_create_domain_cards()

func _create_domain_cards():
	var tower_level = _get_tower_level()
	
	var areas = [
		{
			"name": "Clockwork Tower",
			"desc": "Build a towering steampunk factory\nUnlock: Available",
			"icon": "🏗️",
			"unlocked": true,
			"scene": "res://scenes/steampunk_clicker.tscn",
			"unlock_level": 0
		},
		{
			"name": "Mining Quarry",
			"desc": "Extract resources from the depths\nUnlock: Tower Level 10",
			"icon": "⛏️",
			"unlocked": tower_level >= 10,
			"scene": "res://scenes/mining_area.tscn",
			"unlock_level": 10
		},
		{
			"name": "Airship Dock",
			"desc": "Command a fleet of flying vessels\nUnlock: Tower Level 20",
			"icon": "🛩️",
			"unlocked": tower_level >= 20,
			"scene": "res://scenes/airship_area.tscn",
			"unlock_level": 20
		},
		{
			"name": "Alchemy Lab",
			"desc": "Transmute elements into gold\nUnlock: Tower Level 30",
			"icon": "⚗️",
			"unlocked": tower_level >= 30,
			"scene": "res://scenes/alchemy_area.tscn",
			"unlock_level": 30
		}
	]
	
	var start_x = 100
	var start_y = 250
	var card_width = 420
	var card_height = 280
	var spacing = 40
	
	for i in range(areas.size()):
		var area = areas[i]
		var row = i / 2
		var col = i % 2
		
		var card = Panel.new()
		card.position = Vector2(start_x + col * (card_width + spacing), start_y + row * (card_height + spacing))
		card.custom_minimum_size = Vector2(card_width, card_height)
		
		var card_style = StyleBoxFlat.new()
		if area.unlocked:
			card_style.bg_color = Color(0.25, 0.18, 0.12)
			card_style.border_color = Color(0.6, 0.4, 0.2)
		else:
			card_style.bg_color = Color(0.15, 0.12, 0.08)
			card_style.border_color = Color(0.3, 0.2, 0.1)
		
		card_style.border_width_left = 4
		card_style.border_width_right = 4
		card_style.border_width_top = 4
		card_style.border_width_bottom = 4
		card_style.corner_radius_top_left = 12
		card_style.corner_radius_top_right = 12
		card_style.corner_radius_bottom_left = 12
		card_style.corner_radius_bottom_right = 12
		card.add_theme_stylebox_override("panel", card_style)
		
		var icon = Label.new()
		icon.text = area.icon
		icon.position = Vector2(20, 20)
		icon.add_theme_font_size_override("font_size", 64)
		card.add_child(icon)
		
		var name_label = Label.new()
		name_label.text = area.name
		name_label.position = Vector2(110, 30)
		name_label.add_theme_font_size_override("font_size", 32)
		if area.unlocked:
			name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.5))
		else:
			name_label.add_theme_color_override("font_color", Color(0.5, 0.4, 0.3))
		card.add_child(name_label)
		
		var desc_text = area.desc
		if not area.unlocked:
			desc_text = area.name + "\nProgress: " + str(tower_level) + "/" + str(area.unlock_level)
		
		var desc = Label.new()
		desc.text = desc_text
		desc.position = Vector2(20, 100)
		desc.add_theme_font_size_override("font_size", 20)
		if area.unlocked:
			desc.add_theme_color_override("font_color", Color(0.8, 0.7, 0.5))
		else:
			desc.add_theme_color_override("font_color", Color(0.4, 0.35, 0.25))
		card.add_child(desc)
		
		var play_btn = Button.new()
		play_btn.text = "ENTER" if area.unlocked else "LOCKED"
		play_btn.position = Vector2(120, 200)
		play_btn.size = Vector2(180, 60)
		play_btn.disabled = not area.unlocked
		play_btn.add_theme_font_size_override("font_size", 28)
		
		var play_style = StyleBoxFlat.new()
		if area.unlocked:
			play_style.bg_color = Color(0.4, 0.3, 0.2)
			play_style.border_color = Color(0.7, 0.5, 0.3)
			play_btn.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
		else:
			play_style.bg_color = Color(0.2, 0.15, 0.1)
			play_style.border_color = Color(0.3, 0.2, 0.15)
			play_btn.add_theme_color_override("font_color", Color(0.4, 0.35, 0.25))
		
		play_style.border_width_left = 2
		play_style.border_width_right = 2
		play_style.border_width_top = 2
		play_style.border_width_bottom = 2
		play_style.corner_radius_top_left = 8
		play_style.corner_radius_top_right = 8
		play_style.corner_radius_bottom_left = 8
		play_style.corner_radius_bottom_right = 8
		play_btn.add_theme_stylebox_override("normal", play_style)
		
		var play_hover = play_style.duplicate()
		if area.unlocked:
			play_hover.bg_color = Color(0.5, 0.4, 0.25)
			play_btn.add_theme_stylebox_override("hover", play_hover)
		
		if area.unlocked and area.scene != "":
			play_btn.pressed.connect(_on_play_area.bind(area.scene))
		
		card.add_child(play_btn)
		add_child(card)

func _get_tower_level() -> int:
	if FileAccess.file_exists("user://savegame.dat"):
		var save_file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			return save_data.get("tower_level", 0)
	return 0

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_play_area(scene_path: String):
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
