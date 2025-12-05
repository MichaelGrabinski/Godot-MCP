extends Node

# Elemental System - Fire, Ice, Electric, Poison damage types

class_name ElementalSystem

enum Element {
	NONE,
	FIRE,
	ICE,
	ELECTRIC,
	POISON,
	HOLY,
	DARK
}

class ElementalEffect:
	var element: Element
	var duration: int  # Turns
	var strength: int
	
	func _init(elem: Element, dur: int, str: int):
		element = elem
		duration = dur
		strength = str

# Element colors for visual effects
static func get_element_color(element: Element) -> Color:
	match element:
		Element.FIRE:
			return Color(1.0, 0.4, 0.0)
		Element.ICE:
			return Color(0.4, 0.8, 1.0)
		Element.ELECTRIC:
			return Color(0.9, 0.9, 0.0)
		Element.POISON:
			return Color(0.5, 1.0, 0.3)
		Element.HOLY:
			return Color(1.0, 1.0, 0.8)
		Element.DARK:
			return Color(0.5, 0.2, 0.8)
		_:
			return Color.WHITE

static func get_element_name(element: Element) -> String:
	match element:
		Element.FIRE:
			return "Fire"
		Element.ICE:
			return "Ice"
		Element.ELECTRIC:
			return "Electric"
		Element.POISON:
			return "Poison"
		Element.HOLY:
			return "Holy"
		Element.DARK:
			return "Dark"
		_:
			return "Physical"

# Calculate damage with elemental bonuses
static func calculate_elemental_damage(base_damage: int, attacker_element: Element, defender_element: Element) -> int:
	var multiplier = 1.0
	
	# Fire beats Ice, weak to Water (we'll use Ice as water-like)
	if attacker_element == Element.FIRE and defender_element == Element.ICE:
		multiplier = 1.5
	elif attacker_element == Element.ICE and defender_element == Element.FIRE:
		multiplier = 0.5
	
	# Electric beats Water (Ice), weak to Earth (we'll use Physical)
	if attacker_element == Element.ELECTRIC and defender_element == Element.ICE:
		multiplier = 1.5
	
	# Holy vs Dark
	if attacker_element == Element.HOLY and defender_element == Element.DARK:
		multiplier = 1.5
	elif attacker_element == Element.DARK and defender_element == Element.HOLY:
		multiplier = 1.5
	
	# Poison is strong vs everything but slow
	if attacker_element == Element.POISON:
		multiplier = 0.8  # Lower direct damage but adds DoT
	
	return int(base_damage * multiplier)

# Process elemental effects each turn
static func process_elemental_effect(effect: ElementalEffect, target) -> Dictionary:
	var result = {
		"damage": 0,
		"message": "",
		"expired": false
	}
	
	match effect.element:
		Element.FIRE:
			# Burning damage over time
			result.damage = effect.strength
			result.message = "[color=orange]Burning for " + str(effect.strength) + " damage![/color]"
		
		Element.ICE:
			# Slows movement (we'll handle this differently)
			result.message = "[color=cyan]Frozen! Movement slowed![/color]"
		
		Element.POISON:
			# Poison damage
			result.damage = effect.strength
			result.message = "[color=green]Poisoned for " + str(effect.strength) + " damage![/color]"
		
		Element.ELECTRIC:
			# Chain lightning chance
			result.damage = effect.strength
			result.message = "[color=yellow]Electric shock for " + str(effect.strength) + "![/color]"
		
		Element.DARK:
			# Life drain
			result.damage = effect.strength
			result.message = "[color=purple]Dark energy drains " + str(effect.strength) + " life![/color]"
	
	effect.duration -= 1
	if effect.duration <= 0:
		result.expired = true
	
	return result
