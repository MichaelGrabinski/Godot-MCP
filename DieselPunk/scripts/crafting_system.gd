extends Node

# Crafting System - Combine items to create better gear

class_name CraftingSystem

class Recipe:
	var name: String
	var ingredients: Array  # Array of item names
	var result_item: Object  # ItemSystem.Item
	var recipe_type: String  # "weapon", "armor", "consumable", "special"
	
	func _init(n: String, ingr: Array, result, type: String):
		name = n
		ingredients = ingr
		result_item = result
		recipe_type = type

static func get_all_recipes() -> Array:
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	
	return [
		# Weapon Recipes
		Recipe.new(
			"Enhanced Blade",
			["Gear Blade", "Oil Flask"],
			create_enhanced_weapon("Oiled Gear Blade", 12, 2, 1),
			"weapon"
		),
		Recipe.new(
			"Electric Hammer",
			["Piston Hammer", "Arc Welder"],
			create_elemental_weapon("Electro Hammer", 16, 3, 2),
			"weapon"
		),
		Recipe.new(
			"Inferno Blade",
			["Gear Blade", "Molten Maul"],
			create_elemental_weapon("Blazing Gear", 18, 2, 1),
			"weapon"
		),
		
		# Armor Recipes
		Recipe.new(
			"Reinforced Plating",
			["Brass Plating", "Steel Plate"],
			create_enhanced_armor("Reinforced Brass", 20, 8),
			"armor"
		),
		Recipe.new(
			"Phoenix Armor",
			["Riveted Armor", "Phoenix Down"],
			create_special_armor("Phoenix Plate", 35, 12, "regen_5"),
			"armor"
		),
		
		# Consumable Recipes
		Recipe.new(
			"Mega Potion",
			["Oil Flask", "Steam Injector"],
			create_consumable("Mega Heal", "Restore 100 HP", 100),
			"consumable"
		),
		Recipe.new(
			"Ultimate Serum",
			["Adrenaline Shot", "Combat Serum"],
			create_buff_consumable("God Mode Serum", "+15 ATK, +10 DEF for 10 turns", 15, 10, 10),
			"consumable"
		),
		Recipe.new(
			"Revive Potion",
			["Phoenix Down", "Diesel Fuel"],
			create_special_consumable("Second Chance", "Auto-revive on death", "revive"),
			"consumable"
		),
		
		# Special Recipes
		Recipe.new(
			"Elemental Core",
			["Arc Welder", "Molten Maul", "Frost Breaker"],
			create_tri_elemental_weapon("Trinity Core", 25, 5),
			"special"
		),
		Recipe.new(
			"Omega Gear",
			["Chain Grinder", "Pressure Rifle", "Thunder Fist"],
			create_ultimate_weapon("Omega Destroyer", 35, 8),
			"special"
		),
	]

static func create_enhanced_weapon(name: String, atk: int, def: int, element: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, "Enhanced through crafting", ItemSystem.ItemType.WEAPON, ItemSystem.ItemRarity.RARE)
	item.attack_bonus = atk
	item.defense_bonus = def
	item.element = element
	item.sprite_color = Color(0.5, 0.7, 1.0)
	return item

static func create_elemental_weapon(name: String, atk: int, def: int, element: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, "Infused with elemental power", ItemSystem.ItemType.WEAPON, ItemSystem.ItemRarity.LEGENDARY)
	item.attack_bonus = atk
	item.defense_bonus = def
	item.element = element
	item.elemental_damage = atk / 2
	item.sprite_color = Color(1.0, 0.5, 0.3)
	return item

static func create_enhanced_armor(name: String, hp: int, def: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, "Reinforced protection", ItemSystem.ItemType.ARMOR, ItemSystem.ItemRarity.RARE)
	item.health_bonus = hp
	item.defense_bonus = def
	item.sprite_color = Color(0.6, 0.6, 0.7)
	return item

static func create_special_armor(name: String, hp: int, def: int, effect: String):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, "Special armor with unique effect", ItemSystem.ItemType.ARMOR, ItemSystem.ItemRarity.LEGENDARY)
	item.health_bonus = hp
	item.defense_bonus = def
	item.special_effect = effect
	item.sprite_color = Color(1.0, 0.7, 0.3)
	return item

static func create_consumable(name: String, desc: String, heal: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, desc, ItemSystem.ItemType.CONSUMABLE, ItemSystem.ItemRarity.RARE)
	item.heal_amount = heal
	item.sprite_color = Color(0.3, 1.0, 0.3)
	return item

static func create_buff_consumable(name: String, desc: String, atk: int, def: int, turns: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, desc, ItemSystem.ItemType.CONSUMABLE, ItemSystem.ItemRarity.LEGENDARY)
	item.attack_bonus = atk
	item.defense_bonus = def
	item.damage_boost_turns = turns
	item.defense_boost_turns = turns
	item.sprite_color = Color(1.0, 0.8, 0.2)
	return item

static func create_special_consumable(name: String, desc: String, effect: String):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, desc, ItemSystem.ItemType.CONSUMABLE, ItemSystem.ItemRarity.LEGENDARY)
	item.special_effect = effect
	item.sprite_color = Color(1.0, 0.2, 0.8)
	return item

static func create_tri_elemental_weapon(name: String, atk: int, def: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, "Channels Fire, Ice, and Electric", ItemSystem.ItemType.WEAPON, ItemSystem.ItemRarity.MYTHIC)
	item.attack_bonus = atk
	item.defense_bonus = def
	item.element = 1  # Fire base
	item.elemental_damage = atk
	item.special_effect = "tri_element"
	item.sprite_color = Color(1.0, 0.3, 1.0)
	return item

static func create_ultimate_weapon(name: String, atk: int, def: int):
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	var item = ItemSystem.Item.new(name, "The pinnacle of craftsmanship", ItemSystem.ItemType.WEAPON, ItemSystem.ItemRarity.MYTHIC)
	item.attack_bonus = atk
	item.defense_bonus = def
	item.crit_chance_bonus = 0.25
	item.lifesteal = 0.2
	item.special_effect = "omega"
	item.sprite_color = Color(1.0, 0.9, 0.3)
	return item

static func can_craft(recipe: Recipe, player_inventory: Array) -> bool:
	var inventory_names = []
	for item in player_inventory:
		if item:
			inventory_names.append(item.name)
	
	for ingredient in recipe.ingredients:
		if not ingredient in inventory_names:
			return false
	
	return true

static func craft_item(recipe: Recipe, player_inventory: Array) -> Object:
	if not can_craft(recipe, player_inventory):
		return null
	
	# Remove ingredients from inventory
	for ingredient in recipe.ingredients:
		for i in range(player_inventory.size()):
			if player_inventory[i] and player_inventory[i].name == ingredient:
				player_inventory[i] = null
				break
	
	return recipe.result_item

static func get_available_recipes(player_inventory: Array) -> Array:
	var available = []
	var all_recipes = get_all_recipes()
	
	for recipe in all_recipes:
		if can_craft(recipe, player_inventory):
			available.append(recipe)
	
	return available

static func get_recipe_by_name(recipe_name: String) -> Recipe:
	var all_recipes = get_all_recipes()
	for recipe in all_recipes:
		if recipe.name == recipe_name:
			return recipe
	return null
