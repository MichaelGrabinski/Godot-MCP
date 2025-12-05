extends Node2D

# Airship Dock - Build and manage a fleet of flying vessels!

# Game state
var gold: float = 0.0
var gold_per_second: float = 0.0
var total_gold_earned: float = 0.0

# Fleet management
var fleet_size: int = 0
var active_routes: int = 0
var max_routes: int = 3

# Trade routes (destinations you can send ships to)
var trade_routes = [
	{"name": "Nearby Village", "duration": 5.0, "reward": 20, "unlocked": true},
	{"name": "Coastal City", "duration": 10.0, "reward": 50, "unlocked": true},
	{"name": "Mountain Fortress", "duration": 15.0, "reward": 100, "unlocked": false},
	{"name": "Desert Oasis", "duration": 20.0, "reward": 200, "unlocked": false},
	{"name": "Frozen North", "duration": 30.0, "reward": 400, "unlocked": false},
	{"name": "Sky Islands", "duration": 45.0, "reward": 800, "unlocked": false}
]

# Active expeditions
var expeditions = []

# Upgrades
var upgrades = [
	{
		"name": "Small Balloon",
		"base_cost": 10,
		"cost": 10,
		"gps": 0.5,
		"owned": 0,
		"icon": "🎈"
	},
	{
		"name": "Cargo Blimp",
		"base_cost": 75,
		"cost": 75,
		"gps": 2.0,
		"owned": 0,
		"icon": "🎪"
	},
	{
		"name": "Steam Dirigible",
		"base_cost": 300,
		"cost": 300,
		"gps": 8.0,
		"owned": 0,
		"icon": "🚁"
	},
	{
		"name": "Combat Frigate",
		"base_cost": 1200,
		"cost": 1200,
		"gps": 30.0,
		"owned": 0,
		"icon": "✈️"
	},
	{
		"name": "Sky Fortress",
		"base_cost": 5000,
		"cost": 5000,
		"gps": 120.0,
		"owned": 0,
		"icon": "🛸"
	},
	{
		"name": "Fleet Expansion",
		"base_cost": 500,
		"cost": 500,
		"gps": 0,
		"owned": 0,
		"icon": "📦",
		"special": "route_slot"
	}
]

var ui_layer

func _ready():
	_setup_ui()
	_load_game()

func _setup_ui():
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Background with sky theme
	var bg = ColorRect.new()
	bg.color = Color(0.4, 0.6, 0.9)  # Sky blue
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(bg)
	
	# Cloud decorations
	_create_clouds()
	
	# Header
	var header = Panel.new()
	header.position = Vector2(0, 0)
	header.size = Vector2(1080, 200)
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.2, 0.3, 0.5, 0.9)
	header_style.border_width_bottom = 3
	header_style.border_color = Color(0.8, 0.8, 1.0)
	header.add_theme_stylebox_override("panel", header_style)
	ui_layer.add_child(header)
	
	# Menu button
	var menu_btn = Button.new()
	menu_btn.text = "🏠 MENU"
	menu_btn.position = Vector2(20, 20)
	menu_btn.size = Vector2(180, 60)
	menu_btn.add_theme_font_size_override("font_size", 24)
	menu_btn.pressed.connect(_on_menu_pressed)
	header.add_child(menu_btn)
	
	# Title
	var title = Label.new()
	title.text = "AIRSHIP DOCK"
	title.position = Vector2(220, 20)
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(1, 1, 0.8))
	header.add_child(title)
	
	# Gold counter
	var gold_label = Label.new()
	gold_label.name = "GoldLabel"
	gold_label.text = "Gold: 0"
	gold_label.position = Vector2(220, 90)
	gold_label.add_theme_font_size_override("font_size", 36)
	gold_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	header.add_child(gold_label)
	
	# GPS counter
	var gps_label = Label.new()
	gps_label.name = "GPSLabel"
	gps_label.text = "Per Second: 0"
	gps_label.position = Vector2(220, 140)
	gps_label.add_theme_font_size_override("font_size", 26)
	gps_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.5))
	header.add_child(gps_label)
	
	# Fleet info
	var fleet_label = Label.new()
	fleet_label.name = "FleetLabel"
	fleet_label.text = "Fleet: 0 | Routes: 0/3"
	fleet_label.position = Vector2(680, 90)
	fleet_label.add_theme_font_size_override("font_size", 28)
	fleet_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	header.add_child(fleet_label)
	
	# Trade routes panel
	var routes_panel = Panel.new()
	routes_panel.name = "RoutesPanel"
	routes_panel.position = Vector2(40, 230)
	routes_panel.size = Vector2(1000, 540)
	var routes_style = StyleBoxFlat.new()
	routes_style.bg_color = Color(0.15, 0.2, 0.3, 0.95)
	routes_style.border_width_left = 3
	routes_style.border_width_right = 3
	routes_style.border_width_top = 3
	routes_style.border_width_bottom = 3
	routes_style.border_color = Color(0.5, 0.6, 0.8)
	routes_panel.add_theme_stylebox_override("panel", routes_style)
	ui_layer.add_child(routes_panel)
	
	var routes_title = Label.new()
	routes_title.text = "TRADE ROUTES"
	routes_title.position = Vector2(20, 15)
	routes_title.add_theme_font_size_override("font_size", 36)
	routes_title.add_theme_color_override("font_color", Color(1, 1, 0.8))
	routes_panel.add_child(routes_title)
	
	var routes_scroll = ScrollContainer.new()
	routes_scroll.position = Vector2(20, 70)
	routes_scroll.size = Vector2(960, 460)
	routes_panel.add_child(routes_scroll)
	
	var routes_vbox = VBoxContainer.new()
	routes_vbox.name = "RoutesVBox"
	routes_scroll.add_child(routes_vbox)
	
	_create_route_buttons()
	
	# Upgrades panel
	var upgrades_panel = Panel.new()
	upgrades_panel.position = Vector2(40, 800)
	upgrades_panel.size = Vector2(1000, 1050)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.2, 0.3, 0.95)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.5, 0.6, 0.8)
	upgrades_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(upgrades_panel)
	
	var upgrades_title = Label.new()
	upgrades_title.text = "FLEET & UPGRADES"
	upgrades_title.position = Vector2(20, 15)
	upgrades_title.add_theme_font_size_override("font_size", 36)
	upgrades_title.add_theme_color_override("font_color", Color(1, 1, 0.8))
	upgrades_panel.add_child(upgrades_title)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 70)
	scroll.size = Vector2(960, 970)
	upgrades_panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.name = "UpgradesVBox"
	scroll.add_child(vbox)
	
	_create_upgrade_buttons()

func _create_clouds():
	# Decorative clouds
	for i in range(5):
		var cloud = Label.new()
		cloud.text = "☁️"
		cloud.position = Vector2(randf() * 1000, 400 + randf() * 600)
		cloud.add_theme_font_size_override("font_size", 48 + randf() * 32)
		cloud.modulate = Color(1, 1, 1, 0.6 + randf() * 0.3)
		ui_layer.add_child(cloud)

func _create_route_buttons():
	var vbox = ui_layer.get_node("RoutesPanel/ScrollContainer/RoutesVBox")
	
	for i in range(trade_routes.size()):
		var route = trade_routes[i]
		
		var button = Button.new()
		button.name = "Route" + str(i)
		button.custom_minimum_size = Vector2(920, 60)
		button.add_theme_font_size_override("font_size", 22)
		
		var status = ""
		if not route.unlocked:
			status = "🔒 "
		elif _is_route_active(i):
			status = "✈️ "
		
		var text = status + route.name + " | " + str(route.duration) + "s → " + str(route.reward) + " gold"
		button.text = text
		
		button.disabled = not route.unlocked or active_routes >= max_routes
		button.pressed.connect(_on_route_pressed.bind(i))
		
		var btn_style = StyleBoxFlat.new()
		if route.unlocked:
			btn_style.bg_color = Color(0.25, 0.35, 0.5)
		else:
			btn_style.bg_color = Color(0.15, 0.2, 0.25)
		btn_style.border_width_left = 2
		btn_style.border_width_right = 2
		btn_style.border_width_top = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.5, 0.6, 0.7)
		button.add_theme_stylebox_override("normal", btn_style)
		button.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
		
		vbox.add_child(button)
		
		if i < trade_routes.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 10)
			vbox.add_child(spacer)

func _create_upgrade_buttons():
	var vbox = ui_layer.get_node("Panel/ScrollContainer/UpgradesVBox")
	
	for i in range(upgrades.size()):
		var upgrade = upgrades[i]
		
		var button = Button.new()
		button.name = "Upgrade" + str(i)
		button.custom_minimum_size = Vector2(920, 90)
		button.add_theme_font_size_override("font_size", 22)
		
		var text = upgrade.icon + " " + upgrade.name + "\n"
		if upgrade.special == "route_slot":
			text += "Cost: " + _format_number(upgrade.cost) + " | +1 Trade Route Slot | Owned: " + str(upgrade.owned)
		else:
			text += "Cost: " + _format_number(upgrade.cost) + " | +"
			text += _format_number(upgrade.gps) + "/s | Owned: " + str(upgrade.owned)
		button.text = text
		
		button.pressed.connect(_on_upgrade_pressed.bind(i))
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.25, 0.35, 0.5)
		btn_style.border_width_left = 2
		btn_style.border_width_right = 2
		btn_style.border_width_top = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.5, 0.6, 0.7)
		button.add_theme_stylebox_override("normal", btn_style)
		button.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
		
		vbox.add_child(button)
		
		if i < upgrades.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 8)
			vbox.add_child(spacer)

func _process(delta):
	gold += gold_per_second * delta
	total_gold_earned += gold_per_second * delta
	
	# Update expeditions
	for i in range(expeditions.size() - 1, -1, -1):
		expeditions[i].time_remaining -= delta
		if expeditions[i].time_remaining <= 0:
			_complete_expedition(i)
	
	_update_ui()

func _on_route_pressed(index: int):
	if active_routes >= max_routes:
		print("Max routes active!")
		return
	
	var route = trade_routes[index]
	if not route.unlocked:
		return
	
	# Start expedition
	expeditions.append({
		"route_index": index,
		"time_remaining": route.duration,
		"reward": route.reward
	})
	
	active_routes += 1
	_update_route_buttons()
	print("Expedition to ", route.name, " started!")

func _complete_expedition(index: int):
	var expedition = expeditions[index]
	gold += expedition.reward
	print("Expedition complete! Earned ", expedition.reward, " gold")
	
	expeditions.remove_at(index)
	active_routes -= 1
	_update_route_buttons()

func _is_route_active(route_index: int) -> bool:
	for exp in expeditions:
		if exp.route_index == route_index:
			return true
	return false

func _on_upgrade_pressed(index: int):
	var upgrade = upgrades[index]
	
	if gold >= upgrade.cost:
		gold -= upgrade.cost
		upgrade.owned += 1
		
		if upgrade.special == "route_slot":
			max_routes += 1
		else:
			gold_per_second += upgrade.gps
			fleet_size += 1
		
		upgrade.cost = ceil(upgrade.base_cost * pow(1.15, upgrade.owned))
		
		_update_upgrade_button(index)
		_update_ui()

func _update_ui():
	var gold_label = ui_layer.get_node("Panel/GoldLabel")
	var gps_label = ui_layer.get_node("Panel/GPSLabel")
	var fleet_label = ui_layer.get_node("Panel/FleetLabel")
	
	gold_label.text = "Gold: " + _format_number(gold)
	gps_label.text = "Per Second: " + _format_number(gold_per_second)
	fleet_label.text = "Fleet: " + str(fleet_size) + " | Routes: " + str(active_routes) + "/" + str(max_routes)
	
	for i in range(upgrades.size()):
		_update_upgrade_button(i)

func _update_route_buttons():
	var vbox = ui_layer.get_node("RoutesPanel/ScrollContainer/RoutesVBox")
	
	for i in range(trade_routes.size()):
		var route = trade_routes[i]
		var button = vbox.get_node_or_null("Route" + str(i))
		
		if button:
			var status = ""
			if not route.unlocked:
				status = "🔒 "
			elif _is_route_active(i):
				var exp = _get_expedition_for_route(i)
				if exp:
					status = "✈️ (" + str(int(exp.time_remaining)) + "s) "
			
			var text = status + route.name + " | " + str(route.duration) + "s → " + str(route.reward) + " gold"
			button.text = text
			button.disabled = not route.unlocked or (active_routes >= max_routes and not _is_route_active(i))

func _get_expedition_for_route(route_index: int):
	for exp in expeditions:
		if exp.route_index == route_index:
			return exp
	return null

func _update_upgrade_button(index: int):
	var upgrade = upgrades[index]
	var vbox = ui_layer.get_node("Panel/ScrollContainer/UpgradesVBox")
	var button = vbox.get_node_or_null("Upgrade" + str(index))
	
	if button:
		var text = upgrade.icon + " " + upgrade.name + "\n"
		if upgrade.special == "route_slot":
			text += "Cost: " + _format_number(upgrade.cost) + " | +1 Trade Route Slot | Owned: " + str(upgrade.owned)
		else:
			text += "Cost: " + _format_number(upgrade.cost) + " | +"
			text += _format_number(upgrade.gps) + "/s | Owned: " + str(upgrade.owned)
		button.text = text
		
		button.disabled = gold < upgrade.cost
		
		if gold >= upgrade.cost:
			button.modulate = Color(1, 1, 1)
		else:
			button.modulate = Color(0.6, 0.6, 0.7)

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
		"gold": gold,
		"total_gold_earned": total_gold_earned,
		"fleet_size": fleet_size,
		"max_routes": max_routes,
		"upgrades": [],
		"routes": []
	}
	
	for upgrade in upgrades:
		save_data.upgrades.append({
			"owned": upgrade.owned,
			"cost": upgrade.cost
		})
	
	for route in trade_routes:
		save_data.routes.append({
			"unlocked": route.unlocked
		})
	
	var save_file = FileAccess.open("user://airship_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()

func _load_game():
	if FileAccess.file_exists("user://airship_save.dat"):
		var save_file = FileAccess.open("user://airship_save.dat", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			
			gold = save_data.get("gold", 0.0)
			total_gold_earned = save_data.get("total_gold_earned", 0.0)
			fleet_size = save_data.get("fleet_size", 0)
			max_routes = save_data.get("max_routes", 3)
			
			var saved_upgrades = save_data.get("upgrades", [])
			for i in range(min(saved_upgrades.size(), upgrades.size())):
				upgrades[i].owned = saved_upgrades[i].owned
				upgrades[i].cost = saved_upgrades[i].cost
			
			var saved_routes = save_data.get("routes", [])
			for i in range(min(saved_routes.size(), trade_routes.size())):
				trade_routes[i].unlocked = saved_routes[i].unlocked
			
			gold_per_second = 0.0
			for upgrade in upgrades:
				if upgrade.special != "route_slot":
					gold_per_second += upgrade.gps * upgrade.owned
			
			print("Airship game loaded!")
