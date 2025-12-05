extends Node

# ULTIMATE Item System - Expanded with elementals, cursed items, artifacts

enum ItemType {
	WEAPON,
	ARMOR,
	CONSUMABLE,
	RELIC,
	CURSED
}

enum ItemRarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	MYTHIC
}

class Item:
	var name: String
	var description: String
	var type: ItemType
	var rarity: ItemRarity
	var sprite_color: Color
	
	# Stats modifiers
	var health_bonus: int = 0
	var attack_bonus: int = 0
	var defense_bonus: int = 0
	
	# Consumable effects
	var heal_amount: int = 0
	var damage_boost_turns: int = 0
	var defense_boost_turns: int = 0
	
	# NEW: Elemental properties
	var element: int = 0  # ElementalSystem.Element
	var elemental_damage: int = 0
	
	# NEW: Special effects
	var is_cursed: bool = false
	var curse_effect: String = ""
	var special_effect: String = ""
	var crit_chance_bonus: float = 0.0
	var lifesteal: float = 0.0
	
	func _init(n: String, desc: String, t: ItemType, r: ItemRarity):
		name = n
		description = desc
		type = t
		rarity = r
		
		match rarity:
			ItemRarity.COMMON:
				sprite_color = Color(0.7, 0.7, 0.7)
			ItemRarity.UNCOMMON:
				sprite_color = Color(0.3, 0.8, 0.3)
			ItemRarity.RARE:
				sprite_color = Color(0.3, 0.5, 1.0)
			ItemRarity.LEGENDARY:
				sprite_color = Color(1.0, 0.8, 0.2)
			ItemRarity.MYTHIC:
				sprite_color = Color(1.0, 0.2, 0.8)

# WEAPONS - Physical
static func get_all_weapons() -> Array:
	return [
		# Common Weapons
		["Rusty Pipe", "A corroded metal pipe. Better than nothing.", 2, 0, ItemRarity.COMMON, 0],
		["Steam Wrench", "Heavy industrial wrench. Smells of oil.", 4, 1, ItemRarity.COMMON, 0],
		["Scrap Blade", "Makeshift weapon from junk.", 3, 0, ItemRarity.COMMON, 0],
		
		# Uncommon Weapons
		["Gear Blade", "Spinning gears form a deadly edge.", 6, 1, ItemRarity.UNCOMMON, 0],
		["Piston Hammer", "Hydraulic-powered devastation.", 8, 2, ItemRarity.UNCOMMON, 0],
		["Rivet Gun", "Industrial fastener turned weapon.", 7, 1, ItemRarity.UNCOMMON, 0],
		
		# Rare Weapons
		["Arc Welder", "Electrical discharge weapon.", 10, 2, ItemRarity.RARE, 2],  # Electric
		["Pressure Rifle", "Fires superheated steam bolts.", 12, 3, ItemRarity.RARE, 0],
		["Molten Maul", "Hammer heated by internal forge.", 11, 2, ItemRarity.RARE, 1],  # Fire
		
		# Legendary Weapons
		["Chain Grinder", "Diesel-powered rotary death.", 15, 3, ItemRarity.LEGENDARY, 0],
		["Frost Breaker", "Cryo-powered warhammer.", 14, 4, ItemRarity.LEGENDARY, 3],  # Ice
		["Thunder Fist", "Gauntlet that channels lightning.", 16, 2, ItemRarity.LEGENDARY, 2],  # Electric
		
		# Mythic Weapons
		["Apocalypse Engine", "Reality-breaking siege weapon.", 25, 5, ItemRarity.MYTHIC, 0],
		["Omega Blade", "The ultimate cutting tool.", 22, 6, ItemRarity.MYTHIC, 0],
	]

# CURSED WEAPONS - High power, negative effects
static func get_cursed_weapons() -> Array:
	return [
		["Bloodletter", "Drink deep of victory... and defeat.", 18, 0, "Lose 5 HP per turn, but gain massive damage."],
		["Soul Eater", "It hungers... constantly.", 20, 2, "Cannot heal, but life steal 30% of damage."],
		["Betrayer's Edge", "Sometimes it turns on you.", 16, 3, "10% chance to hit yourself instead."],
		["Demon's Pact", "Power at a price.", 22, 1, "Take double damage, deal double damage."],
	]

# ARMOR - All types
static func get_all_armor() -> Array:
	return [
		# Common
		["Leather Apron", "Oil-stained work apron.", 0, 3, ItemRarity.COMMON],
		["Work Vest", "Basic protective gear.", 5, 2, ItemRarity.COMMON],
		
		# Uncommon
		["Brass Plating", "Lightweight metal protection.", 10, 5, ItemRarity.UNCOMMON],
		["Steam Suit", "Pressurized protective gear.", 15, 7, ItemRarity.UNCOMMON],
		
		# Rare
		["Riveted Armor", "Heavy industrial plating.", 20, 10, ItemRarity.RARE],
		["Shock Plates", "Electricity-infused armor.", 18, 12, ItemRarity.RARE],
		
		# Legendary
		["Diesel Core Armor", "Powered armor suit.", 30, 15, ItemRarity.LEGENDARY],
		["Phoenix Mail", "Armor that regenerates.", 25, 18, ItemRarity.LEGENDARY],
		
		# Mythic
		["Titan Chassis", "Walking fortress.", 50, 25, ItemRarity.MYTHIC],
	]

# CONSUMABLES - Expanded
static func get_all_consumables() -> Array:
	return [
		# Healing
		["Oil Flask", "Restore 30 HP.", 30, 0, 0, ItemRarity.COMMON],
		["Steam Injector", "Restore 50 HP.", 50, 0, 0, ItemRarity.UNCOMMON],
		["Diesel Fuel", "Full heal.", 999, 0, 0, ItemRarity.RARE],
		["Phoenix Down", "Restore to full and cleanse ailments.", 999, 0, 0, ItemRarity.LEGENDARY],
		
		# Combat Buffs
		["Adrenaline Shot", "+5 Attack for 5 turns.", 0, 5, 5, ItemRarity.UNCOMMON],
		["Iron Tonic", "+3 Defense for 5 turns.", 0, 0, 5, ItemRarity.UNCOMMON],
		["Combat Serum", "+7 Attack for 3 turns.", 0, 7, 3, ItemRarity.RARE],
		["Berserker Brew", "+15 Attack for 5 turns, -5 Defense.", 0, 15, 5, ItemRarity.LEGENDARY],
		
		# Utility
		["Smoke Bomb", "Become invisible for 3 turns.", 0, 0, 0, ItemRarity.RARE],
		["Time Coil", "Take 2 actions this turn.", 0, 0, 0, ItemRarity.LEGENDARY],
		["Escape Rope", "Return to previous floor.", 0, 0, 0, ItemRarity.UNCOMMON],
	]

static func get_random_weapon(floor: int) -> Item:
	var all_weapons = get_all_weapons()
	var valid_weapons = []
	
	# Filter by floor (higher floors = better loot chance)
	for weapon_data in all_weapons:
		var min_floor_for_rarity = 0
		match weapon_data[4]:
			ItemRarity.UNCOMMON: min_floor_for_rarity = 2
			ItemRarity.RARE: min_floor_for_rarity = 5
			ItemRarity.LEGENDARY: min_floor_for_rarity = 10
			ItemRarity.MYTHIC: min_floor_for_rarity = 20
		
		if floor >= min_floor_for_rarity:
			valid_weapons.append(weapon_data)
	
	# Small chance for cursed weapon at higher floors
	if floor >= 7 and randi() % 100 < 15:
		return get_cursed_weapon()
	
	var weapon_data = valid_weapons[randi() % valid_weapons.size()]
	var item = Item.new(weapon_data[0], weapon_data[1], ItemType.WEAPON, weapon_data[4])
	item.attack_bonus = weapon_data[2] + int(floor * 0.5)
	item.defense_bonus = weapon_data[3]
	item.element = weapon_data[5]
	
	if item.element > 0:
		item.elemental_damage = item.attack_bonus / 2
	
	return item

static func get_cursed_weapon() -> Item:
	var cursed_weapons = get_cursed_weapons()
	var weapon_data = cursed_weapons[randi() % cursed_weapons.size()]
	
	var item = Item.new(weapon_data[0], weapon_data[1], ItemType.CURSED, ItemRarity.LEGENDARY)
	item.attack_bonus = weapon_data[2]
	item.defense_bonus = weapon_data[3]
	item.is_cursed = true
	item.curse_effect = weapon_data[4]
	item.sprite_color = Color(0.7, 0.1, 0.8)
	
	return item

static func get_random_armor(floor: int) -> Item:
	var all_armor = get_all_armor()
	var valid_armor = []
	
	for armor_data in all_armor:
		var min_floor = 0
		match armor_data[4]:
			ItemRarity.UNCOMMON: min_floor = 2
			ItemRarity.RARE: min_floor = 5
			ItemRarity.LEGENDARY: min_floor = 10
			ItemRarity.MYTHIC: min_floor = 20
		
		if floor >= min_floor:
			valid_armor.append(armor_data)
	
	var armor_data = valid_armor[randi() % valid_armor.size()]
	var item = Item.new(armor_data[0], armor_data[1], ItemType.ARMOR, armor_data[4])
	item.health_bonus = armor_data[2] + floor * 3
	item.defense_bonus = armor_data[3] + floor
	
	# Phoenix Mail special: regeneration
	if item.name == "Phoenix Mail":
		item.special_effect = "regen_3"
	
	return item

static func get_random_consumable() -> Item:
	var all_consumables = get_all_consumables()
	var consumable_data = all_consumables[randi() % all_consumables.size()]
	
	var item = Item.new(consumable_data[0], consumable_data[1], ItemType.CONSUMABLE, consumable_data[5])
	item.heal_amount = consumable_data[2]
	
	if consumable_data[3] > 0:
		item.damage_boost_turns = consumable_data[4]
		item.attack_bonus = consumable_data[3]
	if consumable_data[1].contains("Defense"):
		item.defense_boost_turns = consumable_data[4]
		item.defense_bonus = consumable_data[3]
	
	# Special consumables
	if item.name == "Smoke Bomb":
		item.special_effect = "invisible_3"
	elif item.name == "Time Coil":
		item.special_effect = "extra_turn"
	elif item.name == "Escape Rope":
		item.special_effect = "escape"
	
	return item

static func get_random_item(floor: int) -> Item:
	var roll = randi() % 100
	if roll < 40:
		return get_random_weapon(floor)
	elif roll < 70:
		return get_random_armor(floor)
	else:
		return get_random_consumable()

static func get_rarity_for_floor(floor: int) -> ItemRarity:
	var roll = randi() % 100 + floor * 2
	if roll < 50:
		return ItemRarity.COMMON
	elif roll < 75:
		return ItemRarity.UNCOMMON
	elif roll < 90:
		return ItemRarity.RARE
	elif roll < 98:
		return ItemRarity.LEGENDARY
	else:
		return ItemRarity.MYTHIC
