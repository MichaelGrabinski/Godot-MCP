extends Control

# Main Menu - Hub for all game modes and progression

@onready var start_button = $MenuButtons/StartButton
@onready var daily_button = $MenuButtons/DailyButton
@onready var upgrades_button = $MenuButtons/UpgradesButton
@onready var classes_button = $MenuButtons/ClassesButton
@onready var stats_button = $MenuButtons/StatsButton
@onready var settings_button = $MenuButtons/SettingsButton
@onready var quit_button = $MenuButtons/QuitButton

@onready var meta_currency_label = $TopBar/MetaCurrencyLabel
@onready var title_label = $Title

var meta_stats: MetaProgression.PersistentStats

const MetaProgression = preload("res://DieselPunk/scripts/meta_progression.gd")
const DailyChallenge = preload("res://DieselPunk/scripts/daily_challenge.gd")

func _ready():
	# Load persistent stats
	meta_stats = MetaProgression.load_persistent_stats()
	
	# Update UI
	update_currency_display()
	
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	daily_button.pressed.connect(_on_daily_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	classes_button.pressed.connect(_on_classes_pressed)
	stats_button.pressed.connect(_on_stats_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Check for daily challenge completion
	update_daily_button()
	
	# Title animation
	animate_title()

func update_currency_display():
	meta_currency_label.text = "⚙ Meta Currency: " + str(meta_stats.meta_currency)

func update_daily_button():
	if DailyChallenge.has_completed_today("Player"):  # Would use actual player name
		daily_button.text = "Daily Challenge ✓"
		daily_button.modulate = Color(0.6, 1.0, 0.6)
	else:
		daily_button.text = "Daily Challenge!"
		daily_button.modulate = Color(1.0, 0.9, 0.3)

func animate_title():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(title_label, "scale", Vector2(1.05, 1.05), 1.0)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.0)

func _on_start_pressed():
	# Show class selection, then start game
	show_class_selection(false)

func _on_daily_pressed():
	# Start daily challenge
	var challenge = DailyChallenge.get_today_challenge()
	# Pass challenge to game scene
	get_tree().change_scene_to_file("res://DieselPunk/scenes/main.tscn")

func _on_upgrades_pressed():
	show_upgrades_menu()

func _on_classes_pressed():
	show_class_selection(true)

func _on_stats_pressed():
	show_stats_screen()

func _on_settings_pressed():
	show_settings_menu()

func _on_quit_pressed():
	get_tree().quit()

func show_class_selection(view_only: bool):
	# Create popup showing available classes
	var popup = create_popup("Select Your Class")
	
	var classes = MetaProgression.get_all_classes()
	var y_offset = 50
	
	for player_class in classes:
		var is_unlocked = player_class.name in meta_stats.unlocked_classes
		
		var class_panel = Panel.new()
		class_panel.custom_minimum_size = Vector2(400, 80)
		class_panel.position = Vector2(50, y_offset)
		
		var class_label = Label.new()
		class_label.text = player_class.name + "\n" + player_class.description
		class_label.position = Vector2(10, 10)
		
		if not is_unlocked:
			class_label.text += "\n[LOCKED: " + player_class.unlock_requirement + "]"
			class_panel.modulate = Color(0.5, 0.5, 0.5)
		else:
			if not view_only:
				var select_btn = Button.new()
				select_btn.text = "SELECT"
				select_btn.position = Vector2(300, 25)
				select_btn.pressed.connect(func(): start_game_with_class(player_class.name))
				class_panel.add_child(select_btn)
		
		class_panel.add_child(class_label)
		popup.add_child(class_panel)
		
		y_offset += 100
	
	add_child(popup)

func show_upgrades_menu():
	var popup = create_popup("Meta Upgrades")
	
	var upgrades = MetaProgression.get_all_meta_upgrades()
	var y_offset = 50
	
	for upgrade in upgrades:
		var current_level = meta_stats.purchased_upgrades.get(upgrade.name, 0)
		var can_buy = current_level < upgrade.max_level and meta_stats.can_afford(upgrade.cost)
		
		var upgrade_panel = Panel.new()
		upgrade_panel.custom_minimum_size = Vector2(450, 70)
		upgrade_panel.position = Vector2(50, y_offset)
		
		var upgrade_label = Label.new()
		var level_text = " (Level " + str(current_level) + "/" + str(upgrade.max_level) + ")"
		upgrade_label.text = upgrade.name + level_text + "\n" + upgrade.description
		upgrade_label.position = Vector2(10, 10)
		upgrade_panel.add_child(upgrade_label)
		
		if current_level < upgrade.max_level:
			var buy_btn = Button.new()
			buy_btn.text = "Buy (" + str(upgrade.cost) + " ⚙)"
			buy_btn.position = Vector2(320, 20)
			buy_btn.disabled = not can_buy
			buy_btn.pressed.connect(func(): purchase_upgrade(upgrade, popup))
			upgrade_panel.add_child(buy_btn)
		else:
			var maxed_label = Label.new()
			maxed_label.text = "MAX"
			maxed_label.position = Vector2(350, 25)
			maxed_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.0))
			upgrade_panel.add_child(maxed_label)
		
		popup.add_child(upgrade_panel)
		y_offset += 85
	
	add_child(popup)

func purchase_upgrade(upgrade: MetaProgression.MetaUpgrade, popup: Control):
	var current_level = meta_stats.purchased_upgrades.get(upgrade.name, 0)
	
	if meta_stats.spend_currency(upgrade.cost):
		meta_stats.purchased_upgrades[upgrade.name] = current_level + 1
		MetaProgression.save_persistent_stats(meta_stats)
		
		# Refresh display
		popup.queue_free()
		show_upgrades_menu()
		update_currency_display()

func show_stats_screen():
	var popup = create_popup("Your Statistics")
	
	var stats_text = """
	Total Runs: %d
	Total Kills: %d
	Total Damage Dealt: %d
	Total Damage Taken: %d
	Highest Floor: %d
	Bosses Killed: %d
	Deaths: %d
	
	Unlocked Classes: %d
	Meta Currency: %d
	""" % [
		meta_stats.total_runs,
		meta_stats.total_kills,
		meta_stats.total_damage_dealt,
		meta_stats.total_damage_taken,
		meta_stats.highest_floor,
		meta_stats.bosses_killed,
		meta_stats.total_deaths,
		meta_stats.unlocked_classes.size(),
		meta_stats.meta_currency
	]
	
	var label = Label.new()
	label.text = stats_text
	label.position = Vector2(50, 50)
	label.add_theme_font_size_override("font_size", 18)
	popup.add_child(label)
	
	add_child(popup)

func show_settings_menu():
	var popup = create_popup("Settings")
	
	var label = Label.new()
	label.text = "Settings coming soon!\n\nSound Volume\nMusic Volume\nScreen Shake\nParticle Effects"
	label.position = Vector2(50, 50)
	popup.add_child(label)
	
	add_child(popup)

func create_popup(title_text: String) -> Control:
	var popup = Control.new()
	popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Dark overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup.add_child(overlay)
	
	# Main panel
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 500)
	panel.position = Vector2(360, 140)
	
	# Title
	var title = Label.new()
	title.text = title_text
	title.position = Vector2(20, 10)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	panel.add_child(title)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.position = Vector2(550, 10)
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.pressed.connect(popup.queue_free)
	panel.add_child(close_btn)
	
	popup.add_child(panel)
	
	return popup

func start_game_with_class(class_name: String):
	# Store selected class globally
	GlobalData.selected_class = class_name
	get_tree().change_scene_to_file("res://DieselPunk/scenes/main.tscn")

# Global autoload for passing data between scenes
class GlobalData:
	static var selected_class: String = "Engineer"
	static var is_daily_challenge: bool = false
	static var daily_challenge_seed: int = 0
