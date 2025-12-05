extends Node2D

# Mining Quarry - Dig deeper to find rare resources!

# Game state
var ore: float = 0.0
var ore_per_second: float = 0.0
var ore_per_click: float = 1.0
var total_clicks: int = 0
var depth: int = 0  # Current depth level
var max_depth_reached: int = 0

# Depth mechanics
var depth_progress: float = 0.0
var ore_needed_for_next_depth: float = 50.0

# Upgrades
var upgrades = [
	{
		"name": "Iron Pickaxe",
		"base_cost": 10,
		"cost": 10,
		"ops": 0.2,  # Ore per second
		"owned": 0,
		"icon": "⛏️"
	},
	{
		"name": "Drill",
		"base_cost": 50,
		"cost": 50,
		"ops": 1.0,
		"owned": 0,
		"icon": "🔨"
	},
	{
		"name": "Conveyor Belt",
		"base_cost": 200,
		"cost": 200,
		"ops": 4.0,
		"owned": 0,
		"icon": "📦"
	},
	{
		"name": "Mining Cart",
		"base_cost": 800,
		"cost": 800,
		"ops": 15.0,
		"owned": 0,
		"icon": "🚂"
	},
	{
		"name": "Excavator",
		"base_cost": 3000,
		"cost": 3000,
		"ops": 60.0,
		"owned": 0,
		"icon": "🚜"
	},
	{
		"name": "Deep Bore",
		"base_cost": 10000,
		"cost": 10000,
		"ops": 250.0,
		"owned": 0,
		"icon": "🏗️"
	}
]

# UI nodes will be created dynamically
var ui_layer
var mine_shaft_visual
var click_particles

func _ready():
	_setup_ui()
	_load_game()

func _setup_ui():
	# Create canvas layer for UI
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.08, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(bg)
	
	# Header panel
	var header = Panel.new()
	header.position = Vector2(0, 0)
	header.size = Vector2(1080, 180)
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.15, 0.12, 0.08)
	header_style.border_width_bottom = 3
	header_style.border_color = Color(0.5, 0.3, 0.15)
	header.add_theme_stylebox_override("panel", header_style)
	ui_layer.add_child(header)
	
	# Menu button
	var menu_btn = Button.new()
	menu_btn.name = "MenuButton"
	menu_btn.text = "🏠 MENU"
	menu_btn.position = Vector2(20, 20)
	menu_btn.size = Vector2(180, 60)
	menu_btn.add_theme_font_size_override("font_size", 24)
	menu_btn.pressed.connect(_on_menu_pressed)
	header.add_child(menu_btn)
	
	# Title
	var title = Label.new()
	title.text = "MINING QUARRY"
	title.position = Vector2(220, 20)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.6, 0.3))
	header.add_child(title)
	
	# Ore counter
	var ore_label = Label.new()
	ore_label.name = "OreLabel"
	ore_label.text = "Ore: 0"
	ore_label.position = Vector2(220, 90)
	ore_label.add_theme_font_size_override("font_size", 32)
	ore_label.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
	header.add_child(ore_label)
	
	# OPS counter
	var ops_label = Label.new()
	ops_label.name = "OPSLabel"
	ops_label.text = "Per Second: 0"
	ops_label.position = Vector2(220, 130)
	ops_label.add_theme_font_size_override("font_size", 24)
	ops_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))
	header.add_child(ops_label)
	
	# Depth display
	var depth_label = Label.new()
	depth_label.name = "DepthLabel"
	depth_label.text = "Depth: 0m"
	depth_label.position = Vector2(680, 90)
	depth_label.add_theme_font_size_override("font_size", 32)
	depth_label.add_theme_color_override("font_color", Color(0.7, 0.5, 0.9))
	header.add_child(depth_label)
	
	# Depth progress
	var depth_progress_bar = ProgressBar.new()
	depth_progress_bar.name = "DepthProgress"
	depth_progress_bar.position = Vector2(680, 135)
	depth_progress_bar.size = Vector2(380, 25)
	depth_progress_bar.max_value = 100
	depth_progress_bar.show_percentage = false
	header.add_child(depth_progress_bar)
	
	# Main click button
	var click_btn = Button.new()
	click_btn.name = "ClickButton"
	click_btn.text = "⛏️ DIG ⛏️"
	click_btn.position = Vector2(140, 220)
	click_btn.size = Vector2(800, 250)
	click_btn.add_theme_font_size_override("font_size", 56)
	click_btn.pressed.connect(_on_dig_pressed)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.35, 0.25, 0.15)
	btn_style.border_width_left = 4
	btn_style.border_width_right = 4
	btn_style.border_width_top = 4
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color(0.6, 0.4, 0.2)
	btn_style.corner_radius_top_left = 15
	btn_style.corner_radius_top_right = 15
	btn_style.corner_radius_bottom_left = 15
	btn_style.corner_radius_bottom_right = 15
	click_btn.add_theme_stylebox_override("normal", btn_style)
	click_btn.add_theme_color_override("font_color", Color(1, 0.85, 0.5))
	ui_layer.add_child(click_btn)
	
	# Click value
	var click_value = Label.new()
	click_value.name = "ClickValue"
	click_value.text = "+1 ore per dig"
	click_value.position = Vector2(420, 480)
	click_value.add_theme_font_size_override("font_size", 26)
	click_value.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4))
	ui_layer.add_child(click_value)
	
	# Mine shaft visualization
	_create_mine_shaft()
	
	# Upgrades panel
	var upgrades_panel = Panel.new()
	upgrades_panel.position = Vector2(40, 1220)
	upgrades_panel.size = Vector2(1000, 630)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.12, 0.08)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.5, 0.3, 0.15)
	upgrades_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(upgrades_panel)
	
	var upgrades_title = Label.new()
	upgrades_title.text = "MINING EQUIPMENT"
	upgrades_title.position = Vector2(20, 15)
	upgrades_title.add_theme_font_size_override("font_size", 32)
	upgrades_title.add_theme_color_override("font_color", Color(0.9, 0.6, 0.3))
	upgrades_panel.add_child(upgrades_title)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 65)
	scroll.size = Vector2(960, 550)
	upgrades_panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.name = "UpgradesVBox"
	scroll.add_child(vbox)
	
	_create_upgrade_buttons()

func _create_mine_shaft():
	# Visual representation of mine shaft
	mine_shaft_visual = Node2D.new()
	mine_shaft_visual.name = "MineShaft"
	mine_shaft_visual.position = Vector2(540, 700)
	add_child(mine_shaft_visual)
	
	# Shaft walls
	var left_wall = ColorRect.new()
	left_wall.color = Color(0.25, 0.18, 0.12)
	left_wall.size = Vector2(40, 500)
	left_wall.position = Vector2(-220, -250)
	mine_shaft_visual.add_child(left_wall)
	
	var right_wall = ColorRect.new()
	right_wall.color = Color(0.25, 0.18, 0.12)
	right_wall.size = Vector2(40, 500)
	right_wall.position = Vector2(180, -250)
	mine_shaft_visual.add_child(right_wall)
	
	# Depth markers
	for i in range(10):
		var marker = Label.new()
		marker.text = str(i * 10) + "m"
		marker.position = Vector2(-150, -200 + i * 50)
		marker.add_theme_font_size_override("font_size", 18)
		marker.add_theme_color_override("font_color", Color(0.6, 0.4, 0.2))
		mine_shaft_visual.add_child(marker)

func _create_upgrade_buttons():
	var vbox = ui_layer.get_node("Panel/ScrollContainer/UpgradesVBox")
	
	for i in range(upgrades.size()):
		var upgrade = upgrades[i]
		
		var button = Button.new()
		button.name = "Upgrade" + str(i)
		button.custom_minimum_size = Vector2(920, 90)
		button.add_theme_font_size_override("font_size", 22)
		
		var text = upgrade.icon + " " + upgrade.name + "\n"
		text += "Cost: " + _format_number(upgrade.cost) + " | +"
		text += _format_number(upgrade.ops) + "/s | Owned: " + str(upgrade.owned)
		button.text = text
		
		button.pressed.connect(_on_upgrade_pressed.bind(i))
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.25, 0.18, 0.12)
		btn_style.border_width_left = 2
		btn_style.border_width_right = 2
		btn_style.border_width_top = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.5, 0.35, 0.2)
		button.add_theme_stylebox_override("normal", btn_style)
		button.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6))
		
		vbox.add_child(button)
		
		if i < upgrades.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 8)
			vbox.add_child(spacer)

func _process(delta):
	# Generate ore per second
	ore += ore_per_second * delta
	
	# Depth progression
	depth_progress += ore_per_second * delta
	if depth_progress >= ore_needed_for_next_depth:
		_dig_deeper()
	
	_update_ui()

func _on_dig_pressed():
	ore += ore_per_click
	total_clicks += 1
	depth_progress += ore_per_click
	
	# Visual feedback
	var click_btn = ui_layer.get_node("ClickButton")
	var tween = create_tween()
	tween.tween_property(click_btn, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(click_btn, "scale", Vector2(1.0, 1.0), 0.05)
	
	_update_ui()

func _on_upgrade_pressed(index: int):
	var upgrade = upgrades[index]
	
	if ore >= upgrade.cost:
		ore -= upgrade.cost
		upgrade.owned += 1
		ore_per_second += upgrade.ops
		upgrade.cost = ceil(upgrade.base_cost * pow(1.15, upgrade.owned))
		
		_update_upgrade_button(index)
		_update_ui()

func _dig_deeper():
	depth += 1
	if depth > max_depth_reached:
		max_depth_reached = depth
	
	depth_progress = 0
	ore_needed_for_next_depth = ceil(50 * pow(1.4, depth))
	
	# Bonus for going deeper
	var bonus = depth * 5
	ore += bonus
	
	print("Reached depth ", depth, "m! Bonus: ", bonus, " ore")

func _update_ui():
	var ore_label = ui_layer.get_node("Panel/OreLabel")
	var ops_label = ui_layer.get_node("Panel/OPSLabel")
	var depth_label = ui_layer.get_node("Panel/DepthLabel")
	var depth_bar = ui_layer.get_node("Panel/DepthProgress")
	var click_value = ui_layer.get_node("ClickValue")
	
	ore_label.text = "Ore: " + _format_number(ore)
	ops_label.text = "Per Second: " + _format_number(ore_per_second)
	depth_label.text = "Depth: " + str(depth) + "m"
	depth_bar.value = (depth_progress / ore_needed_for_next_depth) * 100
	click_value.text = "+" + _format_number(ore_per_click) + " ore per dig"
	
	# Update upgrades
	for i in range(upgrades.size()):
		_update_upgrade_button(i)

func _update_upgrade_button(index: int):
	var upgrade = upgrades[index]
	var vbox = ui_layer.get_node("Panel/ScrollContainer/UpgradesVBox")
	var button = vbox.get_node_or_null("Upgrade" + str(index))
	
	if button:
		var text = upgrade.icon + " " + upgrade.name + "\n"
		text += "Cost: " + _format_number(upgrade.cost) + " | +"
		text += _format_number(upgrade.ops) + "/s | Owned: " + str(upgrade.owned)
		button.text = text
		
		button.disabled = ore < upgrade.cost
		
		if ore >= upgrade.cost:
			button.modulate = Color(1, 1, 1)
		else:
			button.modulate = Color(0.6, 0.6, 0.6)

func _format_number(num: float) -> String:
	if num < 1000:
		return str(int(num))
	elif num < 1000000:
		return str(snapped(num / 1000.0, 0.1)) + "K"
	elif num < 1000000000:
		return str(snapped(num / 1000000.0, 0.1)) + "M"
	else:
		return str(snapped(num / 1000000000.0, 0.1)) + "B"

func _on_menu_pressed():
	_save_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _save_game():
	var save_data = {
		"ore": ore,
		"depth": depth,
		"max_depth_reached": max_depth_reached,
		"depth_progress": depth_progress,
		"total_clicks": total_clicks,
		"upgrades": []
	}
	
	for upgrade in upgrades:
		save_data.upgrades.append({
			"owned": upgrade.owned,
			"cost": upgrade.cost
		})
	
	var save_file = FileAccess.open("user://mining_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()

func _load_game():
	if FileAccess.file_exists("user://mining_save.dat"):
		var save_file = FileAccess.open("user://mining_save.dat", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			
			ore = save_data.get("ore", 0.0)
			depth = save_data.get("depth", 0)
			max_depth_reached = save_data.get("max_depth_reached", 0)
			depth_progress = save_data.get("depth_progress", 0.0)
			total_clicks = save_data.get("total_clicks", 0)
			
			var saved_upgrades = save_data.get("upgrades", [])
			for i in range(min(saved_upgrades.size(), upgrades.size())):
				upgrades[i].owned = saved_upgrades[i].owned
				upgrades[i].cost = saved_upgrades[i].cost
			
			# Recalculate OPS
			ore_per_second = 0.0
			for upgrade in upgrades:
				ore_per_second += upgrade.ops * upgrade.owned
			
			print("Mining game loaded!")
