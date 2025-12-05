extends Node

# NPC Encounter System - Friendly NPCs with quests, trades, and lore

class_name NPCSystem

enum NPCType {
	MERCHANT,
	QUEST_GIVER,
	LOREKEEPER,
	GAMBLER,
	BLACKSMITH,
	HEALER,
	MYSTERIOUS_STRANGER
}

class NPC:
	var name: String
	var type: NPCType
	var dialogue: Array  # Array of dialogue strings
	var quest: Object  # Quest object if quest giver
	var shop_inventory: Array  # For merchants
	var sprite_color: Color
	var encountered: bool = false
	
	func _init(n: String, t: NPCType, dlg: Array, color: Color):
		name = n
		type = t
		dialogue = dlg
		sprite_color = color

class Quest:
	var name: String
	var description: String
	var objective: String
	var objective_count: int
	var current_count: int = 0
	var reward_gold: int
	var reward_item: Object
	var completed: bool = false
	
	func _init(n: String, desc: String, obj: String, count: int, gold: int):
		name = n
		description = desc
		objective = obj
		objective_count = count
		reward_gold = gold

static func get_all_npcs() -> Array:
	return [
		# Merchants
		NPC.new(
			"Rusty Pete",
			NPCType.MERCHANT,
			[
				"Oi! Need some gear, traveler?",
				"I've got the good stuff!",
				"Best prices in the depths!"
			],
			Color(0.7, 0.5, 0.3)
		),
		
		# Quest Givers
		NPC.new(
			"Engineer Mara",
			NPCType.QUEST_GIVER,
			[
				"These depths are infested with malfunctioning bots...",
				"Could you help me collect some parts?",
				"I'll make it worth your while!"
			],
			Color(0.4, 0.6, 0.8)
		),
		
		# Lorekeepers
		NPC.new(
			"Old Cogsworth",
			NPCType.LOREKEEPER,
			[
				"Ah, a new face in the depths...",
				"Did you know this facility was once the pride of the empire?",
				"Now it's just rust and regret...",
				"The deeper you go, the stranger it gets.",
				"Some say there's an ancient machine at the very bottom."
			],
			Color(0.6, 0.6, 0.6)
		),
		
		# Gamblers
		NPC.new(
			"Lucky Jack",
			NPCType.GAMBLER,
			[
				"Feeling lucky, friend?",
				"Double or nothing!",
				"Bet your gold, win big!"
			],
			Color(0.9, 0.7, 0.2)
		),
		
		# Blacksmiths
		NPC.new(
			"Forge Master Hank",
			NPCType.BLACKSMITH,
			[
				"Got materials? I can craft you something special.",
				"Bring me the right parts, I'll make you unstoppable!",
				"Quality work ain't cheap, but it's worth it."
			],
			Color(0.8, 0.3, 0.2)
		),
		
		# Healers
		NPC.new(
			"Sister Mercy",
			NPCType.HEALER,
			[
				"You look hurt, child.",
				"Let me tend to your wounds.",
				"No charge for those who fight the darkness."
			],
			Color(0.9, 0.9, 1.0)
		),
		
		# Mysterious Strangers
		NPC.new(
			"The Traveler",
			NPCType.MYSTERIOUS_STRANGER,
			[
				"...",
				"I've been watching you.",
				"You're stronger than the others.",
				"Take this. You'll need it.",
				"We'll meet again... at the bottom."
			],
			Color(0.5, 0.2, 0.8)
		),
	]

static func get_random_npc() -> NPC:
	var all_npcs = get_all_npcs()
	return all_npcs[randi() % all_npcs.size()]

static func get_npc_by_type(type: NPCType) -> NPC:
	var all_npcs = get_all_npcs()
	for npc in all_npcs:
		if npc.type == type:
			return npc
	return all_npcs[0]

# Quest generation
static func generate_quest(floor: int) -> Quest:
	var quest_types = [
		{
			"name": "Extermination",
			"desc": "The bots have gone rogue. Eliminate them.",
			"obj": "kill_enemies",
			"count": 10 + floor * 2,
			"gold": 100 + floor * 20
		},
		{
			"name": "Salvage Operation",
			"desc": "I need rare components from the depths.",
			"obj": "collect_items",
			"count": 5,
			"gold": 150 + floor * 25
		},
		{
			"name": "Survival Test",
			"desc": "Reach deeper floors without dying.",
			"obj": "reach_floor",
			"count": floor + 5,
			"gold": 200 + floor * 30
		},
		{
			"name": "Boss Hunt",
			"desc": "A powerful machine guards the next sector.",
			"obj": "kill_boss",
			"count": 1,
			"gold": 300 + floor * 50
		},
	]
	
	var quest_data = quest_types[randi() % quest_types.size()]
	return Quest.new(
		quest_data.name,
		quest_data.desc,
		quest_data.obj,
		quest_data.count,
		quest_data.gold
	)

# Gambling mini-game
static func gamble_coin_flip(bet_amount: int, player_gold: int) -> Dictionary:
	if player_gold < bet_amount:
		return {"success": false, "result": "Not enough gold!", "gold_change": 0}
	
	var result = randi() % 2  # 0 or 1
	
	if result == 1:  # Win
		return {
			"success": true,
			"result": "You win! Doubled your gold!",
			"gold_change": bet_amount
		}
	else:  # Lose
		return {
			"success": false,
			"result": "You lose! Better luck next time.",
			"gold_change": -bet_amount
		}

static func gamble_high_low(bet_amount: int, player_gold: int) -> Dictionary:
	if player_gold < bet_amount:
		return {"success": false, "result": "Not enough gold!", "gold_change": 0}
	
	var roll = randi() % 100 + 1  # 1-100
	
	if roll >= 50:  # High wins
		var multiplier = 1.5 if roll >= 75 else 1.0
		var winnings = int(bet_amount * multiplier)
		return {
			"success": true,
			"result": "Rolled " + str(roll) + "! You win!",
			"gold_change": winnings
		}
	else:  # Low loses
		return {
			"success": false,
			"result": "Rolled " + str(roll) + "... You lose.",
			"gold_change": -bet_amount
		}

# Healing services
static func healer_service(player, free: bool = true) -> String:
	var cost = 0 if free else 50
	
	if not free and player.gold < cost:
		return "Not enough gold for healing!"
	
	var heal_amount = player.max_health - player.health
	player.health = player.max_health
	
	if not free:
		player.gold -= cost
	
	return "Healed for " + str(heal_amount) + " HP" + ("!" if free else " for " + str(cost) + " gold.")

# Lore revelation
static func get_lore_piece(floor: int) -> String:
	var lore_pieces = [
		"This facility was built during the Great Industrial War...",
		"The machines were designed to be workers, not warriors.",
		"Something went wrong in the lower levels...",
		"They say the Omega Engine lies at floor 50...",
		"The deeper you go, the more the machines... change.",
		"Some workers never came back up. Their echoes still wander.",
		"Floor 25 is where reality starts to break down...",
		"The facility runs on diesel, steam, and something else...",
		"The Brass Commander was once human, they say.",
		"There's a secret entrance to the core on floor " + str(floor + 10) + "...",
	]
	
	return lore_pieces[randi() % lore_pieces.size()]

# Mystery gift from stranger
static func mysterious_gift() -> Dictionary:
	var gifts = [
		{"type": "gold", "amount": 200, "message": "Gold falls from their cloak..."},
		{"type": "relic", "amount": 1, "message": "They hand you an ancient artifact..."},
		{"type": "heal", "amount": 999, "message": "They touch your shoulder. Full health!"},
		{"type": "buff", "amount": 5, "message": "You feel empowered... +5 to all stats!"},
		{"type": "weapon", "amount": 1, "message": "They give you a legendary weapon..."},
	]
	
	return gifts[randi() % gifts.size()]

# Check quest progress
static func update_quest_progress(quest: Quest, event_type: String, amount: int = 1) -> bool:
	if quest.completed:
		return false
	
	if quest.objective == event_type:
		quest.current_count += amount
		
		if quest.current_count >= quest.objective_count:
			quest.completed = true
			return true
	
	return false

static func get_quest_progress_text(quest: Quest) -> String:
	return quest.name + ": " + str(quest.current_count) + "/" + str(quest.objective_count)
