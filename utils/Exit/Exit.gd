extends Area2D


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if KeyState.is_door_unlocked:
			$AnimatedSprite2D.play("unlocked")
			$AudioStreamPlayer2D.play()
			await $AnimatedSprite2D.animation_finished
			KeyState.reset()
			LevelManager.NextLevel()
			
