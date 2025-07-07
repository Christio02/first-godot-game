extends Node

@export var mob_scene: PackedScene
var score: int = 0
var highscore: int = 0
var save_path: String = "user://score.save"


func _ready() -> void:
	$Music.play() # init before clicking start
	$HUD.update_score(0)
	load_score()

func save_score() -> void:
	if score > highscore:
		highscore = score
		var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
		if file:
			file.store_var(highscore)
			file.close()
			print("New highscore saved: ", highscore)
		else:
			print("Error: Could not open file for writing")

func load_score() -> void:
	if FileAccess.file_exists(save_path):
		var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
		if file:
			highscore = file.get_var()
			file.close()
			print("Highscore loaded: ", highscore)
		else:
			print("Error: Could not open file for reading")
			highscore = 0
	else:
		print("Save file not found, creating new one")
		highscore = 0

	$HUD.update_high_score(highscore)



func game_over() -> void:
	$MobTimer.stop()
	$HUD.show_game_over(score, highscore)
	save_score()
	$Music.stop()
	$DeathSound.play()


func new_game() -> void:
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_high_score(highscore)
	$HUD.show_message("Get Ready")
	if !$Music.playing: # if false, play music
		$Music.play()





func _on_mob_timer_timeout() -> void:
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
	var velocity: Vector2 = Vector2(randf_range(200.0, 300.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# spawn mob
	add_child(mob)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()

func _on_projectile_mob_hit():
	score += 1
	$HUD.update_score(score)
