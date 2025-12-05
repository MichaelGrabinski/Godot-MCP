extends Node2D

# Alchemy Lab - Combine elements to create powerful transmutations!

# Game state
var essence: float = 0.0
var essence_per_second: float = 0.0

# Elements system
var elements = {
	"fire": {"amount": 0, "color": Color(1, 0.3, 0)},
	"water": {"amount": 0, "color": Color(0.2, 0.5, 1)},
	"earth": {"amount": 0, "color": Color(0.6, 0.4, 0.2)},
	"air": {"amount": 0, "color": Color(0.8, 0.9, 1)}
}

# Formulas (combinations that create essence)
var formulas = [
	{"name": "Spark", "fire": 1, "air": 1, "essence": 5, "unlocked": true},
	{"name": "Steam", "fire": 1, "water": 1, "essence": 5, "unlocked": true},
	{"name": "Mud", "water": 1, "earth": 1, "essence": 5, "unlocked": true},
	{"name": "Dust", "earth": 1, "air": 1, "essence": 5, "unlocked": true},
	{"name": "Lava", "fire": 2, "earth": 2, "essence": 25, "unlocked": false},
	{"name": "Cloud", "water": 2, "air": 2, "essence": 25, "unlocked": false},
	{"name": "Lightning", "fire": 3, "air": 3, "essence": 100, "unlocked": false},
	{"name": "Crystal", "water": 3, "earth": 3, "essence": 100, "unlocked": false},
	{"name": "Philosopher's Stone", "fire": 10, "water": 10, "earth": 10, "air": 10, "essence": 1000, "unlocked": false}
]

# Generators (produce elements over time)
var generators = [
	{"name": "Candle", "element": "fire", "base_cost": 10, "cost": 10, "rate": 0.1, "owned": 0, "icon": "🕯️"},
	{"name": "Well", "element": "water", "base_cost": 10, "cost": 10, "rate": 0.1, "owned": 0, "icon": "💧"},
	{"name": "Garden", "element": "earth", "base_cost": 10, "cost": 10, "rate": 0.1, "owned": 0, "icon": "🌱"},
	{"name": "Windmill", "element": "air", "base_cost": 10, "cost": 10, "rate": 0.1, "owned": 0, "icon": "💨"},
	{"name": "Furnace", "element": "fire", "base_cost": 100, "cost": 100, "rate": 1.0, "owned": 0, "icon": "🔥"},
	{"name": "Fountain", "element": "water", "base_cost": 100, "cost": 100, "rate": 1.0, "owned": 0, "icon": "⛲"},
	{"name": "Quarry", "element": "earth", "base_cost": 100, "cost": 100, "rate": 1.0, "owned": 0, "icon": "⛰️"},
	{"name": "Cyclone", "element": "air", "base_cost": 100, "cost": 100, "rate": 1.0, "owned": 0, "icon": "🌪️"}
]

var ui_layer

func _ready():
	_setup_ui()
	_load_game()

func _setup_ui():
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	# Purple/mystical background
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.05, 0.2)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(bg)
	
	# Mystical particles background
	_create_mystical_effects()
	
	# Header
	var header = Panel.new()
	header.position = Vector2(0, 0)
	header.size = Vector2(1080, 200)
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.2, 0.1, 0.3, 0.95)
	header_style.border_width_bottom = 3
	header_style.border_color = Color(0.8, 0.4, 1.0)
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
	title.text = "ALCHEMY LAB"
	title.position = Vector2(220, 20)
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(1, 0.7, 1))
	header.add_child(title)
	
	# Essence counter
	var essence_label = Label.new()
	essence_label.name = "EssenceLabel"
	essence_label.text = "Essence: 0"
	essence_label.position = Vector2(220, 90)
	essence_label.add_theme_font_size_override("font_size", 36)
	essence_label.add_theme_color_override("font_color", Color(1, 0.8, 1))
	header.add_child(essence_label)
	
	# EPS counter
	var eps_label = Label.new()
	eps_label.name = "EPSLabel"
	eps_label.text = "Per Second: 0"
	eps_label.position = Vector2(220, 140)
	eps_label.add_theme_font_size_override("font_size", 26)
	eps_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.9))
	header.add_child(eps_label)
	
	# Element displays
	var element_names = ["fire", "water", "earth", "air"]
	var element_icons = ["🔥", "💧", "🌍", "💨"]
	for i in range(4):
		var elem_label = Label.new()
		elem_label.name = element_names[i].capitalize() + "Label"
		elem_label.text = element_icons[i] + " 0"
		elem_label.position = Vector2(680 + (i % 2) * 200, 50 + int(i / 2) * 70)
		elem_label.add_theme_font_size_override("font_size", 28)
		elem_label.add_theme_color_override("font_color", elements[element_names[i]].color)
		header.add_child(elem_label)
	
	# Formulas panel (transmutation recipes)
	var formulas_panel = Panel.new()
	formulas_panel.position = Vector2(40, 230)
	formulas_panel.size = Vector2(1000, 600)
	var formulas_style = StyleBoxFlat.new()
	formulas_style.bg_color = Color(0.18, 0.08, 0.25, 0.95)
	formulas_style.border_width_left = 3
	formulas_style.border_width_right = 3
	formulas_style.border_width_top = 3
	formulas_style.border_width_bottom = 3
	formulas_style.border_color = Color(0.7, 0.3, 0.9)
	formulas_panel.add_theme_stylebox_override("panel", formulas_style)
	ui_layer.add_child(formulas_panel)
	
	var formulas_title = Label.new()
	formulas_title.text = "TRANSMUTATION FORMULAS"
	formulas_title.position = Vector2(20, 15)
	formulas_title.add_theme_font_size_override("font_size", 36)
	formulas_title.add_theme_color_override("font_color", Color(1, 0.7, 1))
	formulas_panel.add_child(formulas_title)
	
	var formulas_scroll = ScrollContainer.new()
	formulas_scroll.position = Vector2(20, 70)
	formulas_scroll.size = Vector2(960, 520)
	formulas_panel.add_child(formulas_scroll)
	
	var formulas_vbox = VBoxContainer.new()
	formulas_vbox.name = "FormulasVBox"
	formulas_scroll.add_child(formulas_vbox)
	
	_create_formula_buttons()
	
	# Generators panel
	var generators_panel = Panel.new()
	generators_panel.position = Vector2(40, 860)
	generators_panel.size = Vector2(1000, 990)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.18, 0.08, 0.25, 0.95)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.7, 0.3, 0.9)
	generators_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(generators_panel)
	
	var generators_title = Label.new()
	generators_title.text = "ELEMENT GENERATORS"
	generators_title.position = Vector2(20, 15)
	generators_title.add_theme_font_size_override("font_size", 36)
	generators_title.add_theme_color_override("font_color", Color(1, 0.7, 1))
	generators_panel.add_child(generators_title)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 70)
	scroll.size = Vector2(960, 910)
	generators_panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.name = "GeneratorsVBox"
	scroll.add_child(vbox)
	
	_create_generator_buttons()

func _create_mystical_effects():
	# Floating sparkles
	for i in range(8):
		var sparkle = Label.new()
		sparkle.text = "✨"
		sparkle.position = Vector2(randf() * 1000, 300 + randf() * 1500)
		sparkle.add_theme_font_size_override("font_size", 24 + randf() * 24)
		sparkle.modulate = Color(1, 0.7 + randf() * 0.3, 1, 0.4 + randf() * 0.4)
		ui_layer.add_child(sparkle)

func _create_formula_buttons():
	var vbox = ui_layer.get_node("Panel/ScrollContainer/FormulasVBox")
	
	for i in range(formulas.size()):
		var formula = formulas[i]
		
		var button = Button.new()
		button.name = "Formula" + str(i)
		button.custom_minimum_size = Vector2(920, 70)
		button.add_theme_font_size_override("font_size", 24)
		
		var text = "⚗️ " + formula.name + " → " + str(formula.essence) + " Essence"
		text += "\nRequires: "
		
		if formula.has("fire") and formula.fire > 0:
			text += "🔥" + str(formula.fire) + " "
		if formula.has("water") and formula.water > 0:
			text += "💧" + str(formula.water) + " "
		if formula.has("earth") and formula.earth > 0:
			text += "🌍" + str(formula.earth) + " "
		if formula.has("air") and formula.air > 0:
			text += "💨" + str(formula.air)
		
		button.text = text
		button.disabled = not formula.unlocked
		button.pressed.connect(_on_formula_pressed.bind(i))
		
		var btn_style = StyleBoxFlat.new()
		if formula.unlocked:
			btn_style.bg_color = Color(0.3, 0.15, 0.4)
		else:
			btn_style.bg_color = Color(0.15, 0.1, 0.2)
		btn_style.border_width_left = 2
		btn_style.border_width_right = 2
		btn_style.border_width_top = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.6, 0.3, 0.8)
		button.add_theme_stylebox_override("normal", btn_style)
		button.add_theme_color_override("font_color", Color(0.95, 0.85, 1))
		
		vbox.add_child(button)
		
		if i < formulas.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 10)
			vbox.add_child(spacer)

func _create_generator_buttons():
	var vbox = ui_layer.get_node("Panel2/ScrollContainer/GeneratorsVBox")
	
	for i in range(generators.size()):
		var gen = generators[i]
		
		var button = Button.new()
		button.name = "Generator" + str(i)
		button.custom_minimum_size = Vector2(920, 90)
		button.add_theme_font_size_override("font_size", 22)
		
		var element_icon = ""
		if gen.element == "fire":
			element_icon = "🔥"
		elif gen.element == "water":
			element_icon = "💧"
		elif gen.element == "earth":
			element_icon = "🌍"
		elif gen.element == "air":
			element_icon = "💨"
		
		var text = gen.icon + " " + gen.name + " (" + element_icon + ")\n"
		text += "Cost: " + _format_number(gen.cost) + " essence | +"
		text += str(gen.rate) + "/s | Owned: " + str(gen.owned)
		button.text = text
		
		button.pressed.connect(_on_generator_pressed.bind(i))
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.3, 0.15, 0.4)
		btn_style.border_width_left = 2
		btn_style.border_width_right = 2
		btn_style.border_width_top = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.6, 0.3, 0.8)
		button.add_theme_stylebox_override("normal", btn_style)
		button.add_theme_color_override("font_color", Color(0.95, 0.85, 1))
		
		vbox.add_child(button)
		
		if i < generators.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 8)
			vbox.add_child(spacer)

func _process(delta):
	essence += essence_per_second * delta
	
	# Generate elements from generators
	for gen in generators:
		if gen.owned > 0:
			elements[gen.element].amount += gen.rate * gen.owned * delta
	
	_update_ui()

func _on_formula_pressed(index: int):
	var formula = formulas[index]
	
	if not formula.unlocked:
		return
	
	# Check if we have enough elements
	var can_craft = true
	if formula.has("fire") and elements.fire.amount < formula.fire:
		can_craft = false
	if formula.has("water") and elements.water.amount < formula.water:
		can_craft = false
	if formula.has("earth") and elements.earth.amount < formula.earth:
		can_craft = false
	if formula.has("air") and elements.air.amount < formula.air:
		can_craft = false
	
	if can_craft:
		# Consume elements
		if formula.has("fire"):
			elements.fire.amount -= formula.fire
		if formula.has("water"):
			elements.water.amount -= formula.water
		if formula.has("earth"):
			elements.earth.amount -= formula.earth
		if formula.has("air"):
			elements.air.amount -= formula.air
		
		# Generate essence
		essence += formula.essence
		
		print("Transmuted ", formula.name, " for ", formula.essence, " essence!")
		
		# Unlock next formulas
		_check_formula_unlocks()

func _check_formula_unlocks():
	# Unlock formulas based on essence earned
	if essence >= 50:
		formulas[4].unlocked = true  # Lava
		formulas[5].unlocked = true  # Cloud
	if essence >= 200:
		formulas[6].unlocked = true  # Lightning
		formulas[7].unlocked = true  # Crystal
	if essence >= 1000:
		formulas[8].unlocked = true  # Philosopher's Stone

func _on_generator_pressed(index: int):
	var gen = generators[index]
	
	if essence >= gen.cost:
		essence -= gen.cost
		gen.owned += 1
		gen.cost = ceil(gen.base_cost * pow(1.15, gen.owned))
		
		_update_generator_button(index)
		_update_ui()

func _update_ui():
	var essence_label = ui_layer.get_node("Panel/EssenceLabel")
	var eps_label = ui_layer.get_node("Panel/EPSLabel")
	
	essence_label.text = "Essence: " + _format_number(essence)
	eps_label.text = "Per Second: " + _format_number(essence_per_second)
	
	# Update element displays
	var fire_label = ui_layer.get_node("Panel/FireLabel")
	var water_label = ui_layer.get_node("Panel/WaterLabel")
	var earth_label = ui_layer.get_node("Panel/EarthLabel")
	var air_label = ui_layer.get_node("Panel/AirLabel")
	
	fire_label.text = "🔥 " + str(int(elements.fire.amount))
	water_label.text = "💧 " + str(int(elements.water.amount))
	earth_label.text = "🌍 " + str(int(elements.earth.amount))
	air_label.text = "💨 " + str(int(elements.air.amount))
	
	# Update formulas
	_check_formula_unlocks()
	for i in range(formulas.size()):
		_update_formula_button(i)
	
	# Update generators
	for i in range(generators.size()):
		_update_generator_button(i)

func _update_formula_button(index: int):
	var formula = formulas[index]
	var vbox = ui_layer.get_node("Panel/ScrollContainer/FormulasVBox")
	var button = vbox.get_node_or_null("Formula" + str(index))
	
	if button:
		button.disabled = not formula.unlocked
		
		# Check if can craft
		var can_craft = formula.unlocked
		if formula.has("fire") and elements.fire.amount < formula.fire:
			can_craft = false
		if formula.has("water") and elements.water.amount < formula.water:
			can_craft = false
		if formula.has("earth") and elements.earth.amount < formula.earth:
			can_craft = false
		if formula.has("air") and elements.air.amount < formula.air:
			can_craft = false
		
		if can_craft and formula.unlocked:
			button.modulate = Color(1, 1, 1)
		else:
			button.modulate = Color(0.6, 0.6, 0.7)

func _update_generator_button(index: int):
	var gen = generators[index]
	var vbox = ui_layer.get_node("Panel2/ScrollContainer/GeneratorsVBox")
	var button = vbox.get_node_or_null("Generator" + str(index))
	
	if button:
		var element_icon = ""
		if gen.element == "fire":
			element_icon = "🔥"
		elif gen.element == "water":
			element_icon = "💧"
		elif gen.element == "earth":
			element_icon = "🌍"
		elif gen.element == "air":
			element_icon = "💨"
		
		var text = gen.icon + " " + gen.name + " (" + element_icon + ")\n"
		text += "Cost: " + _format_number(gen.cost) + " essence | +"
		text += str(gen.rate) + "/s | Owned: " + str(gen.owned)
		button.text = text
		
		button.disabled = essence < gen.cost
		
		if essence >= gen.cost:
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
		"essence": essence,
		"elements": {},
		"generators": [],
		"formulas": []
	}
	
	for elem_name in elements:
		save_data.elements[elem_name] = elements[elem_name].amount
	
	for gen in generators:
		save_data.generators.append({
			"owned": gen.owned,
			"cost": gen.cost
		})
	
	for formula in formulas:
		save_data.formulas.append({
			"unlocked": formula.unlocked
		})
	
	var save_file = FileAccess.open("user://alchemy_save.dat", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()

func _load_game():
	if FileAccess.file_exists("user://alchemy_save.dat"):
		var save_file = FileAccess.open("user://alchemy_save.dat", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			
			essence = save_data.get("essence", 0.0)
			
			var saved_elements = save_data.get("elements", {})
			for elem_name in saved_elements:
				if elements.has(elem_name):
					elements[elem_name].amount = saved_elements[elem_name]
			
			var saved_generators = save_data.get("generators", [])
			for i in range(min(saved_generators.size(), generators.size())):
				generators[i].owned = saved_generators[i].owned
				generators[i].cost = saved_generators[i].cost
			
			var saved_formulas = save_data.get("formulas", [])
			for i in range(min(saved_formulas.size(), formulas.size())):
				formulas[i].unlocked = saved_formulas[i].unlocked
			
			print("Alchemy game loaded!")
