extends Node

# DIAGNOSTIC - Check if asset files exist

func _ready():
	print("\n=== ASSET DIAGNOSTIC ===\n")
	
	# Check hero files
	print("HERO WARRIOR FILES:")
	check_hero_animation("Idle", "Down")
	check_hero_animation("Run", "Down")
	check_hero_animation("Attack", "Down")
	
	print("\nENEMY FILES:")
	check_enemy_files("Rat")
	check_enemy_files("Slime")
	check_enemy_files("Ghost")
	
	print("\nTILESET FILES:")
	var tileset = load("res://DieselPunk/Dungeons and Pixels/Tilesets/Tileset_Dungeon.png")
	if tileset:
		print("✅ Tileset_Dungeon.png found (" + str(tileset.get_width()) + "x" + str(tileset.get_height()) + ")")
	else:
		print("❌ Tileset_Dungeon.png NOT FOUND")
	
	print("\n=== END DIAGNOSTIC ===\n")
	
	get_tree().quit()

func check_hero_animation(anim: String, direction: String):
	var path = "res://DieselPunk/Dungeons and Pixels/Characters/Hero_Warrior/Frames/" + anim + "/" + direction + "/0.png"
	var texture = load(path)
	if texture:
		print("  ✅ " + anim + " " + direction + " exists")
	else:
		print("  ❌ " + anim + " " + direction + " NOT FOUND at: " + path)

func check_enemy_files(enemy_name: String):
	var base = "res://DieselPunk/Dungeons and Pixels/Characters/Enemies/" + enemy_name + "/"
	
	for anim in ["idle", "move", "attack", "death"]:
		var path = base + anim + "_strip.png"
		var texture = load(path)
		if texture:
			print("  ✅ " + enemy_name + " " + anim + "_strip.png (" + str(texture.get_width()) + "px)")
		else:
			print("  ❌ " + enemy_name + " " + anim + "_strip.png NOT FOUND")
