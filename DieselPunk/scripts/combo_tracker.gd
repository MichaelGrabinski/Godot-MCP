extends Node

# Combo System - Rewards consecutive kills

class_name ComboTracker

var combo_count = 0
var combo_timer = 0.0
var combo_timeout = 3.0  # Seconds before combo resets
var max_combo = 0

var damage_multiplier = 1.0
var experience_multiplier = 1.0

signal combo_increased(count: int)
signal combo_broken()
signal combo_milestone(count: int)

func _process(delta):
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			break_combo()

func add_kill():
	combo_count += 1
	combo_timer = combo_timeout
	
	if combo_count > max_combo:
		max_combo = combo_count
	
	# Calculate multipliers
	damage_multiplier = 1.0 + (combo_count * 0.1)  # +10% per combo
	experience_multiplier = 1.0 + (combo_count * 0.15)  # +15% XP per combo
	
	emit_signal("combo_increased", combo_count)
	
	# Milestones
	if combo_count == 5:
		emit_signal("combo_milestone", 5)
	elif combo_count == 10:
		emit_signal("combo_milestone", 10)
	elif combo_count == 15:
		emit_signal("combo_milestone", 15)

func break_combo():
	if combo_count > 0:
		emit_signal("combo_broken")
	combo_count = 0
	combo_timer = 0.0
	damage_multiplier = 1.0
	experience_multiplier = 1.0

func reset():
	combo_count = 0
	combo_timer = 0.0
	damage_multiplier = 1.0
	experience_multiplier = 1.0
	max_combo = 0

func get_combo_color() -> Color:
	if combo_count < 3:
		return Color.WHITE
	elif combo_count < 5:
		return Color(1.0, 0.9, 0.3)  # Yellow
	elif combo_count < 10:
		return Color(1.0, 0.5, 0.0)  # Orange
	else:
		return Color(1.0, 0.2, 0.2)  # Red
