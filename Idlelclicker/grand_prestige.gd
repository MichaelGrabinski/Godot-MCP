extends Control

# Grand Prestige - Reset EVERYTHING for permanent empire-wide bonuses!

var grand_prestige_level: int = 0
var required_total_wealth: float = 1000000.0  # 1M combined wealth

# Permanent bonuses from grand prestige
var permanent_bonuses = {
	"production_multiplier": 1.0,
	"cost_reduction": 0.0,
	"unlock_bonus": false
}

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	_load_grand_prestige()
	_setup_ui()

func _setup_ui():
	# Background gradient
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.02, 0.1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Glowing effect
	for i in range(20):
		var glow = Label.new()
		glow.text = "✨"
		glow.position = Vector2(randf() * 1080, randf() * 1920)
		glow.add_theme_font_size_override("font_size", 24 + randf() * 48)
		glow.modulate = Color(1, 0.8 + randf() * 0.2, 0.2 + randf() * 0.8, 0.3 + randf() * 0.5)
		add_child(glow)
	
	# Title
	var title = Label.new()
	title.text = "⭐ GRAND PRESTIGE ⭐"
	title.position = Vector2(200, 100)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	add_child(title)
	
	# Current level
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "Grand Prestige Level: " + str(grand_prestige_level)
	level_label.position = Vector2(280, 220)
	level_label.add_theme_font_size_override("font_size", 40)
	level_label.add_theme_color_override("font_color", Color(1, 1, 0.7))
	add_child(level_label)
	
	# Info panel
	var info_panel = Panel.new()
	info_panel.position = Vector2(90, 320)
	info_panel.size = Vector2(900, 400)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.1, 0.2, 0.9)
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1, 0.8, 0.3)
	info_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(info_panel)
	
	var info_title = Label.new()
	info_title.text = "WHAT IS GRAND PRESTIGE?"
	info_title.position = Vector2(30, 20)
	info_title.add_theme_font_size_override("font_size", 36)
	info_title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	info_panel.add_child(info_title)
	
	var info_text = Label.new()
	info_text.text = """Reset ALL four domains for permanent bonuses!

💎 Requires: 1M total wealth across all domains
⚠️ Resets: Tower, Mining, Airships, Alchemy
✨ Keeps: Grand Prestige level & bonuses
🎁 Gain: Permanent production multiplier

Each Grand Prestige:
• +50% production in ALL domains (stacks!)
• Tower prestige multiplier also applies
• Access to special upgrades
• Faster progression permanently"""
	info_text.position = Vector2(30, 80)
	info_text.add_theme_font_size_override("font_size", 24)
	info_text.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	info_panel.add_child(info_text)
	
	# Current bonuses panel
	var bonuses_panel = Panel.new()
	bonuses_panel.position = Vector2(90, 760)
	bonuses_panel.size = Vector2(900, 300)
	var bonuses_style = StyleBoxFlat.new()
	bonuses_style.bg_color = Color(0.12, 0.08, 0.18, 0.9)
	bonuses_style.border_width_left = 4
	bonuses_style.border_width_right = 4
	bonuses_style.border_width_top = 4
	bonuses_style.border_width_bottom = 4
	bonuses_style.border_color = Color(0.8, 0.6, 1.0)
	bonuses_panel.add_theme_stylebox_override("panel", bonuses_style)
	add_child(bonuses_panel)
	
	var bonuses_title = Label.new()
	bonuses_title.text = "CURRENT BONUSES"
	bonuses_title.position = Vector2(30, 20)
	bonuses_title.add_theme_font_size_override("font_size", 36)
	bonuses_title.add_theme_color_override("font_color", Color(0.9, 0.7, 1.0))
	bonuses_panel.add_child(bonuses_title)
	
	var multiplier_text = Label.new()
	multiplier_text.name = "MultiplierText"
	var mult = permanent_bonuses.production_multiplier
	multiplier_text.text = "Production Multiplier: x" + str(mult)
	multiplier_text.position = Vector2(50, 90)
	multiplier_text.add_theme_font_size_override("font_size", 32)
	multiplier_text.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	bonuses_panel.add_child(multiplier_text)
	
	var applies_text = Label.new()
	applies_text.text = "Applies to: All production in all domains!"
	applies_text.position = Vector2(50, 140)
	applies_text.add_theme_font_size_override("font_size", 26)
	applies_text.add_theme_color_override("font_color", Color(0.8, 0.9, 0.8))
	bonuses_panel.add_child(applies_text)
	
	# Progress panel
	var progress_panel = Panel.new()
	progress_panel.position = Vector2(90, 1100)
	progress_panel.size = Vector2(900, 250)
	var progress_style = StyleBoxFlat.new()
	progress_style.bg_color = Color(0.18, 0.12, 0.08, 0.9)
	progress_style.border_width_left = 4
	progress_style.border_width_right = 4
	progress_style.border_width_top = 4
	progress_style.border_width_bottom = 4
	progress_style.border_color = Color(1, 0.6, 0.2)
	progress_panel.add_theme_stylebox_override("panel", progress_style)
	add_child(progress_panel)
	
	var progress_title = Label.new()
	progress_title.text = "PROGRESS TO NEXT"
	progress_title.position = Vector2(30, 20)
	progress_title.add_theme_font_size_override("font_size", 36)
	progress_title.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
	progress_panel.add_child(progress_title)
	
	var wealth_label = Label.new()
	wealth_label.name = "WealthLabel"
	wealth_label.text = "Total Wealth: 0 / 1M"
	wealth_label.position = Vector2(50, 90)
	wealth_label.add_theme_font_size_override("font_size", 32)
	wealth_label.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	progress_panel.add_child(wealth_label)
	
	var progress_bar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.position = Vector2(50, 150)
	progress_bar.size = Vector2(800, 40)
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_panel.add_child(progress_bar)
	
	# Prestige button
	var prestige_btn = Button.new()
	prestige_btn.name = "PrestigeButton"
	prestige_btn.text = "⭐ GRAND PRESTIGE ⭐"
	prestige_btn.position = Vector2(290, 1420)
	prestige_btn.size = Vector2(500, 120)
	prestige_btn.add_theme_font_size_override("font_size", 40)
	prestige_btn.pressed.connect(_on_prestige_pressed)
	
	var prestige_style = StyleBoxFlat.new()
	prestige_style.bg_color = Color(0.6, 0.3, 0.1)
	prestige_style.border_width_left = 5
	prestige_style.border_width_right = 5
	prestige_style.border_width_top = 5
	prestige_style.border_width_bottom = 5
	prestige_style.border_color = Color(1, 0.8, 0.2)
	prestige_btn.add_theme_stylebox_override("normal", prestige_style)
	
	var prestige_hover = prestige_style.duplicate()
	prestige_hover.bg_color = Color(0.7, 0.4, 0.15)
	prestige_btn.add_theme_stylebox_override("hover", prestige_hover)
	
	prestige_btn.add_theme_color_override("font_color", Color(1, 1, 0.8))
	add_child(prestige_btn)
	
	# Back button
	var back_btn = Button.new()
	back_btn.text = "← BACK TO MENU"
	back_btn.position = Vector2(340, 1600)
	back_btn.size = Vector2(400, 80)
	back_btn.add_theme_font_size_override("font_size", 32)
	back_btn.pressed.connect(_on_back_pressed)
	
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.3, 0.2, 0.15)
	back_style.border_width_left = 3
	back_style.border_width_right = 3
	back_style.border_width_top = 3
	back_style.border_width_bottom = 3
	back_style.border_color = Color(0.6, 0.4, 0.2)
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	add_child(back_btn)
	
	_update_ui()

func _update_ui():
	var total_wealth = _calculate_total_wealth()
	
	var wealth_label = get_node_or_null("Panel2/WealthLabel")
	if wealth_label:
		wealth_label.text = "Total Wealth: " + _format_number(total_wealth) + " / " + _format_number(required_total_wealth)
	
	var progress_bar = get_node_or_null("Panel2/ProgressBar")
	if progress_bar:
		var percent = (total_wealth / required_total_wealth) * 100.0
		progress_bar.value = min(percent, 100)
	
	var prestige_btn = get_node_or_null("PrestigeButton")
	if prestige_btn:
		if total_wealth >= required_total_wealth:
			prestige_btn.disabled = false
			prestige_btn.text = "⭐ GRAND PRESTIGE ⭐"
		else:
			prestige_btn.disabled = true
			var remaining = required_total_wealth - total_wealth
			prestige_btn.text = "Need " + _format_number(remaining) + " more"
	
	var mult_text = get_node_or_null("Panel/MultiplierText")
	if mult_text:
		mult_text.text = "Production Multiplier: x" + str(permanent_bonuses.production_multiplier)

func _calculate_total_wealth() -> float:
	var total = 0.0
	
	# Tower cogs
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			total += data.get("total_cogs_earned", 0.0)
	
	# Mining ore
	if FileAccess.file_exists("user://mining_save.dat"):
		var file = FileAccess.open("user://mining_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			total += data.get("ore", 0.0)
	
	# Airship gold
	if FileAccess.file_exists("user://airship_save.dat"):
		var file = FileAccess.open("user://airship_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			total += data.get("total_gold_earned", 0.0)
	
	# Alchemy essence
	if FileAccess.file_exists("user://alchemy_save.dat"):
		var file = FileAccess.open("user://alchemy_save.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			total += data.get("essence", 0.0)
	
	return total

func _on_prestige_pressed():
	var total_wealth = _calculate_total_wealth()
	
	if total_wealth < required_total_wealth:
		print("Not enough wealth!")
		return
	
	# Confirm dialog
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Are you sure you want to Grand Prestige?\n\nThis will RESET ALL FOUR DOMAINS!\n\nYou will gain:\n+50% permanent production multiplier"
	confirm.confirmed.connect(_perform_grand_prestige)
	add_child(confirm)
	confirm.popup_centered()

func _perform_grand_prestige():
	# Increase grand prestige level
	grand_prestige_level += 1
	
	# Update permanent bonuses
	permanent_bonuses.production_multiplier = 1.0 + (grand_prestige_level * 0.5)
	
	# Delete all domain saves
	if FileAccess.file_exists("user://savegame.dat"):
		DirAccess.remove_absolute("user://savegame.dat")
	if FileAccess.file_exists("user://mining_save.dat"):
		DirAccess.remove_absolute("user://mining_save.dat")
	if FileAccess.file_exists("user://airship_save.dat"):
		DirAccess.remove_absolute("user://airship_save.dat")
	if FileAccess.file_exists("user://alchemy_save.dat"):
		DirAccess.remove_absolute("user://alchemy_save.dat")
	
	# Save grand prestige data
	_save_grand_prestige()
	
	print("Grand Prestige complete! Level: ", grand_prestige_level)
	print("New multiplier: ", permanent_bonuses.production_multiplier)
	
	# Return to menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _save_grand_prestige():
	var save_data = {
		"level": grand_prestige_level,
		"bonuses": permanent_bonuses
	}
	
	var file = FileAccess.open("user://grand_prestige.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func _load_grand_prestige():
	if FileAccess.file_exists("user://grand_prestige.dat"):
		var file = FileAccess.open("user://grand_prestige.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			
			grand_prestige_level = data.get("level", 0)
			var saved_bonuses = data.get("bonuses", {})
			for key in saved_bonuses:
				permanent_bonuses[key] = saved_bonuses[key]

func _format_number(num: float) -> String:
	if num < 1000:
		return str(int(num))
	elif num < 1000000:
		return str(snapped(num / 1000.0, 0.1)) + "K"
	elif num < 1000000000:
		return str(snapped(num / 1000000.0, 0.1)) + "M"
	else:
		return str(snapped(num / 1000000000.0, 0.1)) + "B"

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
