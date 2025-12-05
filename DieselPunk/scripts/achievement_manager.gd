extends Node

# Achievement System for Dieselpunk Roguelike

class_name AchievementManager

signal achievement_unlocked(achievement_name: String)

class Achievement:
	var id: String
	var name: String
	var description: String
	var unlocked: bool = false
	var icon_color: Color
	
	func _init(i: String, n: String, d: String, c: Color):
		id = i
		name = n
		description = d
		icon_color = c

var achievements = {}
var game

func _init():
	setup_achievements()

func setup_achievements():
	# Combat achievements
	achievements["first_blood"] = Achievement.new(
		"first_blood",
		"First Blood",
		"Defeat your first enemy",
		Color(0.8, 0.3, 0.3)
	)
	
	achievements["slayer"] = Achievement.new(
		"slayer",
		"Slayer",
		"Defeat 50 enemies",
		Color(0.9, 0.2, 0.2)
	)
	
	achievements["exterminator"] = Achievement.new(
		"exterminator",
		"Exterminator",
		"Defeat 100 enemies",
		Color(1.0, 0.1, 0.1)
	)
	
	# Exploration achievements
	achievements["explorer"] = Achievement.new(
		"explorer",
		"Explorer",
		"Reach floor 5",
		Color(0.3, 0.8, 0.3)
	)
	
	achievements["deep_diver"] = Achievement.new(
		"deep_diver",
		"Deep Diver",
		"Reach floor 10",
		Color(0.2, 0.9, 0.2)
	)
	
	achievements["abyss_walker"] = Achievement.new(
		"abyss_walker",
		"Abyss Walker",
		"Reach floor 20",
		Color(0.1, 1.0, 0.1)
	)
	
	# Progression achievements
	achievements["apprentice"] = Achievement.new(
		"apprentice",
		"Apprentice",
		"Reach level 5",
		Color(0.3, 0.3, 0.8)
	)
	
	achievements["journeyman"] = Achievement.new(
		"journeyman",
		"Journeyman",
		"Reach level 10",
		Color(0.2, 0.2, 0.9)
	)
	
	achievements["master"] = Achievement.new(
		"master",
		"Master",
		"Reach level 15",
		Color(0.1, 0.1, 1.0)
	)
	
	# Item achievements
	achievements["collector"] = Achievement.new(
		"collector",
		"Collector",
		"Find a Rare item",
		Color(0.3, 0.5, 1.0)
	)
	
	achievements["treasure_hunter"] = Achievement.new(
		"treasure_hunter",
		"Treasure Hunter",
		"Find a Legendary item",
		Color(1.0, 0.8, 0.2)
	)
	
	achievements["well_equipped"] = Achievement.new(
		"well_equipped",
		"Well Equipped",
		"Equip both weapon and armor",
		Color(0.7, 0.7, 0.7)
	)
	
	# Combat achievements
	achievements["untouchable"] = Achievement.new(
		"untouchable",
		"Untouchable",
		"Clear a floor without taking damage",
		Color(0.9, 0.9, 0.2)
	)
	
	achievements["boss_slayer"] = Achievement.new(
		"boss_slayer",
		"Boss Slayer",
		"Defeat an enemy on a boss floor",
		Color(0.8, 0.2, 0.8)
	)
	
	achievements["combo_master"] = Achievement.new(
		"combo_master",
		"Combo Master",
		"Achieve a 5x combo",
		Color(1.0, 0.5, 0.0)
	)
	
	# Survival achievements
	achievements["survivor"] = Achievement.new(
		"survivor",
		"Survivor",
		"Survive with less than 10% HP",
		Color(0.9, 0.1, 0.1)
	)
	
	achievements["hoarder"] = Achievement.new(
		"hoarder",
		"Hoarder",
		"Carry 10 consumables at once",
		Color(0.6, 0.9, 0.3)
	)

func check_achievement(achievement_id: String) -> bool:
	if achievements.has(achievement_id):
		var achievement = achievements[achievement_id]
		if not achievement.unlocked:
			achievement.unlocked = true
			emit_signal("achievement_unlocked", achievement.name)
			return true
	return false

func get_unlocked_count() -> int:
	var count = 0
	for achievement in achievements.values():
		if achievement.unlocked:
			count += 1
	return count

func get_total_count() -> int:
	return achievements.size()

func get_unlocked_achievements() -> Array:
	var unlocked = []
	for achievement in achievements.values():
		if achievement.unlocked:
			unlocked.append(achievement)
	return unlocked
