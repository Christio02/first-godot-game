extends CanvasLayer

# notify main node that game has started
signal start_game


func show_message(text) -> void:
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over() -> void:
	show_message("Game over")
	# wait for message to timeout
	await $MessageTimer.timeout
	$Message.text = "Dodge the creeps!"
	$Message.show()
	# make one-shot timer and wait -> create delay
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score) -> void:
	$ScoreLabel.text = "Score: {score}".format({"score": score})



func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
