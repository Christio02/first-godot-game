extends Area2D
@export var speed: int = 450
var direction: Vector2
signal mob_hit




func start(pos: Vector2, dir: Vector2, rot: float):
	position = pos
	direction = dir
	rotation = rot


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta

	if position.x < 0 or position.x > get_viewport_rect().size.x:
		queue_free()

func _on_Projectile_body_entered(body: Node2D):
	if body.is_in_group("mobs"):
		body.queue_free() # delete mob on hit
		# signal "main" and update score
		mob_hit.emit()

	queue_free() # also delete projectile
