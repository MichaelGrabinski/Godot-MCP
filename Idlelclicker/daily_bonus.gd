extends Control

# Daily Bonus & Special Events System

var daily_streak: int = 0
var last_claim_day: int = 0
var current_event: Dictionary = {}

# Daily rewards by streak
var daily_rewards = [
	{"day": 1, "type": "cogs", "amount": 100, "icon": "🏗️"},
	{"day": 2, "type": "ore", "amount": 50, "icon": "⛏️"},
	{"day": 3, "type": "gold", "amount": 25, "icon": "🛩️"},
	{"day": 4, "type": "essence", "amount": 10, "icon": "⚗️"},
	{"day": 5, "type": "multiplier", "amount": 2.0, "icon": "⭐"},
	{"day": 6, "type": "all", "amount": 200, "icon": "💎"},
	{"day": 7, "type": "grand", "amount": 1, "icon": "🌟"}
]

# Special events (rotating)
var events = [
	{
		"name": "Double Production Weekend",
		"desc": "All production x2 for 24 hours!",
		"icon": "⚡",
		"multiplier": 2.0,
		"duration": 86400
	},
	{
		"name": "Golden Hour",
		"desc": "Airship expeditions return instantly!",
		"icon": "✈️",
		"effect": "instant_routes",
		"duration": 3600
	},
	{
		"name": "Element Storm",
		"desc": "Elements generate 5x faster!",
		"icon": "🌪️",
		"multiplier": 5.0,
		"duration": 7200
	},
	{
		"name": "Deep Dig Event",
		"desc": "Depth progress 3x faster!",
		"icon": "⛏️",
		"multiplier": 3.0,
		"duration": 10800
	}
]

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	
	_load_daily_data()
	_check_daily_reset()
	_setup_ui()

func _setup_ui():
	# Gradient background
	var bg_top = ColorRect.new()
	bg_top.color = Color(0.2, 0.05, 0.3)
	bg_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bg_top.size.y = 960
	add_child(bg_top)
	
	var bg_bottom = ColorRect.new()
	bg_bottom.color = Color(0.05, 0.02, 0.1)
	bg_bottom.position = Vector2(0, 960)
	bg_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bg_bottom.size = Vector2(1080, 960)
	add_child(bg_bottom)
	
	# Sparkle effects
	for i in range(30):
		var sparkle = Label.new()
		sparkle.text = ["✨", "⭐", "💫"][randi() % 3]
		sparkle.position = Vector2(randf() * 1080, randf() * 1920)
		sparkle.add_theme_font_size_override("font_size", 16 + randf() * 32)
		sparkle.modulate = Color(1, 0.8 + randf() * 0.2, 0.5 + randf() * 0.5, 0.3 + randf() * 0.5)
		add_child(sparkle)
	
	# Title
	var title = Label.new()
	title.text = "🎁 DAILY BONUS 🎁"
	title.position = Vector2(260, 80)
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	add_child(title)
	
	# Streak display
	var streak_label = Label.new()
	streak_label.name = "StreakLabel"
	streak_label.text = "Current Streak: " + str(daily_streak) + " days 🔥"
	streak_label.position = Vector2(350, 180)
	streak_label.add_theme_font_size_override("font_size", 36)
	streak_label.add_theme_color_override("font_color", Color(1, 0.7, 0.3))
	add_child(streak_label)
	
	# Daily rewards grid
	var rewards_panel = Panel.new()
	rewards_panel.position = Vector2(90, 260)
	rewards_panel.size = Vector2(900, 620)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.1, 0.2, 0.95)
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1, 0.8, 0.3)
	rewards_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(rewards_panel)
	
	var rewards_title = Label.new()
	rewards_title.text = "7-DAY REWARDS"
	rewards_title.position = Vector2(30, 20)
	rewards_title.add_theme_font_size_override("font_size", 40)
	rewards_title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	rewards_panel.add_child(rewards_title)
	
	# Create reward day cards
	for i in range(7):
		var day_card = _create_day_card(i)
		var col = i % 4
		var row = int(i / 4)
		day_card.position = Vector2(30 + col * 220, 90 + row * 250)
		rewards_panel.add_child(day_card)
	
	# Claim button
	var claim_btn = Button.new()
	claim_btn.name = "ClaimButton"
	claim_btn.text = "🎁 CLAIM DAILY REWARD 🎁"
	claim_btn.position = Vector2(240, 920)
	claim_btn.size = Vector2(600, 100)
	claim_btn.add_theme_font_size_override("font_size", 36)
	claim_btn.pressed.connect(_on_claim_pressed)
	
	var claim_style = StyleBoxFlat.new()
	claim_style.bg_color = Color(0.5, 0.3, 0.1)
	claim_style.border_width_left = 5
	claim_style.border_width_right = 5
	claim_style.border_width_top = 5
	claim_style.border_width_bottom = 5
	claim_style.border_color = Color(1, 0.8, 0.2)
	claim_btn.add_theme_stylebox_override("normal", claim_style)
	claim_btn.add_theme_color_override("font_color", Color(1, 1, 0.8))
	add_child(claim_btn)
	
	# Event panel
	var event_panel = Panel.new()
	event_panel.position = Vector2(90, 1060)
	event_panel.size = Vector2(900, 440)
	var event_style = StyleBoxFlat.new()
	event_style.bg_color = Color(0.12, 0.08, 0.18, 0.95)
	event_style.border_width_left = 4
	event_style.border_width_right = 4
	event_style.border_width_top = 4
	event_style.border_width_bottom = 4
	event_style.border_color = Color(0.8, 0.6, 1.0)
	event_panel.add_theme_stylebox_override("panel", event_style)
	add_child(event_panel)
	
	var event_title = Label.new()
	event_title.text = "⚡ SPECIAL EVENT ⚡"
	event_title.position = Vector2(30, 20)
	event_title.add_theme_font_size_override("font_size", 40)
	event_title.add_theme_color_override("font_color", Color(0.9, 0.7, 1.0))
	event_panel.add_child(event_title)
	
	var event_info = Label.new()
	event_info.name = "EventInfo"
	event_info.text = "No active event\n\nCheck back later for special bonuses!"
	event_info.position = Vector2(50, 100)
	event_info.add_theme_font_size_override("font_size", 32)
	event_info.add_theme_color_override("font_color", Color(0.85, 0.75, 0.95))
	event_panel.add_child(event_info)
	
	# Start random event button
	var event_btn = Button.new()
	event_btn.text = "🎲 ACTIVATE RANDOM EVENT"
	event_btn.position = Vector2(200, 320)
	event_btn.size = Vector2(500, 80)
	event_btn.add_theme_font_size_override("font_size", 28)
	event_btn.pressed.connect(_on_activate_event_pressed)
	event_panel.add_child(event_btn)
	
	# Back button
	var back_btn = Button.new()
	back_btn.text = "← BACK TO MENU"
	back_btn.position = Vector2(340, 1560)
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

func _create_day_card(day_index: int) -> Panel:
	var reward = daily_rewards[day_index]
	var card = Panel.new()
	card.custom_minimum_size = Vector2(200, 220)
	
	var is_today = (daily_streak % 7) == day_index
	var is_claimed = _is_day_claimed(day_index)
	
	var card_style = StyleBoxFlat.new()
	if is_today and not is_claimed:
		card_style.bg_color = Color(0.4, 0.3, 0.1)
		card_style.border_color = Color(1, 0.9, 0.3)
	elif is_claimed:
		card_style.bg_color = Color(0.15, 0.2, 0.15)
		card_style.border_color = Color(0.5, 0.8, 0.5)
	else:
		card_style.bg_color = Color(0.2, 0.15, 0.2)
		card_style.border_color = Color(0.5, 0.4, 0.5)
	
	card_style.border_width_left = 3
	card_style.border_width_right = 3
	card_style.border_width_top = 3
	card_style.border_width_bottom = 3
	card.add_theme_stylebox_override("panel", card_style)
	
	# Day number
	var day_label = Label.new()
	day_label.text = "Day " + str(reward.day)
	day_label.position = Vector2(60, 10)
	day_label.add_theme_font_size_override("font_size", 24)
	day_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	card.add_child(day_label)
	
	# Icon
	var icon = Label.new()
	icon.text = reward.icon
	icon.position = Vector2(70, 50)
	icon.add_theme_font_size_override("font_size", 56)
	card.add_child(icon)
	
	# Reward text
	var reward_text = Label.new()
	if reward.type == "multiplier":
		reward_text.text = "x" + str(reward.amount) + "\n1 hour"
	elif reward.type == "all":
		reward_text.text = str(reward.amount) + "\nAll types!"
	elif reward.type == "grand":
		reward_text.text = "Skip to\n1M!"
	else:
		reward_text.text = "+" + str(reward.amount) + "\n" + reward.type
	
	reward_text.position = Vector2(40, 130)
	reward_text.add_theme_font_size_override("font_size", 22)
	reward_text.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	card.add_child(reward_text)
	
	# Claimed checkmark
	if is_claimed:
		var check = Label.new()
		check.text = "✓"
		check.position = Vector2(160, 10)
		check.add_theme_font_size_override("font_size", 32)
		check.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		card.add_child(check)
	
	return card

func _check_daily_reset():
	var current_day = int(Time.get_unix_time_from_system() / 86400)
	
	if current_day != last_claim_day:
		# New day! Check if streak continues
		if current_day == last_claim_day + 1:
			# Streak continues but hasn't claimed yet
			pass
		elif current_day > last_claim_day + 1:
			# Missed a day, reset streak
			daily_streak = 0
	
	last_claim_day = current_day

func _is_day_claimed(day_index: int) -> bool:
	var current_day = int(Time.get_unix_time_from_system() / 86400)
	return current_day == last_claim_day and (daily_streak % 7) > day_index

func _on_claim_pressed():
	var current_day = int(Time.get_unix_time_from_system() / 86400)
	
	# Check if already claimed today
	if current_day == last_claim_day and _is_day_claimed(daily_streak % 7):
		print("Already claimed today!")
		return
	
	# Claim reward
	var reward_index = daily_streak % 7
	var reward = daily_rewards[reward_index]
	
	_give_reward(reward)
	
	daily_streak += 1
	last_claim_day = current_day
	
	_save_daily_data()
	_update_ui()

func _give_reward(reward: Dictionary):
	match reward.type:
		"cogs":
			_add_to_save("user://savegame.dat", "total_cogs_earned", reward.amount)
			print("Claimed ", reward.amount, " cogs!")
		"ore":
			_add_to_save("user://mining_save.dat", "ore", reward.amount)
			print("Claimed ", reward.amount, " ore!")
		"gold":
			_add_to_save("user://airship_save.dat", "total_gold_earned", reward.amount)
			print("Claimed ", reward.amount, " gold!")
		"essence":
			_add_to_save("user://alchemy_save.dat", "essence", reward.amount)
			print("Claimed ", reward.amount, " essence!")
		"multiplier":
			# Activate temporary multiplier event
			print("Activated x2 multiplier for 1 hour!")
		"all":
			_add_to_save("user://savegame.dat", "total_cogs_earned", reward.amount)
			_add_to_save("user://mining_save.dat", "ore", reward.amount)
			_add_to_save("user://airship_save.dat", "total_gold_earned", reward.amount)
			_add_to_save("user://alchemy_save.dat", "essence", reward.amount)
			print("Claimed ", reward.amount, " of everything!")
		"grand":
			# Boost toward grand prestige
			_add_to_save("user://savegame.dat", "total_cogs_earned", 250000)
			_add_to_save("user://mining_save.dat", "ore", 250000)
			_add_to_save("user://airship_save.dat", "total_gold_earned", 250000)
			_add_to_save("user://alchemy_save.dat", "essence", 250000)
			print("Claimed GRAND REWARD - 1M total wealth!")

func _add_to_save(path: String, key: String, amount: float):
	var data = {}
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			data = file.get_var()
			file.close()
	
	data[key] = data.get(key, 0.0) + amount
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()

func _on_activate_event_pressed():
	# Activate random event
	var event = events[randi() % events.size()]
	current_event = event.duplicate()
	current_event["end_time"] = Time.get_unix_time_from_system() + event.duration
	
	_save_daily_data()
	_update_ui()
	
	print("Activated event: ", event.name)

func _update_ui():
	var streak_label = get_node_or_null("StreakLabel")
	if streak_label:
		streak_label.text = "Current Streak: " + str(daily_streak) + " days 🔥"
	
	var claim_btn = get_node_or_null("ClaimButton")
	if claim_btn:
		var current_day = int(Time.get_unix_time_from_system() / 86400)
		if current_day == last_claim_day and _is_day_claimed(daily_streak % 7):
			claim_btn.disabled = true
			claim_btn.text = "✓ CLAIMED TODAY"
		else:
			claim_btn.disabled = false
			claim_btn.text = "🎁 CLAIM DAILY REWARD 🎁"
	
	var event_info = get_node_or_null("Panel/EventInfo")
	if event_info:
		if current_event.is_empty():
			event_info.text = "No active event\n\nClick below to activate a random bonus event!"
		else:
			var time_left = current_event.end_time - Time.get_unix_time_from_system()
			var hours = int(time_left / 3600)
			var minutes = int((time_left % 3600) / 60)
			
			event_info.text = current_event.icon + " " + current_event.name + "\n\n"
			event_info.text += current_event.desc + "\n\n"
			event_info.text += "Time left: " + str(hours) + "h " + str(minutes) + "m"

func _save_daily_data():
	var save_data = {
		"streak": daily_streak,
		"last_claim": last_claim_day,
		"event": current_event
	}
	
	var file = FileAccess.open("user://daily_bonus.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func _load_daily_data():
	if FileAccess.file_exists("user://daily_bonus.dat"):
		var file = FileAccess.open("user://daily_bonus.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			
			daily_streak = data.get("streak", 0)
			last_claim_day = data.get("last_claim", 0)
			current_event = data.get("event", {})

func _on_back_pressed():
	_save_daily_data()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
