extends PathFollow2D

## Basic enemy that follows a path

@export var speed: float = 100.0
@export var health: int = 100
@export var max_health: int = 100
@export var gold_reward: int = 10

var game_manager

func _ready():
	game_manager = get_node("/root/test_level/GameManager")
	add_to_group("enemies")
	
	# Create visual placeholder (you'll replace with your art)
	var sprite = ColorRect.new()
	sprite.size = Vector2(30, 30)
	sprite.position = Vector2(-15, -15)
	sprite.color = Color.RED
	add_child(sprite)
	
	# Health bar
	var health_bar_bg = ColorRect.new()
	health_bar_bg.size = Vector2(40, 5)
	health_bar_bg.position = Vector2(-20, -30)
	health_bar_bg.color = Color.BLACK
	add_child(health_bar_bg)
	
	var health_bar = ColorRect.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(40, 5)
	health_bar.position = Vector2(-20, -30)
	health_bar.color = Color.GREEN
	add_child(health_bar)

func _process(delta):
	progress += speed * delta
	
	# Check if reached end
	if progress_ratio >= 1.0:
		reached_end()

func take_damage(amount: int):
	health -= amount
	update_health_bar()
	
	if health <= 0:
		die()

func update_health_bar():
	var health_bar = get_node_or_null("HealthBar")
	if health_bar:
		var health_percent = float(health) / float(max_health)
		health_bar.size.x = 40 * health_percent
		
		# Color gradient from green to red
		if health_percent > 0.5:
			health_bar.color = Color.GREEN
		elif health_percent > 0.25:
			health_bar.color = Color.YELLOW
		else:
			health_bar.color = Color.RED

func die():
	if game_manager:
		game_manager.enemy_defeated(gold_reward)
		game_manager.check_wave_complete()
	queue_free()

func reached_end():
	if game_manager:
		game_manager.lose_life()
		game_manager.check_wave_complete()
	queue_free()
