extends Node

# Companion/Pet System - Fighting buddies that assist you

class_name CompanionSystem

enum CompanionType {
	REPAIR_DRONE,
	ATTACK_BOT,
	SHIELD_DRONE,
	SCAVENGER_BOT,
	ELECTRIC_WISP,
	FIRE_SPRITE,
	ICE_GUARDIAN,
	HEALING_FAIRY
}

class Companion:
	var name: String
	var type: CompanionType
	var health: int
	var max_health: int
	var attack: int
	var special_ability: String
	var cooldown: int = 0
	var sprite_color: Color
	var rarity: int
	
	func _init(n: String, t: CompanionType, hp: int, atk: int, ability: String, color: Color, rar: int):
		name = n
		type = t
		max_health = hp
		health = hp
		attack = atk
		special_ability = ability
		sprite_color = color
		rarity = rar

static func get_all_companions() -> Array:
	return [
		# Common Companions
		Companion.new(
			"Rusty",
			CompanionType.REPAIR_DRONE,
			30,
			3,
			"Repair: Heal player 10 HP (every 5 turns)",
			Color(0.6, 0.4, 0.2),
			0
		),
		Companion.new(
			"Scrapper",
			CompanionType.SCAVENGER_BOT,
			25,
			2,
			"Scavenge: Find extra gold from enemies",
			Color(0.7, 0.7, 0.5),
			0
		),
		
		# Uncommon Companions
		Companion.new(
			"Bolt",
			CompanionType.ATTACK_BOT,
			40,
			8,
			"Focused Fire: Double damage once per battle",
			Color(0.8, 0.3, 0.3),
			1
		),
		Companion.new(
			"Aegis",
			CompanionType.SHIELD_DRONE,
			50,
			4,
			"Shield: Block 5 damage per turn",
			Color(0.3, 0.5, 0.8),
			1
		),
		
		# Rare Companions
		Companion.new(
			"Sparky",
			CompanionType.ELECTRIC_WISP,
			35,
			12,
			"Chain Lightning: Hit 3 enemies for 10 damage",
			Color(0.9, 0.9, 0.3),
			2
		),
		Companion.new(
			"Ember",
			CompanionType.FIRE_SPRITE,
			30,
			15,
			"Flame Burst: AoE 20 fire damage (5 turn cooldown)",
			Color(1.0, 0.4, 0.0),
			2
		),
		Companion.new(
			"Frost",
			CompanionType.ICE_GUARDIAN,
			60,
			8,
			"Freeze: Slow all enemies for 3 turns",
			Color(0.4, 0.8, 1.0),
			2
		),
		
		# Legendary Companion
		Companion.new(
			"Aurora",
			CompanionType.HEALING_FAIRY,
			40,
			10,
			"Divine Light: Full heal + cleanse (once per floor)",
			Color(1.0, 0.9, 0.6),
			3
		),
	]

static func get_random_companion(min_rarity: int = 0) -> Companion:
	var all_companions = get_all_companions()
	var valid_companions = []
	
	for companion in all_companions:
		if companion.rarity >= min_rarity:
			valid_companions.append(companion)
	
	if valid_companions.size() == 0:
		return all_companions[0]
	
	return valid_companions[randi() % valid_companions.size()]

static func companion_take_turn(companion: Companion, game) -> String:
	if companion.cooldown > 0:
		companion.cooldown -= 1
	
	var message = ""
	
	match companion.type:
		CompanionType.REPAIR_DRONE:
			if companion.cooldown == 0:
				game.player.heal(10)
				message = "[color=cyan]" + companion.name + " repairs you for 10 HP![/color]"
				companion.cooldown = 5
		
		CompanionType.ATTACK_BOT:
			if game.enemies.size() > 0:
				var target = game.enemies[randi() % game.enemies.size()]
				if is_instance_valid(target):
					target.take_damage(companion.attack)
					message = "[color=red]" + companion.name + " attacks for " + str(companion.attack) + "![/color]"
		
		CompanionType.SHIELD_DRONE:
			# Passive shield applied in player damage calculation
			message = "[color=blue]" + companion.name + " shields you![/color]"
		
		CompanionType.SCAVENGER_BOT:
			# Handled in enemy death - gives bonus gold
			pass
		
		CompanionType.ELECTRIC_WISP:
			if companion.cooldown == 0 and game.enemies.size() > 0:
				var targets = game.enemies.slice(0, min(3, game.enemies.size()))
				for target in targets:
					if is_instance_valid(target):
						target.take_damage(10)
				message = "[color=yellow]" + companion.name + " chain lightning![/color]"
				companion.cooldown = 4
		
		CompanionType.FIRE_SPRITE:
			if companion.cooldown == 0 and game.enemies.size() > 0:
				for enemy in game.enemies:
					if is_instance_valid(enemy):
						enemy.take_damage(20)
				message = "[color=orange]" + companion.name + " FLAME BURST![/color]"
				companion.cooldown = 5
		
		CompanionType.ICE_GUARDIAN:
			if companion.cooldown == 0 and game.enemies.size() > 0:
				# Freeze effect would need to be implemented in enemy AI
				message = "[color=cyan]" + companion.name + " freezes all enemies![/color]"
				companion.cooldown = 6
		
		CompanionType.HEALING_FAIRY:
			if companion.cooldown == 0 and game.player.health < game.player.max_health * 0.3:
				game.player.health = game.player.max_health
				message = "[color=gold]" + companion.name + " DIVINE LIGHT! Full heal![/color]"
				companion.cooldown = 999  # Once per floor
	
	return message

static func reset_companion_cooldown(companion: Companion):
	# Call when entering new floor
	if companion.type == CompanionType.HEALING_FAIRY:
		companion.cooldown = 0
