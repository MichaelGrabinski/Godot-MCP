extends Node

# Daily Challenge System - Procedurally generated challenges with leaderboards

class_name DailyChallenge

class Challenge:
	var seed: int
	var date: String
	var modifiers: Array = []
	var bonus_reward: int = 100
	
	func _init(s: int, d: String):
		seed = s
		date = d
		generate_modifiers()
	
	func generate_modifiers():
		var count = randi() % 3 + 2  # 2-4 modifiers
		var possible_modifiers = [
			{"name": "Double Enemy HP", "effect": "enemy_hp_2x"},
			{"name": "Half Player HP", "effect": "player_hp_half"},
			{"name": "Double Gold", "effect": "gold_2x"},
			{"name": "No Healing", "effect": "no_heal"},
			{"name": "Speed Run", "effect": "time_limit"},
			{"name": "Curse of Weakness", "effect": "half_damage"},
			{"name": "Blessing of Power", "effect": "double_damage"},
			{"name": "Random Items Only", "effect": "random_items"},
			{"name": "Boss Rush", "effect": "more_bosses"},
			{"name": "Elite Enemies", "effect": "all_elite"},
		]
		
		for i in range(count):
			var mod = possible_modifiers[randi() % possible_modifiers.size()]
			if not modifiers.has(mod):
				modifiers.append(mod)

class LeaderboardEntry:
	var player_name: String
	var score: int
	var floor_reached: int
	var kills: int
	var time: float
	var date: String
	
	func _init(name: String, s: int, floor: int, k: int, t: float, d: String):
		player_name = name
		score = s
		floor_reached = floor
		kills = k
		time = t
		date = d

static func get_today_challenge() -> Challenge:
	# Generate seed based on today's date
	var date_dict = Time.get_date_dict_from_system()
	var date_string = "%04d-%02d-%02d" % [date_dict.year, date_dict.month, date_dict.day]
	
	# Create deterministic seed from date
	var date_hash = date_string.hash()
	
	return Challenge.new(date_hash, date_string)

static func calculate_score(floor: int, kills: int, gold: int, time: float, deaths: int) -> int:
	var base_score = floor * 100
	var kill_score = kills * 10
	var gold_score = gold
	var time_bonus = int(10000.0 / max(time, 1.0))  # Faster = better
	var death_penalty = deaths * 500
	
	return max(0, base_score + kill_score + gold_score + time_bonus - death_penalty)

static func submit_score(challenge: Challenge, entry: LeaderboardEntry):
	# Save to local file (in a real game, this would upload to server)
	var leaderboard_file = "user://daily_" + challenge.date + ".save"
	var leaderboard = load_leaderboard(challenge.date)
	
	leaderboard.append(entry)
	
	# Sort by score
	leaderboard.sort_custom(func(a, b): return a.score > b.score)
	
	# Keep top 100
	if leaderboard.size() > 100:
		leaderboard = leaderboard.slice(0, 100)
	
	# Save
	var save_file = FileAccess.open(leaderboard_file, FileAccess.WRITE)
	if save_file:
		var save_data = []
		for e in leaderboard:
			save_data.append({
				"player_name": e.player_name,
				"score": e.score,
				"floor_reached": e.floor_reached,
				"kills": e.kills,
				"time": e.time,
				"date": e.date
			})
		save_file.store_var(save_data)
		save_file.close()

static func load_leaderboard(date: String) -> Array:
	var leaderboard = []
	var leaderboard_file = "user://daily_" + date + ".save"
	
	if FileAccess.file_exists(leaderboard_file):
		var save_file = FileAccess.open(leaderboard_file, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			
			for entry_data in save_data:
				var entry = LeaderboardEntry.new(
					entry_data.player_name,
					entry_data.score,
					entry_data.floor_reached,
					entry_data.kills,
					entry_data.time,
					entry_data.date
				)
				leaderboard.append(entry)
	
	return leaderboard

static func get_player_rank(challenge: Challenge, player_score: int) -> int:
	var leaderboard = load_leaderboard(challenge.date)
	
	var rank = 1
	for entry in leaderboard:
		if entry.score > player_score:
			rank += 1
		else:
			break
	
	return rank

static func has_completed_today(player_name: String) -> bool:
	var challenge = get_today_challenge()
	var leaderboard = load_leaderboard(challenge.date)
	
	for entry in leaderboard:
		if entry.player_name == player_name:
			return true
	
	return false
