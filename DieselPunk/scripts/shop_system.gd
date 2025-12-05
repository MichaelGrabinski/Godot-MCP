extends Node

# Shop System - Merchant rooms with buyable items

class_name ShopSystem

class ShopItem:
	var item: Object  # ItemSystem.Item
	var price: int
	var sold: bool = false
	
	func _init(it, pr: int):
		item = it
		price = pr

static func generate_shop_inventory(floor: int, count: int = 4) -> Array:
	var inventory = []
	var ItemSystem = load("res://DieselPunk/scripts/item_system.gd")
	
	for i in range(count):
		var item = ItemSystem.get_random_item(floor)
		# Price based on rarity and floor
		var base_price = 50
		match item.rarity:
			0: base_price = 30  # Common
			1: base_price = 60  # Uncommon
			2: base_price = 120  # Rare
			3: base_price = 250  # Legendary
		
		base_price += floor * 10
		
		var shop_item = ShopItem.new(item, base_price)
		inventory.append(shop_item)
	
	return inventory

static func get_merchant_greeting(floor: int) -> String:
	var greetings = [
		"Welcome, traveler! Fine wares for sale!",
		"Ah, a customer! I have just what you need!",
		"Step right up! Best prices in the depths!",
		"Greetings! Care to browse my collection?",
		"Welcome to my humble shop! Everything must go!",
	]
	
	if floor >= 10:
		greetings.append("You've made it far! Special items available!")
	if floor >= 20:
		greetings.append("A true adventurer! Only the finest for you!")
	
	return greetings[randi() % greetings.size()]

static func get_merchant_farewell() -> String:
	var farewells = [
		"Come back soon!",
		"Safe travels!",
		"Good luck out there!",
		"May fortune favor you!",
		"Happy hunting!",
	]
	return farewells[randi() % farewells.size()]

static func get_cant_afford_message() -> String:
	var messages = [
		"Not enough gold, friend!",
		"You'll need more coin for that!",
		"Come back when you're richer!",
		"That's beyond your budget!",
		"You can't afford that!",
	]
	return messages[randi() % messages.size()]
