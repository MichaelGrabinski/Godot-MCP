extends Node

# Weapon System - 7 unique weapon types with special abilities!

class_name WeaponSystem

enum WeaponType {
	SWORD, AXE, DAGGER, HAMMER, SPEAR, CROSSBOW, CHAINSAW
}

enum WeaponRarity {
	COMMON, UNCOMMON, RARE, LEGENDARY
}

static func create_weapon(type: WeaponType, rarity: WeaponRarity, floor: int) -> Dictionary:
	var weapon = {
		"name": "",
		"type": 0,  # For compatibility with existing code
		"weapon_type": type,
		"rarity": rarity,
		"attack_bonus": 0,
		"defense_bonus": 0,
		"health_bonus": 0,
		"speed": 1.0,
		"range": 1,
		"special": ""
	}
	
	match type:
		WeaponType.SWORD:
			weapon.name = "Diesel Blade"
			weapon.attack_bonus = 10 + floor * 2
			weapon.speed = 1.0
			
		WeaponType.AXE:
			weapon.name = "Steam Axe"
			weapon.attack_bonus = 15 + floor * 3
			weapon.speed = 0.7
			weapon.special = "Cleave"
			
		WeaponType.DAGGER:
			weapon.name = "Oil Shank"
			weapon.attack_bonus = 6 + floor
			weapon.speed = 1.5
			weapon.special = "Backstab"
			
		WeaponType.HAMMER:
			weapon.name = "Forge Hammer"
			weapon.attack_bonus = 18 + floor * 3
			weapon.speed = 0.5
			weapon.special = "Shockwave"
			
		WeaponType.SPEAR:
			weapon.name = "Piston Lance"
			weapon.attack_bonus = 12 + floor * 2
			weapon.range = 2
			
		WeaponType.CROSSBOW:
			weapon.name = "Bolt Launcher"
			weapon.attack_bonus = 14 + floor * 2
			weapon.speed = 0.8
			weapon.range = 5
			
		WeaponType.CHAINSAW:
			weapon.name = "Ripper 3000"
			weapon.attack_bonus = 8 + floor
			weapon.speed = 2.0
			weapon.special = "Bleed"
	
	match rarity:
		WeaponRarity.COMMON:
			weapon.name = "Rusty " + weapon.name
		WeaponRarity.UNCOMMON:
			weapon.attack_bonus = int(weapon.attack_bonus * 1.2)
			weapon.name = "Quality " + weapon.name
			weapon.rarity = 1
		WeaponRarity.RARE:
			weapon.attack_bonus = int(weapon.attack_bonus * 1.5)
			weapon.name = "Fine " + weapon.name
			weapon.rarity = 2
		WeaponRarity.LEGENDARY:
			weapon.attack_bonus = int(weapon.attack_bonus * 2.0)
			weapon.name = "LEGENDARY " + weapon.name
			weapon.rarity = 3
	
	return weapon

static func get_random_weapon(floor: int) -> Dictionary:
	var type = randi() % WeaponType.size()
	var rarity_roll = randf()
	
	var rarity = WeaponRarity.COMMON
	if rarity_roll > 0.95:
		rarity = WeaponRarity.LEGENDARY
	elif rarity_roll > 0.80:
		rarity = WeaponRarity.RARE
	elif rarity_roll > 0.50:
		rarity = WeaponRarity.UNCOMMON
	
	return create_weapon(type, rarity, floor)
