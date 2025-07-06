extends Area2D

signal hit

@export var speed: int = 400 # speed of player (pixels / sec) @export allows setting value in game engine
@export var Projectile : PackedScene


var screen_size # game window size
var player_size # sprite size

# Coordinate plane: top left is (0,0) of screen, so to move up -> decrease y value, move right increase x value etc.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_size = $CollisionShape2D.shape.get_rect().size * $AnimatedSprite2D.scale
	hide()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity: Vector2 = Vector2.ZERO

	velocity = player_control()

	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"

	$AnimatedSprite2D.flip_h = velocity.x < 0
	$AnimatedSprite2D.flip_v = velocity.y > 0



	position += velocity * delta # consistent movement regardless of frame rate
	position = position.clamp(Vector2.ZERO + (player_size / 2), screen_size) # prevent player to go out of screen

	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if not visible or not get_parent().get_node("MobTimer").time_left > 0:
		return
	var p: Node = Projectile.instantiate()
	owner.add_child(p)
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (mouse_pos - global_position).normalized()
	p.start(position, direction, direction.angle())
	$GunSound.play()


func player_control() -> Vector2:
	var current_velocity: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		current_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		current_velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		current_velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		current_velocity.y += 1

	# --- Normalize velocity to prevent faster diagonal movement ---
	# If the player is moving (velocity has a length > 0),
	# normalize the vector to make its length 1 (a unit vector).
	# Then, multiply by 'speed' to set the consistent movement speed
	# in any direction. This prevents diagonal movement from being faster.
	if current_velocity.length() > 0:
		current_velocity = current_velocity.normalized() * speed
		# $ -> get Node -> same as get_node("AnimatedSprite2D").play() -> AnimatedSprite2D is a child of player node


	return current_velocity


func start(pos: Vector2) -> void:
	position = pos
	rotation = 0
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body:Node2D) -> void:
	hide() # player disappears when hit
	hit.emit()
	# Must be deferred to disable shape until it is safe, or can cause crash
	$CollisionShape2D.set_deferred("disabled", true)
