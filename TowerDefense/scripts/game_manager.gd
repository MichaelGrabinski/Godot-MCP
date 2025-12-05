extends Node

## Main game manager for tower defense

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_reached_end
signal game_over

@export var starting_gold: int = 500
@export var starting_lives: int = 20

var gold: int = 500
var lives: int = 20
var current_wave: int = 0
var enemies_in_wave: int = 0
var enemies_spawned: int = 0
var is_wave_active: bool = false

@onready var money_label = $"../UI/HUD/MoneyLabel"
@onready var lives_label = $"../UI/HUD/LivesLabel"
@onready var wave_label = $"../UI/HUD/WaveLabel"

func _ready():
	gold = starting_gold
	lives = starting_lives
	update_ui()

func update_ui():
	if money_label:
		money_label.text = "Gold: %d" % gold
	if lives_label:
		lives_label.text = "Lives: %d" % lives
	if wave_label:
		wave_label.text = "Wave: %d" % current_wave

func add_gold(amount: int):
	gold += amount
	update_ui()

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		update_ui()
		return true
	return false

func lose_life():
	lives -= 1
	update_ui()
	emit_signal("enemy_reached_end")
	
	if lives <= 0:
		emit_signal("game_over")
		print("Game Over!")

func start_wave():
	if is_wave_active:
		return
	
	current_wave += 1
	is_wave_active = true
	enemies_spawned = 0
	enemies_in_wave = 5 + current_wave * 2  # Increase enemies each wave
	
	update_ui()
	emit_signal("wave_started", current_wave)
	print("Wave %d started! Enemies: %d" % [current_wave, enemies_in_wave])

func enemy_defeated(gold_reward: int):
	add_gold(gold_reward)

func enemy_spawned():
	enemies_spawned += 1
	if enemies_spawned >= enemies_in_wave:
		# All enemies spawned for this wave
		pass

func check_wave_complete():
	# Check if all enemies are defeated
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0 and enemies_spawned >= enemies_in_wave:
		is_wave_active = false
		emit_signal("wave_completed", current_wave)
		print("Wave %d completed!" % current_wave)
