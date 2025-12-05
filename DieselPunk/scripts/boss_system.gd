extends Node

# Boss System - Unique powerful enemies with special mechanics

class_name BossSystem

class Boss:
	var name: String
	var health: int
	var attack: int
	var defense: int
	var special_ability: String
	var ability_cooldown: int
	var phase: int = 1  # Bosses can have multiple phases
	var sprite_color: Color
	var xp_value: int
	
	func _init(n: String, hp: int, atk: int, def: int, ability: String, cd: int, color: Color, xp: int):
		name = n
		health = hp
		attack = atk
		defense = def
		special_ability = ability
		ability_cooldown = cd
		sprite_color = color
		xp_value = xp

static func get_boss_for_floor(floor: int) -> Boss:
	var boss_tier = floor / 5
	
	match boss_tier:
		1:  # Floor 5
			return Boss.new(
				"The Iron Foreman",
				150,
				12,
				8,
				"Summon Workers",
				5,
				Color(0.4, 0.4, 0.4),
				200
			)
		2:  # Floor 10
			return Boss.new(
				"Furnace Colossus",
				300,
				18,
				12,
				"Molten Wave",
				4,
				Color(1.0, 0.3, 0.0),
				400
			)
		3:  # Floor 15
			return Boss.new(
				"Electric Overlord",
				450,
				25,
				15,
				"Chain Lightning Storm",
				6,
				Color(0.3, 0.5, 1.0),
				600
			)
		4:  # Floor 20
			return Boss.new(
				"Clockwork Tyrant",
				600,
				32,
				18,
				"Time Freeze",
				7,
				Color(0.8, 0.6, 0.2),
				800
			)
		_:  # Floor 25+
			var scaled_health = 600 + (boss_tier - 4) * 200
			var scaled_attack = 32 + (boss_tier - 4) * 8
			var scaled_defense = 18 + (boss_tier - 4) * 3
			var scaled_xp = 800 + (boss_tier - 4) * 200
			
			return Boss.new(
				"Diesel Demon Lord",
				scaled_health,
				scaled_attack,
				scaled_defense,
				"Apocalypse Engine",
				8,
				Color(0.7, 0.1, 0.9),
				scaled_xp
			)

static func execute_boss_ability(boss: Boss, game) -> String:
	match boss.special_ability:
		"Summon Workers":
			# Spawn 2-3 weak enemies
			var count = randi() % 2 + 2
			return boss.name + " summons " + str(count) + " workers!"
		
		"Molten Wave":
			# AoE damage
			var damage = 25
			game.player.take_damage(damage)
			return boss.name + " unleashes a molten wave for " + str(damage) + " damage!"
		
		"Chain Lightning Storm":
			# Multi-hit attack
			var hits = 3
			var damage = 15
			for i in range(hits):
				game.player.take_damage(damage)
			return boss.name + " strikes with " + str(hits) + " lightning bolts!"
		
		"Time Freeze":
			# Skip player's next turn
			return boss.name + " freezes time! You lose your next turn!"
		
		"Apocalypse Engine":
			# Massive damage + summons
			var damage = 40
			game.player.take_damage(damage)
			return boss.name + " activates the Apocalypse Engine! " + str(damage) + " damage!"
		
		_:
			return boss.name + " uses " + boss.special_ability + "!"

static func should_enter_phase_2(boss: Boss, current_health: int) -> bool:
	# Enter phase 2 at 50% health
	return boss.phase == 1 and current_health <= boss.health / 2

static func enter_phase_2(boss: Boss) -> String:
	boss.phase = 2
	boss.attack = int(boss.attack * 1.3)
	boss.ability_cooldown = max(3, boss.ability_cooldown - 1)
	
	return "[color=red]" + boss.name + " enters ENRAGED mode! Attack and speed increased![/color]"
