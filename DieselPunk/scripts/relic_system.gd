extends Node

# Relic System - Permanent passive bonuses

class_name RelicSystem

enum RelicType {
	HEALTH_BOOST,
	DAMAGE_BOOST,
	DEFENSE_BOOST,
	CRIT_CHANCE,
	LIFESTEAL,
	THORNS,
	GOLD_MAGNET,
	XP_BOOST,
	SPEED_BOOST,
	EVASION,
	ELEMENTAL_RESIST,
	VAMPIRE,
	BERSERKER,
	LUCKY,
	REGENERATION
}

class Relic:
	var name: String
	var description: String
	var type: RelicType
	var value: float
	var rarity: int
	var sprite_color: Color
	
	func _init(n: String, desc: String, t: RelicType, val: float, rar: int, color: Color):
		name = n
		description = desc
		type = t
		value = val
		rarity = rar
		sprite_color = color

static func get_all_relics() -> Array:
	return [
		# Common Relics
		Relic.new(
			"Rusty Heart",
			"+20 Max HP",
			RelicType.HEALTH_BOOST,
			20.0,
			0,
			Color(0.7, 0.3, 0.3)
		),
		Relic.new(
			"Gear Tooth",
			"+2 Attack",
			RelicType.DAMAGE_BOOST,
			2.0,
			0,
			Color(0.6, 0.6, 0.5)
		),
		Relic.new(
			"Steel Plate",
			"+1 Defense",
			RelicType.DEFENSE_BOOST,
			1.0,
			0,
			Color(0.5, 0.5, 0.6)
		),
		
		# Uncommon Relics
		Relic.new(
			"Lucky Cog",
			"10% Critical Hit Chance",
			RelicType.CRIT_CHANCE,
			0.1,
			1,
			Color(0.8, 0.7, 0.2)
		),
		Relic.new(
			"Vampire Valve",
			"Heal 20% of damage dealt",
			RelicType.LIFESTEAL,
			0.2,
			1,
			Color(0.8, 0.2, 0.2)
		),
		Relic.new(
			"Spiked Armor",
			"Return 30% damage to attackers",
			RelicType.THORNS,
			0.3,
			1,
			Color(0.6, 0.4, 0.3)
		),
		Relic.new(
			"Scholar's Lens",
			"+50% XP gain",
			RelicType.XP_BOOST,
			0.5,
			1,
			Color(0.3, 0.5, 0.8)
		),
		
		# Rare Relics
		Relic.new(
			"Dodge Matrix",
			"15% chance to evade attacks",
			RelicType.EVASION,
			0.15,
			2,
			Color(0.4, 0.7, 0.9)
		),
		Relic.new(
			"Elemental Ward",
			"25% resistance to elemental damage",
			RelicType.ELEMENTAL_RESIST,
			0.25,
			2,
			Color(0.6, 0.3, 0.9)
		),
		Relic.new(
			"Berserker Gear",
			"+50% damage at low HP (<30%)",
			RelicType.BERSERKER,
			0.5,
			2,
			Color(1.0, 0.3, 0.0)
		),
		
		# Legendary Relics
		Relic.new(
			"Phoenix Core",
			"Regenerate 5 HP per turn",
			RelicType.REGENERATION,
			5.0,
			3,
			Color(1.0, 0.6, 0.0)
		),
		Relic.new(
			"Clockwork Heart",
			"+50 Max HP, +5 Attack, +3 Defense",
			RelicType.HEALTH_BOOST,  # Multi-stat
			50.0,
			3,
			Color(0.9, 0.7, 0.3)
		),
		Relic.new(
			"Fate's Die",
			"All random events 50% more favorable",
			RelicType.LUCKY,
			0.5,
			3,
			Color(1.0, 0.9, 0.3)
		),
	]

static func get_random_relic(min_rarity: int = 0) -> Relic:
	var all_relics = get_all_relics()
	var valid_relics = []
	
	for relic in all_relics:
		if relic.rarity >= min_rarity:
			valid_relics.append(relic)
	
	if valid_relics.size() == 0:
		return all_relics[0]
	
	return valid_relics[randi() % valid_relics.size()]

static func apply_relic_bonus(relic: Relic, player):
	match relic.type:
		RelicType.HEALTH_BOOST:
			player.max_health += int(relic.value)
			player.health += int(relic.value)
			if relic.name == "Clockwork Heart":  # Special multi-stat
				player.attack += 5
				player.defense += 3
		
		RelicType.DAMAGE_BOOST:
			player.attack += int(relic.value)
		
		RelicType.DEFENSE_BOOST:
			player.defense += int(relic.value)
		
		RelicType.CRIT_CHANCE:
			player.crit_chance = relic.value
		
		RelicType.LIFESTEAL:
			player.lifesteal = relic.value
		
		RelicType.THORNS:
			player.thorns = relic.value
		
		RelicType.XP_BOOST:
			player.xp_multiplier = 1.0 + relic.value
		
		RelicType.EVASION:
			player.evasion_chance = relic.value
		
		RelicType.ELEMENTAL_RESIST:
			player.elemental_resist = relic.value
		
		RelicType.BERSERKER:
			player.berserker_bonus = relic.value
		
		RelicType.REGENERATION:
			player.regen_per_turn = int(relic.value)
		
		RelicType.LUCKY:
			player.luck_bonus = relic.value
