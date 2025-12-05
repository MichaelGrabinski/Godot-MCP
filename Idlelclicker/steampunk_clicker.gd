extends Node2D

# ==================== CONSTANTS ====================
const FONT_SIZE = 24
const FONT_NORMAL = 16
const FONT_LARGE = 32
const FONT_SMALL = 12
const AUTO_CLICK_INTERVAL: float = 1.0
const PRESTIGE_REQUIREMENT: float = 100000.0
const COMBO_TIMEOUT: float = 1.5
const FEVER_DURATION: float = 10.0
const FEVER_THRESHOLD: float = 50.0
const FEVER_MULTIPLIER: float = 5.0

# ==================== SCREEN SIZE ====================
var SCREEN_WIDTH: float
var SCREEN_HEIGHT: float
var FONT_TITLE: int
var FONT_LARGE_VAR: int
var FONT_MEDIUM: int
var FONT_SMALL_VAR: int
var BUTTON_HEIGHT: int

# ==================== GAME STATE ====================
var cogs: float = 0.0
var cogs_per_second: float = 0.0
var cogs_per_click: float = 1.0
var total_clicks: int = 0
var total_cogs_earned: float = 0.0
var playtime: float = 0.0
var golden_cogs: int = 0
var lifetime_golden_cogs: int = 0
var gems: int = 0

# Systems
var auto_click_level: int = 0
var auto_click_timer: float = 0.0
var tower_level: int = 0
var tower_construction_progress: float = 0.0
var cogs_needed_for_next_level: float = 100.0
var prestige_level: int = 0
var prestige_multiplier: float = 1.0
var combo_count: int = 0
var combo_timer: float = 0.0
var max_combo: int = 0
var fever_active: bool = false
var fever_timer: float = 0.0
var fever_progress: float = 0.0
var crit_chance: float = 0.05
var crit_multiplier: float = 3.0
var last_save_timestamp: int = 0

# Events
var steam_burst_active: bool = false
var steam_burst_timer: float = 0.0
var next_steam_burst: float = 60.0
var lucky_cog_active: bool = false
var lucky_cog_node: Button = null
var lucky_cog_timer: float = 0.0
var lucky_cogs_caught: int = 0
var golden_hour_active: bool = false
var golden_hour_timer: float = 0.0
var next_golden_hour: float = 300.0
var mega_cog_active: bool = false
var mega_cog_node: Panel = null
var mega_cog_hp: int = 0
var mega_cog_max_hp: int = 0
var mega_cogs_defeated: int = 0
var next_mega_cog: float = 120.0
var boss_active: bool = false
var boss_node: Panel = null
var boss_hp: float = 0
var boss_max_hp: float = 0
var boss_timer: float = 0.0
var boss_level: int = 0
var bosses_defeated: int = 0
var next_boss: float = 180.0
var cog_rain_active: bool = false
var cog_rain_timer: float = 0.0
var rain_cogs: Array = []
var next_cog_rain: float = 90.0

# Daily & Skins
var daily_bonus_claimed: bool = false
var last_daily_claim: int = 0
var daily_streak: int = 0
var current_skin: int = 0
var unlocked_skins: Array = [true, false, false, false, false, false, false, false]

var skin_data = [
	{"name": "Classic Gear", "icon": "⚙️", "color": Color(0.85, 0.6, 0.25), "cost": 0},
	{"name": "Golden Cog", "icon": "🌟", "color": Color(1, 0.84, 0), "cost": 5},
	{"name": "Crimson Engine", "icon": "🔴", "color": Color(0.9, 0.2, 0.2), "cost": 10},
	{"name": "Frozen Gear", "icon": "❄️", "color": Color(0.4, 0.8, 1), "cost": 10},
	{"name": "Nature Cog", "icon": "🌿", "color": Color(0.3, 0.8, 0.3), "cost": 15},
	{"name": "Void Core", "icon": "🟣", "color": Color(0.6, 0.2, 0.8), "cost": 20},
	{"name": "Rainbow Gear", "icon": "🌈", "color": Color(1, 0.5, 0.8), "cost": 30},
	{"name": "Diamond Cog", "icon": "💎", "color": Color(0.7, 0.9, 1), "cost": 50},
]

# Stats
var stats = {
	"total_taps": 0, "total_cogs_all_time": 0.0, "total_crits": 0,
	"total_fevers": 0, "highest_cps": 0.0, "fastest_boss_kill": 999.0,
	"rain_cogs_caught": 0, "mega_cogs_destroyed": 0, "time_in_fever": 0.0,
	"golden_cogs_spent": 0, "prestiges_total": 0,
}

# ==================== PERMANENT UPGRADES ====================
var permanent_upgrades = {
	"starting_cogs": {"level": 0, "max": 10, "cost": 1, "name": "💰 Head Start", "desc": "+100 start"},
	"crit_damage": {"level": 0, "max": 10, "cost": 2, "name": "💥 Crit Power", "desc": "+0.5x crit"},
	"offline_boost": {"level": 0, "max": 5, "cost": 3, "name": "😴 Sleep Worker", "desc": "+10% offline"},
	"fever_duration": {"level": 0, "max": 5, "cost": 2, "name": "🔥 Fever Extend", "desc": "+2s fever"},
	"lucky_chance": {"level": 0, "max": 5, "cost": 2, "name": "🍀 Lucky Charm", "desc": "More lucky"},
	"combo_time": {"level": 0, "max": 5, "cost": 1, "name": "⚡ Combo Time", "desc": "+0.3s combo"},
	"golden_touch": {"level": 0, "max": 3, "cost": 5, "name": "✨ Gold Touch", "desc": "+1🌟/prestige"},
	"boss_damage": {"level": 0, "max": 5, "cost": 3, "name": "⚔️ Boss Slayer", "desc": "+20% boss dmg"},
	"rain_magnet": {"level": 0, "max": 3, "cost": 4, "name": "🧲 Cog Magnet", "desc": "Bigger rain"},
}

# ==================== ACHIEVEMENTS ====================
var achievements = {
	"first_click": {"unlocked": false, "name": "First Steps", "reward": 10, "icon": "👆"},
	"hundred_clicks": {"unlocked": false, "name": "Tapper", "reward": 25, "icon": "✋"},
	"thousand_clicks": {"unlocked": false, "name": "Click Master", "reward": 100, "icon": "🖐️"},
	"ten_k_clicks": {"unlocked": false, "name": "Click Legend", "reward": 500, "icon": "👊"},
	"hundred_cogs": {"unlocked": false, "name": "Pocket Change", "reward": 25, "icon": "🪙"},
	"thousand_cogs": {"unlocked": false, "name": "Getting Started", "reward": 50, "icon": "💵"},
	"ten_k_cogs": {"unlocked": false, "name": "Industrialist", "reward": 100, "icon": "💰"},
	"hundred_k_cogs": {"unlocked": false, "name": "Tycoon", "reward": 250, "icon": "💎"},
	"millionaire": {"unlocked": false, "name": "Millionaire", "reward": 500, "icon": "🏆"},
	"billionaire": {"unlocked": false, "name": "Billionaire", "reward": 2000, "icon": "👑"},
	"first_upgrade": {"unlocked": false, "name": "Investor", "reward": 15, "icon": "📈"},
	"ten_upgrades": {"unlocked": false, "name": "Factory Owner", "reward": 75, "icon": "🏭"},
	"fifty_upgrades": {"unlocked": false, "name": "Baron", "reward": 300, "icon": "🏰"},
	"tower_5": {"unlocked": false, "name": "Builder", "reward": 50, "icon": "🧱"},
	"tower_10": {"unlocked": false, "name": "Sky Scraper", "reward": 100, "icon": "🏗️"},
	"tower_25": {"unlocked": false, "name": "Cloud Piercer", "reward": 300, "icon": "☁️"},
	"tower_50": {"unlocked": false, "name": "Space Elevator", "reward": 1000, "icon": "🚀"},
	"first_prestige": {"unlocked": false, "name": "Rebirth", "reward": 1000, "icon": "⭐"},
	"prestige_5": {"unlocked": false, "name": "Reborn", "reward": 2500, "icon": "🌟"},
	"prestige_10": {"unlocked": false, "name": "Eternal", "reward": 5000, "icon": "✨"},
	"combo_10": {"unlocked": false, "name": "Combo!", "reward": 50, "icon": "⚡"},
	"combo_25": {"unlocked": false, "name": "Combo Master", "reward": 150, "icon": "⚡"},
	"combo_50": {"unlocked": false, "name": "Combo King", "reward": 400, "icon": "👑"},
	"combo_100": {"unlocked": false, "name": "Combo God", "reward": 1000, "icon": "🔱"},
	"fever_first": {"unlocked": false, "name": "Fever Time!", "reward": 75, "icon": "🔥"},
	"fever_10": {"unlocked": false, "name": "Fever Addict", "reward": 300, "icon": "🔥"},
	"critical_hit": {"unlocked": false, "name": "Critical!", "reward": 25, "icon": "💥"},
	"crit_streak_3": {"unlocked": false, "name": "Lucky Strike", "reward": 200, "icon": "🎯"},
	"lucky_catch": {"unlocked": false, "name": "Lucky!", "reward": 100, "icon": "🍀"},
	"lucky_10": {"unlocked": false, "name": "Fortune Hunter", "reward": 500, "icon": "🌈"},
	"speed_demon": {"unlocked": false, "name": "Speed Demon", "reward": 150, "icon": "💨"},
	"night_owl": {"unlocked": false, "name": "Night Owl", "reward": 100, "icon": "🦉"},
	"early_bird": {"unlocked": false, "name": "Early Bird", "reward": 100, "icon": "🐦"},
	"dedicated": {"unlocked": false, "name": "Dedicated", "reward": 200, "icon": "⏰"},
	"first_boss": {"unlocked": false, "name": "Boss Slayer", "reward": 500, "icon": "⚔️"},
	"boss_10": {"unlocked": false, "name": "Boss Hunter", "reward": 2000, "icon": "🗡️"},
	"boss_speed": {"unlocked": false, "name": "Speed Kill", "reward": 1000, "icon": "⚡"},
	"mega_cog": {"unlocked": false, "name": "Mega Destroyer", "reward": 300, "icon": "💫"},
	"rain_catcher": {"unlocked": false, "name": "Rain Catcher", "reward": 400, "icon": "🌧️"},
	"skin_collector": {"unlocked": false, "name": "Fashionista", "reward": 1000, "icon": "👗"},
	"daily_7": {"unlocked": false, "name": "Weekly Player", "reward": 500, "icon": "📅"},
}

var fever_count: int = 0
var crit_streak: int = 0
var recent_clicks: Array = []

# ==================== UPGRADES ====================
var upgrades = [
	{"name": "Steam Pump", "base_cost": 10, "cost": 10, "cps": 0.1, "owned": 0, "icon": "⚗️", "special": "", "tier": 1},
	{"name": "Copper Boiler", "base_cost": 50, "cost": 50, "cps": 0.5, "owned": 0, "icon": "🔥", "special": "", "tier": 1},
	{"name": "Auto-Clicker", "base_cost": 100, "cost": 100, "cps": 0, "owned": 0, "icon": "🤖", "special": "auto_click", "tier": 2},
	{"name": "Gear Assembly", "base_cost": 150, "cost": 150, "cps": 2.0, "owned": 0, "icon": "⚙️", "special": "", "tier": 2},
	{"name": "Brass Automaton", "base_cost": 500, "cost": 500, "cps": 8.0, "owned": 0, "icon": "🦾", "special": "", "tier": 2},
	{"name": "Crit Enhancer", "base_cost": 750, "cost": 750, "cps": 0, "owned": 0, "icon": "💥", "special": "crit_chance", "tier": 2},
	{"name": "Coal Furnace", "base_cost": 1500, "cost": 1500, "cps": 25.0, "owned": 0, "icon": "🏭", "special": "", "tier": 3},
	{"name": "Click Power", "base_cost": 2000, "cost": 2000, "cps": 0, "owned": 0, "icon": "👆", "special": "click_power", "tier": 3},
	{"name": "Clockwork Factory", "base_cost": 5000, "cost": 5000, "cps": 100.0, "owned": 0, "icon": "🏗️", "special": "", "tier": 3},
	{"name": "Steam Engine", "base_cost": 15000, "cost": 15000, "cps": 400.0, "owned": 0, "icon": "🚂", "special": "", "tier": 4},
	{"name": "Aether Generator", "base_cost": 50000, "cost": 50000, "cps": 1500.0, "owned": 0, "icon": "⚡", "special": "", "tier": 4},
	{"name": "Quantum Forge", "base_cost": 150000, "cost": 150000, "cps": 5000.0, "owned": 0, "icon": "🌀", "special": "", "tier": 5},
]

# ==================== UI ====================
var cogs_label: Label
var cps_label: Label
var click_button: Button
var click_value_label: Label
var upgrades_scroll: ScrollContainer
var upgrades_vbox: VBoxContainer
var tower_visual: Node2D
var tower_level_label: Label
var tower_progress_bar: ProgressBar
var combo_label: Label
var fever_bar: ProgressBar
var fever_label: Label
var multiplier_label: Label
var prestige_button: Button
var menu_button: Button
var shop_button: Button
var skin_button: Button
var floating_numbers_node: Node2D
var achievement_popup: Panel
var golden_cog_label: Label
var event_label: Label
var particles_node: Node2D
var gems_label: Label

var save_timer: float = 0.0
var tower_blocks = []
var BLOCK_SIZE: int = 20
var pulse_time: float = 0.0
var steam_particles: Array = []
var rainbow_hue: float = 0.0

func _ready():
	_setup_screen_size()
	_load_game()
	_apply_permanent_upgrades()
	_calculate_offline_progress()
	_create_ui()
	_rebuild_pixel_tower()
	_update_ui()
	_check_time_achievements()
	_randomize_event_timers()
	_check_daily_bonus()

func _randomize_event_timers():
	next_steam_burst = randf_range(30.0, 90.0)
	next_golden_hour = randf_range(180.0, 420.0)
	next_mega_cog = randf_range(90.0, 180.0)
	next_boss = randf_range(150.0, 300.0)
	next_cog_rain = randf_range(60.0, 120.0)

func _setup_screen_size():
	var viewport_size = get_viewport().get_visible_rect().size
	SCREEN_WIDTH = viewport_size.x
	SCREEN_HEIGHT = viewport_size.y
	var scale = min(SCREEN_WIDTH, SCREEN_HEIGHT) / 1080.0
	FONT_TITLE = max(int(48 * scale), 28)
	FONT_LARGE_VAR = max(int(32 * scale), 20)
	FONT_MEDIUM = max(int(24 * scale), 16)
	FONT_SMALL_VAR = max(int(18 * scale), 14)
	BUTTON_HEIGHT = max(int(85 * scale), 60)
	BLOCK_SIZE = max(int(18 * scale), 12)

func _apply_permanent_upgrades():
	if permanent_upgrades.starting_cogs.level > 0 and total_cogs_earned == 0:
		cogs += permanent_upgrades.starting_cogs.level * 100
	crit_multiplier = 3.0 + permanent_upgrades.crit_damage.level * 0.5

func _check_time_achievements():
	var time = Time.get_datetime_dict_from_system()
	if time.hour == 0: _unlock_achievement("night_owl")
	if time.hour == 6: _unlock_achievement("early_bird")

func _create_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.045, 0.038, 0.032)
	bg.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	add_child(bg)
	
	particles_node = Node2D.new()
	particles_node.z_index = 5
	add_child(particles_node)
	
	floating_numbers_node = Node2D.new()
	floating_numbers_node.z_index = 100
	add_child(floating_numbers_node)
	
	_create_header()
	_create_tower_section()
	_create_click_section()
	_create_fever_section()
	_create_upgrades_section()
	_create_achievement_popup()
	_create_event_label()
	_start_ambient_particles()

func _create_header():
	var header_height = SCREEN_HEIGHT * 0.11
	var header = Panel.new()
	header.size = Vector2(SCREEN_WIDTH, header_height)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.07, 0.055)
	style.border_color = Color(0.6, 0.4, 0.2)
	style.border_width_bottom = 3
	header.add_theme_stylebox_override("panel", style)
	add_child(header)
	
	var btn_size = 46
	menu_button = _create_header_btn("☰", 6, btn_size, Color(0.3, 0.25, 0.2))
	menu_button.pressed.connect(_on_menu_pressed)
	header.add_child(menu_button)
	
	shop_button = _create_header_btn("🛒", 56, btn_size, Color(0.35, 0.3, 0.15))
	shop_button.pressed.connect(_on_shop_pressed)
	header.add_child(shop_button)
	
	skin_button = _create_header_btn("🎨", 106, btn_size, Color(0.3, 0.2, 0.35))
	skin_button.pressed.connect(_on_skin_pressed)
	header.add_child(skin_button)
	
	cogs_label = Label.new()
	cogs_label.text = "⚙️ 0"
	cogs_label.position = Vector2(160, 4)
	cogs_label.add_theme_font_size_override("font_size", FONT_TITLE - 6)
	cogs_label.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	header.add_child(cogs_label)
	
	cps_label = Label.new()
	cps_label.text = "0/sec"
	cps_label.position = Vector2(160, 6 + FONT_TITLE - 6)
	cps_label.add_theme_font_size_override("font_size", FONT_SMALL_VAR)
	cps_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
	header.add_child(cps_label)
	
	golden_cog_label = Label.new()
	golden_cog_label.text = "🌟 0"
	golden_cog_label.position = Vector2(SCREEN_WIDTH - 85, 4)
	golden_cog_label.add_theme_font_size_override("font_size", FONT_MEDIUM - 2)
	golden_cog_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	header.add_child(golden_cog_label)
	
	gems_label = Label.new()
	gems_label.text = "💎 0"
	gems_label.position = Vector2(SCREEN_WIDTH - 85, 24)
	gems_label.add_theme_font_size_override("font_size", FONT_SMALL_VAR)
	gems_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1))
	header.add_child(gems_label)
	
	prestige_button = Button.new()
	prestige_button.text = "⚡ Prestige"
	prestige_button.position = Vector2(SCREEN_WIDTH - 150, 48)
	prestige_button.custom_minimum_size = Vector2(135, 36)
	prestige_button.pressed.connect(_on_prestige_pressed)
	prestige_button.visible = false
	_style_button(prestige_button, Color(0.5, 0.4, 0.15))
	prestige_button.add_theme_font_size_override("font_size", FONT_SMALL_VAR)
	header.add_child(prestige_button)
	
	multiplier_label = Label.new()
	multiplier_label.position = Vector2(SCREEN_WIDTH * 0.38, 6 + FONT_TITLE - 6)
	multiplier_label.add_theme_font_size_override("font_size", FONT_SMALL_VAR)
	multiplier_label.add_theme_color_override("font_color", Color(0.9, 1, 0.9))
	header.add_child(multiplier_label)

func _create_header_btn(text: String, x: int, size: int, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = Vector2(x, 6)
	btn.custom_minimum_size = Vector2(size, size)
	_style_button(btn, color)
	btn.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	return btn

func _create_tower_section():
	var tower_y = SCREEN_HEIGHT * 0.11
	var tower_height = SCREEN_HEIGHT * 0.13
	
	var tower_panel = Panel.new()
	tower_panel.position = Vector2(6, tower_y + 3)
	tower_panel.size = Vector2(SCREEN_WIDTH - 12, tower_height)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.065, 0.052, 0.042)
	style.border_color = Color(0.5, 0.35, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	tower_panel.add_theme_stylebox_override("panel", style)
	add_child(tower_panel)
	
	tower_level_label = Label.new()
	tower_level_label.text = "🏗️ Tower: 0"
	tower_level_label.position = Vector2(10, 4)
	tower_level_label.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	tower_level_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	tower_panel.add_child(tower_level_label)
	
	tower_progress_bar = ProgressBar.new()
	tower_progress_bar.position = Vector2(10, 6 + FONT_LARGE_VAR - 4)
	tower_progress_bar.size = Vector2(SCREEN_WIDTH - 35, 16)
	tower_progress_bar.max_value = 100
	tower_progress_bar.show_percentage = false
	var prog_bg = StyleBoxFlat.new()
	prog_bg.bg_color = Color(0.15, 0.12, 0.1)
	prog_bg.set_corner_radius_all(4)
	tower_progress_bar.add_theme_stylebox_override("background", prog_bg)
	var prog_fill = StyleBoxFlat.new()
	prog_fill.bg_color = Color(0.7, 0.5, 0.2)
	prog_fill.set_corner_radius_all(4)
	tower_progress_bar.add_theme_stylebox_override("fill", prog_fill)
	tower_panel.add_child(tower_progress_bar)
	
	tower_visual = Node2D.new()
	tower_visual.position = Vector2(SCREEN_WIDTH / 2, tower_height - 4)
	tower_panel.add_child(tower_visual)
	
	combo_label = Label.new()
	combo_label.position = Vector2(SCREEN_WIDTH - 100, tower_height - 35)
	combo_label.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	combo_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	tower_panel.add_child(combo_label)

func _create_click_section():
	var click_y = SCREEN_HEIGHT * 0.26
	var button_size = min(SCREEN_WIDTH * 0.38, SCREEN_HEIGHT * 0.15)
	
	click_button = Button.new()
	click_button.text = skin_data[current_skin].icon + "\nTAP!"
	click_button.position = Vector2(SCREEN_WIDTH/2 - button_size/2, click_y)
	click_button.custom_minimum_size = Vector2(button_size, button_size)
	click_button.pressed.connect(_on_click_button_pressed)
	_apply_skin_to_button()
	add_child(click_button)
	
	click_value_label = Label.new()
	click_value_label.text = "+1/tap"
	click_value_label.position = Vector2(SCREEN_WIDTH/2 - 35, click_y + button_size + 4)
	click_value_label.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	click_value_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.55))
	add_child(click_value_label)

func _apply_skin_to_button():
	if not click_button: return
	var skin = skin_data[current_skin]
	var button_size = click_button.custom_minimum_size.x
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.14, 0.1)
	style.border_color = skin.color
	style.set_border_width_all(5)
	style.set_corner_radius_all(int(button_size / 2))
	click_button.add_theme_stylebox_override("normal", style)
	var pressed = style.duplicate()
	pressed.bg_color = Color(0.26, 0.2, 0.14)
	click_button.add_theme_stylebox_override("pressed", pressed)
	click_button.add_theme_stylebox_override("hover", style)
	click_button.text = skin.icon + "\nTAP!"
	click_button.add_theme_font_size_override("font_size", FONT_TITLE - 6)
	click_button.add_theme_color_override("font_color", Color(1, 0.9, 0.7))

func _create_fever_section():
	var fever_y = SCREEN_HEIGHT * 0.44
	fever_label = Label.new()
	fever_label.text = "🔥 FEVER"
	fever_label.position = Vector2(SCREEN_WIDTH/2 - 45, fever_y)
	fever_label.add_theme_font_size_override("font_size", FONT_MEDIUM - 3)
	fever_label.add_theme_color_override("font_color", Color(1, 0.5, 0))
	add_child(fever_label)
	
	fever_bar = ProgressBar.new()
	fever_bar.position = Vector2(30, fever_y + FONT_MEDIUM - 1)
	fever_bar.size = Vector2(SCREEN_WIDTH - 60, 20)
	fever_bar.max_value = FEVER_THRESHOLD
	fever_bar.show_percentage = false
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.2, 0.1, 0.05)
	bg.set_corner_radius_all(6)
	fever_bar.add_theme_stylebox_override("background", bg)
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color(1, 0.4, 0)
	fill.set_corner_radius_all(6)
	fever_bar.add_theme_stylebox_override("fill", fill)
	add_child(fever_bar)

func _create_upgrades_section():
	var upgrades_y = SCREEN_HEIGHT * 0.50
	var label = Label.new()
	label.text = "📦 UPGRADES"
	label.position = Vector2(12, upgrades_y)
	label.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	add_child(label)
	
	upgrades_scroll = ScrollContainer.new()
	upgrades_scroll.position = Vector2(6, upgrades_y + FONT_LARGE_VAR)
	upgrades_scroll.size = Vector2(SCREEN_WIDTH - 12, SCREEN_HEIGHT - upgrades_y - FONT_LARGE_VAR - 8)
	add_child(upgrades_scroll)
	
	upgrades_vbox = VBoxContainer.new()
	upgrades_vbox.add_theme_constant_override("separation", 6)
	upgrades_scroll.add_child(upgrades_vbox)
	_create_upgrade_buttons()

func _create_upgrade_buttons():
	for child in upgrades_vbox.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	var tier_colors = [Color(0.14, 0.11, 0.09), Color(0.11, 0.14, 0.1), Color(0.1, 0.11, 0.16), Color(0.16, 0.1, 0.14), Color(0.16, 0.14, 0.09)]
	var tier_borders = [Color(0.7, 0.5, 0.25), Color(0.5, 0.7, 0.35), Color(0.4, 0.5, 0.8), Color(0.7, 0.4, 0.65), Color(0.95, 0.85, 0.3)]
	
	for i in range(upgrades.size()):
		var u = upgrades[i]
		var btn = Button.new()
		btn.name = "Upgrade" + str(i)
		btn.custom_minimum_size = Vector2(SCREEN_WIDTH - 30, BUTTON_HEIGHT - 8)
		var cps_text = "+%.1f/s" % u.cps if u.cps > 0 else _get_special_desc(u.special)
		btn.text = "%s %s [%d]\n💰 %s  •  %s" % [u.icon, u.name, u.owned, _format_number(u.cost), cps_text]
		
		var tier_idx = min(u.tier - 1, 4)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = tier_colors[tier_idx]
		btn_style.border_color = tier_borders[tier_idx]
		btn_style.set_border_width_all(2)
		btn_style.set_corner_radius_all(8)
		btn_style.content_margin_left = 8
		btn_style.content_margin_top = 5
		btn.add_theme_stylebox_override("normal", btn_style)
		var hover = btn_style.duplicate()
		hover.bg_color = tier_colors[tier_idx].lightened(0.15)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)
		btn.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
		btn.add_theme_font_size_override("font_size", FONT_MEDIUM - 3)
		btn.pressed.connect(_on_upgrade_pressed.bind(i))
		upgrades_vbox.add_child(btn)

func _create_achievement_popup():
	achievement_popup = Panel.new()
	achievement_popup.size = Vector2(SCREEN_WIDTH - 40, 80)
	achievement_popup.position = Vector2(20, -90)
	achievement_popup.z_index = 200
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.055, 0.04, 0.95)
	style.border_color = Color(1, 0.84, 0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	achievement_popup.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.name = "Content"
	vbox.position = Vector2(10, 5)
	achievement_popup.add_child(vbox)
	
	var title = Label.new()
	title.name = "Title"
	title.text = "🏆 Achievement!"
	title.add_theme_font_size_override("font_size", FONT_MEDIUM - 3)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(title)
	
	var name_label = Label.new()
	name_label.name = "Name"
	name_label.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	name_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	vbox.add_child(name_label)
	add_child(achievement_popup)

func _create_event_label():
	event_label = Label.new()
	event_label.position = Vector2(12, SCREEN_HEIGHT * 0.24)
	event_label.add_theme_font_size_override("font_size", FONT_SMALL_VAR - 1)
	event_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
	event_label.z_index = 50
	add_child(event_label)

func _start_ambient_particles():
	for i in range(5):
		_spawn_ambient_particle()

func _spawn_ambient_particle():
	var p = Label.new()
	p.text = ["⚙️", "💨", "✨", "⭐"].pick_random()
	p.position = Vector2(randf_range(30, SCREEN_WIDTH - 30), SCREEN_HEIGHT + 20)
	p.add_theme_font_size_override("font_size", int(randf_range(12, 22)))
	p.modulate = Color(1, 1, 1, randf_range(0.1, 0.25))
	particles_node.add_child(p)
	steam_particles.append(p)
	var tween = create_tween()
	tween.tween_property(p, "position:y", -40, randf_range(12, 20))
	tween.parallel().tween_property(p, "position:x", p.position.x + randf_range(-50, 50), randf_range(12, 20))
	tween.tween_callback(func():
		steam_particles.erase(p)
		p.queue_free()
		_spawn_ambient_particle()
	)

func _style_button(btn: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = color.lightened(0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	btn.add_theme_font_size_override("font_size", FONT_MEDIUM)

func _get_special_desc(s: String) -> String:
	match s:
		"auto_click": return "🤖 Auto"
		"crit_chance": return "💥 +2% Crit"
		"click_power": return "👆 +1/tap"
	return ""

func _format_number(num: float) -> String:
	if num < 1000:
		return str(int(num))
	elif num < 1000000:
		return "%.1fK" % (num / 1000.0)
	elif num < 1000000000:
		return "%.2fM" % (num / 1000000.0)
	elif num < 1000000000000:
		return "%.2fB" % (num / 1000000000.0)
	else:
		return "%.2fT" % (num / 1000000000000.0)

func _create_floating_number(value: float, pos: Vector2, color: Color, custom_text: String = ""):
	if not floating_numbers_node: return
	var label = Label.new()
	if custom_text != "":
		label.text = custom_text
	else:
		label.text = "+" + _format_number(value)
	label.position = pos
	label.add_theme_font_size_override("font_size", FONT_MEDIUM)
	label.add_theme_color_override("font_color", color)
	label.z_index = 100
	floating_numbers_node.add_child(label)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", pos.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

func _update_ui():
	if cogs_label:
		cogs_label.text = "⚙️ " + _format_number(cogs)
	if cps_label:
		var effective_cps = cogs_per_second * _get_total_multiplier()
		cps_label.text = _format_number(effective_cps) + "/sec"
	if golden_cog_label:
		golden_cog_label.text = "🌟 " + str(golden_cogs)
	if gems_label:
		gems_label.text = "💎 " + str(gems)
	if click_value_label:
		click_value_label.text = "+" + _format_number(cogs_per_click * _get_total_multiplier()) + "/tap"
	if tower_level_label:
		tower_level_label.text = "🏗️ Tower: " + str(tower_level)
	if tower_progress_bar:
		tower_progress_bar.max_value = cogs_needed_for_next_level
		tower_progress_bar.value = tower_construction_progress
	if prestige_button:
		prestige_button.visible = total_cogs_earned >= PRESTIGE_REQUIREMENT * 0.5
	if multiplier_label:
		var mult = _get_total_multiplier()
		if mult > 1.01:
			multiplier_label.text = "x%.1f" % mult
		else:
			multiplier_label.text = ""
	if fever_bar:
		if fever_active:
			fever_bar.max_value = FEVER_DURATION + permanent_upgrades.fever_duration.level * 2.0
			fever_bar.value = fever_timer
		else:
			fever_bar.max_value = FEVER_THRESHOLD
			fever_bar.value = fever_progress
	_update_combo_display()
	_update_fever_display()

func _update_combo_display():
	if combo_label:
		if combo_count > 0:
			combo_label.text = "⚡ x" + str(combo_count)
			combo_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		else:
			combo_label.text = ""

func _update_fever_display():
	if fever_label:
		if fever_active:
			fever_label.text = "🔥 FEVER! 🔥"
			fever_label.add_theme_color_override("font_color", Color(1, 0.3, 0))
		else:
			fever_label.text = "🔥 FEVER"
			fever_label.add_theme_color_override("font_color", Color(1, 0.5, 0))

func _update_event_label():
	if not event_label: return
	var events = []
	if steam_burst_active: events.append("⚡ Steam Burst!")
	if golden_hour_active: events.append("✨ Golden Hour!")
	if fever_active: events.append("🔥 Fever!")
	if cog_rain_active: events.append("🌧️ Cog Rain!")
	event_label.text = " ".join(events)

func _update_upgrade_button(i: int):
	if not upgrades_vbox: return
	var btn = upgrades_vbox.get_node_or_null("Upgrade" + str(i))
	if btn and i < upgrades.size():
		var u = upgrades[i]
		var cps_text = "+%.1f/s" % u.cps if u.cps > 0 else _get_special_desc(u.special)
		btn.text = "%s %s [%d]\n💰 %s  •  %s" % [u.icon, u.name, u.owned, _format_number(u.cost), cps_text]

func _unlock_achievement(key: String):
	if not achievements.has(key): return
	if achievements[key].unlocked: return
	
	achievements[key].unlocked = true
	var ach = achievements[key]
	cogs += ach.reward
	total_cogs_earned += ach.reward
	
	if achievement_popup:
		var content = achievement_popup.get_node_or_null("Content")
		if content:
			var name_label = content.get_node_or_null("Name")
			if name_label:
				name_label.text = ach.icon + " " + ach.name + " +⚙️" + str(ach.reward)
		
		var tween = create_tween()
		tween.tween_property(achievement_popup, "position:y", 20, 0.3)
		tween.tween_interval(2.5)
		tween.tween_property(achievement_popup, "position:y", -90, 0.3)

func _check_achievements():
	if total_clicks >= 1: _unlock_achievement("first_click")
	if total_clicks >= 100: _unlock_achievement("hundred_clicks")
	if total_clicks >= 1000: _unlock_achievement("thousand_clicks")
	if total_clicks >= 10000: _unlock_achievement("ten_k_clicks")
	
	if total_cogs_earned >= 100: _unlock_achievement("hundred_cogs")
	if total_cogs_earned >= 1000: _unlock_achievement("thousand_cogs")
	if total_cogs_earned >= 10000: _unlock_achievement("ten_k_cogs")
	if total_cogs_earned >= 100000: _unlock_achievement("hundred_k_cogs")
	if total_cogs_earned >= 1000000: _unlock_achievement("millionaire")
	if total_cogs_earned >= 1000000000: _unlock_achievement("billionaire")
	
	var total_owned = 0
	for u in upgrades:
		total_owned += u.owned
	if total_owned >= 1: _unlock_achievement("first_upgrade")
	if total_owned >= 10: _unlock_achievement("ten_upgrades")
	if total_owned >= 50: _unlock_achievement("fifty_upgrades")
	
	if tower_level >= 5: _unlock_achievement("tower_5")
	if tower_level >= 10: _unlock_achievement("tower_10")
	if tower_level >= 25: _unlock_achievement("tower_25")
	if tower_level >= 50: _unlock_achievement("tower_50")
	
	if prestige_level >= 1: _unlock_achievement("first_prestige")
	if prestige_level >= 5: _unlock_achievement("prestige_5")
	if prestige_level >= 10: _unlock_achievement("prestige_10")
	
	if combo_count >= 10: _unlock_achievement("combo_10")
	if combo_count >= 25: _unlock_achievement("combo_25")
	if combo_count >= 50: _unlock_achievement("combo_50")
	if combo_count >= 100: _unlock_achievement("combo_100")
	
	if playtime >= 3600: _unlock_achievement("dedicated")

func _save_game():
	var save_data = {
		"cogs": cogs,
		"cogs_per_second": cogs_per_second,
		"cogs_per_click": cogs_per_click,
		"total_clicks": total_clicks,
		"total_cogs_earned": total_cogs_earned,
		"playtime": playtime,
		"golden_cogs": golden_cogs,
		"lifetime_golden_cogs": lifetime_golden_cogs,
		"gems": gems,
		"auto_click_level": auto_click_level,
		"tower_level": tower_level,
		"tower_construction_progress": tower_construction_progress,
		"cogs_needed_for_next_level": cogs_needed_for_next_level,
		"prestige_level": prestige_level,
		"prestige_multiplier": prestige_multiplier,
		"max_combo": max_combo,
		"crit_chance": crit_chance,
		"crit_multiplier": crit_multiplier,
		"boss_level": boss_level,
		"bosses_defeated": bosses_defeated,
		"mega_cogs_defeated": mega_cogs_defeated,
		"lucky_cogs_caught": lucky_cogs_caught,
		"fever_count": fever_count,
		"daily_bonus_claimed": daily_bonus_claimed,
		"last_daily_claim": last_daily_claim,
		"daily_streak": daily_streak,
		"current_skin": current_skin,
		"unlocked_skins": unlocked_skins,
		"stats": stats,
		"last_save_timestamp": int(Time.get_unix_time_from_system()),
	}
	
	var upgrades_save = []
	for u in upgrades:
		upgrades_save.append({"owned": u.owned, "cost": u.cost})
	save_data["upgrades"] = upgrades_save
	
	var achievements_save = {}
	for key in achievements:
		achievements_save[key] = achievements[key].unlocked
	save_data["achievements"] = achievements_save
	
	var perm_save = {}
	for key in permanent_upgrades:
		perm_save[key] = permanent_upgrades[key].level
	save_data["permanent_upgrades"] = perm_save
	
	var file = FileAccess.open("user://steampunk_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _load_game():
	if not FileAccess.file_exists("user://steampunk_save.json"):
		return
	
	var file = FileAccess.open("user://steampunk_save.json", FileAccess.READ)
	if not file:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return
	
	var save_data = json.get_data()
	
	cogs = save_data.get("cogs", 0.0)
	cogs_per_second = save_data.get("cogs_per_second", 0.0)
	cogs_per_click = save_data.get("cogs_per_click", 1.0)
	total_clicks = save_data.get("total_clicks", 0)
	total_cogs_earned = save_data.get("total_cogs_earned", 0.0)
	playtime = save_data.get("playtime", 0.0)
	golden_cogs = save_data.get("golden_cogs", 0)
	lifetime_golden_cogs = save_data.get("lifetime_golden_cogs", 0)
	gems = save_data.get("gems", 0)
	auto_click_level = save_data.get("auto_click_level", 0)
	tower_level = save_data.get("tower_level", 0)
	tower_construction_progress = save_data.get("tower_construction_progress", 0.0)
	cogs_needed_for_next_level = save_data.get("cogs_needed_for_next_level", 100.0)
	prestige_level = save_data.get("prestige_level", 0)
	prestige_multiplier = save_data.get("prestige_multiplier", 1.0)
	max_combo = save_data.get("max_combo", 0)
	crit_chance = save_data.get("crit_chance", 0.05)
	crit_multiplier = save_data.get("crit_multiplier", 3.0)
	boss_level = save_data.get("boss_level", 0)
	bosses_defeated = save_data.get("bosses_defeated", 0)
	mega_cogs_defeated = save_data.get("mega_cogs_defeated", 0)
	lucky_cogs_caught = save_data.get("lucky_cogs_caught", 0)
	fever_count = save_data.get("fever_count", 0)
	daily_bonus_claimed = save_data.get("daily_bonus_claimed", false)
	last_daily_claim = save_data.get("last_daily_claim", 0)
	daily_streak = save_data.get("daily_streak", 0)
	current_skin = save_data.get("current_skin", 0)
	last_save_timestamp = save_data.get("last_save_timestamp", 0)
	
	var loaded_skins = save_data.get("unlocked_skins", [true, false, false, false, false, false, false, false])
	for i in range(min(loaded_skins.size(), unlocked_skins.size())):
		unlocked_skins[i] = loaded_skins[i]
	
	var loaded_stats = save_data.get("stats", {})
	for key in loaded_stats:
		if stats.has(key):
			stats[key] = loaded_stats[key]
	
	var upgrades_save = save_data.get("upgrades", [])
	for i in range(min(upgrades_save.size(), upgrades.size())):
		upgrades[i].owned = upgrades_save[i].get("owned", 0)
		upgrades[i].cost = upgrades_save[i].get("cost", upgrades[i].base_cost)
	
	var achievements_save = save_data.get("achievements", {})
	for key in achievements_save:
		if achievements.has(key):
			achievements[key].unlocked = achievements_save[key]
	
	var perm_save = save_data.get("permanent_upgrades", {})
	for key in perm_save:
		if permanent_upgrades.has(key):
			permanent_upgrades[key].level = perm_save[key]

func _calculate_offline_progress():
	if last_save_timestamp == 0:
		return
	
	var current_time = int(Time.get_unix_time_from_system())
	var offline_seconds = current_time - last_save_timestamp
	
	offline_seconds = min(offline_seconds, 86400)
	
	if offline_seconds < 60:
		return
	
	var offline_multiplier = 0.1 + permanent_upgrades.offline_boost.level * 0.1
	var offline_earnings = cogs_per_second * offline_seconds * offline_multiplier
	
	if offline_earnings > 0:
		cogs += offline_earnings
		total_cogs_earned += offline_earnings
		call_deferred("_show_offline_popup", offline_seconds, offline_earnings)

func _show_offline_popup(seconds: float, earnings: float):
	await get_tree().create_timer(0.8).timeout
	
	var hours = int(seconds / 3600)
	var minutes = int((int(seconds) % 3600) / 60)
	var time_str = ""
	if hours > 0:
		time_str = str(hours) + "h " + str(minutes) + "m"
	else:
		time_str = str(minutes) + "m"
	
	_create_floating_number(earnings, Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.35), Color(0.5, 0.8, 1), "😴 Offline: +" + _format_number(earnings))

func _check_daily_bonus():
	var current_day = int(Time.get_unix_time_from_system() / 86400)
	if last_daily_claim < current_day:
		if last_daily_claim == current_day - 1:
			daily_streak += 1
		else:
			daily_streak = 1
		# Daily bonus could trigger UI here


	
func _setup_music():
	# Create background music player
	var music = AudioStreamPlayer.new()
	music.name = "MusicPlayer"
	add_child(music)
		
		# Try to load music file if it exists
	if ResourceLoader.exists("res://audio/game_music.ogg"):
		music.stream = load("res://audio/game_music.ogg")
		music.autoplay = true
		music.volume_db = -10
	elif ResourceLoader.exists("res://audio/music.mp3"):
		music.stream = load("res://audio/music.mp3")
		music.autoplay = true
		music.volume_db = -10
	
func _play_sound_effect(sound_name: String):
		# Play sound effects for game events
	var sfx_path = "res://audio/sfx/" + sound_name + ".wav"
	if ResourceLoader.exists(sfx_path):
		var sfx = AudioStreamPlayer.new()
		sfx.stream = load(sfx_path)
		sfx.volume_db = -5
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
	
func _show_daily_rewards_popup():
	await get_tree().create_timer(1.2).timeout
		
	var overlay = ColorRect.new()
	overlay.name = "DailyOverlay"
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	overlay.z_index = 300
	add_child(overlay)
		
	var popup = Panel.new()
	popup.position = Vector2(SCREEN_WIDTH * 0.1, SCREEN_HEIGHT * 0.25)
	popup.size = Vector2(SCREEN_WIDTH * 0.8, SCREEN_HEIGHT * 0.5)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.10, 0.08)
	style.border_color = Color(1, 0.84, 0)
	style.set_border_width_all(4)
	style.set_corner_radius_all(15)
	popup.add_theme_stylebox_override("panel", style)
	overlay.add_child(popup)

	var title = Label.new()
	title.text = "🎁 DAILY BONUS! 🎁"
	title.position = Vector2(popup.size.x / 2 - 110, 20)
	title.add_theme_font_size_override("font_size", FONT_LARGE_VAR)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	popup.add_child(title)
	
	var streak_label = Label.new()
	streak_label.text = "🔥 Day " + str(daily_streak) + " Streak!"
	streak_label.position = Vector2(popup.size.x / 2 - 80, 70)
	streak_label.add_theme_font_size_override("font_size", FONT_MEDIUM)
	streak_label.add_theme_color_override("font_color", Color(1, 0.6, 0.3))
	popup.add_child(streak_label)
	
	var cog_bonus = 100 * daily_streak * (1 + prestige_level * 0.2)
	var golden_bonus = min(daily_streak, 7)
	var gem_bonus = 1 if daily_streak >= 7 else 0
	
	var rewards_text = "⚙️ " + _format_number(cog_bonus) + "  🌟 " + str(golden_bonus)
	if gem_bonus > 0:
		rewards_text += "  💎 " + str(gem_bonus)
		
	var rewards = Label.new()
	rewards.text = rewards_text
	rewards.position = Vector2(popup.size.x / 2 - 100, 120)
	rewards.add_theme_font_size_override("font_size", FONT_LARGE_VAR)
	rewards.add_theme_color_override("font_color", Color(0.95, 0.95, 0.85))
	popup.add_child(rewards)
		
	var claim_btn = Button.new()
	claim_btn.text = "✨ CLAIM! ✨"
	claim_btn.position = Vector2(popup.size.x / 2 - 80, popup.size.y - 80)
	claim_btn.custom_minimum_size = Vector2(160, 50)
	_style_button(claim_btn, Color(0.4, 0.5, 0.2))
	claim_btn.add_theme_font_size_override("font_size", FONT_LARGE_VAR - 4)
	claim_btn.pressed.connect(func():
		cogs += cog_bonus
		total_cogs_earned += cog_bonus
		golden_cogs += golden_bonus
		gems += gem_bonus
		last_daily_claim = int(Time.get_unix_time_from_system() / 86400)
		daily_bonus_claimed = true
		_save_game()
		overlay.queue_free()
		_create_floating_number(cog_bonus, Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.3), Color(1, 0.84, 0), "🎁 +" + _format_number(cog_bonus))
	)
	popup.add_child(claim_btn)
	
func _process(delta):
	playtime += delta
	pulse_time += delta
	rainbow_hue = fmod(rainbow_hue + delta * 0.1, 1.0)
	
	var current_cps = cogs_per_second * _get_total_multiplier()
	if current_cps > stats.highest_cps: stats.highest_cps = current_cps
	if fever_active: stats.time_in_fever += delta
	
	var combo_window = COMBO_TIMEOUT + permanent_upgrades.combo_time.level * 0.3
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			if combo_count > max_combo: max_combo = combo_count
			combo_count = 0
			_update_combo_display()
	
	if fever_active:
		fever_timer -= delta
		if fever_timer <= 0:
			fever_active = false
			fever_progress = 0
			_update_fever_display()
	
	if auto_click_level > 0:
		auto_click_timer += delta
		if auto_click_timer >= AUTO_CLICK_INTERVAL:
			auto_click_timer = 0.0
			for i in range(auto_click_level):
				_perform_click(false, true)
	
	var mult = _get_total_multiplier()
	var gained = cogs_per_second * delta * mult
	cogs += gained
	total_cogs_earned += gained
	stats.total_cogs_all_time += gained
	
	tower_construction_progress += gained
	while tower_construction_progress >= cogs_needed_for_next_level:
		_level_up_tower()
	
	save_timer += delta
	if save_timer >= 5.0:
		save_timer = 0.0
		_save_game()
	
	_check_achievements()
	_animate_tower(delta)
	_animate_click_button(delta)
	_update_ui()
	_update_event_label()

func _get_total_multiplier() -> float:
	var mult = prestige_multiplier
	if combo_count > 0: mult *= 1.0 + log(combo_count + 1) * 0.2
	if fever_active: mult *= FEVER_MULTIPLIER
	if steam_burst_active: mult *= 3.0
	if golden_hour_active: mult *= 2.0
	return mult

func _on_click_button_pressed():
	_perform_click(true, false)
	recent_clicks.append(Time.get_ticks_msec() / 1000.0)
	if recent_clicks.size() >= 10: _unlock_achievement("speed_demon")

func _perform_click(animate: bool, is_auto: bool = false):
	var base_value = cogs_per_click * _get_total_multiplier()
	var click_value = base_value
	var was_crit = false
	
	if randf() < crit_chance:
		click_value *= crit_multiplier
		was_crit = true
		crit_streak += 1
		stats.total_crits += 1
		if crit_streak >= 3: _unlock_achievement("crit_streak_3")
		if not achievements.critical_hit.unlocked: _unlock_achievement("critical_hit")
	else:
		crit_streak = 0
	
	cogs += click_value
	total_cogs_earned += click_value
	stats.total_cogs_all_time += click_value
	total_clicks += 1
	stats.total_taps += 1
	tower_construction_progress += click_value
	
	if not is_auto:
		combo_count += 1
		combo_timer = COMBO_TIMEOUT + permanent_upgrades.combo_time.level * 0.3
		if not fever_active:
			fever_progress += 1
			if fever_progress >= FEVER_THRESHOLD: _trigger_fever()
		_update_combo_display()
	
	if animate and click_button:
		var tween = create_tween()
		tween.tween_property(click_button, "scale", Vector2(0.9, 0.9), 0.05)
		tween.tween_property(click_button, "scale", Vector2(1.0, 1.0), 0.1)
		
		var color = Color(1, 0.9, 0.5)
		var text = ""
		if was_crit:
			color = Color(1, 0.2, 0.2)
			text = "💥 CRIT! +" + _format_number(click_value)
			_spawn_particles(4)
		elif fever_active:
			color = Color(1, 0.5, 0)
			_spawn_particles(2)
		
		_create_floating_number(click_value, Vector2(SCREEN_WIDTH/2 + randf_range(-40, 40), SCREEN_HEIGHT * 0.25), color, text)

func _spawn_particles(count: int):
	for i in range(count):
		var p = Label.new()
		p.text = ["⚡", "✨", "💫", "⭐"].pick_random()
		p.position = Vector2(SCREEN_WIDTH/2 + randf_range(-20, 20), SCREEN_HEIGHT * 0.33)
		p.add_theme_font_size_override("font_size", int(randf_range(14, 24)))
		p.modulate.a = 0.9
		p.z_index = 90
		floating_numbers_node.add_child(p)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(p, "position", p.position + Vector2(randf_range(-60, 60), randf_range(-90, -40)), 0.5)
		tween.tween_property(p, "modulate:a", 0.0, 0.5)
		tween.chain().tween_callback(p.queue_free)

func _trigger_fever():
	fever_active = true
	fever_timer = FEVER_DURATION + permanent_upgrades.fever_duration.level * 2.0
	fever_progress = 0
	fever_count += 1
	stats.total_fevers += 1
	_create_floating_number(0, Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.22), Color(1, 0.5, 0), "🔥 FEVER! 5x 🔥")
	_screen_shake(4, 0.15)
	if not achievements.fever_first.unlocked: _unlock_achievement("fever_first")
	if fever_count >= 10: _unlock_achievement("fever_10")
	_update_fever_display()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_shop_pressed():
	pass

func _on_skin_pressed():
	pass

func _on_prestige_pressed():
	if total_cogs_earned < PRESTIGE_REQUIREMENT:
		return
	
	var points = floor(log(total_cogs_earned / PRESTIGE_REQUIREMENT + 1) / log(2)) + 1
	golden_cogs += points + permanent_upgrades.golden_touch.level
	lifetime_golden_cogs += points + permanent_upgrades.golden_touch.level
	prestige_level += 1
	prestige_multiplier = 1.0 + prestige_level * 0.25
	stats.prestiges_total += 1
	
	cogs = 0
	cogs_per_second = 0
	cogs_per_click = 1.0
	total_clicks = 0
	total_cogs_earned = 0
	combo_count = 0
	max_combo = 0
	fever_progress = 0
	tower_level = 0
	tower_construction_progress = 0
	cogs_needed_for_next_level = 100
	
	for u in upgrades:
		u.owned = 0
		u.cost = u.base_cost
	
	_save_game()
	get_tree().reload_current_scene()

func _on_upgrade_pressed(upgrade_index: int):
	if upgrade_index >= upgrades.size():
		return
	
	var upgrade = upgrades[upgrade_index]
	if cogs >= upgrade.cost:
		cogs -= upgrade.cost
		upgrade.owned += 1
		
		if upgrade.cps > 0:
			cogs_per_second += upgrade.cps
		
		match upgrade.special:
			"auto_click":
				auto_click_level += 1
			"crit_chance":
				crit_chance += 0.02
			"click_power":
				cogs_per_click += 1.0
		
		upgrade.cost = ceil(upgrade.base_cost * pow(1.15, upgrade.owned))
		
		_update_upgrade_button(upgrade_index)
		_save_game()

func _rebuild_pixel_tower():
	if not tower_visual:
		return
	
	for block in tower_blocks:
		if is_instance_valid(block):
			block.queue_free()
	tower_blocks.clear()
	
	var blocks_to_show = min(tower_level, 25)
	for i in range(blocks_to_show):
		var block = ColorRect.new()
		block.size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
		block.position = Vector2(-BLOCK_SIZE/2 + (i % 3 - 1) * BLOCK_SIZE, -i * BLOCK_SIZE)
		
		var hue = float(i) / max(blocks_to_show, 1)
		block.color = Color.from_hsv(hue * 0.15 + 0.05, 0.5, 0.7)
		
		tower_visual.add_child(block)
		tower_blocks.append(block)

func _level_up_tower():
	tower_construction_progress -= cogs_needed_for_next_level
	tower_level += 1
	cogs_needed_for_next_level = ceil(cogs_needed_for_next_level * 1.5)
	
	_rebuild_pixel_tower()
	_screen_shake(4, 0.15)
	_create_floating_number(0, Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT * 0.22), Color(0.7, 0.9, 0.5), "🏗️ Tower Level " + str(tower_level) + "!")
	_check_achievements()

func _animate_tower(delta: float):
	if not tower_visual or tower_blocks.is_empty():
		return
	
	var bob_offset = sin(pulse_time * 2.0) * 2.0
	tower_visual.position.y = SCREEN_HEIGHT * 0.11 + SCREEN_HEIGHT * 0.13 - 4 + bob_offset

func _animate_click_button(delta: float):
	if not click_button:
		return
	
	if fever_active:
		var scale_mod = 1.0 + sin(pulse_time * 8.0) * 0.05
		click_button.scale = Vector2(scale_mod, scale_mod)
	else:
		click_button.scale = Vector2(1.0, 1.0)

func _screen_shake(intensity: float, duration: float = 0.2):
	var original_pos = position
	var shake_tween = create_tween()
	
	for i in range(int(duration * 30)):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property(self, "position", original_pos + offset, duration / 30.0)
	
	shake_tween.tween_property(self, "position", original_pos, 0.05)
