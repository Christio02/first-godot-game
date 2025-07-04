extends Area2D
signal hit
@export var speed: int = 400 # speed of player (pixels / sec) @export allows setting value in game engine
var screen_size # game window size

# Coordinate plane: top left is (0,0) of screen, so to move up -> decrease y value, move right increase x value etc.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()



func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	# --- Normalize velocity to prevent faster diagonal movement ---
	# If the player is moving (velocity has a length > 0),
	# normalize the vector to make its length 1 (a unit vector).
	# Then, multiply by 'speed' to set the consistent movement speed
	# in any direction. This prevents diagonal movement from being faster.
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# $ -> get Node -> same as get_node("AnimatedSprite2D").play() -> AnimatedSprite2D is a child of player node
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta # consistent movement regardless of frame rate
	position = position.clamp(Vector2.ZERO, screen_size) # prevent player to go out of screen

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func _on_body_entered(body:Node2D) -> void:
	hide() # player disappears when hit
	hit.emit()
	# Must be deferred to disable shape until it is safe, or can cause crash
	$CollisionShape2D.set_deferred("disabled", true)
