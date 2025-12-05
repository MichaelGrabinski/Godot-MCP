extends Node

# Asset Loader - WITH DEBUG OUTPUT!

class_name AssetLoader

static func load_tileset() -> Texture2D:
	return load("res://DieselPunk/Dungeons and Pixels/Tilesets/Tileset_Dungeon.png")

static func load_props_tileset() -> Texture2D:
	return load("res://DieselPunk/Dungeons and Pixels/Tilesets/Props_Static.png")

static func load_hero_animation_directional(animation_name: String, direction: String = "Down") -> Array:
	var frames = []
	var base_path = "res://DieselPunk/Dungeons and Pixels/Characters/Hero_Warrior/Frames/" + animation_name + "/"
	
	if animation_name == "Death":
		base_path = "res://DieselPunk/Dungeons and Pixels/Characters/Hero_Warrior/Frames/Death/"
		var frame_index = 0
		while true:
			var frame_path = base_path + str(frame_index) + ".png"
			var texture = load(frame_path)
			if texture:
				frames.append(texture)
				frame_index += 1
			else:
				break
	else:
		base_path += direction + "/"
		var frame_index = 0
		while true:
			var frame_path = base_path + str(frame_index) + ".png"
			var texture = load(frame_path)
			if texture:
				frames.append(texture)
				frame_index += 1
			else:
				break
	
	if frames.size() > 0:
		print("✅ Loaded " + animation_name + " " + direction + ": " + str(frames.size()) + " frames")
	else:
		print("⚠ No frames for " + animation_name + " " + direction)
	
	return frames

static func load_hero_all_directional_animations() -> Dictionary:
	var all_animations = {}
	
	print("🎨 Loading hero animations...")
	
	var directions = ["Down", "Up", "Side"]
	var base_anims = ["Idle", "Run", "Attack"]
	
	for anim in base_anims:
		for dir in directions:
			var key = anim.to_lower() + "_" + dir.to_lower()
			var frames = load_hero_animation_directional(anim, dir)
			if frames.size() > 0:
				all_animations[key] = frames
	
	var death_frames = load_hero_animation_directional("Death")
	if death_frames.size() > 0:
		all_animations["death"] = death_frames
	
	print("✅ Hero animations loaded: " + str(all_animations.size()) + " total")
	return all_animations

static func load_enemy_all_animations(enemy_name: String) -> Dictionary:
	var animations = {}
	var base_path = "res://DieselPunk/Dungeons and Pixels/Characters/Enemies/" + enemy_name + "/"
	
	print("🎨 Loading enemy: " + enemy_name)
	
	var anim_types = ["idle", "move", "attack", "death"]
	
	for anim_type in anim_types:
		var strip_path = base_path + anim_type + "_strip.png"
		var strip_texture = load(strip_path)
		
		if strip_texture:
			var frames = split_sprite_strip(strip_texture, anim_type)
			if frames.size() > 0:
				animations[anim_type] = frames
				print("  ✅ " + anim_type + ": " + str(frames.size()) + " frames")
			else:
				print("  ⚠ Failed to split " + anim_type)
		else:
			print("  ⚠ Missing: " + anim_type + "_strip.png")
	
	return animations

static func split_sprite_strip(strip_texture: Texture2D, anim_type: String) -> Array:
	var frames = []
	
	var frame_width = 16
	var frame_height = 16
	
	var strip_width = strip_texture.get_width()
	var num_frames = strip_width / frame_width
	
	print("    Strip width: " + str(strip_width) + " -> " + str(num_frames) + " frames")
	
	for i in range(num_frames):
		var atlas = AtlasTexture.new()
		atlas.atlas = strip_texture
		atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		frames.append(atlas)
	
	return frames

static func create_multi_animation_sprite(animations: Dictionary, fps: float = 8.0) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	var sprite_frames = SpriteFrames.new()
	
	print("  Creating AnimatedSprite2D with " + str(animations.size()) + " animations")
	
	for anim_name in animations.keys():
		var frames = animations[anim_name]
		if frames.size() > 0:
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, fps)
			sprite_frames.set_animation_loop(anim_name, anim_name != "death" and anim_name != "attack")
			
			for frame in frames:
				sprite_frames.add_frame(anim_name, frame)
			
			print("    ✅ Added animation: " + anim_name + " (" + str(frames.size()) + " frames)")
	
	sprite.sprite_frames = sprite_frames
	sprite.name = "AnimatedSprite2D"
	
	return sprite
