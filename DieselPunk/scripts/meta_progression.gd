extends Node

# Meta Progression System - Persistent upgrades and unlockables

class_name MetaProgression

class PlayerClass:
	var name: String
	var description: String
	var starting_health: int
	var starting_attack: int
	var starting_defense: int
	var special_ability: String
	var unlocked: bool = false
	var unlock_requirement: String
	
	func _init(n: String, desc: String, hp: int, atk: int, def: int, ability: String, req: String):
		name = n
		description = desc
		starting_health = hp
		starting_attack = atk
		starting_defense = def
		special_ability = ability
		unlock_requirement = req

static func get_all_classes() -> Array:
	return [
		PlayerClass.new(
			"Engineer",
			"Balanced stats, reliable.",
			100,
			10,
			5,
			"Repair Bot: Heal 30 HP (7 turn cooldown)",
			"Default class"
		),
		PlayerClass.new(
			"Berserker",
			"High damage, low defense.",
			80,
			15,
			3,
			"Rage Mode: +10 ATK for 5 turns (10 turn cooldown)",
			"Reach floor 10"
		),
		PlayerClass.new(
			"Tank",
			"High HP and defense, low damage.",
			150,
			7,
			10,
			"Iron Wall: Block next attack completely (8 turn cooldown)",
			"Take 500 total damage in one run"
		),
		PlayerClass.new(
			"Assassin",
			"High crit chance, fragile.",
			70,
			12,
			2,
			"Shadow Step: Teleport and deal 2x damage (9 turn cooldown)",
			"Kill 100 enemies total"
		),
		PlayerClass.new(
			"Elemental",
			"Magic damage, elemental focus.",
			90,
			8,
			4,
			"Elemental Burst: Random element AoE (6 turn cooldown)",
			"Collect 5 different elemental weapons"
		),
		PlayerClass.new(
			"Mechanist",
			"Summons turrets.",
			85,
			9,
			6,
			"Deploy Turret: Summon fighting turret (12 turn cooldown)",
			"Reach floor 15"
		),
		PlayerClass.new(
			"Vampire",
			"Lifesteal focused.",
			95,
			11,
			4,
			"Blood Drain: Steal 50% enemy HP (10 turn cooldown)",
			"Heal 1000 HP total from lifesteal"
		),
		PlayerClass.new(
			"Alchemist",
			"Consumable specialist.",
			100,
			8,
			5,
			"Double Brew: Use 2 consumables at once (5 turn cooldown)",
			"Use 50 consumables total"
		),
	]

class MetaUpgrade:
	var name: String
	var description: String
	var cost: int
	var level: int = 0
	var max_level: int = 5
	var purchased: bool = false
	
	func _init(n: String, desc: String, c: int, max_lvl: int = 5):
		name = n
		description = desc
		cost = c
		max_level = max_lvl

static func get_all_meta_upgrades() -> Array:
	return [
		# Permanent stat boosts
		MetaUpgrade.new(
			"Health Boost",
			"+10 Starting HP per level",
			50
		),
		MetaUpgrade.new(
			"Attack Boost",
			"+2 Starting Attack per level",
			75
		),
		MetaUpgrade.new(
			"Defense Boost",
			"+1 Starting Defense per level",
			60
		),
		
		# Quality of life
		MetaUpgrade.new(
			"Better Loot",
			"+10% rare item find per level",
			100
		),
		MetaUpgrade.new(
			"More Gold",
			"+20% gold gain per level",
			80
		),
		MetaUpgrade.new(
			"Starting Gold",
			"Start with 50 gold per level",
			40
		),
		
		# Gameplay modifiers
		MetaUpgrade.new(
			"Extra Life",
			"Revive once per run",
			300,
			1
		),
		MetaUpgrade.new(
			"Treasure Hunter",
			"Reveal secret rooms",
			200,
			1
		),
		MetaUpgrade.new(
			"Lucky Charm",
			"+5% crit chance per level",
			120
		),
		
		# Starting items
		MetaUpgrade.new(
			"Starter Weapon",
			"Begin with uncommon weapon",
			150,
			1
		),
		MetaUpgrade.new(
			"Starter Armor",
			"Begin with uncommon armor",
			150,
			1
		),
		MetaUpgrade.new(
			"Starter Relic",
			"Begin with random relic",
			250,
			1
		),
	]

class PersistentStats:
	var total_runs: int = 0
	var total_kills: int = 0
	var total_damage_dealt: int = 0
	var total_damage_taken: int = 0
	var total_gold_earned: int = 0
	var total_consumables_used: int = 0
	var highest_floor: int = 0
	var total_deaths: int = 0
	var bosses_killed: int = 0
	
	# Current currency
	var meta_currency: int = 0  # Earned from runs
	
	# Unlocks
	var unlocked_classes: Array = ["Engineer"]  # Default class
	var purchased_upgrades: Dictionary = {}
	var discovered_relics: Array = []
	
	func add_meta_currency(amount: int):
		meta_currency += amount
	
	func can_afford(cost: int) -> bool:
		return meta_currency >= cost
	
	func spend_currency(cost: int) -> bool:
		if can_afford(cost):
			meta_currency -= cost
			return true
		return false

static func calculate_run_reward(floor_reached: int, kills: int, bosses: int) -> int:
	var base_reward = floor_reached * 10
	var kill_reward = kills * 2
	var boss_reward = bosses * 50
	
	return base_reward + kill_reward + boss_reward

static func save_persistent_stats(stats: PersistentStats):
	# Save to user:// directory
	var save_file = FileAccess.open("user://meta_progress.save", FileAccess.WRITE)
	if save_file:
		var save_data = {
			"total_runs": stats.total_runs,
			"total_kills": stats.total_kills,
			"total_damage_dealt": stats.total_damage_dealt,
			"total_damage_taken": stats.total_damage_taken,
			"total_gold_earned": stats.total_gold_earned,
			"total_consumables_used": stats.total_consumables_used,
			"highest_floor": stats.highest_floor,
			"total_deaths": stats.total_deaths,
			"bosses_killed": stats.bosses_killed,
			"meta_currency": stats.meta_currency,
			"unlocked_classes": stats.unlocked_classes,
			"purchased_upgrades": stats.purchased_upgrades,
			"discovered_relics": stats.discovered_relics
		}
		save_file.store_var(save_data)
		save_file.close()

static func load_persistent_stats() -> PersistentStats:
	var stats = PersistentStats.new()
	
	if FileAccess.file_exists("user://meta_progress.save"):
		var save_file = FileAccess.open("user://meta_progress.save", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			
			stats.total_runs = save_data.get("total_runs", 0)
			stats.total_kills = save_data.get("total_kills", 0)
			stats.total_damage_dealt = save_data.get("total_damage_dealt", 0)
			stats.total_damage_taken = save_data.get("total_damage_taken", 0)
			stats.total_gold_earned = save_data.get("total_gold_earned", 0)
			stats.total_consumables_used = save_data.get("total_consumables_used", 0)
			stats.highest_floor = save_data.get("highest_floor", 0)
			stats.total_deaths = save_data.get("total_deaths", 0)
			stats.bosses_killed = save_data.get("bosses_killed", 0)
			stats.meta_currency = save_data.get("meta_currency", 0)
			stats.unlocked_classes = save_data.get("unlocked_classes", ["Engineer"])
			stats.purchased_upgrades = save_data.get("purchased_upgrades", {})
			stats.discovered_relics = save_data.get("discovered_relics", [])
	
	return stats

static func check_class_unlocks(stats: PersistentStats) -> Array:
	var newly_unlocked = []
	var all_classes = get_all_classes()
	
	for player_class in all_classes:
		if player_class.name in stats.unlocked_classes:
			continue
		
		var unlocked = false
		
		# Check unlock requirements
		if "floor 10" in player_class.unlock_requirement and stats.highest_floor >= 10:
			unlocked = true
		elif "floor 15" in player_class.unlock_requirement and stats.highest_floor >= 15:
			unlocked = true
		elif "100 enemies" in player_class.unlock_requirement and stats.total_kills >= 100:
			unlocked = true
		elif "500 total damage" in player_class.unlock_requirement and stats.total_damage_taken >= 500:
			unlocked = true
		elif "50 consumables" in player_class.unlock_requirement and stats.total_consumables_used >= 50:
			unlocked = true
		elif "1000 HP" in player_class.unlock_requirement:
			# This would need to track lifesteal healing separately
			pass
		
		if unlocked:
			stats.unlocked_classes.append(player_class.name)
			newly_unlocked.append(player_class.name)
	
	return newly_unlocked
