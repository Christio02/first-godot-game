extends Node

@export var mob_scene: PackedScene
var score

func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func new_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")




func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob: Node = mob_scene.instantiate()

	# get random position along Path2D
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	mob.position = mob_spawn_location.position

	# get direction and set the mobs rotation perpendicular to the path
	var direction = mob_spawn_location.rotation + PI / 2 # use PI for radians -> half turn in radius
	# add randomness
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# get a random velocity
	var velocity: Vector2 = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# spawn mob
	add_child(mob)


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
