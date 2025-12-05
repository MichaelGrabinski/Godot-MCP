extends Node

# Audio System for Dieselpunk Roguelike
# Procedural sound generation using AudioStreamGenerator

class_name AudioManager

var audio_players = []

static func play_hit_sound(parent: Node):
	var player = AudioStreamPlayer.new()
	parent.add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.1
	
	player.stream = generator
	player.volume_db = -10
	player.play()
	
	# Generate metallic hit sound
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var hz = 440.0
		var phase = 0.0
		var frames = int(generator.mix_rate * 0.1)
		
		for i in range(frames):
			var t = float(i) / generator.mix_rate
			var decay = exp(-t * 15.0)
			var value = sin(hz * TAU * t) * decay * 0.3
			value += randf_range(-0.1, 0.1) * decay  # Metallic noise
			playback.push_frame(Vector2(value, value))
	
	await parent.get_tree().create_timer(0.2).timeout
	player.queue_free()

static func play_pickup_sound(parent: Node):
	var player = AudioStreamPlayer.new()
	parent.add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.15
	
	player.stream = generator
	player.volume_db = -15
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frames = int(generator.mix_rate * 0.15)
		for i in range(frames):
			var t = float(i) / generator.mix_rate
			var freq = 800.0 + t * 400.0  # Rising pitch
			var value = sin(freq * TAU * t) * exp(-t * 8.0) * 0.2
			playback.push_frame(Vector2(value, value))
	
	await parent.get_tree().create_timer(0.2).timeout
	player.queue_free()

static func play_level_up_sound(parent: Node):
	var player = AudioStreamPlayer.new()
	parent.add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.3
	
	player.stream = generator
	player.volume_db = -12
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frames = int(generator.mix_rate * 0.3)
		for i in range(frames):
			var t = float(i) / generator.mix_rate
			var freq = 400.0 + t * 800.0
			var value = sin(freq * TAU * t) * exp(-t * 3.0) * 0.25
			playback.push_frame(Vector2(value, value))
	
	await parent.get_tree().create_timer(0.4).timeout
	player.queue_free()

static func play_death_sound(parent: Node):
	var player = AudioStreamPlayer.new()
	parent.add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.5
	
	player.stream = generator
	player.volume_db = -8
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frames = int(generator.mix_rate * 0.5)
		for i in range(frames):
			var t = float(i) / generator.mix_rate
			var freq = 200.0 - t * 150.0  # Falling pitch
			var value = sin(freq * TAU * t) * exp(-t * 2.0) * 0.3
			value += randf_range(-0.15, 0.15) * exp(-t * 2.0)
			playback.push_frame(Vector2(value, value))
	
	await parent.get_tree().create_timer(0.6).timeout
	player.queue_free()

static func play_ability_sound(parent: Node):
	var player = AudioStreamPlayer.new()
	parent.add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.2
	
	player.stream = generator
	player.volume_db = -10
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frames = int(generator.mix_rate * 0.2)
		for i in range(frames):
			var t = float(i) / generator.mix_rate
			var freq = 600.0 + sin(t * 30.0) * 200.0
			var value = sin(freq * TAU * t) * exp(-t * 10.0) * 0.25
			playback.push_frame(Vector2(value, value))
	
	await parent.get_tree().create_timer(0.3).timeout
	player.queue_free()

static func play_steam_sound(parent: Node):
	var player = AudioStreamPlayer.new()
	parent.add_child(player)
	
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 0.4
	
	player.stream = generator
	player.volume_db = -14
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback:
		var frames = int(generator.mix_rate * 0.4)
		for i in range(frames):
			var t = float(i) / generator.mix_rate
			var value = randf_range(-0.2, 0.2) * exp(-t * 5.0)  # White noise
			playback.push_frame(Vector2(value, value))
	
	await parent.get_tree().create_timer(0.5).timeout
	player.queue_free()
