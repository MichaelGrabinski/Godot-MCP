# Global Manager - Singleton that handles cross-domain bonuses
extends Node

var grand_prestige_level: int = 0
var production_multiplier: float = 1.0

func _ready():
	_load_grand_prestige()
	print("Global Manager loaded. Production multiplier: ", production_multiplier)

func get_production_multiplier() -> float:
	return production_multiplier

func get_grand_prestige_level() -> int:
	return grand_prestige_level

func _load_grand_prestige():
	if FileAccess.file_exists("user://grand_prestige.dat"):
		var file = FileAccess.open("user://grand_prestige.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()
			
			grand_prestige_level = data.get("level", 0)
			var bonuses = data.get("bonuses", {})
			production_multiplier = bonuses.get("production_multiplier", 1.0)
