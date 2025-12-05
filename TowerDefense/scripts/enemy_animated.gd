extends PathFollow2D

## Animated enemy that follows a path

@export var speed: float = 100.0
@export var health: int = 100
@export var max_health: int = 100
@export var gold_reward: int = 10

var game_manager
@onready var health_bar = $HealthBar
@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	game_manager = get_node("/root/test_level/GameManager")
	if not game_manager:
		game_manager = get_node_or_null("/root/level_from_json/GameManager")
	
	add_to_group("enemies")
	
	# Play walk animation
	if anim_sprite:
		anim_sprite.play("walk")

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
	if health_bar:
		var health_percent = float(health) / float(max_health)
		health_bar.size.x = 50 * health_percent
		
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
