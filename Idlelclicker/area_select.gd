extends Control

func _ready():
	var back_button = get_node_or_null("BackButton")
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# Connect play buttons for each area
	var grid = get_node_or_null("AreaGrid")
	if grid:
		for card in grid.get_children():
			var play_btn = card.get_node_or_null("PlayButton")
			if play_btn and not play_btn.disabled:
				var card_name = card.name
				if card_name == "ClockworkTowerCard":
					play_btn.pressed.connect(_on_play_clockwork_tower)
				elif card_name == "MiningQuarryCard":
					play_btn.pressed.connect(_on_play_mining_quarry)
				elif card_name == "AirshipDockCard":
					play_btn.pressed.connect(_on_play_airship_dock)
				elif card_name == "AlchemyLabCard":
					play_btn.pressed.connect(_on_play_alchemy_lab)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_play_clockwork_tower():
	get_tree().change_scene_to_file("res://scenes/steampunk_clicker.tscn")

func _on_play_mining_quarry():
	print("Mining Quarry coming soon!")

func _on_play_airship_dock():
	print("Airship Dock coming soon!")

func _on_play_alchemy_lab():
	print("Alchemy Lab coming soon!")
