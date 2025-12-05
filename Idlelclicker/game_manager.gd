extends Node

var enemies_defeated: int = 0
var game_time: float = 0.0
var is_game_over: bool = false

@onready var ui_label: Label = get_node_or_null("/root/UI/GameInfo")

func _ready():
	update_ui()
	print("Game Manager ready!")

func _process(delta):
	if not is_game_over:
		game_time += delta
		update_ui()

func update_ui():
	if ui_label:
		var time_text = "Time: %.1fs" % game_time
		var enemy_count = get_tree().get_nodes_in_group("enemies").size()
		var enemies_text = "Enemies: %d | Defeated: %d" % [enemy_count, enemies_defeated]
		ui_label.text = "WASD: Move | Space: Jump | Shift: Sprint | Left Click: Attack | ESC: Toggle Mouse\n"
		ui_label.text += time_text + " | " + enemies_text

func enemy_defeated():
	enemies_defeated += 1
	print("Enemy defeated! Total: ", enemies_defeated)
	update_ui()
	
	# Check win condition with a small delay to let the count update
	await get_tree().create_timer(0.1).timeout
	var remaining_enemies = get_tree().get_nodes_in_group("enemies").size()
	if remaining_enemies == 0:
		_victory()

func _victory():
	is_game_over = true
	print("VICTORY! All enemies defeated!")
	if ui_label:
		ui_label.text = "*** VICTORY! ***\nTime: %.1fs | Enemies Defeated: %d\nPress R to restart" % [game_time, enemies_defeated]

func _input(event):
	if event.is_action_pressed("ui_cancel") and is_game_over:
		get_tree().reload_current_scene()
	
	# Also allow R key to restart
	if event is InputEventKey and event.pressed and event.keycode == KEY_R and is_game_over:
		get_tree().reload_current_scene()
