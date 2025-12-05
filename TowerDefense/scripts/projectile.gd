extends Node2D

## Projectile that moves toward and damages enemies

var damage: int = 20
var speed: float = 400.0
var target = null

func _ready():
	# Create visual placeholder (you'll replace with your art)
	var sprite = ColorRect.new()
	sprite.size = Vector2(10, 10)
	sprite.position = Vector2(-5, -5)
	sprite.color = Color.YELLOW
	add_child(sprite)

func _process(delta):
	if not target or not is_instance_valid(target):
		queue_free()
		return
	
	# Move toward target
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Rotate to face direction
	rotation = direction.angle()
	
	# Check if hit target
	if global_position.distance_to(target.global_position) < 20:
		hit_target()

func hit_target():
	if target and is_instance_valid(target):
		target.take_damage(damage)
	queue_free()
