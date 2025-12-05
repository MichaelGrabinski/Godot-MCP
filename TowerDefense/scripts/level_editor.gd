extends Node2D

## Complete Level Editor - Creates UI dynamically, no scene setup needed

enum EditorMode { NONE, PATH_DRAWING, TOWER_PLACING }

var current_mode = EditorMode.NONE
var is_panning = false
var pan_start_position = Vector2.ZERO
var tower_spot_size = 80.0
var path_width = 80.0

var camera
var background
var path_line
var tower_spots
var ui_nodes = {}

func _ready():
	setup_scene()
	connect_ui()

func setup_scene():
	# Get or create camera
	camera = get_node_or_null("Camera2D")
	if not camera:
		camera = Camera2D.new()
		camera.name = "Camera2D"
		add_child(camera)
	
	# Get or create background
	background = get_node_or_null("MapBackground")
	if not background:
		background = Sprite2D.new()
		background.name = "MapBackground"
		background.centered = false
		add_child(background)
	
	# Get or create path
	var path_layer = get_node_or_null("PathDrawing")
	if not path_layer:
		path_layer = Node2D.new()
		path_layer.name = "PathDrawing"
		add_child(path_layer)
	
	path_line = path_layer.get_node_or_null("PathLine")
	if not path_line:
		path_line = Line2D.new()
		path_line.name = "PathLine"
		path_line.width = 80
		path_line.default_color = Color(1, 0, 0, 0.5)
		path_layer.add_child(path_line)
	
	# Get or create tower spots
	tower_spots = get_node_or_null("TowerSpots")
	if not tower_spots:
		tower_spots = Node2D.new()
		tower_spots.name = "TowerSpots"
		add_child(tower_spots)
	
	create_ui()

func create_ui():
	var ui = get_node_or_null("EditorUI")
	if not ui:
		ui = CanvasLayer.new()
		ui.name = "EditorUI"
		add_child(ui)
	
	var panel = Panel.new()
	panel.name = "Panel"
	panel.position = Vector2(10, 10)
	panel.custom_minimum_size = Vector2(260, 700)
	ui.add_child(panel)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(5, 5)
	scroll.size = Vector2(250, 690)
	panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)
	
	# Title
	add_label(vbox, "LEVEL EDITOR", 24)
	vbox.add_child(HSeparator.new())
	
	# Load Image
	add_label(vbox, "1. Load Map Image:", 16)
	ui_nodes["image_path"] = add_line_edit(vbox, "res://TowerDefense/assets/terrain/map.png")
	ui_nodes["load_button"] = add_button(vbox, "Load Image")
	vbox.add_child(HSeparator.new())
	
	# Path Drawing
	add_label(vbox, "2. Draw Enemy Path:", 16)
	ui_nodes["path_button"] = add_toggle_button(vbox, "Click to Draw Path")
	add_label(vbox, "Path Width:")
	ui_nodes["path_slider"] = add_slider(vbox, 20, 150, 80)
	ui_nodes["clear_path"] = add_button(vbox, "Clear Path")
	vbox.add_child(HSeparator.new())
	
	# Tower Placement
	add_label(vbox, "3. Place Tower Spots:", 16)
	ui_nodes["tower_button"] = add_toggle_button(vbox, "Click to Place Towers")
	add_label(vbox, "Tower Size:")
	ui_nodes["tower_slider"] = add_slider(vbox, 40, 120, 80)
	ui_nodes["clear_towers"] = add_button(vbox, "Clear All Towers")
	vbox.add_child(HSeparator.new())
	
	# Export
	add_label(vbox, "4. Export Level:", 16)
	ui_nodes["export_button"] = add_button(vbox, "Export to JSON")
	ui_nodes["status"] = add_label(vbox, "Ready", 12)
	vbox.add_child(HSeparator.new())
	
	# Controls
	add_label(vbox, "CONTROLS:\n• Mouse Wheel: Zoom\n• Middle Click: Pan\n• Right Click: Delete", 11)

func add_label(parent, txt, size = 14):
	var label = Label.new()
	label.text = txt
	label.add_theme_font_size_override("font_size", size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(label)
	return label

func add_line_edit(parent, placeholder):
	var edit = LineEdit.new()
	edit.placeholder_text = placeholder
	edit.custom_minimum_size = Vector2(0, 35)
	parent.add_child(edit)
	return edit

func add_button(parent, txt):
	var btn = Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(0, 40)
	parent.add_child(btn)
	return btn

func add_toggle_button(parent, txt):
	var btn = Button.new()
	btn.text = txt
	btn.toggle_mode = true
	btn.custom_minimum_size = Vector2(0, 40)
	parent.add_child(btn)
	return btn

func add_slider(parent, min_val, max_val, val):
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = val
	slider.custom_minimum_size = Vector2(0, 30)
	parent.add_child(slider)
	return slider

func connect_ui():
	ui_nodes["load_button"].pressed.connect(_on_load_image)
	ui_nodes["path_button"].toggled.connect(_on_path_mode)
	ui_nodes["tower_button"].toggled.connect(_on_tower_mode)
	ui_nodes["path_slider"].value_changed.connect(_on_path_width)
	ui_nodes["tower_slider"].value_changed.connect(_on_tower_size)
	ui_nodes["clear_path"].pressed.connect(_on_clear_path)
	ui_nodes["clear_towers"].pressed.connect(_on_clear_towers)
	ui_nodes["export_button"].pressed.connect(_on_export)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_position = event.position
			else:
				is_panning = false
	
	if event is InputEventMouseMotion and is_panning:
		var delta = (event.position - pan_start_position) / camera.zoom
		camera.position -= delta
		pan_start_position = event.position

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if current_mode == EditorMode.PATH_DRAWING:
				path_line.add_point(mouse_pos)
				update_status("Path points: %d" % path_line.get_point_count())
			elif current_mode == EditorMode.TOWER_PLACING:
				place_tower_spot(mouse_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if current_mode == EditorMode.TOWER_PLACING:
				delete_tower_at(mouse_pos)

func _on_load_image():
	var path = ui_nodes["image_path"].text
	if path.is_empty():
		update_status("Enter image path!", true)
		return
	
	var texture = load(path)
	if texture:
		background.texture = texture
		camera.position = texture.get_size() / 2
		update_status("Loaded: " + path)
	else:
		update_status("Failed to load!", true)

func _on_path_mode(pressed):
	if pressed:
		current_mode = EditorMode.PATH_DRAWING
		ui_nodes["tower_button"].button_pressed = false
		update_status("PATH MODE: Click to draw")
	else:
		current_mode = EditorMode.NONE
		update_status("Ready")

func _on_tower_mode(pressed):
	if pressed:
		current_mode = EditorMode.TOWER_PLACING
		ui_nodes["path_button"].button_pressed = false
		update_status("TOWER MODE: Click to place")
	else:
		current_mode = EditorMode.NONE
		update_status("Ready")

func _on_path_width(value):
	path_width = value
	path_line.width = value

func _on_tower_size(value):
	tower_spot_size = value

func _on_clear_path():
	path_line.clear_points()
	update_status("Path cleared")

func _on_clear_towers():
	for child in tower_spots.get_children():
		child.queue_free()
	update_status("Towers cleared")

func place_tower_spot(pos):
	for child in tower_spots.get_children():
		if child.global_position.distance_to(pos) < tower_spot_size:
			update_status("Too close!", true)
			return
	
	var spot = ColorRect.new()
	spot.size = Vector2(tower_spot_size, tower_spot_size)
	spot.position = pos - spot.size / 2
	spot.color = Color(0.3, 0.8, 0.3, 0.6)
	tower_spots.add_child(spot)
	
	var center = ColorRect.new()
	center.size = Vector2(4, 4)
	center.position = spot.size / 2 - Vector2(2, 2)
	center.color = Color.RED
	spot.add_child(center)
	
	update_status("Towers: %d" % tower_spots.get_child_count())

func delete_tower_at(pos):
	for child in tower_spots.get_children():
		var center = child.global_position + child.size / 2
		if center.distance_to(pos) < tower_spot_size / 2:
			child.queue_free()
			update_status("Tower deleted")
			return

func _on_export():
	var data = {
		"map_image": ui_nodes["image_path"].text,
		"path": [],
		"tower_spots": []
	}
	
	for i in range(path_line.get_point_count()):
		var p = path_line.get_point_position(i)
		data.path.append({"x": p.x, "y": p.y})
	
	for child in tower_spots.get_children():
		var c = child.global_position + child.size / 2
		data.tower_spots.append({"x": c.x, "y": c.y, "size": child.size.x})
	
	var json = JSON.stringify(data, "\t")
	var file = FileAccess.open("res://TowerDefense/assets/level_data.json", FileAccess.WRITE)
	if file:
		file.store_string(json)
		file.close()
		update_status("Exported!")
		print("Level exported successfully!")
	else:
		update_status("Export failed!", true)

func update_status(txt, is_error = false):
	ui_nodes["status"].text = txt
	if is_error:
		ui_nodes["status"].add_theme_color_override("font_color", Color.RED)
	else:
		ui_nodes["status"].add_theme_color_override("font_color", Color.WHITE)
